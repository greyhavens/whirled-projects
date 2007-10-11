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
        wait_desc: "Please wait for the other player to join. The game will begin in a moment.",
        wait_cancel: "Cancel and return to Whirled",
        
        round_start: "ROUND ",
        round_end: "ROUND ENDED",

        spawn_choice: "Select what units you would like to send to attack your enemy's tree house:",
        cancel: "Cancel",

        game_ended: "Game ended! Here are the final scores:",
        you_won: "Your winnings this round: ",
        flow: "flow",
        play_again: "Play again!",
        quit: "Quit",
        
        off: "Off",
        path_1: "P1 Map",
        path_2: "P2 Map",
        death_1: "P1 Death",
        death_2: "P2 Death"
    }
}

}
        
