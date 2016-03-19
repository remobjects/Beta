namespace Beta;

interface

uses
  Foundation;

extension method NSArray.distinctArrayWithKey(aKey: String): NSArray;
extension method NSDate.relativeDateString: String;

implementation

extension method NSArray.distinctArrayWithKey(aKey: String): NSArray;
begin
  var keyValues := new NSMutableSet;
  result := new NSMutableArray;
  for each item in self do begin
    var keyForItem := item.valueForKey(aKey);
    if assigned(keyForItem) and not keyValues.containsObject(keyForItem) then begin
     NSMutableArray(result).addObject(item);
     keyValues.addObject(keyForItem);
    end;
  end;
end;

extension method NSDate.relativeDateString: String;
const SECOND = 1;
const MINUTE = 60 * SECOND;
const HOUR = 60 * MINUTE;
const DAY = 24 * HOUR;
const MONTH = 30 * DAY;
begin

  var lNow := NSDate.date;
  var lDelta := lNow.timeIntervalSinceDate(self);

  var lCalendar := NSCalendar.currentCalendar;
  var lUnits := (NSCalendarUnit.NSYearCalendarUnit or 
                 NSCalendarUnit.NSMonthCalendarUnit or 
                 NSCalendarUnit.NSDayCalendarUnit or 
                 NSCalendarUnit.NSHourCalendarUnit or 
                 NSCalendarUnit.NSMinuteCalendarUnit or 
                 NSCalendarUnit.NSSecondCalendarUnit);
  var lComponents := lCalendar.components(lUnits) fromDate(self) toDate(lNow) options(0);

  {if (lDelta < 0) then
    result := '!n the future!'
  else if (lDelta < 1 * MINUTE) then
    result := if (lComponents.second = 1) then 'One second ago' else NSString.stringWithFormat('%d seconds ago', lComponents.second) as NSString
  else if (lDelta < 2 * MINUTE) then
    result := 'a minute ago'
  else if (lDelta < 45 * MINUTE) then
    result := NSString.stringWithFormat('%d minutes ago', lComponents.minute)
  else if (lDelta < 90 * MINUTE) then
    result := 'an hour ago'
  else if (lDelta < 24 * HOUR) then
    result := NSString.stringWithFormat('%d hours ago', lComponents.hour)}
  if (lDelta < 24 * HOUR) then
    result := NSString.stringWithFormat('today')
  else if (lDelta < 48 * HOUR) then
    result := 'yesterday'
  else if (lDelta < 30 * DAY) then
    result := NSString.stringWithFormat('%ld days ago', lComponents.day)
  else if (lDelta < 12 * MONTH) then
    result := if (lComponents.month <= 1) then 'one month ago' else NSString.stringWithFormat('%ld months ago', lComponents.month) as NSString
  else
    result := if (lComponents.year <= 1) then 'one year ago' else NSString.stringWithFormat('%ld years ago', lComponents.year) as NSString;

end;

end.
