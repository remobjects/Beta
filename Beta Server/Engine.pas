namespace BetaServer;

interface

uses
  System,
  System.Collections.Generic,
  System.ComponentModel,
  System.IO, 
  RemObjects.SDK.Push, 
  BetaServer.Properties;

type
  Engine = public partial class(Component)
  protected
    method Dispose(disposing: Boolean); override;
  public
    constructor;
    constructor (container: IContainer);

    method Start();
    method Stop();

    property Active: Boolean read self.serverChannel.Active;
  end;


implementation


constructor Engine();
begin
  self.InitializeComponent();
end;


constructor Engine(container: IContainer);
begin
  constructor();

  if  (assigned(container))  then
    container.Add(self);
end;

method Engine.Dispose(disposing: System.Boolean);
begin
  if  (disposing)  then  begin
    components:Dispose();
  end;

  inherited Dispose(disposing);
end;

method Engine.Start();
begin
  var lDeviceStoreFile := Path.ChangeExtension(typeOf(self).Assembly.Location, 'devices');
  PushManager.DeviceManager := new FileDeviceManager(lDeviceStoreFile);
  PushManager.RequireSession := false;

  self.serverChannel.Port := Settings.Default.ServerPort;
  self.serverChannel.Activate();

  Notifier.Start();
end;

method Engine.Stop();
begin
  self.serverChannel.Deactivate();
  Notifier.Stop();
end;


end.