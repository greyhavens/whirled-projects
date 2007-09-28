package com.threerings.defense.spawners {

import flash.geom.Point;

import com.threerings.defense.Game;
import com.threerings.defense.Level;
import com.threerings.defense.tuning.LevelDefinitions;
import com.threerings.defense.units.Critter;
    
/** Spawner for a single-player game. */
public class AutoSpawner extends Spawner
{
    public function AutoSpawner (game :Game, level :Level, player :int, loc :Point)
    {
        super(game, level, player, loc);
        _currentWave = 0;
    }

    // from Spawner
    override protected function getSpawnDefinitions () :Array // of int
    {
        // get the appropriate list of level definition
        var def :Object = LevelDefinitions.getLevelDefinition(1, _level.number);
        var wave :Array = ((def.spawner as Array)[_currentWave]) as Array;
        
        _currentWave = (_currentWave + 1) % (def.spawner as Array).length;

        var flatwave :Array = new Array();
        for each (var unitdef :Array in wave) {
                // def is of form: [ type, count ]
                var type :int = unitdef[0];
                var count :int = unitdef[1];
                for (var ii :int = 0; ii < count; ii++) {
                    flatwave.push(type);
                }
            }

        return flatwave;
    }

    protected var _currentWave :int;
}
}
