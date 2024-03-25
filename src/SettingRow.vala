public class Schedules.SettingRow : Gtk.ListBoxRow {
    public Setting setting { get; construct; }

    public SettingRow (Setting setting) {
        Object (setting: setting);
    }

    construct {
        var label = new Gtk.Label (setting.display_name);

        var edit_button = new Gtk.MenuButton () {
            icon_name = "application-x-generic",
            popover = new SettingPopover (setting)
        };

        var box = new Gtk.Box (HORIZONTAL, 6);
        box.append (label);
        box.append (edit_button);

        child = box;
    }
}
