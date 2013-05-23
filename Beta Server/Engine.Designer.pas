namespace BetaServer;

{$HIDE H7}

interface

type
  Engine = public partial class
  {$REGION Component Designer generated code}
  private
    components: System.ComponentModel.IContainer;
    message: RemObjects.SDK.BinMessage;
    sessionManager: RemObjects.SDK.Server.MemorySessionManager;
    serverChannel: RemObjects.SDK.Server.IpHttpServerChannel;
    method InitializeComponent;
  {$ENDREGION}
  end;


implementation


{$REGION Component Designer generated code}
method Engine.InitializeComponent;
begin
  self.components := new System.ComponentModel.Container();

  self.message := new RemObjects.SDK.BinMessage();
  self.sessionManager := new RemObjects.SDK.Server.MemorySessionManager(self.components);
  self.serverChannel := new RemObjects.SDK.Server.IpHttpServerChannel(self.components);
  ((self.serverChannel) as System.ComponentModel.ISupportInitialize).BeginInit();
  // 
  // SessionManager
  // 
  self.sessionManager.Timeout := 1800;
  // 
  // message
  // 
  self.message.ContentType := 'application/octet-stream';
  self.message.SerializerInstance := nil;
  // 
  // serverChannel
  // 
  self.serverChannel.Port := 8099;
  self.serverChannel.SendClientAccessPolicyXml := RemObjects.SDK.Server.ClientAccessPolicyType.AllowAll;
  self.serverChannel.Dispatchers.Add(new RemObjects.SDK.Server.MessageDispatcher(self.message.DefaultDispatcherName, self.message));
  ((self.serverChannel) as System.ComponentModel.ISupportInitialize).EndInit()
end;
{$ENDREGION}


end.