package com.threerings.defense.tuning {

import mx.controls.Label;
    
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

    /** Retrieves a string as a Label object. */
    public static function getLabel (key :String) :Label
    {
        var l :Label = new Label();
        l.text = get(key);
        return l;
    }
    
    public static var data :Object =
    {
        menu_title: "Stations",
        health: "Health: ",
        score: " score:",
        cost: "Cost: ",

        cost_desc: "This is how much money you have for new stations.",
        health_desc: "This is your tree house health level.",
        
        off: "Off",
        path_1: "P1 Map",
        path_2: "P2 Map",
        death_1: "P1 Death",
        death_2: "P2 Death"
    }
}

}
        
