﻿namespace Beta;

interface

uses
  UIKit;

type
  [IBObject]
  AppDelegate = class(IUIApplicationDelegate, IDataAccessDelegate)
  private
    method downloadsChanged(aNotification: NSNotification);
    method showInAppPushMessage(aUserInfo: NSDictionary);
  public
    property window: UIWindow;

    {$REGION IUIApplicationDelegate}
    method application(application: UIApplication) didFinishLaunchingWithOptions(launchOptions: NSDictionary): Boolean;
    method application(application: UIApplication) continueUserActivity(userActivity: NSUserActivity) restorationHandler(restorationHandler: block(results: NSArray));
    method application(application: UIApplication) performActionForShortcutItem(shortcutItem: UIApplicationShortcutItem) completionHandler(completionHandler: block(aSuccess: Boolean));
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
    method application(application: UIApplication) didReceiveRemoteNotification(userInfo: NSDictionary) fetchCompletionHandler(completionHandler: block (aResult: UIBackgroundFetchResult));
    {$ENDREGION}

    {$REGION IDataAccessDelegate}
    method askForLogin;
    method alertErrorWithTitle(aTitle: String) message(aMessage: String);
    {$ENDREGION}

  end;

implementation

method AppDelegate.downloadsChanged(aNotification: NSNotification);
begin
  UIApplication.sharedApplication.applicationIconBadgeNumber := 0;
end;

method AppDelegate.application(application: UIApplication) didFinishLaunchingWithOptions(launchOptions: NSDictionary): Boolean;
begin
  NSLog('application:didFinishLaunchingWithOptions:%@', launchOptions);

  DataAccess.sharedInstance.delegate := self;
  NSNotificationCenter.defaultCenter.addObserver(self) 
                                     &selector(selector(downloadsChanged:))
                                     name(DataAccess.NOTIFICATION_DOWNLOADS_CHANGED) 
                                     object(DataAccess.sharedInstance);

  if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPad then begin
    var lSplitViewController := self.window.rootViewController as UISplitViewController;
    var navigationController := lSplitViewController.viewControllers.firstObject;
    lSplitViewController.delegate := navigationController.topViewController as IUISplitViewControllerDelegate;
  end;

  if application.respondsToSelector(selector(registerUserNotificationSettings:)) then begin
    {$HIDE NH0}
    var lSettings := UIUserNotificationSettings.settingsForTypes(UIUserNotificationType.Badge or UIUserNotificationType.Alert or UIUserNotificationType.Sound) categories(nil);
    //var lSettings := NSClassFromString("UIUserNotificationSettings").settingsForTypes(UIUserNotificationType.Badge or UIUserNotificationType.Alert or UIUserNotificationType.Sound) categories(nil);
    application.registerUserNotificationSettings(lSettings);
    {$SHOW NH0}
  end;
  
  if application.respondsToSelector(selector(registerForRemoteNotifications)) then
    {$HIDE NH0}
    application.registerForRemoteNotifications()
    {$SHOW NH0}
  else
    {$HIDE W28}
    application.registerForRemoteNotificationTypes(UIRemoteNotificationType.UIRemoteNotificationTypeAlert or
                                                   UIRemoteNotificationType.UIRemoteNotificationTypeBadge or
                                                   UIRemoteNotificationType.UIRemoteNotificationTypeSound);
    {$SHOW W28}
  result := true;
end;

method AppDelegate.application(application: UIApplication) continueUserActivity(userActivity: NSUserActivity) restorationHandler(restorationHandler: block(results: NSArray));
begin
end;

method AppDelegate.application(application: UIApplication) performActionForShortcutItem(shortcutItem: UIApplicationShortcutItem) completionHandler(completionHandler: block(aSuccess: Boolean));
begin
  if shortcutItem.type.hasSuffix("refresh") then
    DataAccess.sharedInstance.beginGetData();
  completionHandler(true);
  //else if shortcutItem.type.hasSuffix("home") then begn
  //  DataAccess.sharedInstance.beginGetData();
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
  NSLog('Registered for push with device id %@', deviceToken.description);
  DataAccess.sharedInstance.pushDeviceToken := deviceToken;
end;

