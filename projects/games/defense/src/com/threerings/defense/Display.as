package com.threerings.defense {

import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.system.System;
import flash.ui.Mouse;
import flash.utils.getTimer; // function import

import mx.containers.Canvas;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.Text;
import mx.managers.PopUpManager;

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;

import com.threerings.defense.maps.MapFactory;
import com.threerings.defense.spawners.Spawner;
import com.threerings.defense.sprites.CritterSprite;
import com.threerings.defense.sprites.CursorSprite;
import com.threerings.defense.sprites.FloatingScore;
import com.threerings.defense.sprites.MissileSprite;
import com.threerings.defense.sprites.TowerSprite;
import com.threerings.defense.sprites.UnitSprite;
import com.threerings.defense.ui.DebugPanel;
import com.threerings.defense.ui.GroundOverlay;
import com.threerings.defense.ui.Overlay;
import com.threerings.defense.ui.ScorePanel;
import com.threerings.defense.ui.StatusBar;
import com.threerings.defense.ui.TowerPanel;
import com.threerings.defense.units.Critter;
import com.threerings.defense.units.Missile;
import com.threerings.defense.units.Tower;

import Log;

public class Display extends Canvas
{
    public static const MAX_PLAYERS :int = 2; // used for laying out display elements
    
    public function Display ()
    {
    }

    // @Override from Canvas
    override protected function createChildren () :void
    {
        // note - this happens before init
        
        super.createChildren();
        
        // initialize graphics
        _backdrop = new Image();
        addChild(_backdrop);

        _boardSprite = new Canvas();
        _boardSprite.x = Board.BOARD_OFFSETX;
        _boardSprite.y = Board.BOARD_OFFSETY;
        addChild(_boardSprite);

        createUI();
        createOverlays();
        
        // initialize event handlers
        addEventListener(MouseEvent.CLICK, handleBoardClick);
        addEventListener(MouseEvent.MOUSE_MOVE, handleBoardMove);
        addEventListener(Event.ENTER_FRAME, handleFrame);
    }
  
    /** Creates buttons and other UI elements. */
    protected function createUI () :void
    {
        PopUpManager.addPopUp(_towerPanel = new TowerPanel(this), this, false);
        PopUpManager.addPopUp(_debugPanel = new DebugPanel(this), this, false);
        addChild(_statusBar = new StatusBar());

        // these have to be created before we know how many players we actually have.
        // so let's make all of them, and later initialize those that get used.
        _scorePanels = new Array(MAX_PLAYERS);
        for (var ii :int = 0; ii < MAX_PLAYERS; ii++) {
            addChild(_scorePanels[ii] = new ScorePanel());
        }
        
        _counter = new Text();
        _counter.x = 10;
        _counter.y = 40;
        addChild(_counter);
    }
        
    /** Creates images for board overlay bitmaps. */
    protected function createOverlays () :void
    {
        _allOverlays = new Array();
        
        _groundOverlay = new GroundOverlay();
        _allOverlays.push(_groundOverlay);

        // these have to be created before we know how many players we actually have.
        // so let's make all of them, but only initialize those that we'll be using...
        _pathOverlays = new Array(MAX_PLAYERS);
        for (var ii :int = 0; ii < MAX_PLAYERS; ii++) {
            _pathOverlays[ii] = new Overlay();
            _allOverlays.push(_pathOverlays[ii]);
        }

        for each (var o :Overlay in _allOverlays) { 
            _boardSprite.addChild(o);
        }
    }

    public function init (board :Board, game :Game, controller :Controller) :void
    {
        trace("*** DISPLAY: INIT");
        
        _board = board;
        _game = game;
        _controller = controller;

        _towerPanel.init(board, game);
        _statusBar.init(board);
    }

    public function handleUnload (event : Event) : void
    {
        PopUpManager.removePopUp(_towerPanel);
        _towerPanel.handleUnload(event);
        
        removeEventListener(MouseEvent.CLICK, handleBoardClick);
        removeEventListener(MouseEvent.MOUSE_MOVE, handleBoardMove);
        removeEventListener(Event.ENTER_FRAME, handleFrame);
        trace("DISPLAY UNLOAD");
    }
    
    // Functions available to the game logic
    
    /** Initializes the empty board. */
    public function reset () :void
    {
        removeAllTowers();
        resetOverlays();
        resetBoardDisplay();

        var count :int = _board.getPlayerCount();
        var names :Array = _board.getPlayerNames();
        for (var ii :int = 0; ii < count; ii++) {
            (_scorePanels[ii] as ScorePanel).reset(ii, names[ii], _board.getInitialHealth());
        }

        _statusBar.reset(names[_board.getMyPlayerIndex()], _board);

        var pos :Point = Board.TOWERPANEL_POS[_board.getMyPlayerIndex()];
        _towerPanel.x = pos.x;
        _towerPanel.y = pos.y;
    }

    protected function resetBoardDisplay () :void
    {
        _backdrop.source = _board.level.loadBackground(_board.getPlayerCount());
    }
    
    protected function resetOverlays () :void
    {
        _groundOverlay.init(_board.getMapOccupancy(), _board.getMyPlayerIndex());

        var count :int = _board.getPlayerCount();
        for (var ii :int = 0; ii < count; ii++) {
            (_pathOverlays[ii] as Overlay).init(_board.getPathMap(ii), ii);
        }
    }

    /** Shows path overlay for the specified player. Does not hide any other overlays. */
    public function showPathOverlay (player :int) :void
    {
        var o :Overlay = _pathOverlays[player] as Overlay;
        if (o.ready()) {
            o.visible = true;
        }
    }

    /** Hides all path overlays. */
    public function hidePathOverlays () :void
    {
        for each (var o :Overlay in _pathOverlays) {
                if (o.ready()) {
                    o.visible = false;
                }
            }
    }

    // Functions called by the game controller
    
    /** Single function for moving and/or changing the cursor. If the cursor was not previously
     *  shown, it will be created. */
    public function showCursor (tower :Tower, valid :Boolean) :void
    {
        if (tower.cost > _game.myMoney) {
            return; // we can't afford it - don't even show the cursor
        }
        
        Mouse.hide();
        if (_cursor == null) {
            _cursor = new CursorSprite(tower, _board.level);
            _boardSprite.addChild(_cursor);
        }
        if (_cursor.tower != tower) {
            _cursor.updateTower(tower);
        }
        _cursor.update();
        _cursor.setValid(valid);
    }

    /** Hides the cursor (if one is visible) */
    public function hideCursor () :void
    {
        if (_cursor != null) {
            _boardSprite.removeChild(_cursor);
            _cursor = null;
        }
        Mouse.show();
    }

    /** If the cursor is currently displayed, changes its sprite. */
    public function refreshCursor (tower :Tower) :void
    {
        if (_cursor != null) {
            hideCursor();
            showCursor(tower, true);
        }
    }
        
    public function handleAddTower (tower :Tower) :void
    {
        var sprite :TowerSprite = new TowerSprite(tower, _board.level);
        _boardSprite.addChild(sprite);
        _towers.put(tower.guid, sprite);
        sprite.update();
    }
    
    public function handleAddCritter (critter :Critter) :void
    {
        var sprite :CritterSprite = new CritterSprite(critter, _board.level);
        _boardSprite.addChild(sprite);
        _critters.put(critter.guid, sprite);
        sprite.update();
    }

    public function handleRemoveCritter (critter :Critter) :void
    {
        var sprite :CritterSprite = _critters.get(critter.guid);
        if (sprite == null) {
            // this critter's already dead!
            // Log.getLog(this).info("Unit not in display list, cannot remove: " + critter);
            return;
        }

        _boardSprite.removeChild(sprite);
        _critters.remove(critter.guid);
    }

    public function handleTowerFired (tower :Tower, critter :Critter) :void
    {
        var sprite :TowerSprite = _towers.get(tower.guid);
        if (sprite != null) {
            sprite.firingTarget = critter.pos;
        }
    }

    /**
     * Displays a little floating score bubble, and forwards the points over to the controller
     * to add to the scoreboard.
     */
    public function displayKill (playerId :int, points :Number, x :Number, y :Number) :void
    {
        // if it's this player's kill, display floating score display
        if (playerId == _board.getMyPlayerIndex()) {
            var floater :FloatingScore = new FloatingScore("+" + String(points), x, y);
            _boardSprite.addChild(floater);
        }
        
        _controller.changeScore(playerId, points);
        _controller.changeMoney(playerId, points);
    }

    /** Forwards a health decrease request to the server. */
    public function displayEnemySuccess (critterPlayer :int) :void
    {
        var myIndex :int = _board.getMyPlayerIndex();
        
        // who was the target of this attack?
        var targetPlayer :int = myIndex;         // in single player i'm the target
        if (_board.getPlayerCount() == 2 &&      // but in multiplayer,
            critterPlayer == myIndex)            // if this was my critter,
        {
            targetPlayer = (1 - myIndex);        // then the other player was the target.
        }
        
        // tell the server
        _controller.decrementHealth(critterPlayer, targetPlayer);
    }

    /**
     * This function is called as the result of score change making its round-trip to the server.
     * Given the player id and new score, updates the display.
     */
    public function updateScore (player :int, score :Number) :void
    {
        //(_scorePanels[player] as ScorePanel).score = score;
        if (player == _board.getMyPlayerIndex()) {
            _statusBar.score = score;
        }
    }

    /**
     * This function is called as the result of health change making its server round-trip.
     * Given the player id and new health, updates the display.
     */
    public function updateHealth (player :int, health :Number) :void
    {
        (_scorePanels[player] as ScorePanel).health = health;
        if (player == _board.getMyPlayerIndex()) {
            _statusBar.health = health;
        }
    }
    
    /**
     * This function is called as the result of money change making its server round-trip.
     * Given the player id and new health, updates the display.
     */
    public function updateMoney (player :int, money :Number) :void
    {
        if (player == _board.getMyPlayerIndex()) {
            // update displays
            _statusBar.money = money;
            _towerPanel.updateAvailability(money);

            // if the player's current tower is too expensive, reset the cursor
            if (_cursor != null && _cursor.tower.cost > money) {
                hideCursor();
            }
        }
    }

    public function handleAddMissile (missile :Missile) :void
    {
        var sprite :MissileSprite = new MissileSprite(missile, _board.level);
        _boardSprite.addChild(sprite);
        _missiles.put(missile.guid, sprite);
        sprite.update();
    }

    public function handleRemoveMissile (missile :Missile) :void
    {
        var sprite :MissileSprite = _missiles.get(missile.guid);
        if (sprite != null) {
            _boardSprite.removeChild(sprite);
            _missiles.remove(missile.guid);
        }
    }
    
    /**
     * Gets rid of all towers.
     */
    protected function removeAllTowers () :void
    {
        for each (var sprite :TowerSprite in _towers) {
                _boardSprite.removeChild(sprite);
            };
        _towers = new HashMap();
    }

    public function updateOverlays () :void
    {
        for each (var o :Overlay in _allOverlays) {
            o.update();
        }
    }

    public function updateSprites () :void
    {
        _towers.forEach(unitSpriteUpdateWrapper);
        _critters.forEach(unitSpriteUpdateWrapper);
        _missiles.forEach(unitSpriteUpdateWrapper);
    }

    protected function unitSpriteUpdateWrapper (guid :*, sprite :UnitSprite) :void
    {
        sprite.update();
    }
                                      
    // Event handlers
    
    protected function handleBoardClick (event :MouseEvent) :void
    {
        if (_cursor != null) {
            _controller.requestAddTower(_cursor.tower);
        }
    }

    protected function handleBoardMove (event :MouseEvent) :void
    {
        var local :Point = _boardSprite.globalToLocal(new Point(event.stageX, event.stageY));
        _game.handleMouseMove(local.x, local.y);
    }

    protected function handleFrame (event :Event) :void
    {
        var now :int = getTimer();
        var delta :Number = (now - _lastFrameTime) / 1000;
        _lastFrameTime = now;

        _fps = Math.round((_fps + 1 / delta) / 2);
        var mem :Number = System.totalMemory;
        _maxmem = Math.max(mem, _maxmem);
        
        _counter.htmlText = "MEM: " + mem + "<br>MAX: " + _maxmem + "<br>FPS: " + _fps;
        
        updateSprites();
        updateOverlays();
    }

    protected var _board :Board;
    protected var _game :Game;
    protected var _controller :Controller;

    protected var _towerPanel :TowerPanel;
    protected var _debugPanel :DebugPanel;
    protected var _statusBar :StatusBar;
    protected var _scorePanels :Array; // of ScorePanel
    
    protected var _boardSprite :Canvas;
    protected var _backdrop :Image;
    protected var _counter :Text;
    protected var _lastFrameTime :int;

    protected var _fps :Number = 0;
    protected var _maxmem :Number = 0;
    
    protected var _groundOverlay :Overlay;
    protected var _pathOverlays :Array; // of Overlay, one per player
    protected var _allOverlays :Array; // of Overlay
    
    protected var _cursor :CursorSprite;
    protected var _towers :HashMap = new HashMap(); // from Tower guid to TowerSprite
    protected var _critters :HashMap = new HashMap(); // from Critter guid to CritterSprite
    protected var _missiles :HashMap = new HashMap(); // from Missile guid to MissileSprite
}
}
