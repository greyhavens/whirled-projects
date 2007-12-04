package spawners {

import flash.geom.Point;

import game.Board;
import game.Game;

/** Spawner for a two-player game. */
public class PlayerSpawner extends AutoSpawner
{
    public static const WAVES_PER_LEVEL :int = 5;
    
    public function PlayerSpawner (main :Main, board :Board, game :Game, player :int, loc :Point)
    {
        super(main, board, game, player, loc);
    }

    public function setSpawnGroup (value :uint) :void
    {
        // is the value valid?
        if (value < _board.allies.length) {
            _spawnGroup = value;
        }
    }
    
    // from AutoSpawner
    override protected function getSpawnDefinitions () :Array // of typeName Strings
    {
        // no call to super - this replaces the parent version!

        // get the appropriate list of level definition
        var wave :Array = _board.allies[_spawnGroup] as Array;
        _waveCount++;

        return super.flattenWave(wave);
    }

    // from Spawner
    override protected function reevaluateDifficultyLevel () :int
    {
        return int(1 + Math.floor(_waveCount / WAVES_PER_LEVEL));
    }

    /** Which group from LevelDefinition's spawner2p definition will be used to spawn. */
    protected var _spawnGroup :int;
}
}
