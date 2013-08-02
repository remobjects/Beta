namespace Beta;

interface

uses
  System,
  System.Collections,
  System.Collections.Generic,
  System.ComponentModel,
  System.Configuration.Install;

type
  ProjectInstaller = public partial class
  protected
    method Dispose(disposing: Boolean); override;
  public
    constructor;
  end;

implementation

constructor ProjectInstaller;
begin
  //
  // Required for Installer Designer support
  //
  InitializeComponent();
end;

method ProjectInstaller.Dispose(disposing: Boolean);
begin
  if (disposing) then begin
    components:Dispose();
    //
    // TODO: Add custom disposition code here
    //
  end;
  inherited Dispose(disposing);
end;

end.