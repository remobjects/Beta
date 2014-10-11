﻿namespace Beta;

interface

uses
  Foundation, 
  RemObjectsSDK;

type
  DataAccess = public class(INSXMLParserDelegate)
  private
    class var fSharedInstance: DataAccess;
    class method sharedInstance: DataAccess;

    var fUsername, fUserToken: NSString;
    fPushDeviceToken: NSData;
    method setPushDeviceToken(aValue: NSData);

    const PUSH_SERVICE_URL = 'http://beta.remobjects.com:8098/bin';

    const API_URL = 'https://secure.remobjects.com/api/';
    const API_GETTOKEN = 'gettoken';
    const API_DOWNLOADS = 'downloads';
    const API_APPID = 'Beta.iOS';

    const KEY_USERNAME = 'Username';
    const KEY_TOKEN = 'Token';
    const KEY_CACHED_DATA = 'Downloads';
  
    {$REGION INSXMLParserDelegate}
    method parser(parser: NSXMLParser) didStartElement(elementName: NSString) namespaceURI(namespaceURI: NSString) qualifiedName(qName: NSString) attributes(attributeDict: NSDictionary);
    method parser(parser: NSXMLParser) foundCDATA(CDATABlock: NSData);
    {$ENDREGION}
    var fDownloads: NSMutableArray := new NSMutableArray;
    var fTempDownloads: NSMutableArray;
    var fLastDownload: NSMutableDictionary;

    method beginGetDataFromURL(aURL: NSURL) completion(aCompletion: block (aData: NSData; aResponse: NSHTTPURLResponse));

   protected
    method gotLoginToken;
    method gotData;

    method beginRegisterForPush;
  public
    class property sharedInstance: DataAccess read sharedInstance;
    class property isIOS7OrLater: Boolean read UIDevice.currentDevice.systemVersion.componentsSeparatedByString('.')[0].intValue ≥ 7;

    method init: id; override;

    property downloads: NSArray read fDownloads;
    property dataIsStale: Boolean;
    property pushDeviceToken: NSData read fPushDeviceToken write setPushDeviceToken;

    method beginLogin;
    method beginGetData;
    method beginGetDataWithCompletion(aCompletion: block );

    method beginLoginWithUsername(aUsername: String) password(aPassword: String) completion(aCompletion: block(aSUccess: Boolean));

    property delegate: IDataAccessDelegate;
    
    const NOTIFICATION_DOWNLOADS_CHANGED = 'com.remobjects.beta.downloads.changed';
  end;

  IDataAccessDelegate = public interface
    method askForLogin;
    method alertErrorWithTitle(aTitle: String) message(aMessage: String);
  end;

implementation

method DataAccess.init: id;
begin
  fUsername := NSUserDefaults.standardUserDefaults.objectForKey(KEY_USERNAME);
  fUserToken := NSUserDefaults.standardUserDefaults.objectForKey(KEY_TOKEN);

  var lCacheData := NSUserDefaults.standardUserDefaults.objectForKey(KEY_CACHED_DATA) as NSArray;
  if assigned(lCacheData) then begin
    for each c in lCacheData do
      fDownloads.addObject(c.mutableCopy);
    dataIsStale := true;
  end;
end;

class method DataAccess.sharedInstance: DataAccess;
begin
  if not assigned(fSharedInstance) then fSharedInstance := new DataAccess;
  result := fSharedInstance;
end;

method DataAccess.beginLogin;
begin
  if length(fUserToken) = 0 then begin
    delegate.askForLogin();
    exit;
  end;

  gotLoginToken();
end;

method DataAccess.beginGetDataFromURL(aURL: NSURL) completion(aCompletion: block(aData: NSData; aResponse: NSHTTPURLResponse));
begin
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin

      var lRequest := NSURLRequest.requestWithURL(aURL) 
                                   cachePolicy(NSURLRequestCachePolicy.NSURLRequestReloadIgnoringLocalAndRemoteCacheData)
                                   timeoutInterval(30); 
      var lResponse: NSURLResponse;
      var lError: NSError;
      UIApplication.sharedApplication.setNetworkActivityIndicatorVisible(true);
      var lData := NSURLConnection.sendSynchronousRequest(lRequest) returningResponse(var lResponse) error(var lError); 
      UIApplication.sharedApplication.setNetworkActivityIndicatorVisible(false);

      if assigned(lError) then
        NSLog('error: %@', lError);

      // this is a hack; i need to encapsulate the HTTP GET better 
      if not assigned(lResponse) then
        lResponse := new NSHTTPURLResponse withURL(aURL) statusCode(501) HTTPVersion('1.1') headerFields(nil); 

      aCompletion(lData, lResponse as NSHTTPURLResponse);

    end);
end;

method DataAccess.beginGetData;
begin
  beginGetDataWithCompletion(nil);
end;

