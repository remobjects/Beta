namespace Beta;

{$HIDE H7}

interface

type
  [System.ComponentModel.RunInstaller(true)]
  ProjectInstaller = public partial class(System.Configuration.Install.Installer)
  {$REGION Installer Designer generated fields}
  private
    components: System.ComponentModel.IContainer := nil;
    serviceProcessInstaller: System.ServiceProcess.ServiceProcessInstaller;
    serviceInstaller: System.ServiceProcess.ServiceInstaller;
    method InitializeComponent;
  {$ENDREGION}
  end;


implementation


{$REGION Installer Designer generated code}
method ProjectInstaller.InitializeComponent;
begin
  self.serviceProcessInstaller := new System.ServiceProcess.ServiceProcessInstaller();
  self.serviceInstaller := new System.ServiceProcess.ServiceInstaller();
  // 
  // serviceProcessInstaller
  // 
  self.serviceProcessInstaller.Account := System.ServiceProcess.ServiceAccount.NetworkService;
  self.serviceProcessInstaller.Password := nil;
  self.serviceProcessInstaller.Username := nil;
  // 
  // serviceInstaller
  // 
  self.serviceInstaller.DisplayName := 'RemObjects Software Beta Service';
  self.serviceInstaller.ServiceName := 'RemObjects Software Beta Service';
  // 
  // ProjectInstaller
  // 
  self.Installers.AddRange(array of System.Configuration.Install.Installer([self.serviceProcessInstaller, self.serviceInstaller]))
end;
{$ENDREGION}


end.