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
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.player.holdsTrophy(trophyName) : true);
    }

    /* single-player trophies */

    // complete levels 1-3
    public static const TROPHY_FRESHMAN :String = "Freshman";
    // complete levels 1-6
    public static const TROPHY_SOPHOMORE: String = "Sophomore";
    // complete levels 1-9
    public static const TROPHY_JUNIOR :String = "Junior";
    // complete levels 1-12
    public static const TROPHY_SENIOR :String = "Senior";
    // complete the single player game
    public static const TROPHY_GRADUATE :String = "Graduate";
    // complete all levels with an expert score
    public static const TROPHY_MAGNACUMLAUDE :String = "MagnaCumLaude";

    /* multiplayer trophies */

    // Complete a multiplayer game
    public static const TROPHY_PLAYSWELLWITHOTHERS :String = "PlaysWellWithOthers";
    // Complete 25 multiplayer games
    public static const TROPHY_SOCIALBUTTERFLY :String = "SocialButterfly";
    // win a multiplayer game
    public static const TROPHY_BULLY :String = "Bully";
    // win a multiplayer game without taking any damage
    public static const TROPHY_FLAWLESS :String = "Flawless";
    // play a game against another player with the Morbid Infection trophy
    public static const TROPHY_MORBIDINFECTION :String = "MorbidInfection";

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

}

}
