namespace Beta;

interface

uses
  Foundation,
  TwinPeaks,
  UIKit;

type
  [IBObject]
  MasterViewController = public class (UITableViewController, IUITableViewDelegate, IUISplitViewControllerDelegate)
  private
    var fBetaDownloads: NSArray;
    var fRTMDownloads: NSArray;
    var fActivity: NSUserActivity;
    var fIconCache: NSMutableDictionary<String, UIImage> := new NSMutableDictionary<String, UIImage>;
    var fIconQueue: dispatch_queue_t;
    method downloadsChanged(aNotification: NSNotification);
  protected
  public
    property detailViewController: DetailViewController;

    method awakeFromNib; override;
    method viewDidLoad; override;
    method viewDidAppear(animated: BOOL); override;
    method didReceiveMemoryWarning; override;
    method prepareForSegue(segue: not nullable UIStoryboardSegue) sender(sender: id); override;

    {$REGION Table view data source}
    method numberOfSectionsInTableView(tableView: UITableView): Integer;
    method tableView(tableView: UITableView) viewForHeaderInSection(section: Integer): UIView;
    method tableView(tableView: UITableView) heightForHeaderInSection(section: Integer): CGFloat;

    method tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
    method tableView(tableView: UITableView) numberOfRowsInSection(section: Integer): Integer;
    method tableView(tableView: UITableView) shouldHighlightRowAtIndexPath(indexPath: NSIndexPath): Boolean;
    {$ENDREGION}

    {$REGION Table view delegate}
    method tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
    {$ENDREGION}

    {$REGION IUISplitViewControllerDelegate}
    method splitViewController(svc: UISplitViewController) shouldHideViewController(vc: UIViewController) inOrientation(orientation: UIInterfaceOrientation): Boolean;
    {$ENDREGION}

    method refresh(aSender: id);
  end;

implementation

method MasterViewController.awakeFromNib;
begin
  clearsSelectionOnViewWillAppear := true;
  tableView.separatorStyle := UITableViewCellSeparatorStyle.None;
  fIconQueue := dispatch_queue_create('com.remobjects.everewood.beta.iconqueue', DISPATCH_QUEUE_SERIAL);
  inherited awakeFromNib;
end;

method MasterViewController.downloadsChanged(aNotification: NSNotification);
begin
  var lSorting: NSArray := [new NSSortDescriptor withKey('date') ascending(false),
                            new NSSortDescriptor withKey('product') ascending(true)];
  
  locking DataAccess.sharedInstance do begin
    fBetaDownloads := DataAccess.sharedInstance.downloads:filteredArrayUsingPredicate(NSPredicate.predicateWithFormat('prerelease = "true"')):distinctArrayWithKey('product')
                                                         :sortedArrayUsingDescriptors(lSorting);
    fRTMDownloads := DataAccess.sharedInstance.downloads:filteredArrayUsingPredicate(NSPredicate.predicateWithFormat('prerelease <> "true"')):distinctArrayWithKey('product')
                                                         :sortedArrayUsingDescriptors(lSorting);
  end;

  // Pull to Refresh is not available on iOS5.
  if self.respondsToSelector(selector(refreshControl)) then
    refreshControl:endRefreshing();

  tableView.reloadData();
end;

method MasterViewController.viewDidLoad;
begin
  inherited viewDidLoad;
 
  title := 'Available Builds';

  var lTintColor := UIColor.colorWithRed(0.3) green(0.3) blue(0.7) alpha(1.0);
  navigationController.navigationBar.tintColor := lTintColor;

  // Pull to Refresh is not available on iOS5.
  //if self.respondsToSelector(selector(refreshControl)) then begin
  if assigned(typeOf(UIRefreshControl)) then begin
    refreshControl := new UIRefreshControl;
    //62469: Nougat: No member "appearance" on type "Class" and "id"
    refreshControl.tintColor := lTintColor;
    refreshControl.addTarget(self) 
                   action(selector(refresh:))
                   forControlEvents(UIControlEvents.UIControlEventValueChanged);
  end;
  
  if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPad then begin
  end;

  //tableView.backgroundColor := UIColor.scrollViewTexturedBackgroundColor;
  if not DataAccess.isIOS7OrLater then
    tableView.separatorStyle := UITableViewCellSeparatorStyle.UITableViewCellSeparatorStyleNone;

  {navigationItem:leftBarButtonItem := self:editButtonItem;
  var addButton := new UIBarButtonItem withBarButtonSystemItem(UIBarButtonSystemItem.UIBarButtonSystemItemAdd)
                                           target(self)
                                           action(selector(insertNewObject:));
  navigationItem:rightBarButtonItem := addButton;}
  detailViewController := splitViewController:viewControllers:lastObject:topViewController as DetailViewController;

  //DataAccess.sharedInstance.beginGetData();

  NSNotificationCenter.defaultCenter.addObserver(self) 
                                     &selector(selector(downloadsChanged:))
                                     name(DataAccess.NOTIFICATION_DOWNLOADS_CHANGED) 
                                     object(DataAccess.sharedInstance);
  downloadsChanged(nil);
