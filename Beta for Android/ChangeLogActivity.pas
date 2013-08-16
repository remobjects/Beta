namespace com.remobjects.everwood.beta;
interface

uses
  java.util,
  android.app,
  android.content,
  android.os,
  android.util,
  android.view,
  android.webkit,
  android.widget,
  android.support.v4.app;

type
  ChangeLogActivity = public class(Activity)
  {$region Constants}
  public
    const EXTRA_KEY_PRODUCT_INDEX: String = 'product_index';
  {$endregion}

  {$region Private fields}
  private
    const TAG = "Beta.ChangeLog";
    var fDataAccess: DataAccess;
    
    var fProductIndex: Integer;
    var fProduct: Map<String, Object>;
  {$endregion}

  private

  public
    method onCreate(savedInstanceState: Bundle); override;
    method onOptionsItemSelected(aMenuItem: MenuItem): RemObjects.Oxygene.System.Boolean; override;
  end;

implementation

method ChangeLogActivity.onCreate(savedInstanceState: Bundle);
begin
  inherited onCreate(savedInstanceState);
  
  fDataAccess := DataAccess.getInstance();
  fProductIndex := self.Intent.Extras.Int[EXTRA_KEY_PRODUCT_INDEX];
  fProduct := fDataAccess.Products.get(fProductIndex);  
  var lChangeLog := fProduct.get('changelog'):toString();

  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) then begin
    self.ActionBar.DisplayHomeAsUpEnabled := true;
    self.ActionBar.Subtitle := fProduct.get('product').toString() + ' ' + fProduct.get('version'):toString();
  end
  else
    self.Title := 'Changelog of ' + fProduct.get('product').toString();
  
  setContentView(R.layout.activity_changelog);

  var lWebView: WebView := WebView(self.findViewById(R.id.wvChangelog));
  if (assigned(lChangeLog) and (lChangeLog.length > 0)) then begin
    var lHtmlData := '<link rel="stylesheet" type="text/css" href="ChangeLogs.css" />' + lChangeLog;
    lWebView.loadDataWithBaseURL('file:///android_asset/', lHtmlData, 'text/html', 'UTF-8', nil);
  end
  else
    lWebView.loadData('No changelog available for the product.', 'text/plain', nil);
end;

method ChangeLogActivity.onOptionsItemSelected(aMenuItem: MenuItem): RemObjects.Oxygene.System.Boolean;
begin
  case (aMenuItem.ItemId) of
    android.R.id.home: begin
      var upIntent := NavUtils.getParentActivityIntent(self);
      if (NavUtils.shouldUpRecreateTask(self, upIntent)) then begin
        // we should not get here !
        TaskStackBuilder.from(self).addNextIntent(upIntent).startActivities();
        finish();
      end
      else
        //if (manifest[parentactivity].launchMode=singleTop)
        NavUtils.navigateUpTo(self, upIntent);
        // else
        //finish();
      exit (true);
    end;
  end;
  exit inherited.onOptionsItemSelected(aMenuItem);
end;

end.