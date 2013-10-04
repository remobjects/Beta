namespace Beta;

interface

uses
  UIKit;

type
  [IBObject]
  WebViewController = public class(UIViewController)
  private
    fFrame: CGRect;

    fWebView: UIWebView;
    fHtml: String;
    fCss: String;
  public
    method initWithFrame(aFrame: CGRect) andHtml(aHtml: String): id;
    method initWithHtml(aHtml: String): id;

    method viewDidLoad; override;
    method didReceiveMemoryWarning; override;

    method loadHtml(aHtml: String);

  end;

implementation

method WebViewController.initWithFrame(aFrame: CGRect) andHtml(aHtml: String): id;
begin
  self := inherited init;
  if assigned(self) then begin

    fFrame := aFrame;
    fHtml := aHtml;

  end;
  result := self;
end;

method WebViewController.initWithHtml(aHtml: String): id;
begin
  self := inherited init;
  if assigned(self) then begin

    fHtml := aHtml;

  end;
  result := self;
end;

method WebViewController.viewDidLoad;
begin
  inherited viewDidLoad;

  title := 'Change Log';
 
  if fFrame.size.width > 0 then 
    view.frame := fFrame;

  fWebView := new UIWebView withFrame(view.bounds);
  fWebView.autoresizingMask := UIViewAutoresizing.UIViewAutoresizingFlexibleHeight or UIViewAutoresizing.UIViewAutoresizingFlexibleWidth;
  view.autoresizesSubviews := true;
  view.addSubview(fWebView);

  fCss := NSString.stringWithContentsOfFile(NSBundle.mainBundle.pathForResource('ChangeLogs') ofType('css')) encoding(NSStringEncoding.NSUTF8StringEncoding) error(nil); 
  loadHtml(fHtml); 
end;

method WebViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning;

  // Dispose of any resources that can be recreated.
end;

method WebViewController.loadHtml(aHtml: String);
begin
  NSLog('%f/%f', view.bounds.size.width, view.bounds.size.height);
  fWebView.frame := view.bounds;
  fWebView.loadHTMLString('<style>'+fCss+'</style>'+aHtml) baseURL(nil); 
end;

end.
