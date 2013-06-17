namespace com.remobjects.everwood.beta;

interface
uses
  android.content;

type

CommonUtilities = public sealed class
  public
    /// <summary>
    /// Base URL of the Demo Server (such as http://my_host:8080/gcm-demo)
    /// </summary>
    {$IFNDEF TEST}
    class var SERVER_URL: String := 'http://beta.remobjects.com:8098/bin'; readonly;
    {$ELSE}
    class var SERVER_URL: String := 'http://192.168.0.105:8098/bin'; readonly;
    {$ENDIF}
    /// <summary>
    /// Google API project id registered to use GCM.
    /// </summary>
    {$IFNDEF TEST}
    class var SENDER_ID: String := '132572464504'; readonly; // created by marc
    {$ELSE}
    class var SENDER_ID: String := '895043798507'; readonly; // mine test
    {$ENDIF}
    /// <summary>
    /// Tag used on log messages.
    /// </summary>
    class var TAG: String := 'Utilities'; readonly;
    /// <summary>
    /// Intent used to display a message in the screen.
    /// </summary>
    class var DISPLAY_MESSAGE_ACTION: String := 'com.remobjects.everwood.beta.DISPLAY_MESSAGE'; readonly;
    class var DISPLAY_TOAST_ACTION: String := 'com.remobjects.everwood.beta.DISPLAY_TOAST'; readonly;

    class var PREFERENCES_NAME: String := 'prefs'; readonly;
    class var PREFS_SERVER_URL: String := 'server_target_url'; readonly;
    class var PREFS_LOGIN_NAME: String := 'login_name'; readonly;
    class var PREFS_LOGIN_TOKEN: String := 'login_token'; readonly;
    /// <summary>
    /// Intent's extra that contains the message to be displayed.
    /// </summary>
    class var EXTRA_MESSAGE: String := 'message'; readonly;
    class method displayMessage(context: Context; message: String);
    class method displayToast(context: Context; message: String);
    class method readToEndOfStream(aIn: java.io.InputStream): array of SByte;
  end;

implementation

class method CommonUtilities.displayMessage(context: Context; message: String);
begin
  var intent: Intent := new Intent(DISPLAY_MESSAGE_ACTION);
  intent.putExtra(EXTRA_MESSAGE, message);
  context.sendBroadcast(intent);
end;

class method CommonUtilities.displayToast(context: Context; message: String);
begin
  var intent: Intent := new Intent(DISPLAY_TOAST_ACTION);
  intent.putExtra(EXTRA_MESSAGE, message);
  context.sendBroadcast(intent);
end;

class method CommonUtilities.readToEndOfStream(aIn: java.io.InputStream): array of SByte;
begin
  var data: array of SByte := new SByte[0];
  var buffer: array of SByte := new SByte[512];
  var SBytesRead: Integer;
  while (true) do begin
    SBytesRead := aIn.read(buffer);

    if (SBytesRead <= 0) then
       break;
    //  construct large enough array for all the data we now have
    var newData: array of SByte := new SByte[(data.length + SBytesRead)];
    //  copy data previously read
    System.arraycopy(data, 0, newData, 0, data.length);
    //  append data newly read
    System.arraycopy(buffer, 0, newData, data.length, SBytesRead);
    //  discard the old array in favour of the new one
    data := newData
  end;
  exit data
end;

end.
