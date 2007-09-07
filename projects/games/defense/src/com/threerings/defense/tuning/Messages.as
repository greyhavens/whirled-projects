package com.threerings.defense.tuning {

/**
 * String internationalization helper.
 */
public class Messages
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
        menu_title: "Main Menu",
        off: "Off",
        path_1: "P1 Map",
        path_2: "P2 Map",
        death_1: "P1 Death",
        death_2: "P2 Death"
    }
}

}
        
