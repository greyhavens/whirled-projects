package com.threerings.defense.spawners {

import flash.geom.Point;

import com.threerings.defense.Game;
import com.threerings.defense.units.Critter;
    
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

    /** Spawning function. */
    public function spawnIfPossible (gameTime :Number) :void
    {
        if (gameTime < _nextSpawnTime) {
            return;  // not yet!
        }
       
        // figure out what to spawn
        if (_toSpawn.length <= 0) {
            _toSpawn = getSpawnDefinitions();
        }

        // it's alive!
        var critter :Critter = new Critter(_loc.x, _loc.y, int(_toSpawn.shift()), player);
        _game.handleAddCritter(critter);
        _nextSpawnTime = gameTime + _unitDelay;

        // if we ran out of things to spawn, wait a little longer
        if (_toSpawn.length <= 0) {
            _nextSpawnTime = gameTime + _groupDelay;
        }
    }

    /** Returns an array of types of objects that should be spawned. */
    protected function getSpawnDefinitions () :Array // of int
    {
        // this base version doesn't provide anything interesting. subclasses need to replace it.
        return [ ];
    }

    protected var _game :Game;
    protected var _player :int;
    protected var _loc :Point;

    protected var _nextSpawnTime :Number = 0;

    protected var _toSpawn :Array = new Array();
    protected var _unitDelay :Number = 1;
    protected var _groupDelay :Number = 3;
}
}
