package game {

import flash.display.DisplayObject;
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

import def.BoardDefinition;
import modes.GameModeCanvas;
import sprites.CritterSprite;
import sprites.CursorSprite;
import sprites.FloatingScore;
import sprites.MissileSprite;
import sprites.TowerSprite;
import sprites.UnitSprite;
import ui.DebugPanel;
import ui.GroundOverlay;
import ui.Overlay;
import ui.ScorePanel;
import ui.SummaryPanel;
import ui.TowerPanel;
import ui.WaitingPanel;
import units.Critter;
import units.Missile;
import units.Tower;

/**
 * General game board display class, which contains and manages everything that happens during the
 * game.
 */
public class Display extends GameModeCanvas
    implements UnloadListener
{
    public function Display (main :Main)
    {
        super(main);
    }

    public function init (board :Board, game :Game, controller :Controller) :void
    {
        trace("*** DISPLAY: INIT");
        
        _board = board;
        _game = game;
        _controller = controller;
    }

    // @Override from Canvas
    override protected function createChildren () :void
    {
        // note: this happens after init

        super.createChildren();
        
        // initialize graphics
        _backdrop = new Image();
        addChild(_backdrop);

        _boardSprite = new Canvas();
        _boardSprite.x = _board.def.topleft.x;
        _boardSprite.y = _board.def.topleft.y;
        addChild(_boardSprite);

        // create ui elements
        _scorePanels = new Array(_main.playerCount);
        for (var ii :int = 0; ii < _main.playerCount; ii++) {
            addChild(_scorePanels[ii] = new ScorePanel());
        }

        createOverlays();
        
        // initialize event handlers
        addEventListener(MouseEvent.CLICK, handleBoardClick);
        addEventListener(MouseEvent.MOUSE_MOVE, handleBoardMove);
        addEventListener(Event.ENTER_FRAME, handleFrame);
    }
  
    /** Creates images for board overlay bitmaps. */
    protected function createOverlays () :void
    {
        _allOverlays = new Array();
        
        _groundOverlay = new GroundOverlay();
        _allOverlays.push(_groundOverlay);

        // these have to be created before we know how many players we actually have.
        // so let's make all of them, but only initialize those that we'll be using...
        _pathOverlays = new Array(_main.playerCount);
        for (var ii :int = 0; ii < _main.playerCount; ii++) {
            _pathOverlays[ii] = new Overlay();
            _allOverlays.push(_pathOverlays[ii]);
        }

        // give them initial values, so we can populate them
        resetOverlays();
        
        for each (var o :Overlay in _allOverlays) { 
            _boardSprite.addChild(o);
        }
    }

    // from Canvas
    override protected function childrenCreated () :void
    {
        super.childrenCreated();
        trace("*** DISPLAY: CHILDREN CREATED");
        
        handlePlayClicked(); // todo: factor me out
    }
    
    public function handleUnload () : void
    {
        Mouse.show();

        _towerPanel.handleUnload();

        hideUI();
        hideWaitingPopup();
        hideSummary();
        
        removeEventListener(MouseEvent.CLICK, handleBoardClick);
        removeEventListener(MouseEvent.MOUSE_MOVE, handleBoardMove);
        removeEventListener(Event.ENTER_FRAME, handleFrame);
        trace("DISPLAY UNLOAD");
    }



    // Functions available to the game logic

    public function gameStarted () :void
    {
        trace("*** DISPLAY: GAME STARTED");
        hideWaitingPopup();
        hideSummary();
        // todo: reset score?
    }

    public function gameEnded () :void
    {
        trace("*** DISPLAY: GAME ENDED");
        resetOverlays();
        resetBoardDisplay();

        showSummary();
    }

    public function roundStarted (round :int) :void
    {
        trace("*** DISPLAY: ROUND STARTED");
        resetOverlays();
        resetBoardDisplay();

        var count :int = _main.playerCount;
        var names :Array = _main.playerNames;
        for (var ii :int = 0; ii < count; ii++) {
            (_scorePanels[ii] as ScorePanel).reset(ii, names[ii], _board, _controller);
        }

        addChild(new FloatingScore(Messages.get("round_start") + round,
                                   Globals.BG_WIDTH / 2 - 50, Globals.BG_HEIGHT / 2,
                                   "floatingRoundInfo"));
    }

    public function roundEnded (round :int) :void
    {
        trace("*** DISPLAY: ROUND ENDED");
        addChild(new FloatingScore(Messages.get("round_end"),
                                   Globals.BG_WIDTH / 2 - 50, Globals.BG_HEIGHT / 2,
                                   "floatingRoundInfo"));
        hideCursor();
    }

    public function reportFlowAward (amount :int, percentile :int) :void
    {
        showSummary();
        _summary.addFlowScore(amount);
    }
    
    protected function resetBoardDisplay () :void
    {
        _backdrop.source = _board.def.background;
    }
    
    protected function resetOverlays () :void
    {
        _groundOverlay.init(_board, _board.getMapOccupancy(), _main.myIndex);

        for (var ii :int = 0; ii < _main.playerCount; ii++) {
            (_pathOverlays[ii] as Overlay).init(_board, _board.getPathMap(ii), ii);
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
        if (_towerPanel == null) {
            PopUpManager.addPopUp(_towerPanel = new TowerPanel(this, _board, _game), this, false);
            _towerPanel.x = 580;
            _towerPanel.y = 40;
        }

        if (_debugPanel == null) {
            PopUpManager.addPopUp(_debugPanel = new DebugPanel(this), this, false);
        }
    }

    /** Shows the game UI elements. */
    public function hideUI () :void
    {
        if (_towerPanel != null) {
            PopUpManager.removePopUp(_towerPanel);
            _towerPanel = null;
        }
        if (_debugPanel != null) {
            PopUpManager.removePopUp(_debugPanel);
            _debugPanel = null;
        }
    }
    
    // Functions called by the game controller

    /** Called when the game state was changed (e.g. switching between levels). */
    public function gameStateUpdated (oldstate :int, newstate :int) :void
    {
        if (oldstate == Game.GAME_STATE_INIT) {
//            removeChild(_splash);
            showUI();
        }
    }

    /** Displays a little bit of feedback when a spawner's difficulty level increases. */
    public function showNewSpawnerDifficulty (playerIndex :int, difficulty :int) :void
    {
        if (_main.isSinglePlayer) {
            addChild(new FloatingScore(Messages.get("level") + difficulty,
                                       Globals.BG_WIDTH / 2 - 50, Globals.BG_HEIGHT / 2,
                                       "floatingRoundInfo"));
        } else {
            var pos :Point = Globals.SCOREPANEL_POS[playerIndex];
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
            _cursor = new CursorSprite(tower, _board);
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
        var sprite :TowerSprite = new TowerSprite(tower, _board);
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
            (! _board.main.isSinglePlayer) && (_board.main.myIndex == critter.player);
        var sprite :CritterSprite = new CritterSprite(critter, _board, friendly);
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
        if (playerId == _main.myIndex) {
            var floater :FloatingScore = new FloatingScore("+" + String(points), x, y);
            _boardSprite.addChild(floater);
        }
        
        _controller.changeScore(playerId, points);
        _controller.changeMoney(playerId, points);
    }

    /** Forwards a health decrease request to the server. */
    public function displayEnemySuccess (critterPlayer :int) :void
    {
        var myIndex :int = _board.main.myIndex;
        
        // who was the target of this attack?
        var targetPlayer :int = myIndex;         // in single player i'm the target
        if (! _board.main.isSinglePlayer &&      // but in multiplayer,
            critterPlayer == myIndex)            // if this was my critter,
        {
            targetPlayer = (1 - myIndex);        // then the other player was the target.
        }
        
        // tell the server
        _controller.decrementHealth(critterPlayer, targetPlayer);
    }

    /**
     * This function is called as the result of health change making its server round-trip.
     * Given the player id and new health, updates the display.
     */
    public function updateHealth (player :int, health :Number) :void
    {
        (_scorePanels[player] as ScorePanel).health = health;
        if (player == _board.main.myIndex) {
            // _statusBar.health = health;
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
        if (player == _board.main.myIndex) {
            _towerPanel.updateAvailability(money);

            // if the player's current tower is too expensive, reset the cursor
            if (_cursor != null && _cursor.tower.cost > money) {
                hideCursor();
            }
        }
    }

    public function handleAddMissile (missile :Missile) :void
    {
        var sprite :MissileSprite = new MissileSprite(missile, _board);
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
        hideSummary(); // if it's shown at all...
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
        updateSprites();
        updateOverlays();
    }

    protected function showWaitingPopup () :void
    {
        // if we're waiting for more players, show a popup...
        if (_waiting == null && ! _board.main.isSinglePlayer) {
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

    protected function showSummary () :void
    {
        if (_summaryAnimation == null) {
            _summaryAnimation = makeSummaryAnimation();
            addChild(_summaryAnimation);
        }
        if (_summary == null) {
            _summary = new SummaryPanel(
                _main, _controller, handlePlayClicked, _controller.forceQuitGame)
            PopUpManager.addPopUp(_summary, this, false);
        }
        
    }

    protected function hideSummary () :void
    {
        if (_summaryAnimation != null) {
            removeChild(_summaryAnimation);
            _summaryAnimation = null;
        }
        if (_summary != null) {
            PopUpManager.removePopUp(_summary);
            _summary = null;
        }
    }

    protected function makeSummaryAnimation () :Canvas
    {
        var anim :Class;

        if (_board.main.isSinglePlayer) {
            anim = _gameoverscreen;
            
        } else {
            // in multiplayer, compare scores first
            var myIndex :int = _board.main.myIndex;
            var otherIndex :int = 1 - _board.main.myIndex;

            if (_game.scores[myIndex] < _game.scores[otherIndex]) {
                anim = _losescreen;
            } else {
                anim = _winscreen;
            }
        }
            
        // now make a fake canvas to hold it
        var c :Canvas = new Canvas();
        c.rawChildren.addChild((new anim()) as DisplayObject);

        return c;
    }
    
    [Embed(source="../../rsrc/victory/you_win.swf")]
        private static const _winscreen :Class;

    [Embed(source="../../rsrc/victory/you_lose.swf")]
        private static const _losescreen :Class;

    [Embed(source="../../rsrc/victory/GameOver.swf")]
        private static const _gameoverscreen :Class;
    
    protected var _board :Board;
    protected var _game :Game;
    protected var _controller :Controller;

    protected var _towerPanel :TowerPanel;
    protected var _debugPanel :DebugPanel;
    protected var _waiting :WaitingPanel;
    protected var _summary :SummaryPanel;
    protected var _summaryAnimation :DisplayObject;
    protected var _scorePanels :Array; // of ScorePanel

    protected var _boardSprite :Canvas;
    protected var _backdrop :Image;

    protected var _groundOverlay :Overlay;
    protected var _pathOverlays :Array; // of Overlay, one per player
    protected var _allOverlays :Array; // of Overlay
    
    protected var _cursor :CursorSprite;
    protected var _towers :HashMap = new HashMap(); // from Tower guid to TowerSprite
    protected var _critters :HashMap = new HashMap(); // from Critter guid to CritterSprite
    protected var _missiles :HashMap = new HashMap(); // from Missile guid to MissileSprite

}
}
