public class Schedules.Setting : Object {
    public static string[] settings = {_("Do Not Disturb"), _("Dark Mode"), _("Night Light"), _("Monochrome")};

    public signal void removed ();
    public signal void changed ();

    public string name { get; private set; }
    public string display_name { get; private set; }
    public Variant val { get; set; }

    public Setting (string name, Variant val) {
        this.name = name;
        this.display_name = settings[get_index ()];
        this.val = val;
    }

    public Setting.from_index (uint index) {
        set_name_from_index (index);
    }

    construct {
        notify.connect ((pspec) => {
            var name = pspec.get_name ();
            if (name == "name" || name == "display-name" || name == "val") {
                warning ("Setting changed");
                changed ();
            }
        });
    }

    public void set_name_from_index (uint index) {
        switch (index) {
            case 0:
                name = "dnd";
                break;

            case 1:
                name = "dark-mode";
                break;

            case 2:
                name = "night-light";
                break;

            case 3:
                name = "monochrome";
                break;

            default:
                warning ("This shouldn't be reached");
                break;
        }

        display_name = settings[index];
    }

    public uint get_index () {
        switch (name) {
            case "dnd":
                return 0;

            case "dark-mode":
                return 1;

            case "night-light":
                return 2;

            case "monochrome":
                return 3;

            default:
                warning ("This shouldn't be reached");
                return Gtk.INVALID_LIST_POSITION;
        }
    }

    public static ListStore list_from_table (HashTable<string, Variant> table) {
        var result = new ListStore (typeof (Setting));

        foreach (var setting_name in table.get_keys ()) {
            var setting = new Setting (setting_name, table[setting_name]);
            result.append (setting);
        }

        return result;
    }

    public static HashTable<string, Variant> list_to_table (ListStore list) {
        var result = new HashTable<string, Variant> (str_hash, str_equal);

        for (int i = 0; i < list.get_n_items (); i++) {
            var setting = (Setting) list.get_item (i);
            result[setting.name] = setting.val;
        }

        return result;
    }
}
