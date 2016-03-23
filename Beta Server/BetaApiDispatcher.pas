namespace BetaServer;

interface

uses
  System.Collections.Generic,
  System.IO,
  System.Linq,
  System.Text,
  RemObjects.InternetPack.Http,
  RemObjects.SDK,
  RemObjects.SDK.Push,
  RemObjects.SDK.Server;

type
  BetaApiDispatcher = public class(ExtendedHttpDispatcher)
  private
  protected
  public
    method Process(request: RemObjects.SDK.IHttpRequest; response: IHttpResponse; requestData, responseData: Stream); override;
  end;

implementation

method BetaApiDispatcher.Process(request: IHttpRequest; response: IHttpResponse; requestData: Stream; responseData: Stream);
begin
  var lResponseMessage: String;
  try
  
    writeLn(request.TargetUrl+"?"+request.QueryString);
    case request.TargetUrl.ToLower() of
      "/api/registerdevice":begin
      
          var lType := request.GetQueryString("type");
          var lUserName := request.GetQueryString("username");
          var lToken := request.GetQueryString("token");
          
          if (length(lType) > 0) and (length(lUserName) > 0) and (length(lToken) = 64) then begin
  
            case lType.ToLower() of
              "ios": begin
                  var lTokenBinary := RemObjects.SDK.Push.APS.APSConnect.StringToByteArray(lToken);
                  var lDevice := new ApplePushDeviceInfo(Token := lTokenBinary, 
                                                          SubType := 'iOS',
                                                          UserReference := lUserName,
                                                          ClientInfo := nil, 
                                                          ServerInfo := nil,
                                                          LastSeen := DateTime.Now);
                  if not PushManager.DeviceManager.HasDevice(lDevice.ID) then begin
                    PushManager.AddDevice(lDevice);
                    lResponseMessage := "Beta API Server. ADDED.";
                    writeLn("Added "+lToken+" for "+lUserName);
                  end
                  else begin
                    lResponseMessage := "Beta API Server. KNOWN.";
                    writeLn("Already known: "+lToken+" for "+lUserName);
                  end;
                  exit;
                end;
              else begin
                lResponseMessage := "Beta API Server. Unknown Device Type.";
                exit;
              end;
            end;
          end;
          
          lResponseMessage := "Beta API Server. Invalid parameters.";
          exit;
        end;
      
    end;
    lResponseMessage := "Beta API Server. Thank you.";
    
  except
    on e: Exception do
      lResponseMessage := "Exception: "+e.ToString;
  finally
    if length(lResponseMessage) = 0 then
      lResponseMessage := "No Response";
      
    //lResponseMessage := lResponseMessage.Replace('\','\\').Replace('"', '\"').Replace('{', "(*").Replace('}', "*)").Replace(#10, '\n');
    //lResponseMessage := '{ "text": "'+lResponseMessage+'" }';
    //Log(lResponseMessage);
    var w := new StreamWriter(responseData, Encoding.UTF8);// do begin // dont use using
    w.Write(lResponseMessage);
    w.Flush();
    response.ContentType := 'text/plain';
  end;

end;

end.
