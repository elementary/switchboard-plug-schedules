public class Schedules.MainView : Switchboard.SimpleSettingsPage {
    public MainView () {
        Object (
            title: _("Schedules"),
            description: _("Manage your schedules")
        );
    }

    construct {
        content_area.attach (new Gtk.Label ("HELLO"), 0, 0);
    }
}