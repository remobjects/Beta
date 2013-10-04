namespace Beta;

interface

uses
  UIKit;

type
  [IBObject]
  LoginViewController = public class(UIViewController, IUITextFieldDelegate)
  public
    method init: id; override;

    method viewDidLoad; override;

    method textFieldShouldReturn(textField: UITextField): Boolean;

    [IBOutlet] property username: weak UITextField;
    [IBOutlet] property password: weak UITextField;
    [IBOutlet] property activity: weak UIActivityIndicatorView;
    [IBOutlet] property loginButton: weak UIButton;

    [IBAction] method loginTapped(aSender: id);

  end;

implementation

method LoginViewController.init: id;
begin
  self := inherited initWithNibName('LoginViewController') bundle(nil);
  result := self;
end;

method LoginViewController.viewDidLoad;
begin
  inherited viewDidLoad;
  title := 'Login';

  username.becomeFirstResponder();
  activity.hidesWhenStopped := true;
end;

method LoginViewController.textFieldShouldReturn(textField: UITextField): Boolean;
begin
  if textField = username then
    password.becomeFirstResponder()
  else if textField = password then
    loginTapped(nil);
end;

method LoginViewController.loginTapped(aSender: id);
begin
  activity.startAnimating();
  loginButton.enabled := false;
  loginButton.setTitle('Connecting...') forState(UIControlState.UIControlStateNormal);
  DataAccess.sharedInstance.beginLoginWithUsername(username.text) password(password.text) completion(method (aSuccess: Boolean) begin

      activity.stopAnimating();
      if aSuccess then begin
        self.dismissViewControllerAnimated(true) completion(nil);
      end
      else begin
        loginButton.enabled := true;
        loginButton.setTitle('Try again') forState(UIControlState.UIControlStateNormal);
      end;

    end);
end;

end.
