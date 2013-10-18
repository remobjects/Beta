namespace Beta.Helpers;

interface
  extension method DateTime.RelativeDateString: String;

implementation

extension method DateTime.RelativeDateString: String;
  const SECOND: Integer = 1;
  const MINUTE: Integer = 60 * SECOND;
  const HOUR: Integer = 60 * MINUTE;
  const DAY: Integer = 24 * HOUR;
  const MONTH: Integer = 30 * DAY;
begin

  var ts: TimeSpan := new TimeSpan(DateTime.Now.Ticks - self.Ticks);
  var seconds: System.Double := ts.TotalSeconds;

  // Less than one minute
  if seconds < 1 * MINUTE then  
    exit iif(ts.Seconds = 1, 'one second ago', ts.Seconds + ' seconds ago');

  if seconds < 60 * MINUTE then  
    exit ts.Minutes + ' minutes ago';

  if seconds < 120 * MINUTE then  
    exit 'an hour ago';

  if seconds < 24 * HOUR then  
    exit ts.Hours + ' hours ago';

  if seconds < 48 * HOUR then  
    exit 'yesterday';

  if seconds < 30 * DAY then  
    exit ts.Days + ' days ago';

  if seconds < 12 * MONTH then begin
    var months: System.Int32 := Convert.ToInt32(Math.Floor(System.Double(ts.Days) / 30));
    exit iif(months <= 1, 'one month ago', months + ' months ago')
  end;

  var years: System.Int32 := Convert.ToInt32(Math.Floor(System.Double(ts.Days) / 365));
  exit iif(years <= 1, 'one year ago', years + ' years ago')
end;

end.
