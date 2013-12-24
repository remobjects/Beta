namespace BetaServer;

interface

uses
  System.IO, 
  BetaServer.Properties;

type
  Log = public class
  private
    class var fCount: Int32 := 0;
    class var fFilename: String;
    const MAX_LOGFILE_SIZE = 1*1024*1024; { 1MB }
  protected
    class constructor;
  public
    class method Log(aMessage: String); locked;
    class operator Explicit(aString: String): Log;
  end;
  
implementation

class constructor Log;
begin
  if length(Settings.Default.LogFolder) > 0 then begin
    Directory.CreateDirectory(Settings.Default.LogFolder);
    fFilename := Path.Combine(Settings.Default.LogFolder, Path.ChangeExtension(Path.GetFileName(typeOf(self).Assembly.Location), '.'+System.Environment.MachineName+'.log'));
  end
  else begin
    fFilename := Path.ChangeExtension(typeOf(self).Assembly.Location, '.'+System.Environment.MachineName+'.log')
  end;
end;

class method Log.Log(aMessage: String);
begin
  inc(fCount);
  if (fCount > 100) and (new FileInfo(fFilename).Length > MAX_LOGFILE_SIZE) then begin
    var lTemp := Path.ChangeExtension(fFilename, '.previous.log');
    if File.Exists(lTemp) then File.Delete(lTemp);
    File.Move(fFilename, lTemp);
    fCount := 0;
  end;

  File.AppendAllText(fFilename, DateTime.Now.ToString('yyyy-MM-dd HH:mm:ss')+' '+aMessage+#13#10);
  Console.WriteLine(aMessage);
end;

class operator Log.Explicit(aString: String): Log;
begin
  Log(aString);
end;

end.