package com.threerings.defense.spawners {

import flash.geom.Point;

import com.threerings.defense.Game;
import com.threerings.defense.Level;
import com.threerings.defense.units.Critter;
    
/** Thing that spawns critters. :) */
public class Spawner
{
    public function Spawner (game :Game, level :Level, player :int, loc :Point)
    {
        _game = game;
        _level = level;
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
        var spawningCurrentWave :Boolean = (_toSpawn.length > 0);
        
        if (spawningCurrentWave) {
            // spawn the next one when we're good and ready
            if (gameTime >= _nextSpawnTime) {
                var critter :Critter = new Critter(_loc.x, _loc.y, int(_toSpawn.shift()), player);
                _game.handleAddCritter(critter);
                _nextSpawnTime = gameTime + _unitDelay;

                // if we just finished a wave, wait a little longer before we start the next one
                if (_toSpawn.length == 0) {
                    _nextSpawnTime = gameTime + _groupDelay;
                }
            }

        } else {
            // we ran out of things to spawn. should we start another wave?

            var playerBusy :Boolean =
                (gameTime < _nextSpawnTime) ||    // not enough time
                (_game.getCritters().length > 0); // the last wave is still on board

            if (! playerBusy) {
                // figure out what to spawn
                _toSpawn = getSpawnDefinitions();
            }
        }
    }

    /** Returns an array of types of objects that should be spawned. */
    protected function getSpawnDefinitions () :Array // of int
    {
        // this base version doesn't provide anything interesting. subclasses need to replace it.
        return [ ];
    }
            
    protected var _game :Game;
    protected var _level :Level;
    protected var _player :int;
    protected var _loc :Point;

    protected var _nextSpawnTime :Number = 0;

    protected var _toSpawn :Array = new Array();
    protected var _unitDelay :Number = 1;
    protected var _groupDelay :Number = 3;
}
}
