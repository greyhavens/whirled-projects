package com.threerings.defense.units {

import flash.geom.Point;

import com.threerings.defense.Game;
    
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
    public function spawnIfPossible (gameTime :Number) :void
    {
        if (gameTime < _nextSpawnTime) {
            return;
        }

        for each (var d :int in [0]) {
                var critter :Critter = new Critter(_loc.x + d, _loc.y, Critter.TYPE_BULLY, player);
                _game.handleAddCritter(critter);
            }
        _nextSpawnTime = gameTime + _spawnDelay;
    }

    protected var _game :Game;
    protected var _player :int;
    protected var _loc :Point;

    protected var _nextSpawnTime :Number = 0;
    protected var _spawnDelay :Number = 3;
}
}
