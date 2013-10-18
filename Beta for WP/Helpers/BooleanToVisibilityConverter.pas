namespace Beta.Helpers;

interface

uses
  System,
  System.Globalization,
  System.Windows,
  System.Windows.Data;

type
  BooleanToVisibilityConverter = public sealed class(IValueConverter)
  public
    method Convert(value: Object; targetType: &Type; parameter: Object; culture: CultureInfo): Object;
    method ConvertBack(value: Object; targetType: &Type; parameter: Object; culture: CultureInfo): Object;
  end;

implementation

method BooleanToVisibilityConverter.Convert(value: Object; targetType: &Type; parameter: Object; culture: CultureInfo): Object;
begin
  var flag := false;
  
  if value is Boolean then 
    flag := System.Boolean(value)
  else 
  if (value is Nullable Boolean) then begin
    var &nullable := System.Nullable<Boolean>(value);
    flag := &nullable.GetValueOrDefault()
  end;

  if assigned(parameter) then begin
    if System.Boolean.Parse(System.String(parameter)) then
      flag := not flag;
  end;

  if flag then begin
    exit Visibility.Visible
  end
  else begin
    exit Visibility.Collapsed
  end
end;

method BooleanToVisibilityConverter.ConvertBack(value: Object; targetType: &Type; parameter: Object; culture: CultureInfo): Object;
begin
  var back := (value is Visibility) and (Visibility(value) = Visibility.Visible);
  if assigned(parameter) then begin
    if System.Boolean(parameter) then
      back := not back;
  end;
  exit back;
end;

end.
