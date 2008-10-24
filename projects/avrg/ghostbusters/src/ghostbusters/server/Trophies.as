//
// $Id$

package ghostbusters.server {

import ghostbusters.data.Codes;

import flash.utils.Dictionary;

import com.threerings.util.ArrayUtil;

public class Trophies
{
    public static const LIBRARY_SCENES :Array = [ 2914 ];

    public static const TROPHY_LEAGUE :String = "league";
    public static const TROPHY_PROT_CHARM :String = "prot_charm";
    public static const TROPHY_LAST_MAN :String = "last_man";
    public static const TROPHY_RESUSCITATE :String = "resuscitate";
    public static const TROPHY_BAG_OF_TRICKS :String = "tricks";
    public static const TROPHY_WELL_READ :String = "well_read";
    public static const TROPHY_DEATHS_DOOR :String = "deaths_door";
    public static const TROPHY_MEAN_STREAK :String = "mean_streak";
    public static const TROPHY_5_KILLS :String = "5_kills";
    public static const TROPHY_20_KILLS :String = "20_kills";
    public static const TROPHY_100_KILLS :String = "100_kills";
    public static const TROPHY_500_KILLS :String = "500_kills";
    public static const TROPHY_1000_KILLS :String = "1000_kills";
    public static const TROPHY_MINIGAME_PREFIX :String = "minigame_";

    public static function handleGhostDefeat (room :Room) :void
    {
        var fullTeam :Array = room.getTeam(false);
        var liveTeam :Array = room.getTeam(true);

        var inLibrary :Boolean = ArrayUtil.contains(LIBRARY_SCENES, room.roomId);

        // Last Man Standing - everyone else in your party dies, except for you.
        if (fullTeam.length > 3 && liveTeam.length == 1) {
            doAward(Player(liveTeam[0]), TROPHY_LAST_MAN);
        }

        // do the trophies you only win if you were alive at the end
        for (var ii :int = 0; ii < liveTeam.length; ii ++) {
            var player :Player = Player(liveTeam[ii]);

            if (player.health == player.maxHealth) {
                // Protective Charm - beat a ghost with full health
                doAward(player, TROPHY_PROT_CHARM);

            } else if (player.health * 20 < player.maxHealth) {
                // At Death's Door - beat a ghost with less than 5% of your health remaining
                doAward(player, TROPHY_DEATHS_DOOR);

            }
        }

        // then trophies you get even if you died in battle
        for (ii = 0; ii < fullTeam.length; ii ++) {
            player = Player(fullTeam[ii]);

            var minigames :Dictionary = room.getMinigameStats(player.playerId);
            if (minigames != null &&
                minigames[Codes.WPN_LANTERN] && minigames[Codes.WPN_BLASTER] &&
                minigames[Codes.WPN_OUIJA] && minigames[Codes.WPN_POTIONS]) {
                // Bag of Tricks - Use all four minigames against a ghost
                doAward(player, TROPHY_BAG_OF_TRICKS);
            }

            if (inLibrary) {
                // Well Read - Kill more than ten ghosts in a room with the GhostHunters
                // library backdrop
                if (bumpProp(player, Codes.PROP_LIBRARY_KILLS) >= 10) {
                    doAward(player, TROPHY_WELL_READ);
                }
            }

            if (fullTeam.length == Codes.MAX_TEAM_SIZE) {
                // League of Extraordinary Ghosthunters -
                // Defeat 10 ghosts with a party of more than 7 people.
                if (bumpProp(player, Codes.PROP_LEAGUE_KILLS) >= 10) {
                    doAward(player, TROPHY_LEAGUE);
                }
            }

            if (bumpProp(player, Codes.PROP_MEAN_KILLS) >= 5) {
                // Mean Streak - kill five ghosts in a row without dying
                doAward(player, TROPHY_MEAN_STREAK);
            }

            var kills :int = bumpProp(player, Codes.PROP_KILLS);
            if (kills >= 5) {
                doAward(player, TROPHY_5_KILLS);
            }                
            if (kills >= 20) {
                doAward(player, TROPHY_20_KILLS);
            }                
            if (kills >= 100) {
                doAward(player, TROPHY_100_KILLS);
            }
            if (kills >= 500) {
                doAward(player, TROPHY_500_KILLS);
            }                
            if (kills >= 1000) {
                doAward(player, TROPHY_1000_KILLS);
            }                
        }
    }

    public static function handleMinigameCompletion (
        player :Player, weapon :int, win :Boolean) :void
    {
        if (win) {
            if (bumpProp(player, Codes.PROP_MINIGAME_PREFIX + weapon) >= 1000) {
                doAward(player, TROPHY_MINIGAME_PREFIX + weapon);
            }
        }
    }

    public static function handleHeal (healer :Player, healee :Player, heal :int) :void
    {
        // if a player healed somebody else from under 5% to over 10%, award Resuscitate
        if (healer.playerId != healee.playerId &&
            (20 * (healee.health - heal)) < healee.maxHealth &&
            (10 * healee.health) >= healee.maxHealth) {
            doAward(healer, TROPHY_RESUSCITATE);
        }
    }

    public static function handlePlayerDied (player :Player) :void
    {
        // Mean Streak - kill five ghosts in a row without dying
        player.ctrl.props.set(Codes.PROP_MEAN_KILLS, 0, true);
    }

    protected static function bumpProp (player :Player, prop :String) :int
    {
        var num :int = int(player.ctrl.props.get(prop));
        player.ctrl.props.set(Codes.prop, num + 1, true);
        return num;
    }

    protected static function doAward (player :Player, trophy :String) :void
    {
        if (!player.ctrl.holdsTrophy(trophy)) {
            player.ctrl.awardTrophy(trophy);
        }
    }
}
}
