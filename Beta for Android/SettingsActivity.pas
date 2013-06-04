  namespace com.remobjects.beta;
interface
uses
  android.app,
  android.os,
  android.preference,
  android.text,
  android.view;

type
  SettingsActivity = public class(PreferenceActivity)
  public
    class var PREFS_SERVER_URL: String := 'server_target_url'; readonly;
    class var PREFS_LOGIN_NAME: String := 'login_name'; readonly;
    class var PREFS_LOGIN_PASSWORD: String := 'login_password'; readonly;
    class var PREFS_LOGIN_TOKEN: String := 'login_token'; readonly;
  protected
    [SuppressWarnings(Value := ['deprecation'])]
    method onCreate(savedInstanceState: Bundle); override;
  public
    method onOptionsItemSelected(item: MenuItem): Boolean; override; 
    class constructor;
  private
    // A preference value change listener that updates the preference's summary to reflect its new value.
    class var sBindPreferenceSummaryToValueListener: Preference.OnPreferenceChangeListener;
    class method bindPreferenceSummaryToValue(preference: Preference; setSummary: Boolean);
  end;
  SettingsFragment nested in SettingsActivity = public class(PreferenceFragment)
  public
    method onCreate(savedInstanceState: Bundle); override;
    method onCreateView(inflater: LayoutInflater; container: ViewGroup; savedInstanceState: Bundle): View; override;
  end;

implementation

class constructor SettingsActivity;
begin
  sBindPreferenceSummaryToValueListener := new interface Preference.OnPreferenceChangeListener(
      onPreferenceChange := method (preference: Preference; value: Object): Boolean;
      begin
        if ((preference is EditTextPreference) and ((EditTextPreference(preference).EditText.InputType and (InputType.TYPE_TEXT_VARIATION_PASSWORD or InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD)) = 0)) then begin
          var stringValue := value.toString();
          preference.Summary := stringValue;
        end;
        exit  (true);
      end);
end;

method SettingsActivity.onCreate(savedInstanceState: Bundle);
begin
  inherited onCreate(savedInstanceState);
  if  (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)  then  begin
    var bar: ActionBar := self.ActionBar;
    bar.DisplayHomeAsUpEnabled :=true;
    bar.DisplayUseLogoEnabled := true;
    FragmentManager.beginTransaction().replace(android.R.id.content, new SettingsActivity.SettingsFragment()).commit();
  end
  else  begin
    addPreferencesFromResource(R.xml.settings);
    ContentView := R.layout.activity_settings;
    bindPreferenceSummaryToValue(findPreference(PREFS_SERVER_URL), true);
    bindPreferenceSummaryToValue(findPreference(PREFS_LOGIN_NAME), true);
    bindPreferenceSummaryToValue(findPreference(PREFS_LOGIN_PASSWORD), false);
  end
end;

method SettingsActivity.onOptionsItemSelected(item: MenuItem): Boolean;
begin
  if (item.ItemId = android.R.id.home) then
    finish();
  exit  (inherited.onOptionsItemSelected(item));
end;

class method SettingsActivity.bindPreferenceSummaryToValue(preference: Preference; setSummary: Boolean);
begin
  //  Set the listener to watch for value changes.
  preference.setOnPreferenceChangeListener(sBindPreferenceSummaryToValueListener);
  if setSummary then begin
    var lVal: Object := PreferenceManager.getDefaultSharedPreferences(preference.getContext()).getString(preference.getKey(), '');
    preference.setSummary(lVal.toString())
  end
end;

method SettingsActivity.SettingsFragment.onCreate(savedInstanceState: Bundle);
begin
  //  TODO Auto-generated method stub
  inherited onCreate(savedInstanceState);
  //  Add 'general' preferences.
  addPreferencesFromResource(R.xml.settings);
  bindPreferenceSummaryToValue(findPreference(PREFS_SERVER_URL), true);
  bindPreferenceSummaryToValue(findPreference(PREFS_LOGIN_NAME), true);
  bindPreferenceSummaryToValue(findPreference(PREFS_LOGIN_PASSWORD), false);
end;

method SettingsActivity.SettingsFragment.onCreateView(inflater: LayoutInflater; container: ViewGroup; savedInstanceState: Bundle): View;
begin
  result := inflater.inflate(R.layout.activity_settings, container, false);
end;

end.
