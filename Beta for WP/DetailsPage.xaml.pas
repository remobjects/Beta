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
  Beta.Resources;

type
  DetailsPage = public partial class(PhoneApplicationPage)
  private
    method changelogBrowser_LoadCompleted(sender: Object; e: System.Windows.Navigation.NavigationEventArgs);
    method changelogBrowser_Navigating(sender: Object; e: Microsoft.Phone.Controls.NavigatingEventArgs);

  protected
    // When page is navigated to set data context to selected item in list
    method OnNavigatedTo(e: NavigationEventArgs); override;

  public
    // Constructor
    constructor;
  end;

implementation

constructor DetailsPage;
begin
  InitializeComponent()
end;

method DetailsPage.OnNavigatedTo(e: NavigationEventArgs);
begin
  if DataContext = nil then begin
    var selectedIndex: System.String := '';
    if NavigationContext.QueryString.TryGetValue('selectedItem', out selectedIndex) then begin
      var &index: System.Int32 := System.Int32.Parse(selectedIndex);
      DataContext := App.ViewModel.BuildsList[&index]
    end
  end
end;

method DetailsPage.changelogBrowser_LoadCompleted(sender: Object; e: System.Windows.Navigation.NavigationEventArgs);
begin
  // Making webbrowser visible, when content is loaded,
  // to avoid blinking of white background
  changelogBrowser.Opacity := 1;
end;

method DetailsPage.changelogBrowser_Navigating(sender: Object; e: Microsoft.Phone.Controls.NavigatingEventArgs);
begin
  // Making webbrowser invisible, until content is loaded,
  // to avoid blinking of white background
  changelogBrowser.Opacity := 0;
end;

end.
