﻿namespace com.remobjects.everwood.beta;
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
    const ATTRIBUTE_NAME_TEXT = "name";
    const ATTRIBUTE_NAME_ICON = "icon";
    const ATTRIBUTE_NAME_NEW = "new";
  {$endregion}

  {$region Private fields}
  private
    const TAG = "Beta.Main";
    var that: MainActivity;
    var fDataAccess: DataAccess;
    fHandleMessageReceiver: BroadcastReceiver;
    fListView: ListView;
    fRegisterTask: AsyncTask<Void, Void, Void>;
    fAdapter: ProductsListAdapter;
  {$endregion}

  private
    method ensureGCMRegistration();
    method registerReceiver();
    method loadServerData();

  public
    method onCreate(savedInstanceState: Bundle); override;
    method onRestart; override;
    method onDestroy(); override;
    method onPause; override;
    method onActivityResult(requestCode, resultCode: Integer; data: Intent); override;
    method onCreateOptionsMenu(aMenu: Menu): Boolean; override;
    method onMenuItemSelected(aFeatureId: Integer; anItem: MenuItem): Boolean; override;
    method clearRegisterTask();
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
  
  setContentView(R.layout.activity_main);

  //Toast.makeText(self, 'Main: created', Toast.LENGTH_SHORT).show();

  // Make sure the device has the proper dependencies.
  GCMRegistrar.checkDevice(self);
  // Make sure the manifest was properly set - comment out this line
  // while developing the app, then uncomment it when it's ready.
  GCMRegistrar.checkManifest(self);

  fDataAccess := DataAccess.getInstance();
  fListView := ListView(findViewById(android.R.id.list));
  fListView.EmptyView := findViewById(android.R.id.empty);

  self.registerReceiver();

  fAdapter := new ProductsListAdapter(self);
  fListView.setAdapter(fAdapter);
  fListView.OnItemClickListener := new interface AdapterView.OnItemClickListener(
    onItemClick := method(aParent: AdapterView; aView: View; aPos: Integer; anId: Int64) begin
      var lProduct := fDataAccess.Products.get(aPos);
      if (lProduct.containsKey('header')) then exit;
      var  lBundle := new Bundle();
      lBundle.putInt(ChangeLogActivity.EXTRA_KEY_PRODUCT_INDEX, aPos);
      var lIntent := new Intent(self, typeOf(ChangeLogActivity));
      lIntent.putExtras(lBundle);
      self.startActivity(lIntent);
    end
  );

  Log.i(TAG, 'onCreate: initiate login and load data');
  self.fDataAccess.loginAsync(self, new interface DataAccess.RequestCallback(
    gotLogin := method(aStatus: DataAccess.RequestStatus; aUser, aPassword: String) begin
      if (fDataAccess.IsAuthorized) then begin
        ensureGCMRegistration();
        self.loadServerData();
      end;
    end
  ));
end;

method MainActivity.onRestart;
begin
  //Toast.makeText(self, 'Main: restarted', Toast.LENGTH_SHORT).show();
  inherited.onRestart();
end;

method MainActivity.onDestroy;
begin
  if (assigned(fRegisterTask)) then begin
    fRegisterTask.cancel(true);
  end;

  self.unregisterReceiver(fHandleMessageReceiver);
  try
    GCMRegistrar.onDestroy(self);
  except
  end;
  

  inherited onDestroy();
end;

method MainActivity.onPause;
begin
  fDataAccess.flushCacheData();
  Log.i(TAG, "cache data flushed on disk");

  inherited.onPause();
end;

method MainActivity.onActivityResult(requestCode: Integer; resultCode: Integer; data: Intent);
begin
  if  (requestCode = LoginActivity.ACTIVITY_RESULT_LOGIN)  then  begin
    if  (resultCode = RESULT_OK)  then  begin
      ensureGCMRegistration();
      loadServerData();
    end
    else  if  (resultCode = RESULT_CANCELED)  then  begin
      Toast.makeText(self, 'Login cancelled. Press Refresh to force relogin.', Toast.LENGTH_LONG).show();
    end
  end;
  inherited onActivityResult(requestCode, resultCode, data);
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
    R.id.menu_load: begin
      if (not fDataAccess.IsAuthorized) then begin
        self.fDataAccess.loginAsync(self, new interface DataAccess.RequestCallback(
          gotLogin := method(aStatus: DataAccess.RequestStatus; aUser, aPassword: String) begin
            if (fDataAccess.IsAuthorized) then begin
              self.loadServerData();
            end;
          end
        ));
      end
      else
        self.loadServerData();
      exit (true);
    end;
    else
      exit (inherited onMenuItemSelected(aFeatureId, anItem));
  end;
end;
{$ENDREGION }


method MainActivity.ensureGCMRegistration;
begin
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
      //Toast.makeText(self, getString(R.string.already_registered), Toast.LENGTH_SHORT).show();
    end
    else
  begin
      //  Try to register again, but not in the UI thread.
      //  It's also necessary to cancel the thread onDestroy(),
      //  hence the use of AsyncTask instead of a raw thread.
      fRegisterTask := new RegisterAsyncTask(self, regId).execute(nil);
    end
  end;
end;

method MainActivity.registerReceiver;
begin  
  fHandleMessageReceiver:= new MainBroadcastReceiver(self);
  var intFilter := new IntentFilter(CommonUtilities.DISPLAY_MESSAGE_ACTION);
  intFilter.addAction(CommonUtilities.DISPLAY_TOAST_ACTION);
  self.registerReceiver(fHandleMessageReceiver, intFilter);
end;


method MainActivity.clearRegisterTask();
begin
  self.fRegisterTask := nil;
end;

method MainActivity.loadServerData();
begin
  fDataAccess.getDataAsync(self, new interface DataAccess.RequestCallback(
    gotData := method(aStatus: DataAccess.RequestStatus) begin
      if (aStatus = DataAccess.RequestStatus.NetworkError) then begin
        Toast.makeText(self, 'Loading failed. Check network connection.', Toast.LENGTH_SHORT).show();
      end
      else if (fDataAccess.IsAuthorized) then begin
        Toast.makeText(self, 'New data downloaded successfully.', Toast.LENGTH_SHORT).show();
        fAdapter.notifyDataSetChanged();
      end
      else begin
        Toast.makeText(self, 'Login failed. Please try again.', Toast.LENGTH_SHORT).show();
        fDataAccess.loginAsync(self);
      end;      
    end,
    gotCachedData := method begin
       Toast.makeText(self, 'Showing cached data.', Toast.LENGTH_SHORT).show();
       fAdapter.notifyDataSetChanged();
    end    
  ));
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

  case (intent.Action) of
    CommonUtilities.DISPLAY_MESSAGE_ACTION,
    CommonUtilities.DISPLAY_TOAST_ACTION:
      Toast.makeText(fOuter, newMessage, Toast.LENGTH_SHORT).show();
  end;  
end;


end.