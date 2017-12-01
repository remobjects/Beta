namespace Beta;

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

end.
