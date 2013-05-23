namespace BetaServer;

{$HIDE H7}

interface

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  MainForm = partial class
  {$REGION Windows Form Designer generated fields}
  private
    components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method MainForm.InitializeComponent;
begin
  var resources: System.ComponentModel.ComponentResourceManager := new System.ComponentModel.ComponentResourceManager(typeOf(MainForm));
  self.SuspendLayout();
  // 
  // MainForm
  // 
  self.ClientSize := new System.Drawing.Size(292, 69);
  self.FormBorderStyle := System.Windows.Forms.FormBorderStyle.FixedDialog;
  self.Icon := ((resources.GetObject('$this.Icon')) as System.Drawing.Icon);
  self.Name := 'MainForm';
  self.Text := 'Beta Server';
  self.FormClosed += new System.Windows.Forms.FormClosedEventHandler(@self.MainForm_FormClosed);
  self.ResumeLayout(false)
end;
{$ENDREGION}

end.
