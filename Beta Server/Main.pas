namespace BetaServer;

interface

uses
  System,
  System.IO,
  RemObjects.SDK,
  RemObjects.SDK.Push,
  RemObjects.SDK.Server;

type
  Program = class
  public
    class method Main(arguments: array of String);
  end;

implementation

[STAThread]
class method Program.Main(arguments: array of String);
begin
  (new BetaServer()).Run(arguments);
end;
{
class method WWDCNotifyServerMain.Main;
var
  lServerChannel: IpHttpServerChannel;
  lMessage: Message;
begin
  Console.WriteLine('RemObjects Beta Server Server');

  lServerChannel := new RemObjects.SDK.Server.IpHttpServerChannel();
  lServerChannel.Port := 8097;
  lMessage := new RemObjects.SDK.BinMessage();

  lServerChannel.Dispatchers.Add(lMessage.DefaultDispatcherName, lMessage);
        
  lServerChannel.Open();
  try
    Console.WriteLine('Server is active, press Enter to stop.');
    Console.ReadLine();
  finally
    lServerChannel.Close();
  end;
end;}

end.