method DataAccess.beginGetDataWithCompletion(aCompletion: block);
begin
  if length(fUserToken) = 0 then begin
    beginLogin();
    exit;
  end;

  var lURL := new NSURL withString(API_URL+API_DOWNLOADS+'?name='+fUsername+'&token='+fUserToken+'&changelogs=yes');
  beginGetDataFromURL(lURL) completion(method (aData: NSData; aResponse: NSHTTPURLResponse) begin 

      case aResponse.statusCode of
        200: begin
            var lXml := new NSXMLParser withData(aData);
            if assigned(lXml) then begin

              lXml.delegate := self;

              fTempDownloads := new NSMutableArray;
              lXml.parse();
              locking self do begin
                fDownloads := fTempDownloads;
              end;
              fTempDownloads := nil;

              NSUserDefaults.standardUserDefaults.setObject(downloads) forKey(KEY_CACHED_DATA);
              NSUserDefaults.standardUserDefaults.synchronize();
              dataIsStale := false;
              dispatch_async(dispatch_get_main_queue(), -> gotData());
            end 
            else begin
              NSLog('other error: %@', aResponse);
              // ToDo: indicate error?
            end;
          end;
        501: begin
            NSLog('bad login');
            fUserToken := nil;
            dispatch_async(dispatch_get_main_queue(), -> beginLogin());
          end;
        else begin
          NSLog('other error: %@', aResponse);
          // ToDo: indicate error?
        end;
      end;

      if assigned(aCompletion) then 
        dispatch_async(dispatch_get_main_queue(), aCompletion);

    end);
end;

{$REGION INSXMLParserDelegate}
method DataAccess.parser(parser: NSXMLParser) didStartElement(elementName: NSString) namespaceURI(namespaceURI: NSString) qualifiedName(qName: NSString) attributes(attributeDict: NSDictionary);
begin
  if elementName = 'download' then begin
    //NSLog('got download: %@', attributeDict);
    var lDict := attributeDict.mutableCopy();

    var lDateFormatter := new NSDateFormatter;
    lDateFormatter.dateFormat := 'yyyy-MM-dd';
    lDict['date'] := lDateFormatter.dateFromString(lDict['date']);

    var p := lDict['product'].rangeOfString('(').location;
    if p <> NSNotFound then
      lDict['product'] := lDict['product'].substringToIndex(p).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet);

    fTempDownloads.addObject(lDict);
    fLastDownload := lDict;
  end;
end;

method DataAccess.parser(parser: NSXMLParser) foundCDATA(CDATABlock: NSData);
begin
  var lString := new NSString withData(CDATABlock) encoding(NSStringEncoding.NSUTF8StringEncoding);
  //NSLog('CDATA: '+lString);
  fLastDownload:setObject(lString) forKey('changelog');
end;
{$ENDREGION}

method DataAccess.gotData;
begin
  NSNotificationCenter.defaultCenter.postNotificationName(NOTIFICATION_DOWNLOADS_CHANGED) object(self); 
end;

method DataAccess.beginLoginWithUsername(aUsername: String) password(aPassword: String) completion(aCompletion: block (aSUccess: Boolean));
begin
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin

    var lUrl := new NSURL withString(API_URL+API_GETTOKEN+'?name='+aUsername+'&password='+aPassword+'&appid='+API_APPID+'&clientid='{+UIDev});
    beginGetDataFromURL(lUrl) completion(method (aData: NSData; aResponse: NSHTTPURLResponse) begin 

                                           if aResponse.statusCode = 200 then begin
                                             fUsername := aUsername;
                                             fUserToken := new NSString withData(aData) encoding(NSStringEncoding.NSUTF8StringEncoding);

                                             NSLog('got token: %@', fUserToken);
                                             dispatch_async(dispatch_get_main_queue(), method begin
                                                 aCompletion(true);
                                                 gotLoginToken();
                                               end);
                                            end
                                            else begin
                                              NSLog('didnt get token: status %d', aResponse.statusCode);
                                              fUserToken := nil;
                                              dispatch_async(dispatch_get_main_queue(), -> aCompletion(false));
                                            end;

                                         end);

  end);
end;

method DataAccess.gotLoginToken;
begin
  NSUserDefaults.standardUserDefaults.setObject(fUsername) forKey(KEY_USERNAME);  
  NSUserDefaults.standardUserDefaults.setObject(fUserToken) forKey(KEY_TOKEN); 
  NSUserDefaults.standardUserDefaults.synchronize();
  beginRegisterForPush();
  beginGetData();
end;

method DataAccess.beginRegisterForPush;
begin
  if not assigned(fUserToken) or not assigned(fUsername) or not assigned(fPushDeviceToken) then exit; 

  var p := new ApplePushProviderService_AsyncProxy withURL(new NSURL withString(PUSH_SERVICE_URL));
  p.beginRegisterDevice(fPushDeviceToken, fUsername) startWithBlock(method (aRequest: ROAsyncRequest) begin

      try
        p.endRegisterDevice(aRequest);
        //delegate.alertErrorWithTitle('Registered server') message('...');
        NSLog('Registered with server');
      except
        on E: NSException do begin
          delegate.alertErrorWithTitle('Failed to register with server') message(E.description);
        end;
      end;

    end);
end;

method DataAccess.setPushDeviceToken(aValue: NSData);
begin
  fPushDeviceToken := aValue;
  beginRegisterForPush();
end;

end.
