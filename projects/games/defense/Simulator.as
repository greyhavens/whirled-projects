package {

import flash.geom.Point;
    
import com.threerings.flash.MathUtil;

import units.Critter;
import units.Spawner;

/**
 * Contains all the game logic for directing critters on the map.
 */
public class Simulator
{
    public function Simulator (board :Board, game :Game)
    {
        _board = board;
        _game = game;
    }

    public function processSpawners (spawners :Array) :void
    {
        for each (var spawner :Spawner in spawners) {
                spawner.tick();
            }
    }

    public function processCritters (critters :Array, dt :Number) :void
    {
        for each (var critter :Critter in critters) {
                updateCurrentPosition(critter, dt);
                if (critter.delta.length < _targetUpdateEpsilon) {
                    updateTarget(critter);
                }
            }
    };

    protected function updateCurrentPosition (c :Critter, dt :Number) :void
    {
        c.delta.x = c.target.x - c.pos.x;
        c.delta.y = c.target.y - c.pos.y;
        c.vel.x = MathUtil.clamp(c.delta.x / dt, - c.maxvel, c.maxvel);
        c.vel.y = MathUtil.clamp(c.delta.y / dt, - c.maxvel, c.maxvel);
        c.pos.offset(c.vel.x * dt, c.vel.y * dt);
    }
        
    protected function updateTarget (c :Critter) :void
    {
        var p :Point = _board.getPathMap(c.player).getNextNode(c.target.x, c.target.y);
        if (p != null) {
            c.target.x = p.x;
            c.target.y = p.y;
        } else {
            trace("UNABLE TO ADVANCE CRITTER " + c + " - NO PATH FOUND!");
        }
        /*
        var delta :Point = _board.getPlayerTarget(c.player);
        delta.offset(-c.target.x, -c.target.y);

        if (Math.abs(delta.x) > Math.abs(delta.y)) {
            c.target.x += MathUtil.clamp(delta.x, -1, 1);
        } else {
            c.target.y += MathUtil.clamp(delta.y, -1, 1);
            }
        */
    }

    protected var _targetUpdateEpsilon :Number = 0.1;
    
    protected var _board :Board;
    protected var _game :Game;
}
}
