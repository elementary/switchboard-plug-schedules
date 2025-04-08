[DBus (name="io.elementary.settings_daemon.ScheduleManager")]
public interface Schedules.ScheduleManager : Object {
    public enum Type {
        MANUAL,
        DAYLIGHT;

        public string to_nick () {
            return ((EnumClass) typeof (Type).class_peek ()).get_value (this).value_nick;
        }
    }

    public struct Parsed {
        string id;
        Type type;
        string name;
        bool enabled;
        HashTable<string, Variant> args;
        HashTable<string, Variant> active_settings;
        HashTable<string, Variant> inactive_settings;
    }

    public abstract async void delete_schedule (string id) throws IOError, DBusError;
    public abstract async Parsed[] list_schedules () throws IOError, DBusError;
    public abstract async void update_schedule (Parsed parsed) throws IOError, DBusError;
}

public class Schedules.Schedule : Object {
    public static ListStore schedules;

    private static ScheduleManager? manager;

    public static async void init () {
        schedules = new ListStore (typeof (Schedule));
        try {
            manager = yield Bus.get_proxy<ScheduleManager> (
                SESSION,
                "io.elementary.settings-daemon",
                "/io/elementary/settings_daemon"
            );
            yield reload_schedules ();
        } catch (Error e) {
            //TODO: display error in list
            warning ("Failed to get proxy: %s", e.message);
        }
    }

    private static async void reload_schedules () {
        if (manager == null) {
            return;
        }

        Schedule[] new_schedules = {};

        try {
            foreach (var parsed in yield manager.list_schedules ()) {
                new_schedules += new Schedule (parsed);
            }
        } catch (Error e) {
            warning ("Failed to list schedules: %s", e.message);
            return;
        }

        schedules.splice (0, schedules.get_n_items (), new_schedules);
    }

    public static async void create_new () {
        if (manager == null) {
            return;
        }

        ScheduleManager.Parsed new_schedule = {
            Uuid.string_random (),
            DAYLIGHT,
            _("New Schedule"),
            true,
            new HashTable<string, Variant> (str_hash, str_equal),
            new HashTable<string, Variant> (str_hash, str_equal),
            new HashTable<string, Variant> (str_hash, str_equal)
        };

        try {
            yield manager.update_schedule (new_schedule);
        } catch (Error e) {
            warning ("Failed to create schedule: %s", e.message);
        }

        yield reload_schedules ();
    }

    // We're using the parsed as backing store and the gobject property fucks something up there
    // so we have to use the field directly
    private ScheduleManager.Parsed _parsed;
    public ScheduleManager.Parsed parsed { construct { _parsed = value; }}

    public string id { get { return _parsed.id; } }
    public ScheduleManager.Type schedule_type { get { return _parsed.type; } set { _parsed.type = value; } }
    public string name { get { return _parsed.name; } set { _parsed.name = value; } }
    public bool enabled { get { return _parsed.enabled; } set { _parsed.enabled = value; } }

    public ListStore active_settings;
    private ListStore inactive_settings;

    public DateTime from_time {
        owned get { return double_to_date_time (args["from"].get_double ()); }
        set { args["from"] = date_time_to_double (value); }
    }

    public DateTime to_time {
        owned get { return double_to_date_time (args["to"].get_double ()); }
        set { args["to"] = date_time_to_double (value); }
    }

    private HashTable<string, Variant> args { get { return _parsed.args; } }

    public Schedule (owned ScheduleManager.Parsed parsed) {
        Object (parsed: parsed);
    }

    construct {
        active_settings = new ListStore (typeof (Setting));
        inactive_settings = Setting.list_from_table (_parsed.inactive_settings);

        foreach (var setting_name in _parsed.active_settings.get_keys ()) {
            add_setting (new Setting (setting_name, _parsed.active_settings[setting_name]));
        }

        notify.connect ((pspec) => {
            var name = pspec.get_name ();
            if (name == "schedule-type" || name == "name" || name == "enabled" || name == "from" || name == "to") {
                manager.update_schedule.begin (_parsed);
            }
        });
    }

    public async void delete () {
        try  {
            yield manager.delete_schedule (id);
        } catch (Error e) {
            warning ("Failed to delete schedule: %s", e.message);
        }

        reload_schedules.begin ();
    }

    public void add_setting (Setting setting) {
        //TODO: add and bind inverted setting
        active_settings.append (setting);
        setting.changed.connect (sync_settings_and_update);
        setting.removed.connect (remove_setting);

        sync_settings_and_update ();
    }

    private void remove_setting (Setting setting) {
        //TODO: remove inverted setting
        uint position;
        if (active_settings.find (setting, out position)) {
            active_settings.remove (position);
            sync_settings_and_update ();
        }
    }

    private void sync_settings_and_update () {
        _parsed.active_settings = Setting.list_to_table (active_settings);
        _parsed.inactive_settings = Setting.list_to_table (inactive_settings);
        manager.update_schedule.begin (_parsed);
    }

    private static double date_time_to_double (DateTime date_time) {
        double time_double = 0;
        time_double += date_time.get_hour ();
        time_double += (double) date_time.get_minute () / 60;
        return time_double;
    }

    private static DateTime double_to_date_time (double val) {
        var hours = (int) val;
        var minutes = (int) (val - hours) * 60;
        return new DateTime.local (1, 1, 1, hours, minutes, 0);
    }
}
