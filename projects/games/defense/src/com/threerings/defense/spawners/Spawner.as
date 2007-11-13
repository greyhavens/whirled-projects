package com.threerings.defense.spawners {

import flash.geom.Point;

import com.threerings.util.Log;

import com.threerings.defense.Controller;
import com.threerings.defense.Game;
import com.threerings.defense.Level;
import com.threerings.defense.Main;
import com.threerings.defense.units.Critter;
    
/** Thing that spawns critters. :) */
public class Spawner
{
    /** Signifies that the spawner is in the middle of a wave. */
    public static const STATE_SPAWNING :int = 0;
    /** All the units have been spawned, but we need to wait for them to leave the board. */
    public static const STATE_SPAWNED :int = 1;
    /** This spawner is finished with the wave, and pending an okay from the game to continue. */
    public static const STATE_PENDING :int = 2;
    /** This spawner is ready to spawn a new wave. */
    public static const STATE_READY :int = 3;
        
    public function Spawner (game :Game, level :Level, player :int, loc :Point)
    {
        _game = game;
        _level = level;
        _player = player;
        _loc = loc;
        _difficulty = 1;
        _state = STATE_READY;
    }

    public function get player () :int
    {
        return _player;
    }

    public function setReady (value :Boolean) :void
    {
        if (value) {
            _state = STATE_READY;
        }
    }

    public function setDifficulty (value :int) :void
    {
        _difficulty = value;
    }
    
    /**
     * Spawning FSM. It has four basic states:
     *   SPAWNING, where it's in the middle of spawning a wave of units;
     *   SPAWNED, when it created all units, and is waiting until some minimal delay time passes,
     *      or until all units clear the board; 
     *   PENDING, where it's waiting for an okay from the Game to continue on to the next wave;
     *   READY, where it's figuring out what next wave to spawn, and goes back to SPAWNING.
     * This separation lets spawning times be synchronized over the network.
     */
    public function spawnIfPossible (gameTime :Number, controller :Controller) :void
    {
        if (_game.state != Game.GAME_STATE_PLAY) {
            return; // nothing to do right now
        }

        switch (_state) {
        case STATE_SPAWNING:
            // spawn the next one when we're good and ready
            if (gameTime >= _nextSpawnTime) {
                var critter :Critter =
                    new Critter(_loc.x, _loc.y, int(_toSpawn.shift()), player, _difficulty);
                
                _game.handleAddCritter(critter);
                _nextSpawnTime = gameTime + _unitDelay;

                // if we just finished a wave, wait a little longer before we start the next one
                if (_toSpawn.length == 0) {
                    _nextSpawnTime = gameTime + _groupDelay;
                    _state = STATE_SPAWNED;
                }
            }
            break;

        case STATE_SPAWNED:
            var playerBusy :Boolean =
                (gameTime < _nextSpawnTime) ||    // not enough time
                (_game.getCritters().length > 0); // the last wave is still on board

            if (! playerBusy) {
                if (_difficulty != reevaluateDifficultyLevel()) {
                    controller.updateSpawnerDifficulty(player, reevaluateDifficultyLevel());
                }
                controller.readyToSpawn(player);
                _state = STATE_PENDING;
            }
            break;
            
        case STATE_PENDING:
            // do nothing - the Game controller will pop us out of this state manually
//            trace("pending for player " + player);
            break;

        case STATE_READY:
            // figure out what to spawn           
            _toSpawn = getSpawnDefinitions();
            _state = STATE_SPAWNING;
            Main.gcHack(); // so naughty
            break;

        default:
            Log.getLog(this).warning("Unknown spawner state: " + _state);
        }
    }

    /** Returns an array of types of objects that should be spawned. */
    protected function getSpawnDefinitions () :Array // of int
    {
        // this base version doesn't provide anything interesting. subclasses need to replace it.
        return [ ];
    }

    /**
     * Called before spawning a new wave, it returns the difficulty level that should be used
     * while spawning all units in this wave.
     */
    protected function reevaluateDifficultyLevel () :int
    {
        // this base version doesn't provide anything interesting. subclasses should replace it.
        return 1;
    }

    protected var _game :Game;
    protected var _level :Level;
    protected var _player :int;
    protected var _loc :Point;
    protected var _state :int;
    protected var _difficulty :int;
    protected var _nextSpawnTime :Number = 0;

    protected var _toSpawn :Array = new Array();
    protected var _unitDelay :Number = 1;
    protected var _groupDelay :Number = 3;
}
}
