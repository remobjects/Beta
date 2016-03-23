namespace BetaServer;

interface

uses
  System,
  System.IO,
  RemObjects.SDK,
  RemObjects.SDK.Push,
  RemObjects.SDK.Server;

type
  Program = class
  public
    class method Main(arguments: array of String);
  end;

implementation

[STAThread]
class method Program.Main(arguments: array of String);
begin
  var lServer := new ApplicationServer("BetaServer", "RemObjects.Beta", "RemObjects Everwood Beta Service", "RemObjects Everwood Beta Service", []);
  lServer.NetworkServer.Port := BetaServer.Properties.Settings.Default.ServerPort;
  var lApiDispatcher: BetaApiDispatcher;

  lServer.Starting += method begin
    
    lApiDispatcher := new BetaApiDispatcher();
    lApiDispatcher.Server := lServer.NetworkServer.ServerChannel as IHttpServer;
    lApiDispatcher.Path := '/api/';
    
    var lDeviceStoreFile := Path.ChangeExtension(typeOf(self).Assembly.Location, 'devices');
    PushManager.DeviceManager := new FileDeviceManager(lDeviceStoreFile);
    PushManager.RequireSession := false;
    Notifier.Start();
  end;

  lServer.Stopped += method begin
    Notifier.Stop();
  end;

  lServer.Run(arguments);
end;

end.
