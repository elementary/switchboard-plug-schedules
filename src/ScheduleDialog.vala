public class Schedules.ScheduleDialog : Gtk.Window {
    public Schedule schedule { get; construct; }

    public ScheduleDialog (Schedule schedule) {
        Object (schedule: schedule);
    }

    construct {
        var name_entry = new Gtk.Entry ();

        var schedule_label = new Granite.HeaderLabel (_("Schedule"));

        var schedule_sunset_radio = new Gtk.CheckButton.with_label (
            _("Sunset to Sunrise")
        ) {
            active = schedule.schedule_type == DAYLIGHT
        };

        var from_label = new Gtk.Label (_("From:"));

        var from_time = new Granite.TimePicker () {
            hexpand = true,
            margin_end = 6
        };

        var to_label = new Gtk.Label (_("To:"));

        var to_time = new Granite.TimePicker () {
            hexpand = true
        };

        var schedule_manual_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        schedule_manual_box.append (from_label);
        schedule_manual_box.append (from_time);
        schedule_manual_box.append (to_label);
        schedule_manual_box.append (to_time);

        var schedule_manual_radio = new Gtk.CheckButton () {
            group = schedule_sunset_radio,
            active = schedule.schedule_type == MANUAL
        };
        schedule_manual_radio.bind_property ("active", schedule_manual_box, "sensitive", SYNC_CREATE);

        var time_grid = new Gtk.Grid () {
            row_spacing = 6
        };
        time_grid.attach (schedule_label, 0, 0, 2);
        time_grid.attach (schedule_sunset_radio, 0, 1, 2);
        time_grid.attach (schedule_manual_radio, 0, 2, 1);
        time_grid.attach (schedule_manual_box, 1, 2, 1);

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

        var box = new Gtk.Box (VERTICAL, 12) {
            margin_top = 6,
            margin_start = 6,
            margin_end = 6,
            margin_bottom = 6
        };
        box.append (name_entry);
        box.append (time_grid);
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

        add_button.clicked.connect (() => schedule.add_setting (new Setting ("dnd", true)));

        schedule_sunset_radio.toggled.connect (() => {
            if (!schedule_sunset_radio.active) {
                return;
            }

            schedule.schedule_type = DAYLIGHT;
        });

        schedule_manual_radio.toggled.connect (() => {
            if (!schedule_manual_radio.active) {
                return;
            }

            update_manual_schedule (from_time.time, to_time.time);
        });

        var schedule_from_time = schedule.get_manual_from_time ();
        var schedule_to_time = schedule.get_manual_to_time ();
        from_time.time = schedule_from_time ?? new DateTime.now_local ();
        to_time.time = schedule_to_time ?? new DateTime.now_local ();

        from_time.time_changed.connect (() => update_manual_schedule (from_time.time, to_time.time));
        to_time.time_changed.connect (() => update_manual_schedule (from_time.time, to_time.time));
    }

    private void update_manual_schedule (DateTime from_time, DateTime to_time) {
        schedule.schedule_type = MANUAL;
        schedule.set_manual_time (from_time, to_time);
    }
}
