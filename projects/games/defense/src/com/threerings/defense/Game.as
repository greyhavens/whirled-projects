package com.threerings.defense {

import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getTimer; // function import

import com.threerings.defense.spawners.AutoSpawner;
import com.threerings.defense.spawners.PlayerSpawner;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.defense.units.Critter;
import com.threerings.defense.units.Missile;
import com.threerings.defense.units.Tower;
import com.threerings.defense.units.Unit;
import com.threerings.util.ArrayUtil;

public class Game
{
    public static const ROUND_DELAY :int = 3;
    
    public static const GAME_STATE_SPLASH :int = 1;
    public static const GAME_STATE_PLAY :int = 2;
    public static const GAME_STATE_WAIT :int = 3;
    public static const GAME_STATE_DONE :int = 4;

    public function Game (board :Board, display :Display)
    {
        _board = board;
        _display = display;
        
        _simulator = new Simulator(_board, this);

        _display.addEventListener(Event.ENTER_FRAME, handleGameTick);

        // initialize the cursor with dummy data - it will all get overwritten, eventually
        _cursor = new Tower(0, 0, Tower.TYPE_SANDBOX, _board.getMyPlayerIndex(), 0);

        _gamestate = GAME_STATE_SPLASH;
    }

    public function get state () :int
    {
        return _gamestate;
    }

    public function set state (value :int) :void
    {
        var oldvalue :int = _gamestate;
        _gamestate = value;
        _display.gameStateUpdated(oldvalue, value);
    }
    
    public function get myMoney () :Number
    {
        return _myMoney;
    }
    
    public function handleUnload (event : Event) : void
    {
        _display.removeEventListener(Event.ENTER_FRAME, handleGameTick);
        trace("GAME UNLOAD");
    }

    public function isSinglePlayerGame () :Boolean
    {
        return _board.getPlayerCount() == 1;
    }
    
    /** Handles the start of a new game. */
    public function gameStarted (event :StateChangedEvent) :void
    {
        _towers = new Array();
        _critters = new Array();
        _missiles = new Array();
    }

    public function gameEnded (event :StateChangedEvent) :void
    {
        _towers = null;
        _critters = null;
        _missiles = null;
    }

    public function roundStarted (event :StateChangedEvent) :void
    {
        state = GAME_STATE_PLAY;
        
        _board.roundStarted();
        _display.roundStarted();
       
        initializeSpawners();
    }

    public function roundEnded (event :StateChangedEvent) :void
    {
        state = GAME_STATE_WAIT;
        
        removeAllUnits();

        _board.roundEnded();
        _display.roundEnded();
    }

    public function initializeSpawners () :void
    {
        var playerCount :uint = _board.getPlayerCount();
        var spawnerClass :Class = (playerCount == 1) ? AutoSpawner : PlayerSpawner;

        _spawners = new Array(playerCount);
        for (var ii :int = 0; ii < playerCount; ii++) {
            _spawners[ii] = new spawnerClass(this, _board.level, ii, _board.getPlayerSource(ii));
        }
    }

    public function missileReachedTarget (missile :Missile) :void
    {
        // subtract some health from the critter, maybe remove it
        var target :Critter = missile.target;
        target.health -= missile.damage;

        if (target.health <= 0) {
            // the missile might have reached a critter that's already removed from the game.
            // don't try to remove it twice.
            if (ArrayUtil.contains(_critters, target)) {
                _display.displayKill(
                    missile.source.player, target.pointValue, target.centroidx, target.centroidy);
                handleRemoveCritter(target);
            } 
        }

        missileExpired(missile);
    }

    public function missileExpired (missile :Missile) :void
    {
        handleRemoveMissile(missile);
    }

    public function critterReachedTarget (critter :Critter) :void
    {
        // show the enemy reaching the target
        _display.displayEnemySuccess(critter.player);
        
        // now just remove the critter
        handleRemoveCritter(critter);
    }

    public function towerFiredAt (tower :Tower, critter :Critter) :void
    {
        _display.handleTowerFired(tower, critter);
    }

    public function removeAllUnits () :void
    {
        var remove :Function = function (array :Array, removefn :Function) :void
        {
            var copy :Array = array.map (function (elt :*, ... ignore) :* { return elt; });
            for each (var elt :* in copy) {
                    removefn(elt);
                }
        }

        remove(_missiles, handleRemoveMissile);
        remove(_critters, handleRemoveCritter);
        remove(_towers, handleRemoveTower);        
    }
    
    public function handleAddTower (tower :Tower, index :int) :void
    {
        _towers.push(tower);
        _board.markAsOccupied(tower);
        _display.handleAddTower(tower);
    }

    public function handleRemoveTower (tower :Tower) :void
    {
        _display.handleRemoveTower(tower);
        _board.markAsUnoccupied(tower);
        ArrayUtil.removeFirst(_towers, tower);
    }

    public function handleAddCritter (critter :Critter) :void
    {
        _critters.push(critter);
        _display.handleAddCritter(critter);
    }

    public function getCritters () :Array // of Critter
    {
        return _critters;
    }

    public function handleRemoveCritter (critter :Critter) :void
    {
        _display.handleRemoveCritter(critter);
        ArrayUtil.removeFirst(_critters, critter);
    }

    public function handleAddMissile (missile :Missile) :void
    {
        _missiles.push(missile);
        _display.handleAddMissile(missile);
    }

    public function handleRemoveMissile (missile :Missile) :void
    {
        _display.handleRemoveMissile(missile);
        ArrayUtil.removeFirst(_missiles, missile);
    }

    public function handleUpdateScore (playerId :int, score :Number) :void
    {
        _display.updateScore(playerId, score);
    }
    
    public function handleUpdateHealth (playerId :int, health :Number) :void
    {
        _display.updateHealth(playerId, health);
    }

    public function handleUpdateMoney (playerId :int, money :Number) :void
    {
        _display.updateMoney(playerId, money);
        if (playerId == _board.getMyPlayerIndex()) {
            _myMoney = money;
        }
    }

    public function handleResetMoney (allMoney :Array) :void
    {
        var myindex :int = _board.getMyPlayerIndex();
        _myMoney = allMoney[myindex];
        _display.updateMoney(myindex, _myMoney);
    }
        
    public function handleMouseMove (boardx :int, boardy :int) :void
    {
        var logical :Point = Unit.screenToLogicalPosition(boardx, boardy);
        if (logical.x != _cursor.pos.x || logical.y != _cursor.pos.y) {
            _cursor.pos.x = logical.x;
            _cursor.pos.y = logical.y;
            updateCursorDisplay();
        }
    }

    /** Change the current cursor type. */
    public function setCursorType (type :int) :void
    {
        _cursor.updateFromType(type);
        if (_board.isOnBoard(_cursor)) {
            _display.refreshCursor(_cursor);
        }
        updateCursorDisplay();
    }
    
    protected function updateCursorDisplay () :void
    {
        var onBoard :Boolean = _board.isOnBoard(_cursor);
        var overEmptySpace :Boolean = onBoard && _board.isUnoccupied(_cursor);
        if (onBoard) {
            _display.showCursor(_cursor, overEmptySpace);
        } else {
            _display.hideCursor();                    
        }
    }
        
    protected function handleGameTick (event :Event) :void
    {
        var thisTick :int = getTimer();
        var dt :Number = (thisTick - _lastTick) / 1000.0;
        _lastTick = thisTick;

        var gameTime :Number = thisTick / 1000.0; // todo: fix timers across clients?
        
        _simulator.processSpawners(_spawners, gameTime);
        _simulator.processTowers(_towers, gameTime);
        _simulator.processCritters(_critters, dt);
        _simulator.processMissiles(_missiles, dt);

        _board.processMaps();
    }

    protected var _board :Board;
    protected var _display :Display;
    protected var _simulator :Simulator;
    
    protected var _cursor :Tower;
    protected var _towers :Array; // of Tower
    protected var _critters :Array; // of Critter
    protected var _spawners :Array; // of Spawner
    protected var _missiles :Array; // of Missile
    protected var _myMoney :Number;

    protected var _gamestate :int;
    protected var _lastTick :int = getTimer();
}
}
