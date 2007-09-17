package com.threerings.defense.spawners {

import flash.geom.Point;

import com.threerings.defense.Game;
import com.threerings.defense.units.Critter;
    
/** Spawner for a single-player game. */
public class AutoSpawner extends Spawner
{
    public function AutoSpawner (game :Game, player :int, loc :Point)
    {
        super(game, player, loc);
    }

    // from Spawner
    override protected function getSpawnDefinitions () :Array // of int
    {
        // todo: something more interesting
        return [ Critter.TYPE_GIRL, Critter.TYPE_BULLY, Critter.TYPE_BIRD ];
    }
}
}
