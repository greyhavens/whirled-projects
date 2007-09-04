package {

import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.utils.getTimer; // function import

import mx.containers.Canvas;
import mx.controls.Image;
import mx.controls.Label;
import mx.managers.PopUpManager;

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;

import units.Critter;
import units.Spawner;
import units.Tower;

import sprites.CritterSprite;
import sprites.TowerSprite;

import ui.Overlay;
import ui.UIWindow;

import maps.MapFactory;

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
        _boardSprite = new Canvas();
        _boardSprite.x = 0;
        _boardSprite.y = 20;
        addChild(_boardSprite);

        _backdrop = new Image();
        _backdrop.source = MapFactory.makeMapBackground(1);
        resizeImageToBoard(_backdrop);
        _boardSprite.addChild(_backdrop);

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
        PopUpManager.addPopUp(_ui = new UIWindow(this), this, false);
        
        _counter = new Label();
        _counter.x = 10;
        _counter.y = 0;
        addChild(_counter);
    }
        
    /** Creates images for board overlay bitmaps. */
    protected function createOverlays () :void
    {
        _allOverlays = new Array();
        
        _overlayOcc = new Overlay();
        _allOverlays.push(_overlayOcc);

        // these have to be created before we know how many player we actually have...
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
    }

    public function handleUnload (event : Event) : void
    {
        PopUpManager.removePopUp(_ui);
        _ui.handleUnload(event);
        
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
    }

    protected function resetOverlays () :void
    {
        _overlayOcc.init(_board.getMapOccupancy(), _board.getMyPlayerIndex());

        var count :int = _board.getPlayerCount();
        for (var ii :int = 0; ii < count; ii++) {
            (_pathOverlays[ii] as Overlay).init(_board.getPathMap(ii), ii);
        }
    }

    public function togglePathOverlay (player :int) :void
    {
        var o :Overlay = _pathOverlays[player] as Overlay;
        if (o.ready()) {
            o.visible = ! o.visible;
        }
    }
    
    // Functions called by the game controller
    
    /**
     * Single function for moving and/or changing the cursor. If the cursor was not previously
     * shown, it will be created.
     */
    public function showCursor (tower :Tower, valid :Boolean) :void
    {
        Mouse.hide();
        if (_cursor == null) {
            _cursor = new TowerSprite(tower);
            _boardSprite.addChild(_cursor);
        }
        if (_cursor.tower != tower) {
            _cursor.updateTower(tower);
        }
        _cursor.update();
        _cursor.setValid(valid);
    }

    /**
     * Hides the cursor (if one is visible)
     */
    public function hideCursor () :void
    {
        if (_cursor != null) {
            _boardSprite.removeChild(_cursor);
            _cursor = null;
        }
        Mouse.show();
    }

    /**
     * Changes the bitmap displayed under the cursor.
     */
    public function setCursorType (tower :Tower) :void
    {
        hideCursor();
        showCursor(tower, true);
    }
        
    public function handleAddTower (tower :Tower) :void
    {
        var sprite :TowerSprite = new TowerSprite(tower);
        _boardSprite.addChild(sprite);
        _towers.put(tower.guid, sprite);
    }
    
    public function handleAddCritter (critter :Critter) :void
    {
        var sprite :CritterSprite = new CritterSprite(critter);
        _boardSprite.addChild(sprite);
        _critters.put(critter.guid, sprite);
        sprite.update();
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

    
    public function updateCritterSprites () :void
    {
        var sprites :Array = _critters.values();
        for each (var cs :CritterSprite in sprites) {
                cs.update();
            }
    }

    public function updateOverlays () :void
    {
        for each (var o :Overlay in _allOverlays) {
            o.update();
        }
    }

    // Event handlers
    
    protected function handleBoardClick (event :MouseEvent) :void
    {
        trace("*** CLICK: " + event);
        if (_cursor != null) {
            _controller.addTower(_cursor.tower);
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
        _counter.text = "FPS: " + _fps;
        
        updateCritterSprites();
        updateOverlays();
    }

    /**
     * Scales image to be displayed at the same size as the board.
     */
    protected function resizeImageToBoard (image :Image) :void
    {
        image.scaleX = Board.PIXEL_WIDTH / image.source.width;
        image.scaleY = Board.PIXEL_HEIGHT / image.source.height;
    }


    
    protected var _board :Board;
    protected var _game :Game;
    protected var _controller :Controller;

    protected var _ui :UIWindow;
    protected var _boardSprite :Canvas;
    protected var _backdrop :Image;
    protected var _counter :Label;
    protected var _lastFrameTime :int;
    protected var _fps :Number = 0;

    protected var _overlayOcc :Overlay;
    protected var _pathOverlays :Array; // of Overlay, one per player
    protected var _allOverlays :Array; // of Overlay
    
    protected var _cursor :TowerSprite;
    protected var _towers :HashMap = new HashMap(); // from Tower guid to TowerSprite
    protected var _critters :HashMap = new HashMap(); // from Critter guid to CritterSprite
}
}
