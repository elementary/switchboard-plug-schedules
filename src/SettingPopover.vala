public class Schedules.SettingPopover : Gtk.Popover {
    public Setting setting { get; construct; }

    public SettingPopover (Setting setting) {
        Object (setting: setting);
    }

    construct {
        var kind_label = new Gtk.Label (_("Kind: ")) {
            halign = END
        };

        var kind_drop_down = new Gtk.DropDown.from_strings (Setting.settings);
        var size_group = new Gtk.SizeGroup (HORIZONTAL);
        size_group.add_widget (kind_drop_down.get_first_child ());
        size_group.add_widget (kind_drop_down.get_last_child ().get_first_child ());

        var val_label = new Gtk.Label (_("Value: ")) {
            halign = END
        };

        var val_switch = new Gtk.Switch () {
            state = (bool) setting.val
        };

        var grid = new Gtk.Grid ();
        grid.attach (kind_label, 0, 0);
        grid.attach (kind_drop_down, 1, 0);
        grid.attach (val_label, 0, 1);
        grid.attach (val_switch, 1, 1);

        child = grid;
    }

    private static Gtk.SignalListItemFactory create_fixed_width_factory () {
        var size_group = new Gtk.SizeGroup (VERTICAL);

        var factory = new Gtk.SignalListItemFactory ();

        factory.setup.connect ((obj) => {
            var list_item = (Gtk.ListItem) obj;
            list_item.child = new Gtk.Label (null);
            size_group.add_widget (list_item.child);
        });

        factory.bind.connect ((obj) => {
            var list_item = (Gtk.ListItem) obj;
            var string_obj = (Gtk.StringObject) list_item.item;
            var label = (Gtk.Label) list_item.child;
            label.label = string_obj.string;
        });

        factory.teardown.connect ((obj) => {
            var list_item = (Gtk.ListItem) obj;
            size_group.remove_widget (list_item.child);
        });

        return factory;
    }
}
