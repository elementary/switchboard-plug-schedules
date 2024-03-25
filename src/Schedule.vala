[DBus (name="io.elementary.settings_daemon.ScheduleManager")]
public interface Schedules.ScheduleManager : Object {
    public enum Type {
        MANUAL,
        DAYLIGHT
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

    public async static void init () {
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

    private async static void reload_schedules () {
        if (manager == null) {
            return;
        }

        Schedule[] new_schedules = {};

        try {
            foreach (var parsed in yield manager.list_schedules ()) {
                new_schedules += new Schedule.from_parsed (parsed);
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
    public Type schedule_type;
    public string name { get; set; }
    public bool enabled { get; set; }

    public ListStore active_settings;
    public ListStore inactive_settings;

    public Schedule.from_parsed (ScheduleManager.Parsed parsed) {
        id = parsed.id;
        name = parsed.name;
        enabled = parsed.enabled;
        active_settings = new ListStore (typeof (Setting));
        inactive_settings = Setting.list_from_table (parsed.inactive_settings);

        notify.connect ((pspec) => {
            var name = pspec.get_name ();
            if (name == "id" || name == "schedule-type" || name == "name" || name == "enabled") {
                manager.update_schedule.begin (to_parsed ());
            }
        });

        fill_from_table (parsed.active_settings);
    }

    private void fill_from_table (HashTable<string, Variant> table) {
        foreach (var setting_name in table.get_keys ()) {
            var setting = new Setting (setting_name, table[setting_name]);
            add_setting (setting);
        }
    }

    public ScheduleManager.Parsed to_parsed () {
        var private_args = new HashTable<string, Variant> (str_hash, str_equal);
        private_args["from"] = (double) 1f;
        private_args["to"] = (double) 1f;

        if (schedule_type == ScheduleManager.Type.MANUAL) {
            //todo
        }

        ScheduleManager.Parsed result = {
            id,
            schedule_type,
            name,
            enabled,
            private_args,
            Setting.list_to_table (active_settings),
            Setting.list_to_table (inactive_settings)
        };

        return result;
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
        manager.update_schedule.begin (to_parsed ());
    }

    public void remove_setting (Setting setting) {
        //TODO: remove inverted setting
        uint position;
        if (active_settings.find (setting, out position)) {
            active_settings.remove (position);
            manager.update_schedule.begin (to_parsed ());
        }
    }
}
