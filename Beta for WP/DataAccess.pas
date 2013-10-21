namespace Beta;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text,
  System.Net,
  System.IO,
  System.Windows.Navigation,
  System.Windows,
  System.Xml.Linq,
  System.Collections.ObjectModel,
  System.IO,
  System.IO.IsolatedStorage,
  System.Windows.Media,
  Beta.ViewModels,
  Beta.Helpers;

type
  DataAccess = public class
  private
    const URL_GET_DATA: String = '{0}{1}?name={2}&token={3}&changelogs=yes';
          URL_GET_TOKEN: String = '{0}{1}?name={2}&password={3}&appid={4}&clientid={5}';

          CHANGELOG_HTML: String = '<html><body style="background-color: #000000; color: #FFFFFF"> {0} </body> </html>';

    const PUSH_SERVICE_URL = 'http://beta.remobjects.com:8098/bin';

    const API_URL = 'https://secure.remobjects.com/api/';
    const IMAGES_URL = 'http://www.remobjects.com/images/product-logos/{0}-64.png';
    const API_GETTOKEN = 'gettoken';
    const API_DOWNLOADS = 'downloads';
    const API_APPID = 'Beta.WinPhone';

    const KEY_USERNAME = 'UserName';
    const KEY_TOKEN = 'Token';
    const CACHE_DIRNAME = 'Beta';
    const CACHE_FILENAME = CACHE_DIRNAME + '\\DataCache.txt';

    class var fInstance: DataAccess;
    
    var fUserName, fUserToken: String;
    var settings :IsolatedStorageSettings;

    method SavePreferences;
    method SaveDataInCache(data: String);
    method ReadDataFromCache: String;

    method EndGetData(data: IAsyncResult);    
    method ParseData(data: String; dataIsStale: Boolean);
    method TryGetAsyncResponce(request: HttpWebRequest; data: IAsyncResult): HttpWebResponse;

  public
    constructor;

    class method GetInstance: DataAccess;
    method BeginGetData;
    method BeginLogin(userName: String; password: String; callback: AsyncCallback);
    method EndLogin(data: IAsyncResult);
  end;

implementation

constructor DataAccess;
begin
  settings := IsolatedStorageSettings.ApplicationSettings;

  if settings.Contains(KEY_USERNAME) then 
    fUserName := settings[KEY_USERNAME].ToString
  else begin
    settings.Add(KEY_USERNAME, '');
    settings.Save;
  end;

  if settings.Contains(KEY_TOKEN) then 
    fUserToken := settings[KEY_TOKEN].ToString
  else begin
    settings.Add(KEY_TOKEN, '');
    settings.Save;
  end;

  self.ParseData(ReadDataFromCache, true);
end;

class method DataAccess.GetInstance: DataAccess;
begin
  if not assigned(fInstance) then
    fInstance := new DataAccess;

  exit fInstance;
end;

method DataAccess.BeginLogin(userName: String; password: String; callback: AsyncCallback);
begin
  var lURL := String.Format(URL_GET_TOKEN, API_URL, API_GETTOKEN, userName, password, API_APPID, API_APPID);

  var lRequest: HttpWebRequest;
  lRequest := HttpWebRequest(WebRequest.&Create(lURL));
  lRequest.BeginGetResponse(new AsyncCallback(callback), lRequest);

  fUserName := userName;
end;

method DataAccess.EndLogin(data: IAsyncResult);
begin
  var lRequest: HttpWebRequest := HttpWebRequest(&data.AsyncState);

  var lResponse := TryGetAsyncResponce(lRequest, data);

  if (lResponse <> nil) and (lResponse.StatusCode = HttpStatusCode.OK) then begin
    var reader := new StreamReader(lResponse.GetResponseStream);
    fUserToken := reader.ReadToEnd;
    SavePreferences;

    Deployment.Current.Dispatcher.BeginInvoke(() -> begin 
      App.ViewModel.LoginButtonContent := 'Login';
      App.ViewModel.LoginWindowActive := false;
    end);

    BeginGetData;
  end
end;

method DataAccess.BeginGetData;
begin
  var lURL := String.Format(URL_GET_DATA, API_URL, API_DOWNLOADS, fUsername, fUserToken);

  var lRequest: HttpWebRequest;
  lRequest := HttpWebRequest(WebRequest.&Create(lURL));
  App.ViewModel.IsUpdating := true;
  lRequest.BeginGetResponse(new AsyncCallback(EndGetData), lRequest);
end;

method DataAccess.EndGetData(data: IAsyncResult);
begin
  var lRequest: HttpWebRequest := HttpWebRequest(&data.AsyncState);

  var lResponse := TryGetAsyncResponce(lRequest, data);

  if (lResponse <> nil) and (lResponse.StatusCode = HttpStatusCode.OK) then begin
    var reader := new StreamReader(lResponse.GetResponseStream);
    var dataXML := reader.ReadToEnd;
    SaveDataInCache(dataXML);
    App.ViewModel.IsDataLoaded := true;
    ParseData(dataXML, false);
    Deployment.Current.Dispatcher.BeginInvoke(() -> begin 
        App.ViewModel.IsUpdating := false;
    end);
  end