method AppDelegate.application(application: UIKit.UIApplication) didFailToRegisterForRemoteNotificationsWithError(error: Foundation.NSError);
begin
  if error.code = 3010 then exit; // we expect this to fail on Simulator.
  
  NSLog('didFailToRegisterForRemoteNotificationsWithError:%@', error);
  var lAlert := new UIAlertView withTitle('Failed to register for Push') message(error.localizedDescription) &delegate(nil) cancelButtonTitle('Cancel') otherButtonTitles(nil);
  lAlert.show();
end;

method AppDelegate.showInAppPushMessage(aUserInfo: NSDictionary);
begin
  var lAPS := aUserInfo['aps'];
  if assigned(lAPS) then begin
    var lAlert := lAPS['alert'];
    var lBadge := lAPS['badge'];

    if assigned(lBadge) then
      UIApplication.sharedApplication.applicationIconBadgeNumber := lBadge.intValue; 

    if assigned(lAlert) then begin

      if UIApplication.sharedApplication.applicationState = UIApplicationState.UIApplicationStateActive then begin
        NSLog('UIApplicationStateActive');
        var a := new UIAlertView withTitle('Beta') message(lAlert) &delegate(nil) cancelButtonTitle('OK') otherButtonTitles(nil);
        a.show();
      end;
      {else begin
        NSLog('NOT UIApplicationStateActive');
        var lLocalNotification := new UILocalNotification;
        lLocalNotification.alertBody := 'INAPP: '+lAlert;
        UIApplication.sharedApplication.presentLocalNotificationNow(lLocalNotification);
      end;}

    end;
  end;
end;

method AppDelegate.application(application: UIKit.UIApplication) didReceiveRemoteNotification(userInfo: Foundation.NSDictionary);
begin
  NSLog('application:didReceiveRemoteNotification:%@', userInfo);
  DataAccess.sharedInstance.beginGetDataWithCompletion(method begin
      showInAppPushMessage(userInfo);
    end);
end;

method AppDelegate.application(application: UIApplication) didReceiveRemoteNotification(userInfo: NSDictionary) fetchCompletionHandler(completionHandler: block (aResult: UIBackgroundFetchResult));
begin
  NSLog('application:didReceiveRemoteNotification:fetchCompletionHandler: %@', userInfo);
  DataAccess.sharedInstance.beginGetDataWithCompletion(method begin
      
      showInAppPushMessage(userInfo);
      
      if assigned(completionHandler) then completionHandler(UIBackgroundFetchResult.UIBackgroundFetchResultNewData);

    end);
end;
{$ENDREGION}

{$REGION IDataAccessDelegate}
method AppDelegate.askForLogin;
begin
  if DataAccess.sharedInstance.askingForLogin then
    exit;
    
  DataAccess.sharedInstance.askingForLogin := true;
  // try getting credentials from safari keychain
  SecRequestSharedWebCredential("secure.remobjects.com", nil, method (credentials: CFArrayRef; error: CFErrorRef) begin
    if assigned(credentials) then begin
      var lData := bridge<NSArray>(credentials);
      if lData.count > 0 then begin
        var lAccount := lData[0] as NSDictionary;
        if lAccount["srvr"] = "secure.remobjects.com" then begin
          //NSLog("data: %@", lData);
          var lUsername := lAccount["acct"]; // kSecAttrAccount
          var lPassword := lAccount["spwd"]; // kSecSharedPassword
          dispatch_async(dispatch_get_main_queue(), method begin
            DataAccess.sharedInstance.beginLoginWithUsername(lUsername) password(lPassword) fromKeychain(true) completion(method (aSuccess: Boolean) begin
            end);
            //(UIApplication.sharedApplication.delegate as! AppDelegate).gotLoginDetails();
          end);
          exit;
        end
      // if that failed, ask for login
      end;
    end;
    NSLog("Error getting web credentials: %@", bridge<NSError>(error));
    var lLoginViewController := new UINavigationController withRootViewController(new LoginViewController);
    lLoginViewController.modalPresentationStyle := UIModalPresentationStyle.UIModalPresentationFormSheet;
    self.window.rootViewController.presentViewController(lLoginViewController) animated(true) completion(nil); 
  end);

end;

method AppDelegate.alertErrorWithTitle(aTitle: String) message(aMessage: String);
begin
  var lAlert := new UIAlertView withTitle(aTitle) message(aMessage) &delegate(nil) cancelButtonTitle('OK') otherButtonTitles(nil);
  lAlert.show();
end;
{$ENDREGION}

end.
