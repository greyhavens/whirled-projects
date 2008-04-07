//
// $Id$

package ghostbusters.server {

import ghostbusters.Codes;
import ghostbusters.Game;

public class BasicBrain
{
    public static function tick (timer :int) :void
    {
        var lastAttack :int =
            Game.control.state.getRoomProperty(Codes.PROP_LAST_GHOST_ATTACK) as int;

        if (timer - lastAttack < 5) {
            // all attacks have a 5 second cooldown, basically to make sure the animation finished
            return;
        }

        var players :Array = Game.getTeam(true);

        // make sure there's anybody left alive to attack
        if (players.length == 0) {
            return;
        }

        // roll a d20 and determine what happens
        var roll :int = Game.random.nextInt(20);
        if (roll > 3) {
            // 80% chance of doing nothing
            return;
        }
        if (roll == 0 || roll == 1) {
            // 10% chance of attacking a single player
            attackSingle(players);

        } else if (roll == 2 || roll == 3) {
            // 10% chance of an AE attack
            attackTeam(players);
        }

        // remember when the attack happened
        Game.control.state.setRoomProperty(Codes.PROP_LAST_GHOST_ATTACK, timer);
    }

    protected static function attackSingle (team :Array) :void
    {
        // Moronic AI: attack a completely random player each turn
        var ix :int = Game.random.nextInt(team.length);
        Game.server.doDamagePlayer(team[ix], 20);
    }

    protected static function attackTeam (team :Array) :void
    {
        // Splash team with a fixed moderate amount of damage per player
        for (var ii :int = 0; ii < team.length; ii ++) {
            if (Game.server.doDamagePlayer(team[ii], 5)) {
                // the player died; see if we're triumphant
                if (Game.model.isEverybodyDead()) {
                    return;
                }
            }
        }
    }
}
}

