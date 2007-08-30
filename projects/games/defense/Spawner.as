package {

import flash.geom.Point;
    
/** Thing that spawns critters. :) */
public class Spawner
{
    public function Spawner (game :Game, player :int, loc :Point)
    {
        _game = game;
        _player = player;
        _loc = loc;
    }

    public function get player () :int
    {
        return _player;
    }

    // this is just scaffolding
    public function tick () :void
    {
        if (! _temp) {
            trace("SPAWNING SOME TEST CRITTERS");
            _temp = true;
            var critter :Critter = new Critter(_loc.x, _loc.y, Critter.TYPE_WEAK, player);
            _game.handleAddCritter(critter);
        }
    }

    protected var _temp :Boolean = false;

    protected var _game :Game;
    protected var _player :int;
    protected var _loc :Point;
}
}
