namespace Beta.ViewModels;

interface

uses
  System,
  System.Collections.Generic,
  System.Collections.ObjectModel,
  System.ComponentModel,
  System.Linq,
  Beta.Resources,
  Beta;

type
  MainViewModel = public class(INotifyPropertyChanged)
  private
    var fBuildsList: ObservableCollection<BuildViewModel>;
    var fBetaDownloads: ObservableCollection<BuildViewModel>;
    var fReleaseDownloads: ObservableCollection<BuildViewModel>;

    method NotifyPropertyChanged(propertyName: String);
    method setBuildsList(value: ObservableCollection<BuildViewModel>);

  public
    constructor ;

    property BuildsList: ObservableCollection<BuildViewModel> read fBuildsList write setBuildsList; notify;
    property BetaDownloads: ObservableCollection<BuildViewModel> {read getBetaDownloads}; notify;
    property ReleaseDownloads: ObservableCollection<BuildViewModel> {read getReleaseDownloads}; notify;
    
    property IsDataLoaded: Boolean;
    property LoginWindowActive: Boolean; notify;
    property IsUpdating: Boolean; notify;
    property LoginButtonContent: String; notify;

    method LoadData;

    event PropertyChanged: PropertyChangedEventHandler;
  end;

implementation

constructor MainViewModel;
begin

end;

method MainViewModel.LoadData;
begin
  DataAccess.getInstance.BeginGetData;
end;

method MainViewModel.setBuildsList(value: ObservableCollection<BuildViewModel>);
begin
  fBuildsList := value;

  //ToDo: put this distribution in getters
  self.BetaDownloads := new ObservableCollection<BuildViewModel>(from b in fBuildsList 
                                                                        where b.IsBeta 
                                                                        select b);
  self.ReleaseDownloads := new ObservableCollection<BuildViewModel>(from b in fBuildsList 
                                                                              where not b.IsBeta 
                                                                              select b);
end;

method MainViewModel.NotifyPropertyChanged(propertyName: String);
begin
  var handler: PropertyChangedEventHandler := PropertyChanged;
  if nil <> handler then begin
    handler(self, new PropertyChangedEventArgs(propertyName))
  end
end;

end.
