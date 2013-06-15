namespace com.remobjects.everwood.beta;

interface

uses
  java.io,
  java.net,
  java.lang,
  java.util,
  java.util.concurrent,
  android.app,
  android.content,
  android.preference,
  android.util,
  com.remobjects.sdk;

type
  DataAccess = public class(android.app.Application, SharedPreferences.OnSharedPreferenceChangeListener)
  private
    const TAG = "DataService";
    //const PUSH_SERVICE_URL = 'http://beta.remobjects.com:8098/bin';

    const API_URL = 'https://secure.remobjects.com/api/';
    const API_GETTOKEN = 'gettoken';
    const API_DOWNLOADS = 'downloads';
    const API_APPID = 'Beta.Android';

    const KEY_USERNAME = 'Username';
    const KEY_TOKEN = 'Token';
    const KEY_CACHED_DATA = 'Downloads';
    const CACHE_DIR_NAME = 'beta_images_cache';

    //var app_serverUrl: String;
    var app_loginName: String := '';        
    var app_userToken: String := '';
    var app_loginPassword: String := '';

    var fProducts: List<Map<String, Object>> := new ArrayList<Map<String, Object>>();

    class fInstance: DataAccess := nil;
    var aesEnvelope: AesEncryptionEnvelope;
    var fExecutor: java.util.concurrent.Executor := java.util.concurrent.Executors.newFixedThreadPool(5);
    var fIsAuthorizing: Boolean := false;

  public
    method getDataAsync(aContext: MainActivity; aCallback: RequestCallback);
    method loginAsync(aContext: MainActivity): Boolean;
    method loginAsync(aContext: MainActivity; aCallback: RequestCallback): Boolean;
    method retrieveAndSaveToken(aUsername, aPassword: String): RequestStatus;
    property Token: String read app_userToken;
    property UserName: String read app_loginName;
    property IsAuthorized: Boolean read (length(app_userToken) > 0) and (length(app_loginName) > 0);
    property Products: List<Map<String, Object>> read Collections.synchronizedList(fProducts);
    property Executor: Executor read fExecutor;


  private
   method readPreferences();
   method initComponents();
   method readStringFromUrl(anUrl: java.net.URI; aResponse: ReferenceType<String>): Integer;

   method showLogin(aContext: MainActivity);
   method getUniques<T>(aList, aListToFill: List<T>; aPredicate: KeyPredicate<T>);

  public

    method onCreate; override;
    class method getInstance: DataAccess;

    constructor; empty;
    property ImageLoader: com.webimageloader.ImageLoader read private write;
    property IsAuthorizing: Boolean read fIsAuthorizing;
    method dropAutorizing();

    method onSharedPreferenceChanged(prefs: android.content.SharedPreferences; key: java.lang.String);
  end;

  RequestCallback nested in DataAccess = interface
    method gotLogin(aStatus: RequestStatus; aUser, aToken: String);
    method gotData(aStatus: RequestStatus);
  end;

  RequestStatus nested in DataAccess = public enum (Ok, Failed, NetworkError);

  KeyPredicate<T> = interface
    method getKey(aValue: T): String;
  end;


implementation

method DataAccess.readPreferences();
begin
  var ctx := inherited.ApplicationContext;
  var prefs := PreferenceManager.DefaultSharedPreferences[ctx];
  //self.app_serverUrl := prefs.getString(CommonUtilities.PREFS_SERVER_URL, PUSH_SERVICE_URL);
  self.app_loginName := prefs.getString(CommonUtilities.PREFS_LOGIN_NAME, '');
  self.app_userToken := prefs.getString(CommonUtilities.PREFS_LOGIN_TOKEN, nil);
  self.app_loginPassword := prefs.getString(CommonUtilities.PREFS_LOGIN_PASSWORD, nil);
end;



method DataAccess.onCreate;
begin
  inherited.onCreate;

  fInstance := self;
  PreferenceManager.setDefaultValues(self, R.xml.settings, false);
  self.initComponents();
  PreferenceManager.getDefaultSharedPreferences(self).registerOnSharedPreferenceChangeListener(self);

  // TODO get cached data here
