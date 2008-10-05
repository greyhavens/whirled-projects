//
// $Id$

package ghostbusters.server {

import ghostbusters.data.Codes;
public class Trophies
{
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

    public static function handleGhostDefeat (room :Room) :void
    {
        var fullTeam :Array = room.getTeam(false);
        var liveTeam :Array = room.getTeam(true);

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
            var player :Player = Player(liveTeam[ii]);

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

    public static function handlePlayerDied (player :Player) :void
    {
        // Mean Streak - kill five ghosts in a row without dying
        player.ctrl.props.set(Codes.PROP_MEAN_KILLS, 0, true);
    }

    protected static function bumpProp (player :Player, prop :String) :int
    {
        var num :int = int(player.ctrl.props.get(prop));
        player.ctrl.props.set(Codes.PROP_LEAGUE_KILLS, num + 1, true);
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
