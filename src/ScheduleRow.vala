public class Schedules.ScheduleRow : Gtk.ListBoxRow {
    public Schedule schedule { get; construct; }

    public ScheduleRow (Schedule schedule) {
        Object (schedule: schedule);
    }

    construct {
        var label = new Granite.HeaderLabel (schedule.name) {
            hexpand = true
        };

        var edit_button = new Gtk.Button.from_icon_name ("document-edit-symbolic");

        var enabled_switch = new Gtk.Switch () {
            valign = CENTER
        };

        var box = new Gtk.Box (HORIZONTAL, 6);
        box.append (label);
        box.append (edit_button);
        box.append (enabled_switch);

        child = box;

        schedule.bind_property ("name", label, "label", DEFAULT);
        schedule.bind_property ("enabled", enabled_switch, "active", SYNC_CREATE | BIDIRECTIONAL);

        edit_button.clicked.connect (() => new ScheduleDialog (schedule).present ());
    }
}