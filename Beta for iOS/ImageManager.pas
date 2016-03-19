namespace Beta;

interface

type
  ImageManager = public static class
  private
    var fIconCache: NSMutableDictionary<String, UIImage> := new NSMutableDictionary<String, UIImage>;
    var fIconQueue: dispatch_queue_t := dispatch_queue_create('com.remobjects.everewood.beta.iconqueue', DISPATCH_QUEUE_SERIAL);
  protected
  public
    method getImage(aLogoName: String) callback(aCallback: block (aImage: UIImage)): UIImage;
  end;

implementation

method ImageManager.getImage(aLogoName: String) callback(aCallback: block(aImage: UIImage)): UIImage;
begin
  //
  // Check in local cache
  //
  locking self do result := fIconCache[aLogoName];
  if assigned(result) then begin
    //NSLog('Image %@ found in cache', aLogoName);
    exit;
  end;
  
  //
  // Check on disk
  //
  var imageFilename := DataAccess.sharedInstance.cachesFolder.stringByAppendingPathComponent(aLogoName+'-64-flat.png');
  if NSFileManager.defaultManager.fileExistsAtPath(imageFilename) then begin
    //NSLog('Image %@ found on disk', aLogoName);
    var lData := new NSData withContentsOfFile(imageFilename);
    result := UIImage.imageWithData(lData) scale(2.0); // all images are @2x
    locking self do fIconCache[aLogoName] := result;
    exit;
  end;
    
  //
  // else return empty and delay-download.
  //
  var lEmptyImage := UIImage.imageNamed(if not DataAccess.isIOS7OrLater then 'EmptyAppLogo' else 'EmptyAppLogo7');
  result := lEmptyImage;
  
  dispatch_async(fIconQueue, method begin

    var lImage2: UIImage;
    
    locking self do lImage2 := fIconCache[aLogoName];
    if not assigned(lImage2) then begin

      var lUrl := new NSURL withString('https://secure.remobjects.com/images/product-logos/'+imageFilename.lastPathComponent);
      //NSLog('downloading %@', lUrl);
      var lData := new NSData withContentsOfURL(lUrl);
      //NSLog('downloading done');
      
      if assigned(lData) then begin
        lData.writeToFile(imageFilename) atomically(true);
        lImage2 := UIImage.imageWithData(lData) scale(2.0); // all images are @2x
        locking self do fIconCache[aLogoName] := lImage2;
      end
      else begin
        NSLog('Can''t download image %@', aLogoName);
        locking self do fIconCache[aLogoName] := lEmptyImage; // use place holder image in cache to avoid repeat tries
      end;
    end;
    
    if assigned(lImage2) then
      dispatch_async(dispatch_get_main_queue(), method begin
        aCallback(lImage2);
      end);
    
  end); 
end;

end.
