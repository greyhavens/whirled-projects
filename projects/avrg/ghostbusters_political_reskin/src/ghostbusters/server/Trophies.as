//
// $Id$

package ghostbusters.server {

import ghostbusters.data.Codes;

public class Trophies
{
    public static const LIBRARY_SCENES :Array = [ 2914 ];

//    public static const TROPHY_LEAGUE :String = "league";
//    public static const TROPHY_PROT_CHARM :String = "prot_charm";
//    public static const TROPHY_LAST_MAN :String = "last_man";
//    public static const TROPHY_RESUSCITATE :String = "resuscitate";
//    public static const TROPHY_BAG_OF_TRICKS :String = "tricks";
//    public static const TROPHY_WELL_READ :String = "well_read";
//    public static const TROPHY_DEATHS_DOOR :String = "deaths_door";
//    public static const TROPHY_MEAN_STREAK :String = "mean_streak";
//    public static const TROPHY_5_KILLS :String = "5_kills";
//    public static const TROPHY_20_KILLS :String = "20_kills";
//    public static const TROPHY_100_KILLS :String = "100_kills";
//    public static const TROPHY_500_KILLS :String = "500_kills";
//    public static const TROPHY_1000_KILLS :String = "1000_kills";
//    public static const TROPHY_MINIGAME_PREFIX :String = "minigame_";
    
    
    public static const TROPHY_LEVEL_1 :String = "level_1";
    public static const TROPHY_LEVEL_2 :String = "level_2";
    public static const TROPHY_LEVEL_3 :String = "level_3";
    public static const TROPHY_LEVEL_4 :String = "level_4";
    public static const TROPHY_LEVEL_5 :String = "level_5";
    public static const TROPHY_LEVEL_6 :String = "level_6";
    public static const TROPHY_LEVEL_7 :String = "level_7";
    public static const TROPHY_LEVEL_8 :String = "level_8";
    public static const TROPHY_LEVEL_9 :String = "level_9";
    
    
    public static const AWARD_AVATAR_1 :String = "award_avatar_palin";
    public static const AWARD_AVATAR_2 :String = "award_avatar_mccain";
    public static const AWARD_AVATAR_3 :String = "award_avatar_gopmonster";
    
    

    public static function handleGhostDefeat (room :Room) :void
    {
        trace("Trophies.handleGhostDefeat()");
        var fullTeam :Array = room.getTeam(false);
        var liveTeam :Array = room.getTeam(true);

//        var inLibrary :Boolean = ArrayUtil.contains(LIBRARY_SCENES, room.roomId);

        // Last Man Standing - everyone else in your party dies, except for you.
//        if (fullTeam.length > 3 && liveTeam.length == 1) {
//            doAward(Player(liveTeam[0]), TROPHY_LAST_MAN);
//        }

        // do the trophies you only win if you were alive at the end
//        for (var ii :int = 0; ii < liveTeam.length; ii ++) {
//            var player :Player = Player(liveTeam[ii]);
//
//            if (player.health == player.maxHealth) {
//                // Protective Charm - beat a ghost with full health
//                doAward(player, TROPHY_PROT_CHARM);
//
//            } else if (player.health * 20 < player.maxHealth) {
//                // At Death's Door - beat a ghost with less than 5% of your health remaining
//                doAward(player, TROPHY_DEATHS_DOOR);
//
//            }
//        }

        // then trophies you get even if you died in battle
        for (var ii :int = 0; ii < fullTeam.length; ii ++) {
            var player :Player = Player(fullTeam[ii]);
            
//            if( player.level >= 1) {
////                if( doAward( player, TROPHY_LEVEL_1) ) {
////                   player.ctrl.awardPrize(AWARD_AVATAR_1);
////                }
//            }
            
            if( player.level >= 2) {
                if( doAward( player, TROPHY_LEVEL_2) ) {
//                   player.ctrl.awardPrize(AWARD_AVATAR_1);
                }
            }
            
            if( player.level >= 3) {
                if( doAward( player, TROPHY_LEVEL_3) ) {
//                   player.ctrl.awardPrize(AWARD_AVATAR_1);
                }
            }
            
            if( player.level >= 4) {
                if( doAward( player, TROPHY_LEVEL_4) ) {
//                   player.ctrl.awardPrize(AWARD_AVATAR_1);
                }
            }
            
            if( player.level >= 5) {
                if( doAward( player, TROPHY_LEVEL_5) ) {
                   player.ctrl.awardPrize(AWARD_AVATAR_1);
                }
            }
            
            if( player.level >= 6) {
                if( doAward( player, TROPHY_LEVEL_6) ) {
//                   player.ctrl.awardPrize(AWARD_AVATAR_2);
                }
            }
            
            if( player.level >= 7) {
                if( doAward( player, TROPHY_LEVEL_7) ) {
                    player.ctrl.awardPrize(AWARD_AVATAR_2);
                }
            }
            
            if( player.level >= 8) {
                if( doAward( player, TROPHY_LEVEL_8) ) {
//                   player.ctrl.awardPrize(AWARD_AVATAR_1);
                }
            }
            
            if( player.level >= 9) {
                if( doAward( player, TROPHY_LEVEL_9) ) {
                    player.ctrl.awardPrize(AWARD_AVATAR_3);
                }
            }
            

//            var minigames :Dictionary = room.getMinigameStats(player.playerId);
//            if (minigames[Codes.WPN_QUOTE] && minigames[Codes.WPN_IRAQ] &&
//                minigames[Codes.WPN_VOTE] && minigames[Codes.WPN_PRESS]) {
//                // Bag of Tricks - Use all four minigames against a ghost
//                doAward(player, TROPHY_BAG_OF_TRICKS);
//            }
//
//            if (inLibrary) {
//                // Well Read - Kill more than ten ghosts in a room with the GhostHunters
//                // library backdrop
//                if (bumpProp(player, Codes.PROP_LIBRARY_KILLS) >= 10) {
//                    doAward(player, TROPHY_WELL_READ);
//                }
//            }
//
//            if (fullTeam.length == Codes.MAX_TEAM_SIZE) {
//                // League of Extraordinary Ghosthunters -
//                // Defeat 10 ghosts with a party of more than 7 people.
//                if (bumpProp(player, Codes.PROP_LEAGUE_KILLS) >= 10) {
//                    doAward(player, TROPHY_LEAGUE);
//                }
//            }
//
//            if (bumpProp(player, Codes.PROP_MEAN_KILLS) >= 5) {
//                // Mean Streak - kill five ghosts in a row without dying
//                doAward(player, TROPHY_MEAN_STREAK);
//            }
//
//            var kills :int = bumpProp(player, Codes.PROP_KILLS);
//            if (kills >= 5) {
//                doAward(player, TROPHY_5_KILLS);
//            }                
//            if (kills >= 20) {
//                doAward(player, TROPHY_20_KILLS);
//            }                
//            if (kills >= 100) {
//                doAward(player, TROPHY_100_KILLS);
//            }
//            if (kills >= 500) {
//                doAward(player, TROPHY_500_KILLS);
//            }                
//            if (kills >= 1000) {
//                doAward(player, TROPHY_1000_KILLS);
//            }                
        }
    }

    public static function handleMinigameCompletion (
        player :Player, weapon :int, win :Boolean) :void
    {
//        if (win) {
//            if (bumpProp(player, Codes.PROP_MINIGAME_PREFIX + weapon) >= 1000) {
//                doAward(player, TROPHY_MINIGAME_PREFIX + weapon);
//            }
//        }
    }

    public static function handleHeal (healer :Player, healee :Player, heal :int) :void
    {
        // if a player healed somebody else from under 5% to over 10%, award Resuscitate
//        if (healer.playerId != healee.playerId &&
//            (20 * (healee.health - heal)) < healee.maxHealth &&
//            (10 * healee.health) >= healee.maxHealth) {
//            doAward(healer, TROPHY_RESUSCITATE);
//        }
    }

    public static function handlePlayerDied (player :Player) :void
    {
        // Mean Streak - kill five ghosts in a row without dying
//        player.ctrl.props.set(Codes.PROP_MEAN_KILLS, 0, true);
    }

    protected static function bumpProp (player :Player, prop :String) :int
    {
        var num :int = int(player.ctrl.props.get(prop));
        player.ctrl.props.set(Codes.PROP_LEAGUE_KILLS, num + 1, true);
        return num;
    }

    protected static function doAward (player :Player, trophy :String) :Boolean
    {
        if (!player.ctrl.holdsTrophy(trophy)) {
            player.ctrl.awardTrophy(trophy);
            return true;//SKIN
        }
        return false;//SKIN
    }
}
}
