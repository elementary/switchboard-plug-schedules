/*
 */

public class Schedules.Plug : Switchboard.Plug {
    private MainView? main_view;

    public Plug () {
        GLib.Intl.bindtextdomain (Schedules.GETTEXT_PACKAGE, Schedules.LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (Schedules.GETTEXT_PACKAGE, "UTF-8");
        Object (
            category: Category.PERSONAL,
            code_name: "io.elementary.settings.schedules",
            display_name: _("Schedules"),
            description: _("View and edit schedules"),
            icon: ""
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_view == null) {
            main_view = new MainView ();
        }

        return main_view;
    }

    public override void shown () {
    }

    public override void hidden () {
    }

    public override void search_callback (string str) {

    }

    public override async Gee.TreeMap<string, string> search (string term) {
        return new Gee.TreeMap<string, string> ();
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Schedules plug");
    var plug = new Schedules.Plug ();
    return plug;
}
