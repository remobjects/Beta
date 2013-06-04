namespace com.remobjects.dataabstract.simple;

interface

uses
  java.util,
  android.app,
  android.content,
  android.os,
  android.util,
  android.view,
  android.widget;


type
  LoginActivity = public class(Activity)
  public
    class ACTIVITY_ACTION: Integer := RESULT_FIRST_USER + 3; readonly;

  private
    etLogin, etPassword: EditText;
    cbSavePassword: CheckBox;

    method loadPreferences;
    method savePreferences;

  protected
    method onCreate(bundle: Bundle); override;
    method onPause; override;

  public    
    method buttonOkClick(aView: View);
    method buttonCancelClick(aView: View);
  end;

implementation


method LoginActivity.onCreate(bundle: Bundle);
begin
  inherited onCreate(bundle);

  self.ContentView := R.layout.activity_login;

  etLogin := EditText(findViewById(R.id.act_login_tb_login));
  etPassword := EditText(findViewById(R.id.act_login_tb_password));
  cbSavePassword := CheckBox(findViewById(R.id.act_login_check_remember));

  loadPreferences();
end;

method LoginActivity.buttonOkClick(aView: View);
begin
  var i := new Intent();
  i.putExtra(MainActivity.USER_ID_KEY, etLogin.Text.toString);
  i.putExtra(MainActivity.USER_PWD_KEY, etPassword.Text.toString);
  self.setResult(RESULT_OK, i);
  finish();
end;

method LoginActivity.buttonCancelClick(aView: View);
begin
  self.setResult(RESULT_CANCELED);
  finish();
end;

method LoginActivity.onPause;
begin
  inherited onPause();
  savePreferences();
end;

method LoginActivity.loadPreferences;
begin
  var lApplicationSettings := self.getSharedPreferences(MainActivity.PREFS_NAME, MODE_PRIVATE);
  etLogin.setText(lApplicationSettings.getString(MainActivity.USER_ID_KEY, ''));
  etPassword.setText(lApplicationSettings.getString(MainActivity.USER_PWD_KEY, ''));
end;

method LoginActivity.savePreferences;
begin
  var lApplicationSettings := self.getSharedPreferences(MainActivity.PREFS_NAME, MODE_PRIVATE);
  var editor := lApplicationSettings.edit();

  editor.putString(MainActivity.USER_ID_KEY, etLogin.Text.toString());
  if  (cbSavePassword.isChecked)  then    
    editor.putString(MainActivity.USER_PWD_KEY, etPassword.Text.toString());
  editor.commit();
end;

end.
