namespace BetaServer;

interface

uses
  System.ServiceProcess,
  System.Windows.Forms,
  RemObjects.SDK.Server;

type
  BetaServer = class(ApplicationServer)
  private
    var fConsoleEngine: Engine;

  protected
    property Identifier: String read '9eeb9502-ae13-4bd3-a591-80f39fb93306'; override;
    property ServiceName: String read 'Beta Service'; override;
    property ApplicationName: String read 'Beta'; override;

    method RunAsConsoleApplication(); override;
    method ShutdownAsConsoleApplication(); override;
    method RunAsWindowsService(); override;
    method RunAsWindowsApplication(); override;
  end;


implementation


method BetaServer.RunAsConsoleApplication();
begin
  self.fConsoleEngine := new Engine();
  self.fConsoleEngine.Start();
end;


method BetaServer.ShutdownAsConsoleApplication();
begin
  self.fConsoleEngine.Stop();
  self.fConsoleEngine.Dispose();
end;


method BetaServer.RunAsWindowsService();
begin
  ServiceBase.Run(new MainService());
end;


method BetaServer.RunAsWindowsApplication();
begin
  Application.EnableVisualStyles();
  Application.Run(new MainForm());
end;


end.