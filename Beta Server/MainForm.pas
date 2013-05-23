namespace BetaServer;

interface

uses
  System,
  System.Collections,
  System.ComponentModel,
  System.Drawing,
  System.Windows.Forms;

  
type
  MainForm = partial class(System.Windows.Forms.Form)
  private
    var fEngine: Engine;

    method StartServer();
    method StopServer();
    method MainForm_FormClosed(sender: System.Object; e: System.Windows.Forms.FormClosedEventArgs);
  protected
    method Dispose(disposing: Boolean); override;  
  public
    constructor;

    property IsServerActive: Boolean read (self.fEngine:Active);
  end;


implementation


constructor MainForm;
begin
  //
  // Required for Windows Form Designer support
  //
  self.InitializeComponent();

  self.StartServer()
end;


method MainForm.Dispose(disposing: System.Boolean);
begin
  if  (disposing)  then  begin
    components:Dispose();
  end;

  inherited Dispose(disposing);
end;


method MainForm.StartServer();
begin
  if  (self.IsServerActive)  then
    self.StopServer();

  self.fEngine := new Engine();
  self.fEngine.Start()
end;


method MainForm.StopServer();
begin
  if  (self.IsServerActive)  then  begin
    self.fEngine.Dispose();
    self.fEngine := nil;
  end;
end;


method MainForm.MainForm_FormClosed(sender: System.Object; e: System.Windows.Forms.FormClosedEventArgs);
begin
  self.StopServer();
end;


end.