end;

method MasterViewController.viewDidAppear(animated: BOOL);
begin
  if NSClassFromString("NSUserActivity") ≠ nil then begin
    NSLog('creating NSUserActivity');
    fActivity := new NSUserActivity withActivityType(NSUserActivityTypeBrowsingWeb);
    fActivity.webpageURL := NSURL.URLWithString("https://secure.remobjects.com/portal/downloads");
    fActivity.becomeCurrent();
  end;
end;

method MasterViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning;
  // Dispose of any resources that can be recreated.
end;

{$REGION Table view data source}

method MasterViewController.numberOfSectionsInTableView(tableView: UITableView): Integer;
begin
  result := if fRTMDownloads:count > 0 then 2 else 1;
end;

method MasterViewController.tableView(tableView: UITableView) viewForHeaderInSection(section: Integer): UIView;
begin
  var lCaption := case section of
                    0: if fBetaDownloads:count > 0 then 'Beta Downloads';
                    1: 'Release Downloads';
                  end;
  result := if assigned(lCaption) then 
              new TPHeaderView withWidth(tableView.frame.size.width) caption(lCaption);
end;

method MasterViewController.tableView(tableView: UITableView) heightForHeaderInSection(section: Integer): CGFloat;
begin

  result := case section of
              0: if fBetaDownloads:count > 0 then TPHeaderView.headerHeight else 0;
              1: TPHeaderView.headerHeight;
              else 0;
            end;
end;

method MasterViewController.tableView(tableView: UITableView) numberOfRowsInSection(section: Integer): Integer;
begin
  case section of
    0: result := fBetaDownloads:count;
    1: result := fRTMDownloads:count;
  end;
end;

