namespace Beta;

interface

uses
  System,
  System.Collections.Generic,
  System.Linq,
  System.Net,
  System.Windows,
  System.Windows.Controls,
  System.Windows.Navigation,
  Microsoft.Phone.Controls,
  Microsoft.Phone.Shell,
  Beta.Resources,
  Beta.ViewModels,
  System.Windows.Data;

type
  MainPage = public partial class(PhoneApplicationPage)
  private
    method MainLongListSelector_SelectionChanged(sender: System.Object; e: SelectionChangedEventArgs);
    method btnLogin_Click(sender: Object; e: System.Windows.RoutedEventArgs);
    method MainPage_Loaded(sender: Object; e: System.Windows.RoutedEventArgs);
    property isUpdatingBinding: Binding;

  public
    // Constructor
    constructor ;
    
end;

implementation

constructor MainPage;
begin
  InitializeComponent();

  DataContext := App.ViewModel;
  self.isUpdatingBinding := new Binding('IsUpdating', Source := DataContext);

  App.ViewModel.LoginButtonContent := "Login";
  self.LoginWindowBorder.Height := Application.Current.Host.Content.ActualHeight;
  self.LoginWindowBorder.Width := Application.Current.Host.Content.ActualWidth;
end;

method MainPage.MainPage_Loaded(sender: Object; e: System.Windows.RoutedEventArgs);
begin
  var progressIndicator: ProgressIndicator := SystemTray.ProgressIndicator;
  
  if progressIndicator = nil then begin
    progressIndicator := new ProgressIndicator;
    BindingOperations.SetBinding(progressIndicator, ProgressIndicator.IsVisibleProperty, self.isUpdatingBinding);
    progressIndicator.SetValue(ProgressIndicator.IsIndeterminateProperty, true);
    progressIndicator.SetValue(ProgressIndicator.TextProperty, 'Updating data...');
    SystemTray.SetProgressIndicator(self, progressIndicator)
  end;

  if not App.ViewModel.IsDataLoaded then begin
    App.ViewModel.LoadData()
  end
end;

method MainPage.MainLongListSelector_SelectionChanged(sender: System.Object; e: SelectionChangedEventArgs);
begin
  var currentList := sender as LongListSelector;

  // If selected item is null (no selection) do nothing
  if currentList.SelectedItem = nil then    
    exit;

  // Navigate to the new page
  NavigationService.Navigate(new Uri('/DetailsPage.xaml?selectedItem=' + (BuildViewModel(currentList.SelectedItem)).ID, UriKind.Relative));

  // Reset selected item to null (no selection)
  currentList.SelectedItem := nil
end;

method MainPage.btnLogin_Click(sender: Object; e: System.Windows.RoutedEventArgs);
begin
  if self.UsernameTextBox.Text = '' then begin
    MessageBox.Show('Please enter user name', 'Error', MessageBoxButton.OK);
    exit
  end;

  App.ViewModel.LoginButtonContent := 'Connecting...';
  DataAccess.GetInstance.BeginLogin(self.UsernameTextBox.Text,
                                    self.PasswordTextBox.Password,
                                    new AsyncCallback(DataAccess.GetInstance.EndLogin));

  
end;

end.
