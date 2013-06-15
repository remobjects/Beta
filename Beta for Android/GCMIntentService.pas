namespace com.remobjects.everwood.beta;

interface
uses
  android.app,
  android.content,
  android.util,
  com.google.android.gcm;

type
  GCMIntentService = public class(GCMBaseIntentService)
  private
    class var TAG: String := 'GCMIntentService'; readonly;
  public
    constructor();
  protected
    method onRegistered(aContext: Context; registrationId: String); override;
    method onUnregistered(aContext: Context; registrationId: String); override;
    method onMessage(aContext: Context; intent: Intent); override;
    method onDeletedMessages(aContext: Context; total: Integer); override;
  public
    method onError(aContext: Context; errorId: String); override;
  protected
    method onRecoverableError(aContext: Context; errorId: String): Boolean; override;
  private
    class method generateNotification(aContext: Context; message: String);
  end;

implementation

constructor GCMIntentService();
begin
  inherited constructor(CommonUtilities.SENDER_ID);
end;

method GCMIntentService.onRegistered(aContext: Context; registrationId: String);
begin
  //  get the registration id and pass it to the RO server to REGISTER
  Log.i(TAG, (getString(R.string.gcm_registered) + '' + registrationId));
  ServerUtilities.register(aContext, registrationId)
end;

method GCMIntentService.onUnregistered(aContext: Context; registrationId: String);
begin
  //  get the registration id and pass it to the RO server to UNREGISTER
  Log.i(TAG, getString(R.string.gcm_unregistered));
  if GCMRegistrar.isRegisteredOnServer(aContext) then begin
    ServerUtilities.unregister(aContext, registrationId);
  end
  else begin
    //  This callback results from the call to unregister made on
    //  ServerUtilities when the registration to the server failed.
    Log.i(TAG, 'Ignoring unregister callback')
  end;
end;

method GCMIntentService.onMessage(aContext: Context; intent: Intent);
begin
  //  Called when RO server sends a message to GCM, and GCM delivers it to the device.
  //  If the message has a payload, its contents are available as extras in the intent.
  Log.i(TAG, 'Received message');
  var message: String := getString(R.string.gcm_message);
  var lServerMessage: String := intent.getStringExtra(CommonUtilities.EXTRA_MESSAGE);
  if (lServerMessage <> nil) then
    message := message + (': ' + lServerMessage);
  CommonUtilities.displayMessage(aContext, message);
  //  notifies user
  GCMIntentService.generateNotification(aContext, message)
end;

method GCMIntentService.onDeletedMessages(aContext: Context; total: Integer);
begin
  Log.i(TAG, getString(R.string.gcm_deleted, total));
end;

method GCMIntentService.onError(aContext: Context; errorId: String);
begin
  Log.i(TAG, getString(R.string.gcm_error, errorId));
end;

method GCMIntentService.onRecoverableError(aContext: Context; errorId: String): Boolean;
begin
  //  log message
  Log.i(TAG, getString(R.string.gcm_recoverable_error, errorId));
  exit inherited onRecoverableError(aContext, errorId)
end;

class method GCMIntentService.generateNotification(aContext: Context; message: String);
begin
  var icon: Integer := R.drawable.ic_launcher;
  var when: Int64 := System.currentTimeMillis();  
  var title: String := aContext.getString(R.string.app_name);
  
  var notificationIntent := new Intent(aContext, typeOf(MainActivity));
  //  set intent so it does not start a new activity
  notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP);
  var intent: PendingIntent := PendingIntent.getActivity(aContext, 0, notificationIntent, 0);
  
  var lPopupBuilder := new android.support.v4.app.NotificationCompat.Builder(aContext);
  lPopupBuilder.SmallIcon := R.drawable.ic_launcher;
  lPopupBuilder.When := System.currentTimeMillis();
  lPopupBuilder.ContentTitle := title;
  lPopupBuilder.ContentText := message;
  lPopupBuilder.ContentIntent := intent;
  lPopupBuilder.AutoCancel := true;

  var lManager: NotificationManager := NotificationManager(aContext.getSystemService(Context.NOTIFICATION_SERVICE));
  lManager.notify(0, lPopupBuilder.build());

end;

end.