end;

class method DataAccess.getInstance: DataAccess;
begin
  if  (fInstance = nil)  then
    raise  new IllegalStateException('DataAccess instance not yet created');
  exit  (fInstance);
end;

method DataAccess.initComponents();
begin
try
  self.readPreferences();

  var am := android.app.ActivityManager(self.SystemService[Context.ACTIVITY_SERVICE]);
  var memClass: Integer := am.MemoryClass;

  // Use part of the available memory for memory cache.
  var memoryCacheSize: Integer := (((1024 * 1024) * memClass) div 8);
  var cacheDir := new java.io.File(getExternalCacheDir(), CACHE_DIR_NAME);

  // Find the dir to save cached images
  if (android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED)) then
      cacheDir := new File(self.getExternalCacheDir(), CACHE_DIR_NAME)
  else
      cacheDir := self.getCacheDir();
  if (not cacheDir.exists()) then
      cacheDir.mkdirs();

  self.ImageLoader := new com.webimageloader.ImageLoader.Builder(self)
                                                      .enableDiskCache(cacheDir, ((10 * 1024) * 1024))
                                                      .enableMemoryCache(memoryCacheSize)
                                                      .build();


except
  on ex: Exception do 
begin
    System.err.println(java.lang.String.format('DataModule.initComponents : %s', ex.getMessage()))
  end

end;

end;

method DataAccess.onSharedPreferenceChanged(prefs: android.content.SharedPreferences; key: java.lang.String);
begin
  self.readPreferences;
end;

method DataAccess.showLogin(aContext: MainActivity);
begin
  var act := Activity(aContext);
  var i := new Intent(act, typeOf(LoginActivity));
  act.startActivityForResult(i, LoginActivity.ACTIVITY_RESULT_LOGIN);
end;

method DataAccess.loginAsync(aContext: MainActivity): Boolean;
begin
  exit (loginAsync(aContext, nil));
end;

method DataAccess.loginAsync(aContext: MainActivity; aCallback: RequestCallback): Boolean;
begin
  if (fIsAuthorizing) then
    exit (false);
  fIsAuthorizing := true;
  var prefs := aContext.SharedPreferences[CommonUtilities.PREFENCES_NAME, Context.MODE_PRIVATE];

  // maybe we have token stored
  if (prefs.contains(CommonUtilities.PREFS_LOGIN_TOKEN)) then begin
    app_loginName := prefs.getString(CommonUtilities.PREFS_LOGIN_NAME, '');
    app_userToken := prefs.getString(CommonUtilities.PREFS_LOGIN_TOKEN, '');
    fIsAuthorizing := false;
    if (aCallback <> nil) then
      aCallback.gotLogin(RequestStatus.Ok, app_loginName, app_userToken);
    exit (true);
  end;

  // check if we have login/password stored
  if (prefs.contains(CommonUtilities.PREFS_LOGIN_PASSWORD)) then begin
    app_loginName := prefs.getString(CommonUtilities.PREFS_LOGIN_NAME, '');
    app_loginPassword := prefs.getString(CommonUtilities.PREFS_LOGIN_PASSWORD, '');
    
    // perform async http call to get token
    fExecutor.execute(()->begin

      var lRes := self.retrieveAndSaveToken(app_loginName, app_loginPassword);
      if (self.IsAuthorized) then begin              
        fIsAuthorizing := false;
        if (aCallback <> nil) then
          aContext.runOnUiThread(()-> aCallback.gotLogin(lRes, app_loginName, app_userToken));
      end
      else begin
        self.showLogin(aContext);
      end;
    end);

    exit (false);
  end;

  // show login screen to get login/password
  // login activity itself can retrieve token.
  // and return result back to main activity only on success
  self.showLogin(aContext);
end;

method DataAccess.dropAutorizing;
begin
  self.fIsAuthorizing := false;
end;


