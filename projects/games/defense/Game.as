package {

import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getTimer; // function import

import units.Critter;
import units.Spawner;
import units.Tower;

public class Game
{
    public function Game (board :Board, display :Display)
    {
        _board = board;
        _display = display;

        _simulator = new Simulator(_board, this);

        _display.addEventListener(Event.ENTER_FRAME, handleGameTick);

        // initialize the cursor with dummy data - it will all get overwritten, eventually
        _cursor = new Tower(0, 0, Tower.TYPE_SIMPLE, _board.getMyPlayerIndex(), 0);
    }

    public function handleUnload (event : Event) : void
    {
        _display.removeEventListener(Event.ENTER_FRAME, handleGameTick);
        trace("GAME UNLOAD");
    }

    /** Handles the start of a new game. */
    public function startGame () :void
    {
        _board.reset();
        _display.reset();
        
        _towers = new Array(Board.HEIGHT * Board.WIDTH);
        _critters = new Array();
        initializeSpawners();
    }

    public function endGame () :void
    {
        _towers = null;
        _critters = null;
    }

    public function resetRound () :void
    {
    }

    public function initializeSpawners () :void
    {
        var playerCount :uint = _board.getPlayerCount();
        _spawners = new Array(playerCount);
        for (var ii :int = 0; ii < playerCount; ii++) {
            _spawners[ii] = new Spawner(this, ii, _board.getPlayerSource(ii));
        }
    }

    public function handleAddTower (tower :Tower, index :int) :void
    {
        _towers.push(tower);
        _board.markAsOccupied(tower);
        _display.handleAddTower(tower);
    }

    public function handleRemoveTower (towerId :int) :void
    {
    }

    public function handleAddCritter (critter :Critter) :void
    {
        _critters.push(critter);
        _display.handleAddCritter(critter);
    }
    
    public function handleMouseMove (logical :Point) :void
    {
        if (logical.x != _cursor.x || logical.y != _cursor.y) {
            _cursor.x = logical.x;
            _cursor.y = logical.y;
            var onBoard :Boolean = _board.isOnBoard(_cursor);
            var overEmptySpace :Boolean = onBoard && _board.isUnoccupied(_cursor);
            if (onBoard) {
                _display.showCursor(_cursor, overEmptySpace);
            } else {
                _display.hideCursor();                    
            }
        }
    }
        
    protected function handleGameTick (event :Event) :void
    {
        var thisTick :int = getTimer();
        var dt :Number = (thisTick - _lastTick) / 1000.0;
        _lastTick = thisTick;

        _simulator.processSpawners(_spawners);
        _simulator.processCritters(_critters, dt);

        _board.processMaps();
    }

    protected var _board :Board;
    protected var _display :Display;
    protected var _simulator :Simulator;
    
    protected var _cursor :Tower;
    protected var _towers :Array; // of Tower
    protected var _critters :Array; // of Critter
    protected var _spawners :Array; // of Spawner

    protected var _lastTick :int = getTimer();
}
}
