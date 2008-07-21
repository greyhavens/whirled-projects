package popcraft {
    import com.threerings.util.Log;


public class TrophyManager
{
    public static function awardTrophy (trophyName :String) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.player.awardTrophy(trophyName);
        } else {
            log.info("Trophy awarded: " + trophyName);
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
    // expert-complete all single player levels
    public static const TROPHY_MAGNACUMLAUDE :String = "MagnaCumLaude";

    /* multiplayer trophies */

    // Complete 10 multiplayer games
    public static const TROPHY_RALPH :String = "Ralph";
    public static const RALPH_NUMGAMES :int = 10;
    // Complete 100 multiplayer games
    public static const TROPHY_JACK :String = "Jack";
    public static const JACK_NUMGAMES :int = 100;
    // Complete 1000 multiplayer games
    public static const TROPHY_WEARDD :String = "Weardd";
    public static const WEARDD_NUMGAMES :int = 1000;
    // Play a 1v1, 2v1, 1v1v1, 3v1, 2v2, 2v1v1, and 1v1v1v1 multiplayer game
    public static const TROPHY_LIBERALARTS :String = "LiberalArts";
    // win a multiplayer game
    public static const TROPHY_BULLY :String = "Bully";
    // win a multiplayer game without taking any damage
    public static const TROPHY_FLAWLESS :String = "Flawless";
    // win a multiplayer game with very low health
    public static const TROPHY_CHEATDEATH :String = "CheatDeath";
    public static const CHEATDEATH_HEALTH_PERCENT :Number = 0.1;
    // play a game against another player with the Morbid Infection trophy
    public static const TROPHY_MORBIDINFECTION :String = "MorbidInfection";
    // win a game against a player whose Whirled name is "Professor Weardd"
    public static const TROPHY_MALEDICTORIAN :String = "Maledictorian";
    // win a multiplayer game on a full moon
    public static const TROPHY_BADMOON :String = "BadMoon";

    /* general trophies */

    public static const TROPHY_RESOURCE_CLEAR_TILE_COUNT :int = 14;
    public static const TROPHY_RESOURCE_CLEAR :Array = [
        "PressTheFlesh",    // clear 14+ flesh tiles simultaneously
        "Bloodbath",        // ...etc
        "PowerSurge",
        "Scrapper",
    ];

    // clear 4+ pieces, X times in a row
    public static const TROPHY_PIECECLEARRUNS :Array = [
        "ElbowGrease",          10,
        "NoseToTheGrindstone",  20,
        "WellOiledMachine",     30,
        "PerpetualMotion",      40,
    ];

    // max out all your resources
    public static const TROPHY_MAXEDOUT :String = "MaxedOut";

    // kill 2500 creatures total
    public static const TROPHY_WHATAMESS :String = "WhatAMess";
    public static const WHATAMESS_NUMCREATURES :int = 2500;

    // Delivery Boy damages a base at sunrise
    public static const TROPHY_RUSHDELIVERY :String = "RushDelivery";

    // Get 3 bloodlusted, rigor-mortised Behemoths on the battlefield simultaneously
    public static const TROPHY_DOOMSDAY :String = "Doomsday";
    public static const DOOMSDAY_BEHEMOTHS :int = 3;

    // Get 10 Delivery Boys on the battlefield simultaneously
    public static const TROPHY_CRYHAVOC :String = "CryHavoc";
    public static const CRYHAVOC_SAPPERS :int = 10;

    protected static var log :Log = Log.getLog(TrophyManager);
}

}
