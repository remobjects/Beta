namespace com.remobjects.beta;

interface
uses
  android.content;

type

CommonUtilities = public sealed class
  public
    /// <summary>
    /// Base URL of the Demo Server (such as http://my_host:8080/gcm-demo)
    /// </summary>
    class var SERVER_URL: String := 'http://beta.remobjects.com:8098/bin'; readonly;
    /// <summary>
    /// Google API project id registered to use GCM.
    /// </summary>
    class var SENDER_ID: String := '895043798507'; readonly; // 132572464504 - created by marc
    /// <summary>
    /// Tag used on log messages.
    /// </summary>
    class var TAG: String := 'Utilities'; readonly;
    /// <summary>
    /// Intent used to display a message in the screen.
    /// </summary>
    class var DISPLAY_MESSAGE_ACTION: String := 'com.remobjects.beta.DISPLAY_MESSAGE'; readonly;
    /// <summary>
    /// Intent's extra that contains the message to be displayed.
    /// </summary>
    class var EXTRA_MESSAGE: String := 'message'; readonly;
    class method displayMessage(context: Context; message: String);
  end;

implementation

class method CommonUtilities.displayMessage(context: Context; message: String);
begin
  var intent: Intent := new Intent(DISPLAY_MESSAGE_ACTION);
  intent.putExtra(EXTRA_MESSAGE, message);
  context.sendBroadcast(intent)
end;

end.
