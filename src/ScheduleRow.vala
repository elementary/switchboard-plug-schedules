public class ScheduleRow : Gtk.ListBoxRow {
    public Schedule schedule { get; construct; }

    public ScheduleRow (Schedule schedule) {
        Object (schedule: schedule);
    }

    construct {
        var label = new Granite.HeaderLabel (schedule.name) {
            hexpand = true
        };

        var enabled_switch = new Gtk.Switch () {
            valign = CENTER
        };

        var box = new Gtk.Box (HORIZONTAL, 6);
        box.append (label);
        box.append (enabled_switch);

        child = box;

        schedule.bind_property ("name", label, "label", DEFAULT);
        schedule.bind_property ("enabled", enabled_switch, "active", SYNC_CREATE | BIDIRECTIONAL);
    }
}