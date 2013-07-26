namespace Beta;

interface

uses
  Foundation,
  TwinPeaks,
  UIKit;

type
  [IBObject]
  MasterViewController = public class (UITableViewController, IUITableViewDelegate)
  private
    var fBetaDownloads: NSArray;
    var fRTMDownloads: NSArray;
    var fIconCache: NSMutableDictionary<String, UIImage> := new NSMutableDictionary<String, UIImage>;
    method downloadsChanged(aNotification: NSNotification);
  protected
  public
    property detailViewController: DetailViewController;

    method awakeFromNib; override;
    method viewDidLoad; override;
    method didReceiveMemoryWarning; override;
    method prepareForSegue(segue: UIStoryboardSegue) sender(sender: id); override;

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

    method refresh(aSender: id);
  end;

implementation

method MasterViewController.awakeFromNib;
begin
  if UIDevice.currentDevice.userInterfaceIdiom = UIUserInterfaceIdiom.UIUserInterfaceIdiomPad then begin
    clearsSelectionOnViewWillAppear := true;
    contentSizeForViewInPopover := CGSizeMake(320.0, 600.0);
  end;
  inherited awakeFromNib;
end;

method MasterViewController.downloadsChanged(aNotification: NSNotification);
begin
  var lSorting: NSArray := [new NSSortDescriptor withKey('date') ascending(false),
                            new NSSortDescriptor withKey('product') ascending(true)];
  
  locking DataAccess.sharedInstance do begin
    fBetaDownloads := DataAccess.sharedInstance.downloads.filteredArrayUsingPredicate(NSPredicate.predicateWithFormat('prerelease = "true"')).distinctArrayWithKey('product')
                                                         .sortedArrayUsingDescriptors(lSorting);
    fRTMDownloads := DataAccess.sharedInstance.downloads.filteredArrayUsingPredicate(NSPredicate.predicateWithFormat('prerelease <> "true"')).distinctArrayWithKey('product')
                                                         .sortedArrayUsingDescriptors(lSorting);
  end;

  // Pull to Refresh is not available on iOS5.
  if self.respondsToSelector(selector(refreshControl)) then
    refreshControl:endRefreshing();

  tableView.reloadData();
end;

method MasterViewController.viewDidLoad;
begin
  inherited viewDidLoad;
 
  title := 'Betas';

  var lTintColor := UIColor.colorWithRed(0.3) green(0.3) blue(0.7) alpha(1.0);
  navigationController.navigationBar.tintColor := lTintColor;

  // Pull to Refresh is not available on iOS5.
  //if self.respondsToSelector(selector(refreshControl)) then begin
  if assigned(typeOf(UIRefreshControl)) then begin
    refreshControl := UIRefreshControl.alloc.init;
    //62469: Nougat: No member "appearance" on type "Class" and "id"
    refreshControl .tintColor := lTintColor;
    refreshControl.addTarget(self) 
                   action(selector(refresh:))
                   forControlEvents(UIControlEvents.UIControlEventValueChanged);
  end;

  tableView.backgroundColor := UIColor.scrollViewTexturedBackgroundColor;
  if UIDevice.currentDevice.systemVersion.floatValue < 7.0 then
    tableView.separatorStyle := UITableViewCellSeparatorStyle.UITableViewCellSeparatorStyleNone;

  {navigationItem:leftBarButtonItem := self:editButtonItem;
  var addButton := new UIBarButtonItem withBarButtonSystemItem(UIBarButtonSystemItem.UIBarButtonSystemItemAdd)
                                           target(self)
                                           action(selector(insertNewObject:));
  navigationItem:rightBarButtonItem := addButton;}
  detailViewController := splitViewController:viewControllers:lastObject:topViewController as DetailViewController;

  DataAccess.sharedInstance.beginGetData();

  NSNotificationCenter.defaultCenter.addObserver(self) 
                                     &selector(selector(downloadsChanged:))
                                     name(DataAccess.NOTIFICATION_DOWNLOADS_CHANGED) 
                                     object(DataAccess.sharedInstance);
  downloadsChanged(nil);
end;

method MasterViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning;
  // Dispose of any resources that can be recreated.
end;

{$REGION Table view data source}

method MasterViewController.numberOfSectionsInTableView(tableView: UITableView): Integer;
begin
  result := if fRTMDownloads.count > 0 then 2 else 1;
end;

method MasterViewController.tableView(tableView: UITableView) viewForHeaderInSection(section: Integer): UIView;
begin
  var lCaption := case section of
                    0: if fBetaDownloads.count > 0 then 'Beta Downloads';
                    1: 'Release Downloads';
                  end;
  result := if assigned(lCaption) then 
              new HeaderView withWidth(tableView.frame.size.width) caption(lCaption);
end;

method MasterViewController.tableView(tableView: UITableView) heightForHeaderInSection(section: Integer): CGFloat;
begin

  result := case section of
              0: if fBetaDownloads.count > 0 then HeaderView.headerHeight else 0;
              1: HeaderView.headerHeight;
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
    result := new BaseCell withStyle(UITableViewCellStyle.UITableViewCellStyleSubtitle) reuseIdentifier('RootCell');

    if UIDevice.currentDevice.systemVersion.floatValue < 7.0 then begin
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


    var lImage := fIconCache[lLogoName];
    if assigned(lImage) then begin
      result.imageView.image := lImage;
    end
    else begin

      result.imageView.image := UIImage.imageNamed(if not DataAccess.isIOS7OrLater then 'EmptyAppLogo' else 'EmptyAppLogo7');
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), method begin

          var lImageSuffix := if not DataAccess.isIOS7OrLater then (if lIsRetina then '-64.png' else '-32.png') else '-64-flat.png';

          var lData := new NSData withContentsOfURL(new NSURL withString('http://www.remobjects.com/images/product-logos/'+lDownload['logo']+lImageSuffix));
          if assigned(lData) then begin
            var lImage2 := //if UIImage.respondsToSelector(selector(imageWithData:scale:)) then
                             UIImage.imageWithData(lData) scale(if lIsRetina then 2.0 else 1.0);
                           //else
                           //  UIImage.imageWithData(lData);
            lDownload["image"] := lImage2;
            fIconCache[lLogoName] := lImage2;
            dispatch_async(dispatch_get_main_queue(), method begin
 
                tableView.reloadRowsAtIndexPaths(NSArray.arrayWithObject(indexPath)) withRowAnimation(UITableViewRowAnimation.UITableViewRowAnimationNone);
                //tableView.reloadRowsAtIndexPaths([indexPath]) withRowAnimation(UITableViewRowAnimation.UITableViewRowAnimationNone);

              end);
          end;
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

  if assigned(lDownload['changelog']) then
    navigationController.pushViewController(new WebViewController withHtml(lDownload['changelog'])) animated(true); 

  tableView.deselectRowAtIndexPath(indexPath) animated(true); 
end;

{$ENDREGION}

method MasterViewController.prepareForSegue(segue: UIStoryboardSegue) sender(sender: id);
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

end.
