package popcraft {

public class TrophyManager
{
    public static function awardTrophy (trophyName :String) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.player.awardTrophy(trophyName);
        }
    }

    public static function hasTrophy (trophyName :String) :Boolean
    {
        return (AppContext.gameCtrl.isConnected() && AppContext.gameCtrl.player.holdsTrophy(trophyName));
    }

    /* single-player trophies */

    // complete levels 1-3
    public static const TROPHY_FRESHMAN :String = "Freshman";
    public static const FRESHMAN_LEVEL :int = 2;
    // complete levels 1-6
    public static const TROPHY_SOPHOMORE: String = "Sophomore";
    public static const SOPHOMORE_LEVEL :int = 5;
    // complete levels 1-9
    public static const TROPHY_JUNIOR :String = "Junior";
    public static const JUNIOR_LEVEL :int = 8;
    // complete levels 1-12
    public static const TROPHY_SENIOR :String = "Senior";
    public static const SENIOR_LEVEL :int = 11;
    // complete the single player game
    public static const TROPHY_GRADUATE :String = "Graduate";
    public static const GRADUATE_LEVEL :int = 13;
    // complete all levels with an expert score
    public static const TROPHY_MAGNACUMLAUDE :String = "MagnaCumLaude";

    /* multiplayer trophies */

    // Complete 25 multiplayer games
    public static const TROPHY_JACK :String = "Jack";
    public static const JACK_NUMGAMES :int = 25;
    // Complete 100 multiplayer games
    public static const TROPHY_WEARDD :String = "Weardd";
    public static const WEARDD_NUMGAMES :int = 100;
    // Play a 1v1, 2v1, 1v1v1, 3v1, 2v2, 2v1v1, and 1v1v1v1 multiplayer game
    public static const TROPHY_LIBERALARTS :String = "LiberalArts";
    // win a multiplayer game
    public static const TROPHY_BULLY :String = "Bully";
    // win a multiplayer game without taking any damage
    public static const TROPHY_FLAWLESS :String = "Flawless";
    // play a game against another player with the Morbid Infection trophy
    public static const TROPHY_MORBIDINFECTION :String = "MorbidInfection";
    // win a game against a player whose Whirled name is "Professor Weardd"
    public static const TROPHY_MALEFACTOR :String = "Malefactor";
    // play a multiplayer game on a full moon
    public static const TROPHY_BADMOONONTHERISE :String = "BadMoonOnTheRise";

    /* general trophies */

    // Get 3 bloodlusted, rigor-mortised Behemoths on the battlefield at once
    public static const TROPHY_DOOMSDAY :String = "Doomsday";
    // get 50+ flesh resources in a single clear
    public static const TROPHY_PRESSTHEFLESH :String = "PressTheFlesh";
    // get 50+ blood resources in a single clear
    public static const TROPHY_BLOODBATH :String = "Bloodbath";
    // get 50+ energy resources in a single clear
    public static const TROPHY_POWERSURGE :String = "PowerSurge";
    // get 50+ scrap resources in a single clear
    public static const TROPHY_SCRAPPER :String = "Scrapper";

    // kill 2500 creatures total
    public static const TROPHY_WHATAMESS :String = "WhatAMess";
    public static const WHATAMESS_NUMCREATURES :int = 2500;

}

}
