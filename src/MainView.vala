public class Schedules.MainView : Switchboard.SettingsPage {
    public MainView () {
        Object (
            title: _("Schedules"),
            description: _("Manage your schedules")
        );
    }

    construct {
        var empty_alert = new Granite.Placeholder (_("Schedules")) {
            description = _("Add apps to the Startup list by clicking the icon in the toolbar below."),
            icon = new ThemedIcon ("system-restart")
        };

        var list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        list.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
        list.set_placeholder (empty_alert);

        var drop_target = new Gtk.DropTarget (typeof (Gdk.FileList), Gdk.DragAction.COPY);
        list.add_controller (drop_target);

        var scrolled = new Gtk.ScrolledWindow () {
            child = list
        };

        var add_button_box = new Gtk.Box (HORIZONTAL, 0);
        add_button_box.append (new Gtk.Image.from_icon_name ("application-add-symbolic"));
        add_button_box.append (new Gtk.Label (_("Add Schedule…")));

        var add_button = new Gtk.Button () {
            child = add_button_box,
            margin_top = 3,
            margin_bottom = 3
        };
        add_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var actionbar = new Gtk.ActionBar ();
        actionbar.add_css_class (Granite.STYLE_CLASS_FLAT);
        actionbar.pack_start (add_button);

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (scrolled);
        box.append (actionbar);

        var frame = new Gtk.Frame (null) {
            child = box
        };

        child = frame;

        Schedule.init.begin (() => {
            list.bind_model (Schedule.schedules, (obj) => {
                return new ScheduleRow ((Schedule) obj);
            });
        });

        add_button.clicked.connect (() => Schedule.create_new.begin ());
    }
}