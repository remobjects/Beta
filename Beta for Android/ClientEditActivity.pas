namespace com.remobjects.beta;

interface

uses
  java.util,
  android.app,
  android.content,
  android.os,
  android.support.v4.app,
  android.util,
  android.view,
  android.widget,
  com.remobjects.dataabstract.data,
  com.remobjects.dataabstract.util;

type
  ClientEditActivity = public class(Activity)
  public
    class CLIENT_ROWID: String := '_id'; readonly;
    class ACTIVITY_ACTION: String := 'action'; readonly;
    class ACTIVITY_ACTION_CREATE: Integer := RESULT_FIRST_USER +1; readonly;
    class ACTIVITY_ACTION_EDIT: Integer := RESULT_FIRST_USER + 2; readonly;
  private
    fAction: Integer := - 1;
    fRowId: nullable Long;
    fDataAccess: DataAccess;
    fRow: DataRow;
    etName, etPhone: EditText;
    etAddress: EditText;
    etDiscount: EditText;
    etInfo: EditText;

    method populateFields;
    method saveState;
    method getStringValueFromCell(aColumnName: String): String;    
    method getStringValueFromCell(aColumnName: String; aDefaultValue: String): String;
    method setStringValueToCell(aColumnName: String; aValue: String);

  public
    method onCreate(aSavedInstanceState: Bundle); override;
    method btConfirmClick(view: View);
    method onCreateOptionsMenu(aMenu: Menu): Boolean; override;
    method onMenuItemSelected(featureId: Integer; item: MenuItem): Boolean; override;
  end;

implementation


method ClientEditActivity.onCreate(aSavedInstanceState: Bundle);
begin
  inherited onCreate(aSavedInstanceState);

  setContentView(R.layout.activity_edit);

  fDataAccess := DataAccess.getInstance;

  var lSubTitleId: Integer;

  var extras: Bundle := self.Intent.Extras;
  fAction := extras.getInt(ACTIVITY_ACTION, - 1);

  if ((fAction <> ACTIVITY_ACTION_CREATE) and (fAction <> ACTIVITY_ACTION_EDIT)) then   begin
    Toast.makeText(self, java.lang.String.format('wrong activity action: %s', fAction), Toast.LENGTH_LONG).show();
    setResult(RESULT_CANCELED);
    exit;
  end
  else
    lSubTitleId := (if (fAction = ACTIVITY_ACTION_CREATE) then R.string.activity_subtitle_edit_add else R.string.activity_subtitle_edit_update);

  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) then begin
    self.ActionBar.DisplayHomeAsUpEnabled := true;
    self.ActionBar.setSubtitle(lSubTitleId);
  end
  else
    self.Title := java.lang.String.format('%s: %s', self.String[R.string.activity_title], self.String[lSubTitleId]);


  fRowId := iif(assigned(aSavedInstanceState), nullable Long(aSavedInstanceState.getSerializable(CLIENT_ROWID)), nil);
  if  (fRowId = nil)  then
    fRowId := iif(assigned(extras), Long.valueOf(extras.getLong(CLIENT_ROWID)), nil);

  etName := EditText(findViewById(R.id.edit_et_name));
  etPhone := EditText(findViewById(R.id.edit_et_phone));
  etAddress := EditText(findViewById(R.id.edit_et_address));
  etDiscount := EditText(findViewById(R.id.edit_et_discount));
  etInfo := EditText(findViewById(R.id.edit_et_additionalinfo));
  populateFields;
end;

method ClientEditActivity.onCreateOptionsMenu(aMenu: Menu): Boolean;
begin
  MenuInflater.inflate(R.menu.edit, aMenu);
  exit  (true);
end;


method ClientEditActivity.onMenuItemSelected(featureId: Integer; item: MenuItem): Boolean;
begin
  case (item.ItemId) of
    android.R.id.home: begin
        NavUtils.navigateUpTo(self, new Intent(self, typeOf(MainActivity)));
        exit  (true);
      end;
    R.id.menu_settings: begin
        self.startActivity(new Intent(self, typeOf(SettingsActivity)));
        exit  (true);
      end
    else
      exit inherited onMenuItemSelected(featureId, item);
  end
end;

method ClientEditActivity.populateFields;
begin
  case (fAction) of
    ACTIVITY_ACTION_EDIT: begin
    try
      fRow := fDataAccess.data.viewClients.Row[fRowId.intValue()];
    except
      on  ex: Exception  do  begin
        Log.e(self.Class.SimpleName, ex.Message);
      end
    end;
    etName.setText(getStringValueFromCell('ClientName'));
    etPhone.setText(getStringValueFromCell('ContactPhone'));
    etAddress.setText(getStringValueFromCell('ContactAddress'));
    etDiscount.setText(getStringValueFromCell('ClientDiscount'));
    etInfo.setText(getStringValueFromCell('AdditionalInfo'));

    end;
    ACTIVITY_ACTION_CREATE:  begin
      var lData: array of Object := [(('{' + UUID.randomUUID().toString()) + '}'),
                                     '<new client name here>', nil, nil, nil, 0.0];
      fRow := fDataAccess.data.tableClients.loadDataRow(lData);
    end;
  end;

  etName.setText(getStringValueFromCell('ClientName'));
  etPhone.setText(getStringValueFromCell('ContactPhone', nil));
  etAddress.setText(getStringValueFromCell('ContactAddress', nil));
  etDiscount.setText(getStringValueFromCell('ClientDiscount'));
  etInfo.setText(getStringValueFromCell('AdditionalInfo', nil));

end;


method ClientEditActivity.saveState;
begin
  setStringValueToCell('ClientName', etName.getText().toString());
  setStringValueToCell('ContactPhone', etPhone.getText().toString());
  setStringValueToCell('ContactAddress', etAddress.getText().toString());
  setStringValueToCell('ClientDiscount', etDiscount.getText().toString());
  setStringValueToCell('AdditionalInfo', etInfo.getText().toString())
end;

method ClientEditActivity.getStringValueFromCell(aColumnName: String): String;
begin
  exit getStringValueFromCell(aColumnName, '')
end;

method ClientEditActivity.getStringValueFromCell(aColumnName: String; aDefaultValue: String): String;
begin
  var lValue: Object := fRow.Field[aColumnName];
  exit  (iif(assigned(lValue), lValue.toString, aDefaultValue));
end;

method ClientEditActivity.setStringValueToCell(aColumnName: String; aValue: String);
begin
  var lType: &Class;
  try
    lType := fDataAccess.data.tableClients.Columns.Column[aColumnName].DataType;
  except
    on ex: Exception do  begin
      Log.wtf(self.Class.SimpleName, ex.Message + ' Stack: ' + ex.StackTrace);
      lType := typeOf(Object);
    end
  end;
  var lOriginalValue: Object := fRow.Field[aColumnName];

  if  (lType = typeOf(String))  then  begin
    if  (not StringUtils.isNullOrEmpty(java.lang.String(lOriginalValue)) or (not StringUtils.isNullOrEmpty(aValue)))  then  begin
      fRow.Field[aColumnName] := aValue;
    end;
    exit;
  end;
  if (lType = typeOf(java.lang.Double)) then begin
    fRow.Field[aColumnName] := java.lang.Double.valueOf(aValue);
    exit;
  end;
  if (lType = typeOf(java.lang.Float)) then begin
    fRow.Field[aColumnName] := java.lang.Float.valueOf(aValue);
    exit;
  end
end;

method ClientEditActivity.btConfirmClick(view: View);
begin
  saveState();
  self.setResult(RESULT_OK);
  finish();
end;

end.
