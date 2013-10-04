namespace Beta;

interface

uses
  Foundation,
  UIKit;

type
  [IBObject]
  DetailViewController = public class (UIViewController)
  private
    fDetailItem: id;
    fWebViewController: WebViewController;
    method setDetailItem(newDetailItem: id);
    method configureView;
  protected
  public
    property detailItem: id read fDetailItem write setDetailItem;

    [IBOutlet] property detailDescriptionLabel: weak UILabel;
    [IBOutlet] property masterPopoverController: UIPopoverController;

    method viewDidLoad; override;
    method didReceiveMemoryWarning; override;

    method showChangeLog(aHtml: String);
    method hideChangeLog;
  end;

implementation

method DetailViewController.viewDidLoad;
begin
  inherited.viewDidLoad;

  // Do any additional setup after loading the view, typically from a nib.
  configureView();
end;

method DetailViewController.setDetailItem(newDetailItem: id);
begin
  if fDetailItem ≠ newDetailItem then begin
    fDetailItem := newDetailItem;
    configureView();
  end;

  if assigned(masterPopoverController) then
    masterPopoverController.dismissPopoverAnimated(true);
end;

method DetailViewController.configureView;
begin
  // Update the user interface for the detail item.

  if assigned(detailItem) then
    //detailDescriptionLabel.text := detailItem.description; //bug: why isn't detailDescriptionLabel getting connected from storyboard?
end;

method DetailViewController.didReceiveMemoryWarning;
begin
  inherited.didReceiveMemoryWarning;
  // Dispose of any resources that can be recreated.
end;

method DetailViewController.showChangeLog(aHtml: String);
begin
  if not assigned(fWebViewController) then begin

    var f := view.bounds;
    f.size.height := f.size.height - 64;
    f.origin.y := 64;

    fWebViewController := new WebViewController withFrame(f) andHtml(aHtml);
    fWebViewController.view.frame := f;
    fWebViewController.view.autoresizingMask := UIViewAutoresizing.UIViewAutoresizingFlexibleHeight or UIViewAutoresizing.UIViewAutoresizingFlexibleWidth;
    view.autoresizingMask := UIViewAutoresizing.UIViewAutoresizingFlexibleHeight or UIViewAutoresizing.UIViewAutoresizingFlexibleWidth;
    view.autoresizesSubviews := true;
    view.addSubview(fWebViewController.view);

  end
  else begin

    fWebViewController.loadHtml(aHtml);

  end;

end;

method DetailViewController.hideChangeLog;
begin
  if assigned(fWebViewController) then begin
    fWebViewController.view.removeFromSuperview();
    fWebViewController := nil;
  end;
end;

end.
