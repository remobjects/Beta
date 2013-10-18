namespace Beta.ViewModels;

interface

uses
  System,
  System.ComponentModel,
  System.Diagnostics,
  System.Net,
  System.Windows,
  System.Windows.Controls,
  System.Windows.Input,
  System.Windows.Media,
  System.Windows.Media.Animation;

type
  BuildViewModel = public class(INotifyPropertyChanged)
  private
    var fId: String;
        fProductName: String;
        fProductVersion: String;
        fBuildDate: String;
        fIsBeta: Boolean;
        fIsNew: Boolean;
        fChangeLog: String;
        fProductTextColor: Brush;
        fProductIconOpacity: Double;
        fImageURL: Uri;

    method NotifyPropertyChanged(propertyName: String);
    method getChangeLog: String;

  public
    constructor;

    property ID: String read fId write fId; notify;
    property ProductName: String read fProductName write fProductName; notify;
    property ProductVersion: String read fProductVersion write fProductVersion; notify;
    property BuildDate: String read fBuildDate write fBuildDate; notify;
    property IsBeta: Boolean read fIsBeta write fIsBeta; notify;
    property IsNew: Boolean read fIsNew write fIsNew; notify;
    property ProductTextColor: Brush read fProductTextColor write fProductTextColor; notify;
    property ProductIconOpacity: Double read fProductIconOpacity write fProductIconOpacity; notify;
    property ChangeLog: String read getChangeLog write fChangeLog; notify;
    property ImageURL: Uri read fImageURL write fImageURL; notify;

    event PropertyChanged: PropertyChangedEventHandler;
  end;

implementation

constructor BuildViewModel;
begin
  fImageURL := new Uri("../Assets/EmptyAppLogo.png", UriKind.RelativeOrAbsolute);
end;

method BuildViewModel.NotifyPropertyChanged(propertyName: String);
begin
  var handler: PropertyChangedEventHandler := PropertyChanged;
  if nil <> handler then begin
    handler(self, new PropertyChangedEventArgs(propertyName))
  end
end;

method BuildViewModel.getChangeLog: String;
begin
  if not String.IsNullOrEmpty(fChangeLog) then
    exit fChangeLog;

  exit "No Changelog available for this product."
end;

end.
