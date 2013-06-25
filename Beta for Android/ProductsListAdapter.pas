namespace com.remobjects.everwood.beta;
interface
uses
  java.util,
  android.content,
  android.graphics,
  android.graphics.drawable,
  android.util,
  android.view,
  android.widget;

type
  ProductsListAdapter = public class(BaseAdapter)
  private
    const TAG = "ProductsListAdapter";
    var fContext: Context;
    var fInflater: LayoutInflater;
    var fProductDateFormat: java.text.DateFormat := new java.text.SimpleDateFormat("EEE, d MMM yyyy"{"MM/dd/yyyy"});
    var fPrettyFormat: org.ocpsoft.prettytime.PrettyTime;

    var fData: DataAccess := DataAccess.getInstance();
  public
    constructor(aContext: Context);
    method getCount(): Integer;
    method getItem(i: Integer): Object;
    method getItemId(i: Integer): Int64;
    method getRecordId(i: Integer): Object;
    method getView(position: Integer; convertView: View; parent: ViewGroup): View;
    method getValueAsString(aMap: java.util.Map<String, Object>; aKey, defaultValue: String): String;
    method getItemViewType(aPos: Integer): Integer; override;
    property ViewTypeCount: Integer read 2; override;
    method notifyDataSetChanged; override;
  end;

  Holder nested in ProductsListAdapter = public class
  public
    var headerText: TextView;
    var productName: TextView;
    var addInfo: TextView;
    var logo: ImageView;
    var badgeNew: ImageView;
  end;

implementation

constructor ProductsListAdapter(aContext: Context);
begin
  fContext := aContext;
  fInflater := LayoutInflater(fContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE));

  fPrettyFormat := new org.ocpsoft.prettytime.PrettyTime(Locale.ENGLISH);
end;

method ProductsListAdapter.getCount(): Integer;
begin
  exit fData.Products.size;
end;

method ProductsListAdapter.getItem(i: Integer): Object;
begin
  exit fData.Products.get(i);
end;

method ProductsListAdapter.getItemId(i: Integer): Int64;
begin
  exit  (Int64(i));
end;

method ProductsListAdapter.getRecordId(i: Integer): Object;
begin
  exit  (i);
end;

method ProductsListAdapter.getView(position: Integer; convertView: View; parent: ViewGroup): View;
begin
  var lProducts := fData.Products;
  var lProduct := lProducts.get(position);

  var lIsHeader: Boolean := false;
  var lHeaderText: String;

  var lView: View := convertView;    
  var lHolder: ProductsListAdapter.Holder;

  if (lProduct.containsKey('header')) then begin
    lIsHeader := true;
    lHeaderText := String(lProduct.get('header'));
  end;
      
  if (lView = nil) then begin
    lHolder := new ProductsListAdapter.Holder();
    if (lIsHeader) then begin
      lView := fInflater.inflate(R.layout.product_list_header, parent, false);
      lHolder.headerText := TextView(lView.findViewById(R.id.product_list_header_text));
    end
    else begin
      lView := fInflater.inflate(R.layout.product_list_item, parent, false);
      lHolder.productName := TextView(lView.findViewById(R.id.product_list_name));
      lHolder.addInfo := TextView(lView.findViewById(R.id.product_list_add_info));
      lHolder.logo := ImageView(lView.findViewById(R.id.product_list_logo));
      lHolder.badgeNew := ImageView(lView.findViewById(R.id.product_list_badge));
    end;
    lView.Tag := lHolder;
  end;

  if (lHolder = nil) and (lView <> nil) then begin
    var lTag := lView.Tag;
    if (lTag is ProductsListAdapter.Holder) then
      lHolder := ProductsListAdapter.Holder(lTag);
  end;

  if (lHolder <> nil) then
    if (not lIsHeader) then begin  
      lHolder.productName.Text := getValueAsString(lProduct, 'product', '!undefined!');

      var lPublishDate: Date := Date(lProduct.get('date'));
      var lPublishCal := Calendar.Instance;
      lPublishCal.Time := lPublishDate;

      //var lPrDate := fProductDateFormat.format(lPublishDate);
      var lPrDate := if (android.text.format.DateUtils.isToday(lPublishDate.Time)) then "today" else fPrettyFormat.format(lPublishDate);

      lHolder.addInfo.Text := java.lang.String.format("%s (%s)", getValueAsString(lProduct, 'version', '!undefined!'), lPrDate);
  
      var lImgUrl := String.format('http://www.remobjects.com/images/product-logos/%s-64.png', lProduct['logo']);

      var now := Calendar.Instance;
      var lVerge := Calendar.Instance;
      lVerge.add(Calendar.DAY_OF_YEAR, -3);
      
      if (lPublishCal.before(lVerge)) then
        lHolder.badgeNew.Visibility := View.GONE
      else
        lHolder.badgeNew.Visibility := View.VISIBLE;
  
      var lPreviousUrl := String(lHolder.logo.Tag);
      if (not lImgUrl.equals(lPreviousUrl)) then begin
        lHolder.logo.ImageResource := R.drawable.empty_product_logo;
        var lBitmap := fData.ImageLoader.load(lHolder.logo, lImgUrl, new interface com.webimageloader.ImageLoader.Listener<ImageView>(
          onSuccess := method(iv: ImageView; bm: Bitmap) begin            
            var lOld := iv.Drawable;
            if (lOld = nil) then begin
              lOld := new ColorDrawable(android.R.color.transparent);
            end;
            var d := new TransitionDrawable([lOld, new BitmapDrawable(self.fContext.Resources, bm)]);
            iv.ImageDrawable := d;
            d.startTransition(50);

            iv.Tag := lImgUrl;
          end,
          onError := method(iv: ImageView; thr: Throwable) begin
            Log.d(TAG, "Error loading bitmap " + lImgUrl, thr);
            iv.ImageResource := R.drawable.empty_product_logo;
            iv.Tag := nil;
          end
        ));
        if (lBitmap <> nil) then begin
          lHolder.logo.ImageBitmap := lBitmap;
          lHolder.logo.Tag := lImgUrl;
        end;
      end;

      //new com.webimageloader.ext.ImageHelper(self.fContext, fData.ImageLoader)
          //.setFadeIn(true)
          //.setLoadingResource(R.drawable.empty_product_logo)
          //.load(lHolder.logo, lImgUrl);
    end
    else
      lHolder.headerText.Text := lHeaderText;  

  exit  (lView);
end;

method ProductsListAdapter.getValueAsString(aMap: java.util.Map<String, Object>; aKey, defaultValue: String): String;
begin
    if (not aMap.containsKey(aKey)) then
      exit (defaultValue);

    var val: Object := aMap.get(aKey);
    exit if (val = nil) then defaultValue else val.toString();  
end;

method ProductsListAdapter.getItemViewType(aPos: Integer): Integer;
begin
  
  var lProducts := fData.Products;
  var lProduct := lProducts.get(aPos);
  if (lProduct.containsKey('header')) then begin
    exit (0)
  end
  else
    exit (1);
end;

method ProductsListAdapter.notifyDataSetChanged;
begin
  fPrettyFormat.Reference := new Date();
  inherited.notifyDataSetChanged();
end;

end.
