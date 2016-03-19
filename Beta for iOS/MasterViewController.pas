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
    var fCollapse := true;
    method downloadsChanged(aNotification: NSNotification);
    method collapseDownloads(var aDownloads: NSArray);
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
  inherited awakeFromNib;
end;

method MasterViewController.downloadsChanged(aNotification: NSNotification);
begin
  var lSorting: NSArray := [new NSSortDescriptor withKey('date') ascending(false),
                            new NSSortDescriptor withKey('product') ascending(true)];
  
  locking DataAccess.sharedInstance do begin
    fBetaDownloads := DataAccess.sharedInstance.downloads:filteredArrayUsingPredicate(NSPredicate.predicateWithFormat('prerelease = "true"')):distinctArrayWithKey('product');
    fRTMDownloads := DataAccess.sharedInstance.downloads:filteredArrayUsingPredicate(NSPredicate.predicateWithFormat('prerelease <> "true"')):distinctArrayWithKey('product');
  end;
  
  if fCollapse then begin
    collapseDownloads(var fBetaDownloads);
    collapseDownloads(var fRTMDownloads);
  end;
  
  fBetaDownloads := fBetaDownloads:sortedArrayUsingDescriptors(lSorting);
  fRTMDownloads := fRTMDownloads:sortedArrayUsingDescriptors(lSorting);

  // Pull to Refresh is not available on iOS5.
  if self.respondsToSelector(selector(refreshControl)) then
    refreshControl:endRefreshing();

  tableView.reloadData();
end;

method MasterViewController.collapseDownloads(var aDownloads: NSArray);
begin
  var lProductsToMerge := new NSMutableDictionary();
  var lKeptProducts := new NSMutableArray();
  for each d in aDownloads do begin
    var lName := d['product'];
    var p := lName.rangeOfString(" for ").location;
    if p ≠ NSNotFound then begin
      lName := lName.substringToIndex(p);

      var lExisting := lProductsToMerge[lName];
      if not assigned(lExisting) then begin
        lExisting := new NSMutableArray();
        lProductsToMerge[lName] := lExisting;
      end;
      lExisting.addObject(d);
        
    end
    else begin
      lKeptProducts.addObject(d);
    end;
  end;
  
  for each k in lProductsToMerge.allKeys do begin
    var lFirst: NSDictionary;
    for each d in lProductsToMerge[k] do begin
      if not assigned(lFirst) then
        lFirst := d;
        
      if String(d['version']) ≠ String(lFirst['version']) then begin
        lFirst := nil;
        break;
      end;
       
    end;
    if assigned(lFirst) then begin
      var lCopy := lFirst.mutableCopy();
      lCopy['product'] := k;
      lKeptProducts.addObject(lCopy);
    end
    else begin
      lKeptProducts.addObjectsFromArray(lProductsToMerge[k]);
    end;
  end;
  
  aDownloads := lKeptProducts;
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
    result.textLabel.textColor := UIColor.lightGrayColor;
    result.detailTextLabel.textColor := UIColor.lightGrayColor;
    result.imageView.alpha := 0.5;
  end
  else begin
    result.textLabel.textColor := UIColor.blackColor;
    result.detailTextLabel.textColor := UIColor.blackColor;
    result.imageView.alpha := 1.0;
  end;

  result.imageView.image := ImageManager.getImage(lDownload['logo']) callback( (aImage: UIImage) -> begin
    tableView.reloadRowsAtIndexPaths(NSArray.arrayWithObject(indexPath)) withRowAnimation(UITableViewRowAnimation.UITableViewRowAnimationNone);
    //tableView.reloadRowsAtIndexPaths([indexPath]) withRowAnimation(UITableViewRowAnimation.UITableViewRowAnimationNone);
  end);
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
