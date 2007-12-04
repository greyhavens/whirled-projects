package spawners {

import flash.geom.Point;

import game.Board;
import game.Game;

import def.WaveElementDefinition;
    
/** Spawner for a single-player game. */
public class AutoSpawner extends Spawner
{
    public function AutoSpawner (main :Main, board :Board, game :Game, player :int, loc :Point)
    {
        super(main, board, game, player, loc);
        _currentWave = 0;
        _waveCount = 0;
    }

    // from Spawner
    override protected function getSpawnDefinitions () :Array // of typeName Strings
    {
        // get the appropriate list of level definition
        var wave :Array = (_board.enemies[_currentWave]) as Array;
        _currentWave = (_currentWave + 1) % _board.enemies.length;
        _waveCount++;
        
        return flattenWave(wave);
    }

    // from Spawner
    override protected function reevaluateDifficultyLevel () :int
    {
        return int(1 + Math.floor(_waveCount / _board.enemies.length));
    }

    protected function flattenWave (wave :Array) :Array
    {
        var flatwave :Array = new Array();
        for each (var unitdef :WaveElementDefinition in wave) {
            for (var ii :int = 0; ii < unitdef.count; ii++) {
                flatwave.push(unitdef.typeName);
            }
        }

        return flatwave;
    }

    protected var _currentWave :int;
    protected var _waveCount :int; // how many sets of waves we've gone through
}
}
