package com.threerings.defense.spawners {

import flash.geom.Point;

import com.threerings.defense.Game;
import com.threerings.defense.Level;
import com.threerings.defense.tuning.LevelDefinitions;
import com.threerings.defense.units.Critter;
    
/** Spawner for a two-player game. */
public class PlayerSpawner extends AutoSpawner
{
    public function PlayerSpawner (game :Game, level :Level, player :int, loc :Point)
    {
        super(game, level, player, loc);
    }

    public function setSpawnGroup (value :uint) :void
    {
        // is the value valid?
        var spawndefs :Array = LevelDefinitions.getSpawnWaves(2, _level.number);
        if (value < spawndefs.length) {
            _spawnGroup = value;
        }
    }
    
    // from AutoSpawner
    override protected function getSpawnDefinitions () :Array // of int
    {
        // no call to super - this replaces the parent's version!

        // get the appropriate list of level definition
        var spawndefs :Array = LevelDefinitions.getSpawnWaves(2, _level.number);
        var wave :Array = (spawndefs[_spawnGroup]) as Array;
        return super.flattenWave(wave);
    }

    /** Which group from LevelDefinition's spawner2p definition will be used to spawn. */
    protected var _spawnGroup :int;
}
}