end;

method DataAccess.ParseData(data: String; dataIsStale: Boolean);
begin
  if String.IsNullOrEmpty(data) then 
    exit;

  var doc: XDocument;

  try
    doc := XDocument.Parse(data);
  except on e: Exception do begin
    var s := e.Message;
    end
  end;

  var fParsedItems := new ObservableCollection<BuildViewModel>;

  var itemID := 0;
  var fPrereleaseAttribute: XAttribute;

  for each docNode in doc.Descendants('download') do begin
    var newBuildItem := new BuildViewModel;
    
    newBuildItem.ID := itemID.ToString;
    newBuildItem.ProductName := docNode.Attribute('product').Value;
    newBuildItem.ProductVersion := docNode.Attribute('version').Value;
    var buildDate := DateTime.Parse(docNode.Attribute('date').Value);
    newBuildItem.BuildDate := String.Format('({0})', buildDate.RelativeDateString);
    
    fPrereleaseAttribute := docNode.Attribute('prerelease');
    newBuildItem.IsBeta := iif (assigned(fPrereleaseAttribute), 
                                Convert.ToBoolean(fPrereleaseAttribute.Value), 
                                false);    
    newBuildItem.IsNew := (DateTime.Now - buildDate).TotalDays < 3;
    
    if dataIsStale then begin
      newBuildItem.ProductTextColor := new SolidColorBrush(Color.FromArgb(255, 190, 190, 190));
      newBuildItem.ProductIconOpacity := 0.5
    end
    else 
      Deployment.Current.Dispatcher.BeginInvoke(() -> begin 
        newBuildItem.ProductTextColor := new SolidColorBrush(Color.FromArgb(255, 255, 255, 255));
        newBuildItem.ProductIconOpacity := 1;
      end);

    newBuildItem.ImageURL := new Uri(String.Format(IMAGES_URL, docNode.Attribute('logo').Value));

    var changeLog := docNode.Value.ToString;
    newBuildItem.ChangeLog := 
      iif(String.IsNullOrEmpty(changeLog),
          String.Format(CHANGELOG_HTML, 'No changelog available for this product.'),
          String.Format(CHANGELOG_HTML, changeLog));

    fParsedItems.Add(newBuildItem);
    inc(itemID);
  end;

  Deployment.Current.Dispatcher.BeginInvoke(() -> begin 
    App.ViewModel.BuildsList := fParsedItems;
  end);
end;

method DataAccess.SavePreferences;
begin
  settings[KEY_USERNAME] := fUserName;
  settings[KEY_TOKEN] := fUserToken;
  settings.Save;
end;

method DataAccess.ReadDataFromCache: String;
begin
  var fileStorage := IsolatedStorageFile.GetUserStoreForApplication;

  if not fileStorage.FileExists(CACHE_FILENAME) then
    exit '';

  var fileReader: StreamReader := new StreamReader(new IsolatedStorageFileStream(
                                            CACHE_FILENAME, FileMode.Open, fileStorage));
  result := fileReader.ReadToEnd;
  fileReader.Close;
end;

method DataAccess.SaveDataInCache(data: String);
begin
  var fileStorage := IsolatedStorageFile.GetUserStoreForApplication;

  //Does nothing if directory exists
  fileStorage.CreateDirectory(CACHE_DIRNAME);

  var fileWriter := new StreamWriter(new IsolatedStorageFileStream(
                                       CACHE_FILENAME, FileMode.&Create, fileStorage));
  fileWriter.Write(data);
  fileWriter.Close;
end;

method DataAccess.TryGetAsyncResponce(request: HttpWebRequest; data: IAsyncResult): HttpWebResponse;
begin
  var lResponse: HttpWebResponse;

  try
    lResponse := HttpWebResponse(request.EndGetResponse(&data));
  except 
    on webEx: WebException do begin
    var errorResponse := HttpWebResponse(webEx.Response); 

    if (errorResponse.StatusCode = HttpStatusCode.NotImplemented) or //501 
       (errorResponse.StatusCode = HttpStatusCode.Unauthorized) then begin
      fUserToken := nil;
      Deployment.Current.Dispatcher.BeginInvoke(() -> begin 
        App.ViewModel.LoginButtonContent := 'Login';
        App.ViewModel.IsUpdating := false;
        App.ViewModel.LoginWindowActive := true 
      end);
      end;

    if errorResponse.StatusCode = HttpStatusCode.NotFound then begin //404
      Deployment.Current.Dispatcher.BeginInvoke(() -> begin 
        App.ViewModel.IsUpdating := false;
        MessageBox.Show(String.Format("Unable to update data."), "Error", MessageBoxButton.OK);
      end);
      end
    end;

    on ex: Exception do begin
      App.ViewModel.IsUpdating := false;
      MessageBox.Show(String.Format("Error occured: {0}", ex.Message), "Error", MessageBoxButton.OK);
    end
  end;

  exit lResponse;
end;

end.
