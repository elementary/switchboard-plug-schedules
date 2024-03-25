public class Schedules.Setting : Object {
    public static string[] settings = {_("DND"), _("Dark Mode"), _("Night Light")};

    public signal void changed ();

    public string name { get; private set; }
    public string display_name { get; private set; }
    public Variant val { get; set; }

    public Setting (string name, Variant val) {
        this.name = name;
        this.display_name = "Placeholder for now";
        this.val = val;
    }

    public Setting.from_index (uint index) {
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

            default:
                warning ("This shouldn't be reached");
                break;
        }

        display_name = settings[index];
    }

    construct {
        notify.connect ((pspec) => {
            var name = pspec.get_name ();
            if (name == "name" || name == "display-name" || name == "val") {
                changed ();
            }
        });
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
            var setting = (Setting)list.get_item (i);
            result[setting.name] = setting.val;
        }

        return result;
    }
}