method MasterViewController.tableView(tableView: UITableView) cellForRowAtIndexPath(indexPath: NSIndexPath): UITableViewCell;
begin
  var lDownloads := case indexPath.section of
                      0: fBetaDownloads;
                      1: fRTMDownloads;
                    end;
  var lDownload := lDownloads[indexPath.row];

  //result := tableView.dequeueReusableCellWithIdentifier('RootCell');
  if not assigned(result) then begin
    result := new TPBaseCell withStyle(UITableViewCellStyle.UITableViewCellStyleSubtitle) reuseIdentifier('RootCell');

    if not DataAccess.isIOS7OrLater then begin
      var selectionColor := new UIView;
      selectionColor.backgroundColor := navigationController.navigationBar.tintColor;
      result.selectedBackgroundView := selectionColor;
    end;

    result.textLabel.backgroundColor := UIColor.clearColor;
    result.textLabel.font := UIFont.systemFontOfSize(18);
    result.detailTextLabel.backgroundColor := UIColor.clearColor;
    result.detailTextLabel.font := UIFont.systemFontOfSize(10);

    if NSDate.date().timeIntervalSinceDate(lDownload['date']) < 60*60*24*3 {3 days} then begin
      var lNew := new UIImageView withImage(UIImage.imageNamed('New'));
      var lLeft := if not DataAccess.isIOS7OrLater then 22 else 30;
      lNew.frame := CGRectMake(lLeft, 4, lNew.image.size.width, lNew.image.size.height);
      result.addSubview(lNew);
    end;
  end;

  result.textLabel.text := lDownload['product'];
  result.detailTextLabel.text :=lDownload['version']+' ('+lDownload['date'].relativeDateString+')' ;

  if DataAccess.sharedInstance.dataIsStale then begin
    result.textLabel.textColor := result.detailTextLabel.textColor;
    result.imageView.alpha := 0.5;
  end;

  //62454: Nougat: Internal Compiler error on scope issue
  var lLogoName := lDownload['logo'];

  var lIsRetina := UIScreen.mainScreen.scale > 1;

  if not assigned(lDownload["image"]) then begin


    var lImage: UIImage;
    locking self do lImage := fIconCache[lLogoName];
    if assigned(lImage) then begin
      result.imageView.image := lImage;
    end
    else begin

      result.imageView.image := UIImage.imageNamed(if not DataAccess.isIOS7OrLater then 'EmptyAppLogo' else 'EmptyAppLogo7');
      dispatch_async(fIconQueue, method begin

        var lImage2: UIImage;
        locking self do lImage2 := fIconCache[lLogoName];
        if not assigned(lImage2) then begin

          var lImageSuffix := if not DataAccess.isIOS7OrLater then (if lIsRetina then '-64.png' else '-32.png') else '-64-flat.png';
          var lScale := if DataAccess.isIOS7OrLater or lIsRetina then 2.0 else 1.0; 
          
          var lUrl := new NSURL withString('https://secure.remobjects.com/images/product-logos/'+lDownload['logo']+lImageSuffix);
          NSLog('downloading %@', lUrl);
          var lData := new NSData withContentsOfURL(lUrl);
          NSLog('downloading done');
          if assigned(lData) then begin
            lImage2 := if UIImage.respondsToSelector(selector(imageWithData:scale:)) then
                             UIImage.imageWithData(lData) scale(lScale)
                           else
                             UIImage.imageWithData(lData);
            locking self do fIconCache[lLogoName] := lImage2;
          end;
        end;
        dispatch_async(dispatch_get_main_queue(), method begin
          lDownload["image"] := lImage2;

          tableView.reloadRowsAtIndexPaths(NSArray.arrayWithObject(indexPath)) withRowAnimation(UITableViewRowAnimation.UITableViewRowAnimationNone);
          //tableView.reloadRowsAtIndexPaths([indexPath]) withRowAnimation(UITableViewRowAnimation.UITableViewRowAnimationNone);

        end);
      end);

    end;

  end
  else begin
    result.imageView.image := lDownload["image"];
  end;
end;

{$ENDREGION}

{$REGION  Table view delegate}

method MasterViewController.tableView(tableView: UITableView) shouldHighlightRowAtIndexPath(indexPath: NSIndexPath): Boolean;
begin
  if  assigned(detailViewController) then exit true;

  var lDownloads := case indexPath.section of
                      0: fBetaDownloads;
                      1: fRTMDownloads;
                    end;
  var lDownload := lDownloads[indexPath.row];

  result := assigned(lDownload) and assigned(lDownload['changelog']);
end;

method MasterViewController.tableView(tableView: UITableView) didSelectRowAtIndexPath(indexPath: NSIndexPath);
begin
  var lDownloads := case indexPath.section of
                      0: fBetaDownloads;
                      1: fRTMDownloads;
                    end;
  var lDownload := lDownloads[indexPath.row];

  if assigned(detailViewController) then begin
    //detailViewController.isBeta := indexPath.section = 0;
    if assigned(lDownload['changelog']) then begin
      detailViewController.showChangeLog(lDownload['changelog'])
    end
    else begin
      detailViewController.hideChangeLog();
    end;
  end
  else begin
    if assigned(lDownload['changelog']) then 
      navigationController.pushViewController(new WebViewController withHtml(lDownload['changelog'])) animated(true); 
    tableView.deselectRowAtIndexPath(indexPath) animated(true); 
  end;

end;

{$ENDREGION}

method MasterViewController.prepareForSegue(segue: not nullable UIStoryboardSegue) sender(sender: id);
begin
  if segue.identifier.isEqualToString('showDetail') then begin
  //  var lIndexPath := tableView.indexPathForSelectedRow;

  //  var lObject := fObjects[lIndexPath.row];

 //   segue.destinationViewController.setDetailItem(lObject);
 //   (segue.destinationViewController as  DetailViewController).setDetailItem(lObject);
  end;
end;

method MasterViewController.refresh(aSender: id);
begin
  DataAccess.sharedInstance.beginGetData();
end;

{$REGION IUISplitViewControllerDelegate}
method MasterViewController.splitViewController(svc: UISplitViewController) shouldHideViewController(vc: UIViewController) inOrientation(orientation: UIInterfaceOrientation): Boolean;
begin
  result := false;
end;
{$ENDREGION}

end.
