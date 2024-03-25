/*
 */

public class Schedules.Plug : Switchboard.Plug {
    private Gtk.Box? box;

    public Plug () {
        GLib.Intl.bindtextdomain (Schedules.GETTEXT_PACKAGE, Schedules.LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (Schedules.GETTEXT_PACKAGE, "UTF-8");
        Object (
            category: Category.PERSONAL,
            code_name: "io.elementary.settings.schedules",
            display_name: _("Schedules"),
            description: _("View and edit schedules"),
            icon: "media-playlist-repeat"
        );
    }

    public override Gtk.Widget get_widget () {
        if (box == null) {
            var header_bar = new Adw.HeaderBar () {
                title_widget = new Gtk.Grid () //todo replace with show_title
            };
            header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

            var main_view = new MainView () {
                vexpand = true
            };

            box = new Gtk.Box (VERTICAL, 0);
            box.append (header_bar);
            box.append (main_view);
        }

        return box;
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
