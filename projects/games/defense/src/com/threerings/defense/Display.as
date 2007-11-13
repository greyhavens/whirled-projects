package com.threerings.defense {

import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.system.System;
import flash.ui.Mouse;
import flash.utils.getTimer; // function import

import mx.containers.Canvas;
import mx.controls.Button;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.Text;
import mx.managers.PopUpManager;

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.threerings.defense.maps.MapFactory;
import com.threerings.defense.tuning.Messages;
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
import com.threerings.defense.ui.SummaryPanel;
import com.threerings.defense.ui.TowerPanel;
import com.threerings.defense.ui.WaitingPanel;
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

        _towerPanel.x = 580;
        _towerPanel.y = 40;
        
        hideUI();
        
        // these have to be created before we know how many players we actually have.
        // so let's make all of them, and later initialize those that get used.
        _scorePanels = new Array(MAX_PLAYERS);
        for (var ii :int = 0; ii < MAX_PLAYERS; ii++) {
            addChild(_scorePanels[ii] = new ScorePanel());
        }
        
        _counter = new Text();
        _counter.x = 5;
        _counter.y = 420;
        addChild(_counter);

        _splash = new Splash(handlePlayClicked);
        addChild(_splash);
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

    public function gameStarted () :void
    {
        hideWaitingPopup();
        hideSummaryPopup();
        _statusBar.score = 0;
    }

    public function gameEnded () :void
    {
        resetOverlays();
        resetBoardDisplay();

        showSummaryPopup();
    }

    public function roundStarted (round :int) :void
    {
        resetOverlays();
        resetBoardDisplay();

        var count :int = _board.getPlayerCount();
        var names :Array = _board.getPlayerNames();
        for (var ii :int = 0; ii < count; ii++) {
            (_scorePanels[ii] as ScorePanel).reset(ii, names[ii], _board, _controller);
        }
        _statusBar.reset(_board.getPlayerNames()[_board.getMyPlayerIndex()], _board);

        addChild(new FloatingScore(Messages.get("round_start") + round,
                                   Board.BG_WIDTH / 2 - 50, Board.BG_HEIGHT / 2,
                                   "floatingRoundInfo"));
    }

    public function roundEnded (round :int) :void
    {
        addChild(new FloatingScore(Messages.get("round_end"),
                                   Board.BG_WIDTH / 2 - 50, Board.BG_HEIGHT / 2,
                                   "floatingRoundInfo"));
        hideCursor();
    }

    public function reportFlowAward (amount :int, percentile :int) :void
    {
        showSummaryPopup();
        _summary.addFlowScore(amount);
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

    /** Shows the game UI elements. */
    public function showUI () :void
    {
        _towerPanel.visible = _debugPanel.visible = true;
    }

    /** Shows the game UI elements. */
    public function hideUI () :void
    {
        _towerPanel.visible = _debugPanel.visible = false;
    }
    
    // Functions called by the game controller

    /** Called when the game state was changed (e.g. switching between levels). */
    public function gameStateUpdated (oldstate :int, newstate :int) :void
    {
        if (oldstate == Game.GAME_STATE_SPLASH) {
            removeChild(_splash);
            showUI();
        }
    }

    /** Displays a little bit of feedback when a spawner's difficulty level increases. */
    public function showNewSpawnerDifficulty (playerIndex :int, difficulty :int) :void
    {
        if (_board.getPlayerCount() == 1) {
            addChild(new FloatingScore(Messages.get("level") + difficulty,
                                       Board.BG_WIDTH / 2 - 50, Board.BG_HEIGHT / 2,
                                       "floatingRoundInfo"));
        } else {
            var pos :Point = Board.SCOREPANEL_POS[playerIndex];
            addChild(new FloatingScore(Messages.get("level") + difficulty, pos.x, pos.y));
        }
    }
    
    /** Single function for moving and/or changing the cursor. If the cursor was not previously
     *  shown, it will be created. */
    public function showCursor (tower :Tower, valid :Boolean) :void
    {
        if (_game.state != Game.GAME_STATE_PLAY) {
            Mouse.show();
            return; // only show a tower cursor during play
        }
        
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
    
    public function handleRemoveTower (tower :Tower) :void
    {
        var sprite :TowerSprite = _towers.get(tower.guid);
        if (sprite != null) {
            _boardSprite.removeChild(sprite);
            _towers.remove(tower.guid);
        }
    }

    public function handleAddCritter (critter :Critter) :void
    {
        var friendly :Boolean =
            (_board.getPlayerCount() > 1) && (_board.getMyPlayerIndex() == critter.player);
        var sprite :CritterSprite = new CritterSprite(critter, _board.level, friendly);
        _boardSprite.addChild(sprite);
        _critters.put(critter.guid, sprite);
        sprite.update();
        sprite.updateHealth();
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

    public function updateCritterHealth (critter :Critter) :void
    {
        var sprite :CritterSprite = _critters.get(critter.guid);
        if (sprite != null) {
            sprite.updateHealth();
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

        if (health <= 0) {
            _controller.playerLost(player);
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

    protected function handlePlayClicked () :void
    {
        hideSummaryPopup(); // if it's shown at all...
        showWaitingPopup();
        _controller.playerReady();
    }
    
    protected function handleBoardClick (event :MouseEvent) :void
    {
        if (_cursor != null) {
            _controller.requestAddTower(_cursor.tower);
        }
    }

    protected function handleBoardMove (event :MouseEvent) :void
    {
        if (_game != null) {
            var local :Point = _boardSprite.globalToLocal(new Point(event.stageX, event.stageY));
            _game.handleMouseMove(local.x, local.y);
        }
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

    protected function showWaitingPopup () :void
    {
        // if we're waiting for more players, show a popup...
        if (_waiting == null && _board.getPlayerCount() > 1) {
            PopUpManager.addPopUp(_waiting = new WaitingPanel(_controller), this, false);
        }
    }

    protected function hideWaitingPopup () :void
    {
        if (_waiting != null) {
            PopUpManager.removePopUp(_waiting);
            _waiting = null;
        }
    }

    protected function showSummaryPopup () :void
    {
        if (_summary == null) {
            _summary = new SummaryPanel(_board, handlePlayClicked, _controller.forceQuitGame)
            PopUpManager.addPopUp(_summary, this, false);
        }
    }

    protected function hideSummaryPopup () :void
    {
        if (_summary != null) {
            PopUpManager.removePopUp(_summary);
            _summary = null;
        }
    }
    
    protected var _board :Board;
    protected var _game :Game;
    protected var _controller :Controller;

    protected var _splash :Splash;
    protected var _towerPanel :TowerPanel;
    protected var _debugPanel :DebugPanel;
    protected var _waiting :WaitingPanel;
    protected var _summary :SummaryPanel;
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
