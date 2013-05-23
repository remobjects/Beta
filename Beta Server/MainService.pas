namespace BetaServer;

interface

uses
  System,
  System.Collections,
  System.ComponentModel,
  System.ServiceProcess;

  
type
  MainService = assembly partial class(System.ServiceProcess.ServiceBase)
  private
    {$REGION Private fields}
    var fEngine: Engine;
    {$ENDREGION}

  protected
    method Dispose(disposing: Boolean); override;

    method OnStart(args: array of String); override;
    method OnStop(); override;
    method OnPause(); override;
    method OnContinue(); override;

  public
    constructor;
  end;


implementation


constructor MainService;
begin
  inherited constructor;

  //
  // Required for Service Designer support
  //
  self.InitializeComponent();
end;


method MainService.Dispose(disposing: Boolean);
begin
  if  (disposing)  then  begin
    components:Dispose();

    //
    // TODO: Add custom disposition code here
    //
  end;

  inherited Dispose(disposing);
end;


method MainService.OnStart(args: array of String);
begin
  inherited OnStart(args);
  self.fEngine := new Engine();
  self.fEngine.Start()
end;


method MainService.OnStop();
begin
  inherited OnStop();
  self.fEngine.Stop();
  self.fEngine.Dispose();
  self.fEngine := nil
end;


method MainService.OnPause();
begin
  inherited OnPause();
  self.fEngine.Stop()
end;


method MainService.OnContinue();
begin
  inherited OnContinue();
  self.fEngine.Start()
end;


end.