method DataAccess.retrieveAndSaveToken(aUsername: String; aPassword: String): RequestStatus;
begin  
  java.net.HttpURLConnection.FollowRedirects := true;

  var lURL := new java.net.URI(API_URL + API_GETTOKEN + '?name=' + aUsername + '&password=' + aPassword + '&appid=' + API_APPID + '&clientid=' + API_APPID);

  var lResponse := new ReferenceType<String>();
  var lResponseCode := self.readStringFromUrl(lURL, lResponse);
  var lResponseString := lResponse.Value;

  case (lResponseCode) of
    200: begin
      app_loginName := aUsername;
      app_userToken := lResponseString;

      Log.i(TAG, 'got token: ' + app_userToken);

      {$REGION save fine token to preferences}
      var prefs := self.SharedPreferences[CommonUtilities.PREFENCES_NAME, Context.MODE_PRIVATE];
      prefs.edit()
           .putString(CommonUtilities.PREFS_LOGIN_TOKEN, app_userToken)
           .commit();
      {$ENDREGION }
      exit (RequestStatus.Ok);
    end;
    501: begin // login failed
      Log.e(TAG, java.lang.String.format('didnt get token: status %d', lResponseCode));
      Log.e(TAG, java.lang.String.format('response was: %s', lResponseString));
      exit (RequestStatus.Failed);
    end;
    503: begin
      Log.e(TAG, java.lang.String.format('didnt get token: status %d', lResponseCode));
      Log.e(TAG, java.lang.String.format('response was: %s', lResponseString));
      exit (RequestStatus.NetworkError);
    end;
  end;
end;


method DataAccess.getDataAsync(aContext: MainActivity; aCallback: RequestCallback);
begin  
  fExecutor.execute(()->begin    
      var lURL := new java.net.URI(API_URL + API_DOWNLOADS + '?name=' + app_loginName + '&token=' + app_userToken);

      var lResponse := new ReferenceType<String>();
      var lResponseCode := self.readStringFromUrl(lURL, lResponse);
      var lResponseString := lResponse.Value;
  
      var lResponseStatus : RequestStatus;

      case lResponseCode of
        200: begin
          {$REGION parse xml from response}
          var dbf := javax.xml.parsers.DocumentBuilderFactory.newInstance();
          dbf.IgnoringComments := true;
          dbf.Validating := false;
          dbf.IgnoringElementContentWhitespace := true;
          var db := dbf.newDocumentBuilder();
          
          var lInput := new org.xml.sax.InputSource();
          lInput.CharacterStream := new StringReader(lResponseString);
          var lXml := db.parse(lInput);
          lXml.normalizeDocument();          
          {$ENDREGION }

          {$REGION  processing xml nodes into a showable list of key-pair values}
          var nodes := lXml.DocumentElement.ElementsByTagName['download'];
          var lProducts := new ArrayList<Map<String, Object>>();
          for i: Integer := 0 to nodes.Length - 1 do begin
            var lElemDownload: org.w3c.dom.Element := org.w3c.dom.Element(nodes.item(i));
            var lProduct := new java.util.HashMap<String, Object>(); // product logo url version branch date prerelease
            var attrs := lElemDownload.Attributes;
            for ia: Integer := 0 to attrs.Length -1 do begin
              var attr := org.w3c.dom.Attr(attrs.item(ia));
              // todo: process date separately
              var lValue: Object := attr.Value;
              case (attr.Name) of
                'product': begin
                   var lPrName: String := java.lang.String(lValue);
                   var pos := lPrName.indexOf('(');
                   if (pos > 0) then
                     //lPrName := lPrName.substring(0, pos);
                     continue;
                    lValue := lPrName;
                end;
                'date': begin
                  var lFromServer := new java.text.SimpleDateFormat('yyyy-MM-dd');
                  var lPrDate: Date := lFromServer.parse(java.lang.String(lValue));

                  lValue := lPrDate;
                end;
              end;
              lProduct.put(attr.Name, lValue);
            end;
            lProducts.add(lProduct);
          end;         
          {$ENDREGION }

          {$REGION additional sorting and filtering}
          var lSort := new interface Comparator<Map<String, Object>>(
            compare := method(p1, p2: Map<String, Object>) begin
              result := Date(p2.get('date')).compareTo(Date(p1.get('date')));
              if (result = 0) then
                result := java.lang.String(p1.get('product')).compareTo(java.lang.String(p2.get('product')));
            end
          );

          var lBetaProducts:=  new ArrayList<Map<String, Object>>();
          getUniques(lProducts, lBetaProducts, (val) -> begin
            if ( not 'true'.equals(val.get('prerelease')) )  then
              exit (nil); // no key -> not included in result list
            exit (java.lang.String(val.get('product')));
          end);
          Collections.sort(lBetaProducts, lSort);

          var lRtmProducts:=  new ArrayList<Map<String, Object>>();
          getUniques(lProducts, lRtmProducts, (val) -> begin
            if ( 'true'.equals(val.get('prerelease')) )  then
              exit (nil); // no key -> not included in result list
            exit (java.lang.String(val.get('product')));
          end);
          Collections.sort(lRtmProducts, lSort);

          lProducts.clear();
          var lBetaHeader := new HashMap<String,Object>();
          lBetaHeader.put('header', 'Beta Downloads');
          lProducts.add(lBetaHeader);
          lProducts.addAll(lBetaProducts);
          var lRtmHeader := new HashMap<String,Object>();
          lRtmHeader.put('header', 'Release Downloads');
          lProducts.add(lRtmHeader);
          lProducts.addAll(lRtmProducts);

          locking (fProducts) do begin
            fProducts.clear();
            fProducts.addAll(lProducts);
          end;

          {$ENDREGION }

          lResponseStatus := RequestStatus.Ok;
        end;        
        501: begin // 501
          Log.w(TAG, "bad login");
          app_userToken := nil;
          lResponseStatus := RequestStatus.Failed;
        end;
        else begin
          Log.e(TAG, java.lang.String.format("other error: %d", lResponseCode));
          lResponseStatus := RequestStatus.NetworkError;
        end;
      end;

      if (assigned(aCallback)) then
        aContext.runOnUiThread(()-> aCallback.gotData(lResponseStatus));
  end);
