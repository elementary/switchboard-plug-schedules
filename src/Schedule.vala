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

    public abstract async void create_schedule (Parsed parsed) throws IOError, DBusError;
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

    public string id { get; protected set; }
    public ScheduleManager.Type schedule_type { get; set; }
    public string name { get; set; }
    public bool enabled { get; set; }

    public ListStore active_settings;
    private ListStore inactive_settings;

    public DateTime from_time {
        owned get { return double_to_date_time (private_args["from"].get_double ()); }
        set { private_args["from"] = date_time_to_double (value); }
    }

    public DateTime to_time {
        owned get { return double_to_date_time (private_args["to"].get_double ()); }
        set { private_args["to"] = date_time_to_double (value); }
    }

    private HashTable<string, Variant> private_args;

    public Schedule (ScheduleManager.Parsed parsed) {
        id = parsed.id;
        schedule_type = parsed.type;
        name = parsed.name;
        enabled = parsed.enabled;
        active_settings = new ListStore (typeof (Setting));
        inactive_settings = Setting.list_from_table (parsed.inactive_settings);

        private_args = parsed.args;

        notify.connect ((pspec) => {
            var name = pspec.get_name ();
            if (name == "schedule-type" || name == "name" || name == "enabled" || name == "from" || name == "to") {
                manager.update_schedule.begin (to_parsed ());
            }
        });

        foreach (var setting_name in parsed.active_settings.get_keys ()) {
            add_setting (new Setting (setting_name, parsed.active_settings[setting_name]));
        }
    }

    private ScheduleManager.Parsed to_parsed () {
        return {
            id,
            schedule_type,
            name,
            enabled,
            private_args,
            Setting.list_to_table (active_settings),
            Setting.list_to_table (inactive_settings)
        };
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
        setting.changed.connect (() =>  manager.update_schedule.begin (to_parsed ()));
        setting.removed.connect (remove_setting);

        manager.update_schedule.begin (to_parsed ());
    }

    private void remove_setting (Setting setting) {
        //TODO: remove inverted setting
        uint position;
        if (active_settings.find (setting, out position)) {
            active_settings.remove (position);
            manager.update_schedule.begin (to_parsed ());
        }
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
