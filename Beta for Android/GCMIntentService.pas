namespace com.remobjects.beta;

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
    method onRegistered(context: Context; registrationId: String); override;
    method onUnregistered(context: Context; registrationId: String); override;
    method onMessage(context: Context; intent: Intent); override;
    method onDeletedMessages(context: Context; total: Integer); override;
  public
    method onError(context: Context; errorId: String); override;
  protected
    method onRecoverableError(context: Context; errorId: String): Boolean; override;
  private
    class method generateNotification(ctx: Context; message: String);
  end;

implementation

constructor GCMIntentService();
begin
  inherited constructor (CommonUtilities.SENDER_ID)
end;

method GCMIntentService.onRegistered(context: Context; registrationId: String);
begin
  //  get the registration id and pass it to the RO server to REGISTER
  Log.i(TAG, ('Device registered: regId = ' + registrationId));
  CommonUtilities.displayMessage(context, getString(R.string.gcm_registered));
  ServerUtilities.&register(context, registrationId)
end;

method GCMIntentService.onUnregistered(context: Context; registrationId: String);
begin
  //  get the registration id and pass it to the RO server to UNREGISTER
  Log.i(TAG, 'Device unregistered');
  CommonUtilities.displayMessage(context, getString(R.string.gcm_unregistered));
  if GCMRegistrar.isRegisteredOnServer(context) then begin
    ServerUtilities.unregister(context, registrationId)
  end
  else
begin
    //  This callback results from the call to unregister made on
    //  ServerUtilities when the registration to the server failed.
    Log.i(TAG, 'Ignoring unregister callback')
  end
end;

method GCMIntentService.onMessage(context: Context; intent: Intent);
begin
  //  Called when RO server sends a message to GCM, and GCM delivers it to the device.
  //  If the message has a payload, its contents are available as extras in the intent.
  Log.i(TAG, 'Received message');
  var message: String := getString(R.string.gcm_message);
  var lServerMessage: String := intent.getStringExtra('server_message');
  if (lServerMessage <> nil) then     message := message + (': ' + lServerMessage);
  var lServerTime: String := intent.getStringExtra('server_time');
  if (lServerTime <> nil) then     message := message + ('Server time is: ' + lServerTime);
  CommonUtilities.displayMessage(context, message);
  //  notifies user
  generateNotification(context, message)
end;

method GCMIntentService.onDeletedMessages(context: Context; total: Integer);
begin
  Log.i(TAG, 'Received deleted messages notification');
  var message: String := getString(R.string.gcm_deleted, total);
  CommonUtilities.displayMessage(context, message);
  //  notifies user
  generateNotification(context, message)
end;

method GCMIntentService.onError(context: Context; errorId: String);
begin
  Log.i(TAG, ('Received error: ' + errorId));
  CommonUtilities.displayMessage(context, getString(R.string.gcm_error, errorId))
end;

method GCMIntentService.onRecoverableError(context: Context; errorId: String): Boolean;
begin
  //  log message
  Log.i(TAG, ('Received recoverable error: ' + errorId));
  CommonUtilities.displayMessage(context, getString(R.string.gcm_recoverable_error, errorId));
  exit inherited onRecoverableError(context, errorId)
end;

class method GCMIntentService.generateNotification(ctx: Context; message: String);
begin
  var icon: Integer := R.drawable.ic_launcher;
  var when: Int64 := System.currentTimeMillis();
  var notificationManager: NotificationManager := NotificationManager(ctx.getSystemService(Context.NOTIFICATION_SERVICE));
  var lPopup: Notification := new Notification(icon, message, when);
  var title: String := ctx.getString(R.string.app_name);
  var notificationIntent: Intent := new Intent(ctx, typeOf(MainActivity));
  //  set intent so it does not start a new activity
  notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP);
  var intent: PendingIntent := PendingIntent.getActivity(ctx, 0, notificationIntent, 0);
  lPopup.setLatestEventInfo(ctx, title, message, intent);
  lPopup.&flags := lPopup.&flags or Notification.FLAG_AUTO_CANCEL;
  notificationManager.&notify(0, lPopup);
end;

end.
