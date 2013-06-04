namespace com.remobjects.beta;

interface

uses
  android.content,
  android.preference,
  com.remobjects.sdk;

type
  DataAccess = public class(android.app.Application, SharedPreferences.OnSharedPreferenceChangeListener)
  private
    const PUSH_SERVICE_URL = 'http://beta.remobjects.com:8098/bin';

    const API_URL = 'https://secure.remobjects.com/api/';
    const API_GETTOKEN = 'gettoken';
    const API_DOWNLOADS = 'downloads';
    const API_APPID = 'Beta.iOS';

    const KEY_USERNAME = 'Username';
    const KEY_TOKEN = 'Token';
    const KEY_CACHED_DATA = 'Downloads';

    var app_serverUrl: String;
    var app_loginName: String := '';
    var app_userToken: String := '';
    var app_loginPassword: String := '';


    class fInstance: DataAccess := nil;
    aesEnvelope: AesEncryptionEnvelope ;
  private
   method readPreferences();
   method initComponents();

  public

    method onCreate; override;
    class method getInstance: DataAccess;

    constructor; empty;
    property MaxRecordsToLoad: Integer read private write;
    property ImgLoader: com.webimageloader.ImageLoader read private write;

    method onSharedPreferenceChanged(prefs: android.content.SharedPreferences; key: java.lang.String);
end;


implementation

method DataAccess.readPreferences();
begin
  var ctx := inherited.ApplicationContext;
  var prefs := PreferenceManager.DefaultSharedPreferences[ctx];
  self.app_serverUrl := prefs.getString(SettingsActivity.PREFS_SERVER_URL, PUSH_SERVICE_URL);
  self.app_loginName := prefs.getString(SettingsActivity.PREFS_LOGIN_NAME, '');
  self.app_loginPassword := prefs.getString(SettingsActivity.PREFS_LOGIN_PASSWORD, nil);
  self.app_userToken := prefs.getString(SettingsActivity.PREFS_LOGIN_TOKEN, nil);

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
  var cacheDir := new java.io.File(getExternalCacheDir(), 'images');
  self.ImgLoader := new com.webimageloader.ImageLoader.Builder(self)
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
  self.initComponents();
end;

end.
