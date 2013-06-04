namespace com.remobjects.beta;
{$DEFINE USE_ASYNC}
//{$DEFINE EVENTS}
interface

uses
  java.util,
  java.util.concurrent,
  android.app,
  android.content,
  android.os,
  android.util,
  android.view,
  android.widget,
  com.google.android.gcm;

type
  MainActivity = public class(Activity)
  {$region Constants}
  public
    class var PREFS_NAME: String := 'com.remobjects.dataabstract.sample'; readonly;
    const USER_ID_KEY: String = 'Name';
    const USER_PWD_KEY: String = 'Password';

    const ATTRIBUTE_NAME_TEXT = "name";
    const ATTRIBUTE_NAME_ICON = "icon";
    const ATTRIBUTE_NAME_NEW = "new";
  {$endregion}

  {$region Private fields}
  private
    const TAG = "Beta.MainActivity";
    var that: MainActivity;
    var fDataAccess: DataAccess;
    fHandleMessageReceiver: BroadcastReceiver;
    fListView: ListView;
    fDisplay: TextView;
    fRegisterTask: AsyncTask<Void, Void, Void>;
    fAdapter: BaseAdapter;
  {$endregion}

  private

  public
    method onCreate(savedInstanceState: Bundle); override;
    method onCreateOptionsMenu(aMenu: Menu): Boolean; override;
    method onMenuItemSelected(aFeatureId: Integer; anItem: MenuItem): Boolean; override;
    method clearRegisterTask();
    property LogTextView: TextView read fDisplay;
  end;

  MainBroadcastReceiver nested in MainActivity = assembly class(BroadcastReceiver)
  private    
    var fOuter: MainActivity;
  public
    constructor(anOuter: MainActivity);
    method onReceive(ctx: Context; intent: Intent); override;
  end;

  RegisterAsyncTask nested in MainActivity = assembly class(AsyncTask<Void, Void, Void>)
  private
    var fRegId: String;
    var fOuter: MainActivity;
  public
    constructor(anOuter: MainActivity; aRegId: String);
    method doInBackground(params arg1: array of Void): Void; override;
    method onPostExecute(arg1: Void); override;
  end;

implementation

method MainActivity.onCreate(savedInstanceState: Bundle);
begin
  inherited onCreate(savedInstanceState);

  // Make sure the device has the proper dependencies.
  GCMRegistrar.checkDevice(self);
  // Make sure the manifest was properly set - comment out this line
  // while developing the app, then uncomment it when it's ready.
  GCMRegistrar.checkManifest(self);

  setContentView(R.layout.activity_main);
  that := self;

  fDataAccess := DataAccess.getInstance();
  fListView := ListView(findViewById(android.R.id.list));
  fListView.EmptyView := findViewById(android.R.id.empty);
  fDisplay := TextView(findViewById(R.id.log_view));

  fHandleMessageReceiver:= new MainBroadcastReceiver(self);
  self.registerReceiver(fHandleMessageReceiver, new IntentFilter(CommonUtilities.DISPLAY_MESSAGE_ACTION));

  var regId := GCMRegistrar.getRegistrationId(self);

  if  (regId.equals(''))  then  begin
    //  Automatically registers application on startup.
    GCMRegistrar.register(self, CommonUtilities.SENDER_ID);
  end
  else  begin
    //  Device is already registered on GCM, check server.
    if  (GCMRegistrar.isRegisteredOnServer(self))  then  begin
      //  Skips registration.
      // TODO: show in UI that device already registered
      fDisplay.setText((getString(R.string.already_registered) + #10));
    end
    else
  begin
      //  Try to register again, but not in the UI thread.
      //  It's also necessary to cancel the thread onDestroy(),
      //  hence the use of AsyncTask instead of a raw thread.
      fRegisterTask := new RegisterAsyncTask(self, regId).execute(nil);
    end
  end;

  //fListView.setAdapter(fAdapter);
  
  var load: array of Integer := [41, 48, 22, 35, 30, 67, 51, 88];
  var data := new ArrayList<Map<String, Object>>(load.length);
  var m: Map<String, Object>;
  for i: Integer := 0 to high(load) do begin
    m := new HashMap<String, Object>();
    m.put(ATTRIBUTE_NAME_TEXT, "Product " + (i+1));
    m.put(ATTRIBUTE_NAME_ICON, "http://remobjects.com/product_icon" + load[i] + ".png");
    m.put(ATTRIBUTE_NAME_NEW, false);
    data.add(m);
  end;

  // массив имен атрибутов, из которых будут читаться данные
  var &from: array of String := [ATTRIBUTE_NAME_TEXT, ATTRIBUTE_NAME_ICON];
  // массив ID View-компонентов, в которые будут вставлять данные
  var &to: array of Integer := [R.id.twName, R.id.twAddress];
  // создаем адаптер
  var sAdapter: SimpleAdapter := new SimpleAdapter(self, data, R.layout.mainlist_item, &from, &to);
  fListView.setAdapter(sAdapter);


  registerForContextMenu(fListView);
end;

constructor MainActivity.RegisterAsyncTask(anOuter: MainActivity; aRegId: String);
begin
  fOuter := anOuter;
  fRegId := aRegId;
end;

method MainActivity.RegisterAsyncTask.doInBackground(params arg1: array of Void): Void;
begin
  var registered: Boolean := ServerUtilities.&register(fOuter, fRegId);
    //  At this point all attempts to register with the app
    //  server failed, so we need to unregister the device
    //  from GCM - the app will try to register again when
    //  it is restarted. Note that GCM will send an
    //  unregistered callback upon completion, but
    //  GCMIntentService.onUnregistered() will ignore it.
  if  (not registered)  then
    GCMRegistrar.unregister(fOuter);
end;

method MainActivity.RegisterAsyncTask.onPostExecute(arg1: Void);
begin
  fOuter.clearRegisterTask();
end;

constructor MainActivity.MainBroadcastReceiver(anOuter: MainActivity);
begin
  self.fOuter := anOuter;
end;

method MainActivity.MainBroadcastReceiver.onReceive(ctx: Context; intent: Intent);
begin
  var newMessage: String := intent.getExtras().getString(CommonUtilities.EXTRA_MESSAGE);
  fOuter.LogTextView.setText(newMessage + #10);
end;

method MainActivity.clearRegisterTask();
begin
  self.fRegisterTask := nil;
end;

{$REGION  UI handlers }
method MainActivity.onCreateOptionsMenu(aMenu: Menu): Boolean;
begin
  MenuInflater.inflate(R.menu.main, aMenu);  
  exit  (true);
end;

method MainActivity.onMenuItemSelected(aFeatureId: Integer; anItem: MenuItem): Boolean;
begin
  case (anItem.ItemId) of
    R.id.menu_add: begin
        exit  (true);
    end;
    R.id.menu_load: begin
        exit  (true);
    end;
    R.id.menu_update: begin
        exit  (true);
    end;
    R.id.menu_settings: begin
      self.startActivity(new Intent(self, typeOf(SettingsActivity)));
      exit true;
    end;
    else
      exit (inherited onMenuItemSelected(aFeatureId, anItem));
  end;
end;
{$ENDREGION }




end.