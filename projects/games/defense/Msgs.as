package {

/**
 * String internationalization helper.
 */
public class Msgs
{
    /** Retrieves a string with the given key. */
    public static function get (key :String) :String
    {
        // this will eventually come from content packs... I hope...
        var val :String = data[key];
        return (val != null) ? val : key;
    }

    public static var data :Object =
    {
        menu_title: "Buildings",
        path_1: "Player 1 Map",
        path_2: "Player 2 Map"
    }
}

}
        
