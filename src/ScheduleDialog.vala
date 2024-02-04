public class Schedules.ScheduleDialog : Gtk.Window {
    public Schedule schedule { get; construct; }

    public ScheduleDialog (Schedule schedule) {
        Object (schedule: schedule);
    }

    construct {
        var name_entry = new Gtk.Entry ();

        var box = new Gtk.Box (VERTICAL, 6) {
            margin_top = 6,
            margin_start = 6,
            margin_end = 6,
            margin_bottom = 6
        };
        box.append (name_entry);

        child = box;
        titlebar = new Gtk.HeaderBar () {
            title_widget = new Gtk.Grid ()
        };
        titlebar.add_css_class (Granite.STYLE_CLASS_FLAT);

        schedule.bind_property ("name", name_entry, "text", SYNC_CREATE | BIDIRECTIONAL);
    }
}