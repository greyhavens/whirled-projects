package com.threerings.defense.spawners {

import flash.geom.Point;

import com.threerings.defense.Game;
import com.threerings.defense.Level;
import com.threerings.defense.units.Critter;
    
/** Spawner for a single-player game. */
public class PlayerSpawner extends Spawner
{
    public function PlayerSpawner (game :Game, level :Level, player :int, loc :Point)
    {
        super(game, level, player, loc);
    }

    // from Spawner
    override protected function getSpawnDefinitions () :Array // of int
    {
        // todo: make this player-configurable
        return [ Critter.TYPE_BIRD, Critter.TYPE_BIRD ];
    }
}
}
