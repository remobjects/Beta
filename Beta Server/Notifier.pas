namespace BetaServer;

interface

uses
  System.Collections,
  System.Collections.Generic,
  System.ComponentModel, 
  System.Configuration,
  System.IO,
  System.Linq,
  System.Linq.Expressions,
  System.Net,
  System.Reflection.Emit,
  System.Security.Permissions,
  System.Xml.Linq,
  RemObjects.SDK.Push,
  RemObjects.SDK.Server, 
  BetaServer.Properties;

type
  Notifier = public static partial class
  private
    fTimer: System.Timers.Timer := nil;
    fInTimer: Boolean;

    fPushConnect: GenericPushConnect := new GenericPushConnect;

    fBetaProducts: Dictionary<String,String> := new Dictionary<String,String>;
    fRTMProducts: Dictionary<String,String> := new Dictionary<String,String>;
    fBetaProductsFile, fRTMProductsFile: String;

    method LoadCache;
    method SaveCache;

    const PING_TIME = 5*60*1000; // we check the website every 5 mins

    method TimerElapsed(sender: Object; e: System.Timers.ElapsedEventArgs);
    method GetUniqueProducts(aProducts: Dictionary<String, String>): List<String>;
    method GetProductMessage(aProducts: List<String>): String;
    method LoadFileToDictionary(aFile: String; aDictionary: Dictionary<String, String>);
  protected
  public
    constructor;

    method Start;
    method Stop;
  end;

implementation

{$REGION Construction and Disposition}
constructor Notifier;
begin
  try
    fBetaProductsFile := Path.ChangeExtension(typeOf(self).Assembly.Location, 'beta.products.txt');
    fRTMProductsFile := Path.ChangeExtension(typeOf(self).Assembly.Location, 'rtm.products.txt');
    LoadCache();

    var lCertificatePath := Path.ChangeExtension(typeOf(self).Assembly.Location, 'iOS.p12');
    fPushConnect.APSConnect.iOSCertificateFile := lCertificatePath;
    Log('Loaded Apple iOS Push Certificate from '+lCertificatePath);

    fPushConnect.GCMConnect.ApiKey := Settings.Default.GCMSenderApiKey;

    fTimer := new System.Timers.Timer;
    fTimer.Interval := PING_TIME;
    fTimer.Elapsed += TimerElapsed;
  except
    on Ex:Exception do begin
      Log(Ex.GetType.Name+': '+Ex.Message);
    end;
  end;
end;
{$ENDREGION}

method Notifier.GetUniqueProducts(aProducts: Dictionary<String, String>): List<String>;
begin
  result:= aProducts.Keys.Select(method (aProductName: String): String begin

                                     result := aProductName;
                                     var p := result.IndexOf(' for');
                                     if p > 0 then result := result.Substring(0, p);
 
                                   end).Distinct().ToList().OrderBy(p -> p).ToList();
end;

method Notifier.GetProductMessage(aProducts: List<String>): String;
begin
  for each p in aProducts index i do begin
    if (i = aProducts.Count-1) and (aProducts.Count > 1) then 
      result := result+' and '
    else if i > 0 then 
      result := result+', ';
    result := result+p;
  end;
end;

method Notifier.TimerElapsed(sender: Object; e: System.Timers.ElapsedEventArgs);
begin
  if fInTimer then exit;
  fInTimer := true;
  try

    var lNewBetaProducts := new Dictionary<String, String>;
    var lNewRTMProducts := new Dictionary<String, String>;

    var lUrl := String.Format(Settings.Default.DownloadInfoURL, Settings.Default.ReferenceUsername, 
                                                                Settings.Default.ReferenceUserToken,
                                                                'Everwood.Beta.Server' {App ID},
                                                                'Everwood.Beta.Server' {Client ID});
    Log('checking '+lUrl);
    var lXml := XDocument.Load(lUrl);
    for each lDownload in lXml.Root.Elements('download') do begin

      var lProduct := lDownload.Attribute('product'):Value;
      var lVersion := lDownload.Attribute('version'):Value;
      if not assigned(lProduct) or not assigned(lVersion) then continue;

      if lDownload.Attribute('prerelease'):Value ≠ 'true' then begin
        
        if (not fRTMProducts.ContainsKey(lProduct)) or (fRTMProducts[lProduct] <> lVersion) then begin
          fRTMProducts[lProduct] := lVersion;
          lNewRTMProducts[lProduct] := lVersion;
        end;
        
      end 
      else begin

        if (not fBetaProducts.ContainsKey(lProduct)) or (fBetaProducts[lProduct] <> lVersion) then begin
          fBetaProducts[lProduct] := lVersion;
          lNewBetaProducts[lProduct] := lVersion;
        end;
      end;

    end;

    var lUniqueBetaProducts := GetUniqueProducts(lNewBetaProducts);
    var lUniqueRTMProducts := GetUniqueProducts(lNewRTMProducts);
    var lCount := lUniqueBetaProducts.Count+lUniqueRTMProducts.Count;

    if lNewBetaProducts.Count > 0 then begin

      var lMessage := 'New beta downloads for '+GetProductMessage(lUniqueBetaProducts)+' are available now.';
      Log(lMessage);

      for each d in PushManager.Instance.DeviceManager.Devices do
        fPushConnect.PushMessageAndBadgeNotification(d, lMessage, lCount);
      Log('Done sending Push notifications for Beta');

    end;

    if lNewRTMProducts.Count > 0 then begin

      var lMessage := 'New RTM downloads for '+GetProductMessage(lUniqueRTMProducts)+' are available now.';
      Log(lMessage);

      for each d in PushManager.Instance.DeviceManager.Devices do
        fPushConnect.PushMessageAndBadgeNotification(d, lMessage, lCount);
      Log('Done sending Push notifications for RTM');

    end;

    SaveCache();

  except
    on Ex:Exception do begin
      Log(Ex.GetType.Name+': '+Ex.Message);
    end;
  finally
    fInTimer := false;
  end;
end;

method Notifier.Start;
begin
  fTimer.Enabled := true;
  TimerElapsed(nil, nil);
end;

method Notifier.Stop;
begin
  fTimer.Enabled := false;
end;

class method Notifier.LoadFileToDictionary(aFile: String; aDictionary: Dictionary<String, String>);
begin
  aDictionary.Clear();
  if File.Exists(aFile) then begin
    var lLines := File.ReadAllLines(aFile);
    for each l in lLines do begin
      var lParts := l.Split('|');
      if lParts.Length = 2 then
        aDictionary[lParts[0]] := lParts[1];
    end;
  end;
end;

class method Notifier.LoadCache;
begin
  LoadFileToDictionary(fBetaProductsFile, fBetaProducts);
  LoadFileToDictionary(fRTMProductsFile, fRTMProducts);
end;

class method Notifier.SaveCache;
begin
  File.WriteAllLines(fBetaProductsFile, fBetaProducts.Keys.Select(k -> k+'|'+fBetaProducts[k]).ToArray());
  File.WriteAllLines(fRTMProductsFile, fRTMProducts.Keys.Select(k -> k+'|'+fRTMProducts[k]).ToArray());
end;

end.
