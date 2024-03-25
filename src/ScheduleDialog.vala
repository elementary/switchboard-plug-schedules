public class Schedules.ScheduleDialog : Gtk.Window {
    public Schedule schedule { get; construct; }

    public ScheduleDialog (Schedule schedule) {
        Object (schedule: schedule);
    }

    construct {
        var name_entry = new Gtk.Entry ();

        var list_box = new Gtk.ListBox ();
        list_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);

        var scrolled = new Gtk.ScrolledWindow () {
            child = list_box,
            vexpand = true
        };

        var add_button_box = new Gtk.Box (HORIZONTAL, 0);
        add_button_box.append (new Gtk.Image.from_icon_name ("application-add-symbolic"));
        add_button_box.append (new Gtk.Label (_("Add Setting…")));

        var add_button = new Gtk.Button () {
            child = add_button_box,
            margin_top = 3,
            margin_bottom = 3
        };
        add_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var actionbar = new Gtk.ActionBar ();
        actionbar.add_css_class (Granite.STYLE_CLASS_FLAT);
        actionbar.pack_start (add_button);

        var settings_box = new Gtk.Box (VERTICAL, 0);
        settings_box.append (scrolled);
        settings_box.append (actionbar);

        var frame = new Gtk.Frame (null) {
            child = settings_box
        };

        var box = new Gtk.Box (VERTICAL, 6) {
            margin_top = 6,
            margin_start = 6,
            margin_end = 6,
            margin_bottom = 6
        };
        box.append (name_entry);
        box.append (frame);

        child = box;
        titlebar = new Gtk.HeaderBar () {
            title_widget = new Gtk.Grid ()
        };
        titlebar.add_css_class (Granite.STYLE_CLASS_FLAT);

        schedule.bind_property ("name", name_entry, "text", SYNC_CREATE | BIDIRECTIONAL);

        list_box.bind_model (schedule.active_settings, (obj) => {
            warning ("created");
            return new SettingRow ((Setting) obj);
        });

        add_button.clicked.connect (() => {
            schedule.add_setting (new Setting ("dnd", true));
        });
    }
}
