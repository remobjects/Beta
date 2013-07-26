namespace Beta;

interface

uses
  UIKit;

type
  [IBObject]
  WebViewController = public class(UIViewController)
  private
    fWebView: UIWebView;
    fHtml: String;
  public
    method initWithHtml(aHtml: String): id;

    method viewDidLoad; override;
    method didReceiveMemoryWarning; override;

  end;

implementation

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
 
  fWebView := new UIWebView withFrame(view.bounds);
  fWebView.autoresizingMask := UIViewAutoresizing.UIViewAutoresizingFlexibleHeight;
  view.addSubview(fWebView);

  var lCss := NSString.stringWithContentsOfFile(NSBundle.mainBundle.pathForResource('ChangeLogs') ofType('css')); 
  fWebView.loadHTMLString('<style>'+lCss+'</style>'+fHtml) baseURL(nil); 
end;

method WebViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning;

  // Dispose of any resources that can be recreated.
end;

end.
