package {

import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.utils.getTimer; // function import

import mx.containers.Canvas;
import mx.controls.Button;
import mx.controls.ButtonBar;
import mx.controls.Image;
import mx.controls.Label;
import mx.events.ItemClickEvent;

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;

public class Display extends Canvas
{
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
        _backdrop.scaleX = Board.PIXEL_WIDTH / _backdrop.source.width;
        _backdrop.scaleY = Board.PIXEL_HEIGHT / _backdrop.source.height;
        _boardSprite.addChild(_backdrop);

        createUI();
        
        // initialize event handlers
        addEventListener(MouseEvent.CLICK, handleBoardClick);
        addEventListener(MouseEvent.MOUSE_MOVE, handleBoardMove);
        addEventListener(Event.ENTER_FRAME, handleFrame);
    }

    /** Creates buttons and other UI elements. */
    protected function createUI () :void
    {
        _counter = new Label();
        _counter.x = 10;
        _counter.y = 0;
        addChild(_counter);

        var buttonBar :ButtonBar = new ButtonBar();
        buttonBar.addEventListener(ItemClickEvent.ITEM_CLICK, handleButtonBarClick);
        buttonBar.x = 700;
        buttonBar.y = 40;
        addChild(buttonBar);
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
    }

    // Functions called by the game controller
    
    /**
     * Single function for moving and/or changing the cursor. If the cursor was not previously
     * shown, it will be created.
     */
    public function showCursor (defref :TowerDef, valid :Boolean) :void
    {
        Mouse.hide();
        if (_cursor == null) {
            _cursor = new TowerSprite(defref);
            _boardSprite.addChild(_cursor);
        } else {
            _cursor.defref = defref;
        }
        _cursor.updateLocation();
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
    public function setCursorType (defref :TowerDef) :void
    {
        hideCursor();
        showCursor(defref, true);
    }
        
    public function handleAddTower (tower :Tower) :void
    {
        var sprite :TowerSprite = new TowerSprite(tower.def);
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


    // Event handlers
    
    protected function handleBoardClick (event :MouseEvent) :void
    {
        trace("*** CLICK: " + event);
        _controller.addTower(_cursor.defref);
    }

    protected function handleBoardMove (event :MouseEvent) :void
    {
        var local :Point = _boardSprite.globalToLocal(new Point(event.stageX, event.stageY));
        var logical :Point = Board.screenToLogicalPosition(local.x, local.y);
        _game.handleMouseMove(logical);
    }

    protected function handleFrame (event :Event) :void
    {
        var now :int = getTimer();
        var delta :Number = (now - _lastFrameTime) / 1000;
        _lastFrameTime = now;
        _fps = Math.round((_fps + 1 / delta) / 2);
        _counter.text = "FPS: " + _fps;
        
        updateCritterSprites();
    }

    protected function handleButtonBarClick (itemClick :ItemClickEvent) :void
    {
        
    }
    
    protected var _board :Board;
    protected var _game :Game;
    protected var _controller :Controller;
    
    protected var _boardSprite :Canvas;
    protected var _backdrop :Image;
    protected var _counter :Label;
    protected var _lastFrameTime :int;
    protected var _fps :Number = 0;

    protected var _cursor :TowerSprite;
    protected var _towers :HashMap = new HashMap(); // from Tower guid to TowerSprite
    protected var _critters :HashMap = new HashMap(); // from Critter guid to CritterSprite
}
}
