//
// $Id$

package ghostbusters.server {

import com.threerings.util.Random;

import ghostbusters.Codes;
import ghostbusters.Content;
import ghostbusters.Game;

public class Ghost
{
    public static function spawnNewGhost (roomId :int) :Ghost
    {
        var roomRandom :Random = new Random(roomId);

        // the ghost id/model is currently completely random; this will change
        var ghosts :Array = [ "pinchy", "duchess", "widow", "demon" ];
        var names :Array = [ "Mr. Pinchy", "The Duchess", "The Widow", "Soul Crusher" ];
        var ix :int = Game.random.nextInt(ghosts.length);

        // the ghost's level base is completely determined by the room
        var rnd :Number = roomRandom.nextNumber();

        // the base is in [1, 10] and low level ghosts to more common than high level ones
        var levelBase :int = int(1 + 10*rnd*rnd);

        // the actual level is the base plus a genuinely random tweak of 0, 1 or 2
        var level :int = levelBase + Game.random.nextInt(3);

        var ghost :Ghost = new Ghost(ghosts[ix], level);

        var zest :int = ghost.calculateMaxZest();
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_CUR_ZEST, zest);
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_MAX_ZEST, zest);

        var health :int = ghost.calculateMaxHealth();
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_CUR_HEALTH, health);
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_MAX_HEALTH, health);

        // reset the 'last attack' timer
        Game.control.state.setRoomProperty(Codes.PROP_LAST_GHOST_ATTACK, null);

        // now actually spawn the ghost
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_ID, [ ghosts[ix], names[ix], level ]);

        Game.log.debug("Spawned new ghost: " + ghosts[ix] + "/" + names[ix] + "/" + level);

        return ghost;
    }

    public static function loadIfPresent () :Ghost
    {
        var data :Object = Game.model.ghostId;
        if (data != null) {
            Game.log.debug("Loaded existing ghost: " + data.id + "/" + data.level);
            return new Ghost(data.id as String, data.level as int);
        }
        return null;
    }

    public function Ghost (id :String, level :int)
    {
        _id = id;
        _level = level;
    }

    public function selfTerminate () :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_ID, null);
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_CUR_ZEST, null);
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_MAX_ZEST, null);
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_CUR_HEALTH, null);
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_MAX_HEALTH, null);
    }
    
    public function isDead () :Boolean
    {
        return Game.control.state.getRoomProperty(Codes.PROP_GHOST_CUR_HEALTH) === 0;
    }

    public function calculateSingleAttack () :int
    {
        // e.g. a level 3 ghost does 40-48 points of dmg to one target
        return rndStretch(10 * (_level + 1), 1.2);
    }
    
    public function calculateSplashAttack () :int
    {
        // e.g. a level 3 ghost does 16-24 points of dmg to the whole party
        return rndStretch(4 * (_level + 1), 1.5);
    }

    protected function rndStretch (n :int, f :Number) :int
    {
        // randomly stretch a value by a factor [1, f]
        return int(n * (1 + (f-1)*Game.random.nextNumber()));
    }
    
    public function calculateMaxZest () :int
    {
        return 150 + 100 * Game.random.nextNumber();
    }

    public function calculateMaxHealth () :int
    {
        return 100;
    }

    public function tick (tick :int) :void
    {
        return BasicBrain.tick(this, tick);
    }

    protected var _id :String;
    protected var _level :int;
}

}
