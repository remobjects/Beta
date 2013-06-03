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
    fBetaProductsFile: String;

    method LoadCache;
    method SaveCache;

    const PING_TIME = 5*60*1000; // we check the website every 5 mins

    method TimerElapsed(sender: Object; e: System.Timers.ElapsedEventArgs);
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
    LoadCache();

    var lCertificatePath := Path.ChangeExtension(typeOf(self).Assembly.Location, 'iOS.p12');
    fPushConnect.APSConnect.iOSCertificateFile := lCertificatePath;
    Log('Loaded ZApple iOS Push Certificate from '+lCertificatePath);

    fPushConnect.GCMConnect.SenderApiKey := Settings.Default.GCMSenderApiKey;

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

method Notifier.TimerElapsed(sender: Object; e: System.Timers.ElapsedEventArgs);
begin
  if fInTimer then exit;
  fInTimer := true;
  try

    var lNewProducts := new Dictionary<String, String>;

    var lUrl := String.Format(Settings.Default.DownloadInfoURL, Settings.Default.ReferenceUsername, 
                                                                Settings.Default.ReferenceUserToken,
                                                                'Everwood.Beta.Server' {App ID},
                                                                'Everwood.Beta.Server' {Client ID});
    Log('checking '+lUrl);
    var lXml := XDocument.Load(lUrl);
    for each lDownload in lXml.Root.Elements('download') do begin
      if lDownload.Attribute('prerelease'):Value ≠ 'true' then continue;

      var lProduct := lDownload.Attribute('product'):Value;
      var lVersion := lDownload.Attribute('version'):Value;
      if not assigned(lProduct) or not assigned(lVersion) then continue;

      if (not fBetaProducts.ContainsKey(lProduct)) or (fBetaProducts[lProduct] <> lVersion) then begin
        fBetaProducts[lProduct] := lVersion;
        lNewProducts[lProduct] := lVersion;
      end;

    end;

    if lNewProducts.Count = 0 then begin
      Log('no changes. done.');
      exit;
    end;

    var lUniqueProducts := lNewProducts.Keys.Select(method (aProductName: String): String begin

                                                      result := aProductName;
                                                      var p := result.IndexOf(' for');
                                                      if p > 0 then result := result.Substring(0, p);

                                                    end).Distinct().ToList().OrderBy(p -> p);

    var lMessage := 'New beta downloads for ';
    for each p in lUniqueProducts index i do begin
      if (i = lUniqueProducts.Count-1) and (lUniqueProducts.Count > 1) then 
        lMessage := lMessage+' and '
      else if i > 0 then 
        lMessage := lMessage+', ';
      lMessage := lMessage+p;
    end;
    lMessage := lMessage+' are available.';

    Log(lMessage);

    for each d in PushManager.Instance.DeviceManager.Devices do
      fPushConnect.PushMessageAndBadgeNotification(d, lMessage, lUniqueProducts.Count);
    Log('Done sending Push notifications');
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
  //for each d in PushManager.Instance.DeviceManager.Devices do
  //  fPushConnect.PushMessageNotification(d, 'False alarm. WWDCNotify Server was just restarted');
  fTimer.Enabled := true;
  TimerElapsed(nil, nil);
end;

method Notifier.Stop;
begin
  fTimer.Enabled := false;
end;

class method Notifier.LoadCache;
begin
  fBetaProducts.Clear();
  if File.Exists(fBetaProductsFile) then begin
    var lLines := File.ReadAllLines(fBetaProductsFile);
    for each l in lLines do begin
      var lParts := l.Split('|');
      if lParts.Length = 2 then
        fBetaProducts[lParts[0]] := lParts[1];
    end;
  end;
end;

class method Notifier.SaveCache;
begin
  File.WriteAllLines(fBetaProductsFile, fBetaProducts.Keys.Select(k -> k+'|'+fBetaProducts[k]).ToArray());
end;

end.
