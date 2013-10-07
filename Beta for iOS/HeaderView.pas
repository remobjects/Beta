namespace TwinPeaks;

interface

uses
  UIKit;

type
  HeaderView = public class(UIView)
  private
    var fCaption: String;
  public
    method initWithWidth(aWidth: CGFloat) caption(aCaption: String): id;

    method drawRect(rect: CGRect); override;

    class method headerHeight: CGFloat;

    {$HIDE NH0}
    class property Font: UIFont read if UIDevice.currentDevice.systemVersion.componentsSeparatedByString('.')[0].intValue < 7.0 then UIFont.boldSystemFontOfSize(15) else UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline);
    {$SHOW NH0}
  end;

implementation

method HeaderView.initWithWidth(aWidth: CGFloat) caption(aCaption: String): id;
begin
  var lSize := aCaption.sizeWithFont(Font);

  self := inherited initWithFrame(CGRectMake(0, 0, aWidth, lSize.height+10));
  if assigned(self) then begin

    opaque := false;
    fCaption := aCaption;

  end;
  result := self;
end;

method HeaderView.drawRect(rect: CGRect);
begin
  var lSize := fCaption.sizeWithFont(Font);
  var f := frame;

  var lGray := 0.0;
  UIColor.colorWithRed(lGray) green(lGray) blue(lGray) alpha(0.65).setFill();
  UIRectFill(bounds);

  UIColor.whiteColor.set();
  fCaption.drawAtPoint(CGRectMake( (f.size.width-lSize.width)/2, (f.size.height-lSize.height)/2, 0, 0).origin) withFont(Font);
end;

class method HeaderView.headerHeight: CGFloat;
begin
  result := 'Xq'.sizeWithFont(Font).height+10;
end;

end.
