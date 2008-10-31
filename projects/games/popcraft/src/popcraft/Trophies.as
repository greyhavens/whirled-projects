package popcraft {

public class Trophies
{
    /* endless mode trophies */

    // complete level 5
    public static const ABECEDARIAN :String = "Abecedarian";
    public static const ABECEDARIAN_MAP_INDEX :int = 4;
    // complete all sp levels 1, 2, 3 times
    public static const ENDLESS_COMPLETION_TROPHIES :Array = [
        "Adequate",
        "Accepted",
        "Admired",
    ];
    // complete mp level 9
    public static const COLLABORATOR :String = "Collaborator";
    public static const COLLABORATOR_MP_MAP_INDEX :int = 8;
    // resurrect your teammate in multiplayer
    public static const REANIMATOR :String = "Reanimator";
    // get your multiplier to 5x
    public static const MAX_X :String = "MaxX";
    // defeat an opponent who took a multiplier from the battlefield
    public static const HANDICAPPER :String = "Handicapper";
    // get a very high score
    public static const HEAD_OF_THE_CLASS :String = "HeadOfTheClass";
    public static const HEAD_OF_THE_CLASS_SCORE :int = 600000;

    /* single-player trophies */

    // complete levels 1-3
    public static const FRESHMAN :String = "Freshman";
    public static const FRESHMAN_LEVEL :int = 2;
    // complete levels 1-6
    public static const SOPHOMORE: String = "Sophomore";
    public static const SOPHOMORE_LEVEL :int = 5;
    // complete levels 1-9
    public static const JUNIOR :String = "Junior";
    public static const JUNIOR_LEVEL :int = 8;
    // complete levels 1-12
    public static const SENIOR :String = "Senior";
    public static const SENIOR_LEVEL :int = 11;
    // complete the single player game
    public static const GRADUATE :String = "Graduate";
    public static const GRADUATE_LEVEL :int = 13;
    // expert-complete all single player levels
    public static const MAGNACUMLAUDE :String = "MagnaCumLaude";

    /* multiplayer trophies */

    // Complete 10 multiplayer games
    public static const RALPH :String = "Ralph";
    public static const RALPH_NUMGAMES :int = 10;
    // Complete 100 multiplayer games
    public static const JACK :String = "Jack";
    public static const JACK_NUMGAMES :int = 100;
    // Complete 1000 multiplayer games
    public static const WEARDD :String = "Weardd";
    public static const WEARDD_NUMGAMES :int = 1000;
    // Play a 1v1, 2v1, 1v1v1, 3v1, 2v2, 2v1v1, and 1v1v1v1 multiplayer game
    public static const LIBERALARTS :String = "LiberalArts";
    // win a multiplayer game
    public static const BULLY :String = "Bully";
    // win a multiplayer game without taking any damage
    public static const FLAWLESS :String = "Flawless";
    // win a multiplayer game with very low health
    public static const CHEATDEATH :String = "CheatDeath";
    public static const CHEATDEATH_HEALTH_PERCENT :Number = 0.1;
    // play a game against another player with the Morbid Infection trophy
    public static const MORBIDINFECTION :String = "MorbidInfection";
    // win a game against a player whose Whirled name is "Professor Weardd"
    public static const MALEDICTORIAN :String = "Maledictorian";
    public static const MALEDICTORIAN_NAME :String = "Professor Weardd";
    // win a multiplayer game on a full moon
    public static const BADMOON :String = "BadMoon";

    /* general trophies */

    public static const RESOURCE_CLEAR_TILE_COUNT :int = 20;
    public static const RESOURCE_CLEAR_TROPHIES :Array = [
        "PressTheFlesh",    // clear 20+ flesh tiles simultaneously
        "Bloodbath",        // ...etc
        "PowerSurge",
        "Scrapper",
    ];

    // clear 4+ pieces, X times in a row
    public static const PIECE_CLEAR_RUN_TROPHIES :Array = [
        "ElbowGrease",          10,
        "NoseToTheGrindstone",  20,
        "WellOiledMachine",     30,
        "PerpetualMotion",      40,
    ];

    // max out all your resources
    public static const MAXEDOUT :String = "MaxedOut";

    // kill 2500 creatures total
    public static const WHATAMESS :String = "WhatAMess";
    public static const WHATAMESS_NUMCREATURES :int = 2500;

    // Delivery Boy damages a base at sunrise
    public static const RUSHDELIVERY :String = "RushDelivery";

    // Get 3 bloodlusted, rigor-mortised Behemoths on the battlefield simultaneously
    public static const DOOMSDAY :String = "Doomsday";
    public static const DOOMSDAY_BEHEMOTHS :int = 3;

    // Get 10 Delivery Boys on the battlefield simultaneously
    public static const CRYHAVOC :String = "CryHavoc";
    public static const CRYHAVOC_SAPPERS :int = 10;
}

}
