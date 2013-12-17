namespace Beta.Helpers;

interface

uses
  System.Windows,
  Microsoft.Phone.Controls;

type
  WebBrowserHelper = public static class
  public
    class var HtmlProperty: DependencyProperty := 
      DependencyProperty.RegisterAttached('Html', 
                                          typeOf(System.String), 
                                          typeOf(WebBrowserHelper), 
                                          new PropertyMetadata(@OnHtmlChanged)); readonly;

    class method GetHtml(aDependencyObject: DependencyObject): System.String;
    class method SetHtml(aDependencyObject: DependencyObject; value: System.String);

  private
    class method OnHtmlChanged(d: DependencyObject; e: DependencyPropertyChangedEventArgs);
  end;

implementation

class method WebBrowserHelper.GetHtml(aDependencyObject: DependencyObject): System.String;
begin
  exit System.String(aDependencyObject.GetValue(HtmlProperty))
end;

class method WebBrowserHelper.SetHtml(aDependencyObject: DependencyObject; value: System.String);
begin
  aDependencyObject.SetValue(HtmlProperty, value)
end;

class method WebBrowserHelper.OnHtmlChanged(d: DependencyObject; e: DependencyPropertyChangedEventArgs);
begin
  var browser := WebBrowser(d);

  if browser = nil then    
    exit;

  var html := e.NewValue.ToString();
  
  // Making webbrowser invisible, until content is loaded,
  // to avoid blinking of white background
  browser.Opacity := 0;
  browser.NavigateToString(html);
end;

end.