end;

method DataAccess.getUniques<T>(aList, aListToFill: List<T>; aPredicate: KeyPredicate<T>);
begin
  aListToFill.clear();

  var lHash := new HashMap<String, String>();

  for each obj in aList do begin
    var lKey := aPredicate(obj);
    if (assigned(lKey)) then begin
      var lVal := lHash.get(lKey);
      if (lVal = nil) then begin
        lHash.put(lKey, lKey);
        aListToFill.add(obj);
      end;
    end;
  end;
end;



method DataAccess.readStringFromUrl(anUrl: java.net.URI; aResponse: ReferenceType<String>): Integer;
begin
  var lConn := java.net.HttpURLConnection(anUrl.toURL.openConnection());
  lConn.ConnectTimeout := 3000;
  lConn.RequestMethod := 'GET';
  lConn.DoInput := true;
  lConn.DoOutput := false;
                          
  var lRequestStream: InputStream;

  var lOutputBuffer: array of SByte;
  try
    lConn.connect();
    result := lConn.ResponseCode;
    if result = 200 then
	    lRequestStream := lConn.InputStream
    else
      lRequestStream := lConn.ErrorStream;

    // cannot trust Content-Length here, as stream is gzipped. The one way is to read it to the end.
    //var lContLength := lConn.ContentLength;	

    lOutputBuffer := CommonUtilities.readToEndOfStream(lRequestStream);
  except
    on ioex: java.io.IOException do begin
      lRequestStream := lConn.ErrorStream;
      try
        lOutputBuffer := CommonUtilities.readToEndOfStream(lRequestStream);      
        result := lConn.ResponseCode;
      except
        on ex: Exception do begin
          Log.e(TAG, ex.Message, ex);
          result := 503; //service unavailable
        end;
      end;
    end;
    on ex: Throwable do begin
      Log.e(TAG, ex.Message, ex);
      result := 503; //service unavailable
    end;
  finally
    lConn.disconnect;  
    lRequestStream := nil;
  end;

  if assigned(lOutputBuffer) then
    aResponse.Value := new java.lang.String(lOutputBuffer, "UTF-8");
end;

end.
