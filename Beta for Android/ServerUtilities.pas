namespace com.remobjects.everwood.beta;

interface
uses
  com.google.android.gcm,
  com.remobjects.sdk,
  android.content,
  android.util,
  java.io,
  java.net,
  java.util;

type
/// <summary>
/// Helper class used to communicate with the demo server
/// </summary>
ServerUtilities = public sealed class
  private
    class var TAG: String := CommonUtilities.TAG; readonly;
    class var MAX_ATTEMPTS: Integer := 5; readonly;
    class var BACKOFF_MILLI_SECONDS: Integer := 2000; readonly;
    class var random: Random := new Random(); readonly;
    class var fService: GooglePushProviderService_Proxy;
  assembly    
    class constructor;
    class method &register(const context: Context; const regId: String): Boolean;
    class method unregister(const context: Context; const regId: String);
end;

implementation

class constructor ServerUtilities;
begin
  try
    fService := new GooglePushProviderService_Proxy(new URI(CommonUtilities.SERVER_URL));
  except
    on e2: URISyntaxException do begin
      //  TODO Auto-generated catch block
      e2.printStackTrace();
    end    
  end;
end;

class method ServerUtilities.&register(const context: Context; const regId: String): Boolean;
begin
  Log.i(TAG, (('registering device (regId = ' + regId) + ')'));
  var backoff: Int64 := (BACKOFF_MILLI_SECONDS + random.nextInt(1000));
  //  Once GCM returns a registration id, we need to register it in the
  //  RO+Push server. As the server might be down, we will retry it a couple
  //  times.
  begin
    var i: Integer := 1;
    while (i <= MAX_ATTEMPTS) do begin
      Log.i(TAG, context.getString(R.string.server_registering, i, MAX_ATTEMPTS));
      try
        //CommonUtilities.displayMessage(context, context.getString(R.string.server_registering, i, MAX_ATTEMPTS));
        fService.registerDevice(regId, typeOf(MainActivity).getPackage().getName());
        GCMRegistrar.setRegisteredOnServer(context, true);
        Log.i(TAG, context.getString(R.string.server_registered));
        CommonUtilities.displayMessage(context, context.getString(R.string.server_registered));
        exit true;
      except
        on e: Exception do begin
          //  Here we are simplifying and retrying on any error; in a real
          //  application, it should retry only on unrecoverable errors
          //  (like HTTP error code 503).
          Log.e(TAG, ('Failed to register on attempt ' + i), e);
          if (i = MAX_ATTEMPTS) then begin
            break
          end;
          try
            Log.d(TAG, (('Sleeping for ' + backoff) + ' ms before retry'));
            Thread.sleep(backoff);
          except
            on e1: InterruptedException do begin
              //  Activity finished before we complete - exit.
              Log.d(TAG, 'Thread interrupted: abort remaining retries!');
              Thread.currentThread().interrupt();
              exit false;
            end
          end;
          //  increase backoff exponentially
          backoff := backoff * 2
        end;
      end;
      inc(i);
    end;
  end;
  var message: String := context.getString(R.string.server_register_error, MAX_ATTEMPTS);
  CommonUtilities.displayMessage(context, message);
  exit false
end;

class method ServerUtilities.unregister(const context: Context; const regId: String);
begin
  Log.i(TAG, (('unregistering device (regId = ' + regId) + ')'));
  try
    fService.unregisterDevice(regId);
    GCMRegistrar.setRegisteredOnServer(context, false);
    var message: String := context.getString(R.string.server_unregistered);
    CommonUtilities.displayMessage(context, message);
  except
    on e: Exception do begin
      //  At this point the device is unregistered from GCM, but still
      //  registered in the server.
      //  We could try to unregister again, but it is not necessary:
      //  if the server tries to send a message to the device, it will get
      //  a "NotRegistered" error message and should unregister the device.
      var message: String := context.getString(R.string.server_unregister_error, e.getMessage());
      CommonUtilities.displayMessage(context, message)
    end;
  end;
end;

end.
