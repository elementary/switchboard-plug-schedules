public class Schedules.SettingRow : Gtk.ListBoxRow {
    public Setting setting { get; construct; }

    public SettingRow (Setting setting) {
        Object (setting: setting);
    }

    construct {
        var label = new Gtk.Label (setting.display_name) {
            ellipsize = MIDDLE,
            hexpand = true,
            xalign = 0
        };

        var edit_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            popover = new SettingPopover (setting)
        };

        var box = new Gtk.Box (HORIZONTAL, 6);
        box.append (label);
        box.append (edit_button);

        child = box;

        setting.bind_property ("display-name", label, "label", DEFAULT);
    }
}
