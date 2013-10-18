namespace Beta;

interface

uses
  System,
  System.Diagnostics,
  System.Resources,
  System.Windows,
  System.Windows.Markup,
  System.Windows.Navigation,
  Microsoft.Phone.Controls,
  Microsoft.Phone.Shell,
  Beta.Resources,
  Beta.ViewModels;

type
  App = public partial class(Application)
  private
    class var fviewModel: MainViewModel := nil;

    // Code to execute when the application is launching (eg, from Start)
    // This code will not execute when the application is reactivated
    method Application_Launching(sender: System.Object; e: LaunchingEventArgs);
    
    // Code to execute when the application is activated (brought to foreground)
    // This code will not execute when the application is first launched
    method Application_Activated(sender: System.Object; e: ActivatedEventArgs);

    // Code to execute when the application is deactivated (sent to background)
    // This code will not execute when the application is closing
    method Application_Deactivated(sender: System.Object; e: DeactivatedEventArgs);

    // Code to execute when the application is closing (eg, user hit Back)
    // This code will not execute when the application is deactivated
    method Application_Closing(sender: System.Object; e: ClosingEventArgs);

    // Code to execute if a navigation fails
    method RootFrame_NavigationFailed(sender: System.Object; e: NavigationFailedEventArgs);

    // Code to execute on Unhandled Exceptions
    method Application_UnhandledException(sender: System.Object; e: ApplicationUnhandledExceptionEventArgs);

    // Avoid double-initialization
    var phoneApplicationInitialized: System.Boolean := false;
    method InitializePhoneApplication;
    method CompleteInitializePhoneApplication(sender: System.Object; e: NavigationEventArgs);
    method CheckForResetNavigation(sender: System.Object; e: NavigationEventArgs);
    method ClearBackStackAfterReset(sender: System.Object; e: NavigationEventArgs);

  public
    
    /// <summary>
    /// A static ViewModel used by the views to bind against.
    /// </summary>
    /// <returns>The MainViewModel object.</returns>
    class property ViewModel: MainViewModel read get_ViewModel;
    class method get_ViewModel: MainViewModel;

    /// <summary>
    /// Provides easy access to the root frame of the Phone Application.
    /// </summary>
    /// <returns>The root frame of the Phone Application.</returns>
    class property RootFrame: PhoneApplicationFrame;

    /// <summary>
    /// Constructor for the Application object.
    /// </summary>
    constructor ;

    class method CurrentRootVisual: PhoneApplicationFrame;
    class method Navigate(source: Uri): System.Boolean;
    class method GoBack;

end;

implementation

class method App.get_ViewModel: MainViewModel; 
begin
  // Delay creation of the view model until necessary
  if fviewModel = nil then 
    fviewModel := new MainViewModel();

  exit fviewModel
end;

constructor App;
begin
  // Global handler for uncaught exceptions.
  UnhandledException += Application_UnhandledException;

  // Standard XAML initialization
  InitializeComponent();

  // Phone-specific initialization
  InitializePhoneApplication();

  // Show graphics profiling information while debugging.
  if Debugger.IsAttached then begin

    // Display the current frame rate counters.
    Application.Current.Host.Settings.EnableFrameRateCounter := true;

    // Prevent the screen from turning off while under the debugger by disabling
    // the application's idle detection.
    // Caution:- Use this under debug mode only. Application that disables user idle detection will continue to run
    // and consume battery power when the user is not using the phone.
    PhoneApplicationService.Current.UserIdleDetectionMode := IdleDetectionMode.Disabled
  end
end;

method App.Application_Launching(sender: System.Object; e: LaunchingEventArgs);
begin

end;

method App.Application_Activated(sender: System.Object; e: ActivatedEventArgs);
begin
end;

method App.Application_Deactivated(sender: System.Object; e: DeactivatedEventArgs);
begin
  // Ensure that required application state is persisted here.
end;


method App.Application_Closing(sender: System.Object; e: ClosingEventArgs);
begin

end;

method App.RootFrame_NavigationFailed(sender: System.Object; e: NavigationFailedEventArgs);
begin
  if Debugger.IsAttached then begin
    // A navigation has failed; break into the debugger
    Debugger.Break()
  end
end;

method App.Application_UnhandledException(sender: System.Object; e: ApplicationUnhandledExceptionEventArgs);
begin
  if Debugger.IsAttached then begin
    // An unhandled exception has occurred; break into the debugger
    Debugger.Break()
  end
end;

// Do not add any additional code to this method
method App.InitializePhoneApplication;
begin
  if phoneApplicationInitialized then
    exit;

  // Create the frame but don't set it as RootVisual yet; this allows the splash
  // screen to remain active until the application is ready to render.
  RootFrame := new PhoneApplicationFrame();
  RootFrame.Navigated += CompleteInitializePhoneApplication;

  // Handle navigation failures
  RootFrame.NavigationFailed += RootFrame_NavigationFailed;

  // Handle reset requests for clearing the backstack
  RootFrame.Navigated += CheckForResetNavigation;

  // Ensure we don't initialize again
  phoneApplicationInitialized := true
end;

// Do not add any additional code to this method
method App.CompleteInitializePhoneApplication(sender: System.Object; e: NavigationEventArgs);
begin
  // Set the root visual to allow the application to render
  if RootVisual <> RootFrame then 
    RootVisual := RootFrame;

  // Remove this handler since it is no longer needed
  RootFrame.Navigated -= CompleteInitializePhoneApplication
end;

method App.CheckForResetNavigation(sender: System.Object; e: NavigationEventArgs);
begin
  // If the app has received a 'reset' navigation, then we need to check
  // on the next navigation to see if the page stack should be reset
  if e.NavigationMode = NavigationMode.Reset then
    RootFrame.Navigated += ClearBackStackAfterReset
end;

method App.ClearBackStackAfterReset(sender: System.Object; e: NavigationEventArgs);
begin
  // Unregister the event so it doesn't get called again
  RootFrame.Navigated -= ClearBackStackAfterReset;

  // Only clear the stack for 'new' (forward) and 'refresh' navigations
  if (e.NavigationMode <> NavigationMode.New) and (e.NavigationMode <> NavigationMode.Refresh) then    exit;

  // For UI consistency, clear the entire page stack
  while RootFrame.RemoveBackEntry() <> nil do begin
    // do nothing
  end
end;

class method App.CurrentRootVisual: PhoneApplicationFrame;
begin
  exit App.Current.RootVisual as PhoneApplicationFrame
end;

class method App.Navigate(source: Uri): System.Boolean;
begin
  if CurrentRootVisual <> nil then    
    exit CurrentRootVisual.Navigate(source);

  exit false
end;

class method App.GoBack;
begin
  if CurrentRootVisual <> nil then   
    CurrentRootVisual.GoBack()
end;


end.
