namespace Beta;

interface

uses
  UIKit;

type
  [IBObject]
  AppDelegate = class(IUIApplicationDelegate, IDataAccessDelegate)
  private
  public
    property window: UIWindow;

    {$REGION IUIApplicationDelegate}
    method application(application: UIApplication) didFinishLaunchingWithOptions(launchOptions: NSDictionary): Boolean;
    method applicationWillResignActive(application: UIApplication);
    method applicationDidEnterBackground(application: UIApplication);
    method applicationWillEnterForeground(application: UIApplication);
    method applicationDidBecomeActive(application: UIApplication);
    method applicationWillTerminate(application: UIApplication);
    {$ENDREGION}

    {$REGION Push Notifications}
    method application(application: UIKit.UIApplication) didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Foundation.NSData);
    method application(application: UIKit.UIApplication) didFailToRegisterForRemoteNotificationsWithError(error: Foundation.NSError);
    method application(application: UIKit.UIApplication) didReceiveRemoteNotification(userInfo: Foundation.NSDictionary);
    {$ENDREGION}

    {$REGION IDataAccessDelegate}
    method askForLogin;
    method alertErrorWithTitle(aTitle: String) message(aMessage: String);
    {$ENDREGION}

  end;

implementation

method AppDelegate.application(application: UIApplication) didFinishLaunchingWithOptions(launchOptions: NSDictionary): Boolean;
begin
  DataAccess.sharedInstance.delegate := self;

  UINavigationBar.appearance.tintColor := UIColor.colorWithRed(0.3) green(0.3) blue(0.7) alpha(1.0);
  
  if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPad then begin
    var lSplitViewController := self.window.rootViewController as UISplitViewController;
    var navigationController := lSplitViewController.viewControllers.lastObject;
    lSplitViewController.delegate := navigationController.topViewController as IUISplitViewControllerDelegate;
  end;

  application.registerForRemoteNotificationTypes(UIRemoteNotificationType.UIRemoteNotificationTypeAlert or
                                                 UIRemoteNotificationType.UIRemoteNotificationTypeBadge or
                                                 UIRemoteNotificationType.UIRemoteNotificationTypeSound);

  result := true;
end;

method AppDelegate.applicationWillResignActive(application: UIApplication);
begin
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
end;

method AppDelegate.applicationDidEnterBackground(application: UIApplication);
begin
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
end;

method AppDelegate.applicationWillEnterForeground(application: UIApplication);
begin
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
end;

method AppDelegate.applicationDidBecomeActive(application: UIApplication);
begin
  DataAccess.sharedInstance.beginGetData();
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
end;

method AppDelegate.applicationWillTerminate(application: UIApplication);
begin
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
end;

{$REGION Push Notifications}
method AppDelegate.application(application: UIKit.UIApplication) didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Foundation.NSData);
begin
  NSLog('Registered for push with devcie id %@', deviceToken.description);
  DataAccess.sharedInstance.pushDeviceToken := deviceToken;
end;

method AppDelegate.application(application: UIKit.UIApplication) didFailToRegisterForRemoteNotificationsWithError(error: Foundation.NSError);
begin
  if error.code = 3010 then exit; // we expect this to fail on Simulator.
  
  NSLog('didFailToRegisterForRemoteNotificationsWithError:%@', error);
  var lAlert := new UIAlertView withTitle('Failed to register for Push') message(error.localizedDescription) &delegate(nil) cancelButtonTitle('Cancel') otherButtonTitles(nil);
  lAlert.show();
end;

method AppDelegate.application(application: UIKit.UIApplication) didReceiveRemoteNotification(userInfo: Foundation.NSDictionary);
begin

end;
{$ENDREGION}

{$REGION IDataAccessDelegate}
method AppDelegate.askForLogin;
begin
  self.window.rootViewController.presentViewController(new LoginViewController) animated(true) completion(nil); 
end;

method AppDelegate.alertErrorWithTitle(aTitle: String) message(aMessage: String);
begin
  var lAlert := new UIAlertView withTitle(aTitle) message(aMessage) &delegate(nil) cancelButtonTitle('OK') otherButtonTitles(nil);
  lAlert.show();
end;
{$ENDREGION}

end.
