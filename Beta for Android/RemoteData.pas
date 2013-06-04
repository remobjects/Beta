namespace com.remobjects.beta;

interface

uses
  com.remobjects.sdk,
  com.remobjects.dataabstract,
  {$IFDEF SWING}
  com.remobjects.dataabstract.swing,
  {$ENDIF}
  com.remobjects.dataabstract.data;

type
  RemoteData = public class
  public
    var tableClients: DataTable;
    var viewClients: DataTableView;

  public
    constructor();
    method initialize();   

  end;

implementation


constructor RemoteData();
begin
  initialize();
end;

method RemoteData.initialize();
begin
  self.tableClients := new DataTable();
  self.tableClients.TableName := 'Clients';

  self.viewClients := new DataTableView(self.tableClients);
  self.tableClients.addTableChangedListener(self.viewClients);
end;


end.