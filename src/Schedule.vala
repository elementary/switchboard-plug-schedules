[DBus (name="io.elementary.settings_daemon.ScheduleManager")]
public interface ScheduleManager : Object {
    public enum Type {
        MANUAL,
        DAYLIGHT
    }

    public struct Parsed {
        string name;
        Type type;
        bool enabled;
        HashTable<string, Variant> args;
        HashTable<string, Variant> active_settings;
        HashTable<string, Variant> inactive_settings;
    }

    public abstract async void create_schedule (Parsed parsed) throws IOError, DBusError;
    public abstract async void delete_schedule (string name) throws IOError, DBusError;
    public abstract async Parsed[] list_schedules () throws IOError, DBusError;
    public abstract async void update_schedule (Parsed parsed) throws IOError, DBusError;
}

public class Schedule : Object {
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

    public string name { get; set; }
    public Type schedule_type;
    public bool enabled { get; set; }
    public HashTable<string, Variant> active_settings;
    public HashTable<string, Variant> inactive_settings;

    public Schedule.from_parsed (ScheduleManager.Parsed parsed) {
        name = parsed.name;
        enabled = parsed.enabled;
        active_settings = parsed.active_settings;
        inactive_settings = parsed.inactive_settings;
    }
}