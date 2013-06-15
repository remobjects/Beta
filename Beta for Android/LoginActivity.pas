namespace com.remobjects.everwood.beta;

interface

uses
  java.util,
  android.app,
  android.content,
  android.os,
  android.util,
  android.view,
  android.preference,
  android.widget;


type
  LoginActivity = public class(Activity)
  public
    class var ACTIVITY_RESULT_LOGIN: Int32 := 1234; readonly;
    
    const EXTRA_KEY_USER_ID: String = 'Name';
    const EXTRA_KEY_USER_PWD: String = 'Password';

  private
    etLogin, etPassword: EditText;
    cbSavePassword: CheckBox;
    btLogin: Button;

    fPrefs: SharedPreferences;

    method loadPreferences;
    method savePreferences;

  protected
    method onCreate(bundle: Bundle); override;
    method onPause; override;

  public    
    method buttonLoginClick(aView: View);
  end;

implementation


method LoginActivity.onCreate(bundle: Bundle);
begin
  inherited onCreate(bundle);

  self.ContentView := R.layout.activity_login;

  etLogin := EditText(findViewById(R.id.act_login_tb_login));
  etPassword := EditText(findViewById(R.id.act_login_tb_password));
  btLogin := Button(findViewById(R.id.login_bt_ok));
  cbSavePassword := CheckBox(findViewById(R.id.act_login_check_remember));

  fPrefs := self.SharedPreferences[CommonUtilities.PREFENCES_NAME, Context.MODE_PRIVATE];

  loadPreferences();
end;

method LoginActivity.buttonLoginClick(aView: View);
begin
  savePreferences();
  var lAccess := DataAccess.getInstance();

  var lLogin := etLogin.Text.toString;
  var lPassword := etPassword.Text.toString;

  lAccess.Executor.execute(()-> begin  
    var lRes := lAccess.retrieveAndSaveToken(lLogin, lPassword);

    self.runOnUiThread(()-> begin
      if (lAccess.IsAuthorized) then begin
        lAccess.dropAutorizing;
        self.setResult(RESULT_OK);
        self.finish();
      end
      else begin
        var lMessage := 'Login failed for ' + lLogin + '.';
        if (lRes = DataAccess.RequestStatus.NetworkError) then
          lMessage := lMessage + ' Check network connection.';
        Toast.makeText(self, lMessage, Toast.LENGTH_SHORT).show();
        btLogin.Text := 'Try Again';
      end;
    end);    
  end);
end;

method LoginActivity.onPause;
begin
  inherited onPause();
  savePreferences();
end;

method LoginActivity.loadPreferences;
begin
  etLogin.setText(fPrefs.getString(CommonUtilities.PREFS_LOGIN_NAME, ''));
  etPassword.setText(fPrefs.getString(CommonUtilities.PREFS_LOGIN_PASSWORD, ''));
end;

method LoginActivity.savePreferences;
begin
  var editor := fPrefs.edit();

  editor.putString(CommonUtilities.PREFS_LOGIN_NAME, etLogin.Text.toString());
  if  (cbSavePassword.isChecked)  then    
    editor.putString(CommonUtilities.PREFS_LOGIN_PASSWORD, etPassword.Text.toString());
  editor.commit();
end;

end.
