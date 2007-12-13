//
// $Id$

package {

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.geom.Point;

import flash.media.Camera;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import flash.utils.Timer;

import fl.controls.Button;
import fl.controls.ComboBox;
import fl.controls.Label;
import fl.controls.ScrollPolicy;
import fl.controls.TextArea;

import fl.skins.DefaultButtonSkins;
import fl.skins.DefaultComboBoxSkins;
import fl.skins.DefaultTextAreaSkins;

import mx.effects.easing.Cubic;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.ValueEvent;
import com.threerings.util.Util;

import com.threerings.flash.path.Path;
import com.threerings.flash.path.EasingPath;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

[SWF(width="220", height="250")]
public class Fifteen extends Sprite
{
    public static const BOARD_WIDTH :int = 200;
    public static const BOARD_HEIGHT :int = 200;

    /** How many tiles per side should we use? */
    public static const SIZE :int = 4;

    public static const TILE_WIDTH :int = int(BOARD_WIDTH / SIZE);
    public static const TILE_HEIGHT :int = int(BOARD_HEIGHT / SIZE);

    public static const SOLVED_STATE :Array = computeSolvedState();

    public static const SOURCE_NUMBERS :int = 0;
    public static const SOURCE_URL :int = 1;
    public static const SOURCE_CAMERA :int = 2;

    public static const SOURCES :Array = [ "Numbers", "Mona Lisa", "Camera" ];

    public function Fifteen ()
    {
        _ctrl = new FurniControl(this);
        _toy = new ToyState(_ctrl, true, 15);
        _toy.addEventListener(ToyState.STATE_UPDATED, handleStateUpdated);

        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);

        initUI();
        readState();
    }

    /**
     * Expose this to the helper classes.
     */
    public function computeTilePosition (position :int) :Point
    {
        return new Point((position % SIZE) * TILE_WIDTH, int(position / SIZE) * TILE_HEIGHT);
    }

    private static function refSkins () :void
    {
        DefaultButtonSkins;
        DefaultComboBoxSkins;
    }

    protected function initUI () :void
    {
        var mask :Sprite = new Sprite();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, 220, 250);
        mask.graphics.endFill();
        addChild(mask);
        this.mask = mask;

        // draw the board background
        graphics.beginFill(0xFFFFFF);
        graphics.lineStyle(0x000000, 1);
        graphics.drawRoundRect(0, 30, BOARD_WIDTH + 20, BOARD_HEIGHT + 20, 20, 20);

        graphics.beginFill(0x000000);
        graphics.lineStyle(0, 0, 0);
        graphics.drawRect(10, 40, BOARD_WIDTH, BOARD_HEIGHT);

        var tileHolder :Sprite = new Sprite();
        tileHolder.x = 10;
        tileHolder.y = 40;
        addChild(tileHolder);

        var ii :int;

        // create the regular tile sprites
        _tiles = [];
        for (ii = 0; ii < BLANK_TILE; ii++) {
            var tile :Sprite = new Sprite();
            _tiles.push(tile);
            tile.addEventListener(MouseEvent.CLICK, handleClick);
            tileHolder.addChild(tile);
        }

        // make the blank tile sprite
        _blank = new BlankTile();
        _tiles.push(_blank);
        tileHolder.addChildAt(_blank, 0); // lowest drawn
        _blank.addEventListener(MouseEvent.MOUSE_DOWN, handleBlankDown);

        tileHolder.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);

        _palette = new Sprite();
        addChild(_palette);

        // create the label used to report who is modifying
        _label = new Label();
        _label.text = "";
        _label.setStyle("textFormat", new TextFormat(null, 12, null, true));
        _label.setSize(220, 22);
        _palette.addChild(_label);

        var config :Button = new Button();
        config.label = "Config";
        config.setSize(config.textField.textWidth + 20, 22);
        config.x = 220 - config.width;
        config.addEventListener(MouseEvent.CLICK, handleOpenConfig);
        _palette.addChild(config);

        // finally, let's set our tile provider
        if (_ctrl.isConnected()) {
            _skinData = _ctrl.lookupMemory("skin") as Array;
        }
        updateTileProvider();
    }

    protected function handleOpenConfig (event :MouseEvent) :void
    {
        _sourceBox = new ComboBox();
        _sourceBox.addItem({ label: "Numbers" });
        _sourceBox.addItem({ label: "Mona Lisa",
            data: [ SOURCE_URL,
                    "http://media.whirled.com/16ee8aa22ff39ee61a245c28d0b183d0c1b972dd.jpg" ] });
        _sourceBox.addItem({ label: "Bogologo",
            data: [ SOURCE_URL, "http://bogocorp.com/bogologo.gif" ] });
        _sourceBox.addItem({ label: "Dude",
            data: [ SOURCE_URL, "http://media.whirled.com/c95c59abc8da0ac99628fbc4c68799b93c129716.swf" ]});
// TODO: real URL entry?
//        _sourceBox.addItem({ label: "URL", data: [ SOURCE_URL, null ] });
        var names :Array = Camera.names;
        if (names != null && names.length > 0) {
// TODO: real camera selection?
//            for (var ii :int = 0; ii < names.length; ii++) {
//                _sourceBox.addItem({ label: "Camera: " + names[ii],
//                    data: [ SOURCE_CAMERA, String(ii) ] });
//            }
            _sourceBox.addItem({ label: "Camera (local)", data: [ SOURCE_CAMERA ] });
        }

        // select the right source
        var found :Boolean = false;
        for (var ii :int = 0; ii < _sourceBox.length; ii++) {
            if (Util.equals(_skinData, _sourceBox.getItemAt(ii).data)) {
                found = true;
                _sourceBox.selectedIndex = ii;
                break;
            }
        }
        if (!found && _skinData[0] == SOURCE_URL) {
            var item :Object = { label: _skinData[1], data: _skinData };
            _sourceBox.addItem(item);
            _sourceBox.selectedItem = item;
        }

        var close :Button = new Button();
        close.label = "Close";
        close.setSize(close.textField.textWidth + 20, 22);
        close.x = 220 + (220 - close.width);;
        close.addEventListener(MouseEvent.CLICK, handleCloseConfig)
        _palette.addChild(close);

        _sourceBox.addEventListener(Event.CHANGE, handleSourceSelected);
        _sourceBox.addEventListener(Event.OPEN, handleSourceOpened);
        _sourceBox.addEventListener(Event.CLOSE, handleSourceClosed);
        _sourceBox.setSize(220 - close.width, 22);
        _sourceBox.x = 220;
        _palette.addChild(_sourceBox);

        _closeTimer = new Timer(20000, 1);
        _closeTimer.addEventListener(TimerEvent.TIMER, handleCloseConfig);
        _closeTimer.start();

        // then, actually open it
        new EasingPath(_palette, -220, 0, 1000, Cubic.easeInOut).start();
    }

    protected function handleSourceSelected (... ignored) :void
    {
        var skinData :Array = _sourceBox.selectedItem.data as Array;
        // TODO: Url entry?
        setSkin(skinData);
    }

    protected function handleSourceOpened (... ignored) :void
    {
        _closeTimer.reset();
    }

    protected function handleSourceClosed (... ignored) :void
    {
        _closeTimer.start();
    }

    protected function setSkin (skinData :Array) :void
    {
        if (Util.equals(skinData, _skinData)) {
            // if no change, ignore
            return;
        }

        _skinData = skinData;
        _setOwnSkin = true;

        if (_ctrl.isConnected() && _ctrl.canEditRoom()) {
            _ctrl.updateMemory("skin", skinData);
        }
        updateTileProvider();
    }

    protected function updateTileProvider () :void
    {
        // shutdown any previous provider
        if (_tileProvider != null) {
            _tileProvider.shutdown();
            _tileProvider = null;
        }

        var provider :int;
        var arg :String;
        if (_skinData == null) {
            provider = SOURCE_NUMBERS;

        } else {
            provider = int(_skinData[0]);
            arg = _skinData[1] as String;
        }

        switch (provider) {
        case SOURCE_URL:
            _tileProvider = new UrlTileProvider(arg);
            break;

        case SOURCE_CAMERA:
            // make sure this user HAS cameras
            var camNames :Array = Camera.names;
            if (camNames != null && camNames.length > 0) {
                //_tileProvider = new CameraTileProvider(_ctrl.getCamera(arg));
                _tileProvider = new CameraTileProvider(_ctrl.getCamera());
                break;
            }
            // else, fall through...

        default:
            _tileProvider = new NumberTileProvider();
            break;
        }

        _tileProvider.init(this, _tiles);
    }

    protected function handleCloseConfig (event :Event) :void
    {
        _closeTimer.stop();
        _closeTimer = null;

        // defang the controls
        _sourceBox.removeEventListener(Event.CHANGE, handleSourceSelected);

        var closePath :Path = new EasingPath(_palette, 0, 0, 1000, Cubic.easeInOut);
        closePath.setOnComplete(configWasClosed);
        closePath.start();
    }

    protected function configWasClosed (path :Path) :void
    {
        _sourceBox = null;

        // clean up palette
        while (_palette.numChildren > 2) {
            _palette.removeChildAt(2);
        }
    }

    protected function handleMemoryChanged (event :ControlEvent) :void
    {
        if (event.name == "skin") {
            // we only update if this local client hasn't configured their own skin
            if (!_setOwnSkin) {
                var skinData :Array = event.value as Array;
                if (!Util.equals(skinData, _skinData)) {
                    _skinData = skinData;
                    updateTileProvider();
                }
            }
        }
    }

    protected function readState () :void
    {
        _state = _toy.getState() as Array;
        // detect an invalid state and reset
        if (_state == null || _state.length != (SIZE * SIZE)) {
            // make a copy of the solved state
            _state = SOLVED_STATE.concat();
        }
        positionTiles();
        updateModifierName(_toy.getUsernameOfState());
    }

    protected function updateModifierName (name :String) :void
    {
        _label.text = (name == null) ? "" : (name + " is solving.");
    }

    protected function positionTiles () :void
    {
        // cancel any paths
        for (var jj :int = _paths.length - 1; jj >= 0; jj--) {
            (_paths[jj] as Path).abort();
            // they'll be cleared, too
        }

        for (var ii :int = 0; ii < _state.length; ii++) {
            var number :int = int(_state[ii]);
            var tile :Sprite = _tiles[number] as Sprite;
            var p :Point = computeTilePosition(ii);
            tile.x = p.x;
            tile.y = p.y;
        }
    }

    protected function handleClick (event :MouseEvent) :void
    {
        var tile :Sprite = event.currentTarget as Sprite;
        var number :int = identifyTile(tile);
        var position :int = findPosition(number);

        trySwap(position, true);
    }

    protected function trySwap (position :int, doSet :Boolean = false) :void
    {
        var blankPosition :int = findPosition(BLANK_TILE);
        if (areAdjacent(position, blankPosition)) {
            var tile :Sprite = _tiles[_state[position]] as Sprite;
            if (tile == null) {
                // TODO: saw a bug here once, but haven't been able to duplicate it since
                trace("position: " + position + ", " + blankPosition);
                trace("state: " + _state);
            }

            // update our state
            _state[blankPosition] = _state[position];
            _state[position] = BLANK_TILE;
            if (doSet) {
                _stateQueue.length = 0; // truncate our state queue, we're taking control
                _label.text = "You are solving.";
                _toy.setState(_state);
            }

            // animate the tile moving to the blank position
            var src :Point = computeTilePosition(position);

            var path :Path = Path.move(tile, src.x, src.y, _blank.x, _blank.y, 250);
            path.setOnComplete(handlePathComplete);
            _paths.push(path);
            path.start();

            // and jump the blank tile to its new home
            _blank.x = src.x;
            _blank.y = src.y;
        }
    }

    protected function handlePathComplete (path :Path) :void
    {
        _paths.splice(_paths.indexOf(path), 1);
        if (_paths.length == 0 && _stateQueue.length > 0) {
            moveToState(_stateQueue.shift() as Array, _stateQueue.shift() as String);
        }
    }

    protected function handleBlankDown (event :MouseEvent) :void
    {
        _blank.parent.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
    }

    protected function handleMouseMove (event :MouseEvent) :void
    {
        var p :Point = new Point(event.localX, event.localY);
        p = (event.target as DisplayObject).localToGlobal(p);
        p = _blank.parent.globalToLocal(p);
        trySwap(int(p.x / TILE_WIDTH) + SIZE * int(p.y / TILE_HEIGHT), true);
    }

    protected function handleMouseUp (event :MouseEvent) :void
    {
        _blank.parent.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
        _blank.setMouseUp();
    }

    protected function identifyTile (tile :Sprite) :int
    {
        for (var ii :int = 0; ii < _tiles.length; ii++) {
            if (tile == _tiles[ii]) {
                return ii;
            }
        }

        Log.dumpStack();
        return -1;
    }

    protected function findPosition (tileId :int) :int
    {
        for (var ii :int = 0; ii < _state.length; ii++) {
            if (tileId == _state[ii]) {
                return ii;
            }
        }

        Log.dumpStack();
        return -1;
    }

    protected function areAdjacent (pos1 :int, pos2 :int) :Boolean
    {
        if (pos1 < 0 || pos1 >= (SIZE * SIZE) || pos2 < 0 || pos2 >= (SIZE * SIZE)) {
            return false;
        }

        var x1 :int = (pos1 % SIZE);
        var y1 :int = int(pos1 / SIZE);
        var x2 :int = (pos2 % SIZE);
        var y2 :int = int(pos2 / SIZE);

        return ((x1 == x2) && (1 == Math.abs(y1 - y2))) ||
            ((y1 == y2) && (1 == Math.abs(x1 - x2)));
    }

    protected function resetState (... ignored) :void
    {
        _toy.resetState();
        readState();
    }

    protected function shuffleState (... ignored) :void
    {
        // TODO: this is actually invalid, because there is a "parity" issue with board states,
        // only half of them are solvable
        ArrayUtil.shuffle(_state);
        _toy.setState(_state);

        positionTiles();
    }

    protected function handleStateUpdated (... ignored) :void
    {
        var newState :Array = _toy.getState() as Array;
        var username :String = _toy.getUsernameOfState();

        if (_paths.length > 0) {
            _stateQueue.push(newState, username);

        } else {
            moveToState(newState, username);
        }
    }

    protected function moveToState (newState :Array, username :String) :void
    {
        var diffCount :int = 0;
        var swapPos :int = -1;
        if (newState != null) {
            for (var ii :int = 0; ii < (SIZE * SIZE); ii++) {
                if (_state[ii] != newState[ii]) {
                    diffCount++;
                    if (diffCount == 1) {
                        swapPos = ii;

                    } else if (diffCount == 2) {
                        if ((_state[ii] == newState[swapPos]) &&
                                (_state[swapPos] == newState[ii])) {
                            if (_state[swapPos] == BLANK_TILE) {
                                swapPos = ii;

                            } else if (_state[ii] != BLANK_TILE) {
                                diffCount++; // no good, one needs to be the blank tile
                            }

                        } else {
                            diffCount++; // no good, count that as a difference
                        }
                    }
                    if (diffCount > 2) {
                        break;
                    }
                }
            }
        }

        if (diffCount == 2) {
            trySwap(swapPos);
            updateModifierName(username);

        } else {
            readState();
        }
    }

    /**
     * Compute the "solved" state for this puzzle.
     */
    protected static function computeSolvedState () :Array
    {
        var state :Array = [];
        for (var ii :int = 0; ii < (SIZE * SIZE); ii++) {
            state.push(ii);
        }
        return state;
    }

    protected static const BLANK_TILE :int = (SIZE * SIZE) - 1; 

    protected var _ctrl :FurniControl;

    protected var _toy :ToyState;

    protected var _blank :BlankTile;

    protected var _setOwnSkin :Boolean;

    protected var _skinData :Array;

    protected var _tileProvider :TileProvider;

    protected var _state :Array;

    protected var _stateQueue :Array = [];

    protected var _tiles :Array;

    protected var _paths :Array = [];

    protected var _palette :Sprite;

    protected var _sourceBox :ComboBox;

    protected var _closeTimer :Timer;

    protected var _label :Label;
}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.ProgressEvent;

import flash.geom.Matrix;
import flash.geom.Point;

import flash.events.MouseEvent;

import flash.media.Camera;
import flash.media.Video;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;

import flash.net.URLRequest;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class BlankTile extends Sprite
{
    public function BlankTile ()
    {
        addEventListener(MouseEvent.MOUSE_OVER, handleMouse);
        addEventListener(MouseEvent.MOUSE_OUT, handleMouse);
        addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
        repaint();
    }

    public function setMouseUp () :void
    {
        _down = false;
        repaint();
    }

    protected function handleMouse (event :MouseEvent) :void
    {
        switch (event.type) {
        case MouseEvent.MOUSE_OVER:
            _over = true;
            break;

        case MouseEvent.MOUSE_OUT:
            _over = false;
            break;

        case MouseEvent.MOUSE_DOWN:
            _down = true;
            break;
        }

        repaint();
    }

    protected function repaint () :void
    {
        graphics.clear();
        graphics.beginFill(0x000000);
        graphics.drawRect(0, 0, Fifteen.TILE_WIDTH, Fifteen.TILE_HEIGHT);
        graphics.endFill();

        if (_over || _down) {
            graphics.lineStyle(5, _down ? 0x660000 : 0x000066);
            graphics.drawRoundRect(10, 10, Fifteen.TILE_WIDTH - 20, Fifteen.TILE_HEIGHT - 20,
                10, 10);
        }
    }

    protected var _over :Boolean;
    protected var _down :Boolean;
}

class TileProvider
{
    public function init (fifteen :Fifteen, tiles :Array) :void
    {
        _fifteen = fifteen;
        _tiles = tiles;
        clearTiles();
        startup();
    }

    public function shutdown () :void
    {
    }

    public function startup () :void
    {
        // nothing, by default
    }

    /**
     * Clear tiles completely.
     */
    protected function clearTiles () :void
    {
        for (var ii :int = 0; ii < _tiles.length - 1; ii++) {
            var tile :Sprite = _tiles[ii] as Sprite;
            tile.mask = null;
            tile.graphics.clear();
            while (tile.numChildren > 0) {
                tile.removeChildAt(0);
            }
        }
    }

    protected var _tiles :Array;

    protected var _fifteen :Fifteen;
}

class NumberTileProvider extends TileProvider
{
    override public function startup () :void
    {
        super.startup();

        for (var ii :int = 0; ii < _tiles.length - 1; ii++) {
            var tile :Sprite = _tiles[ii] as Sprite;
            tile.graphics.beginFill(0xFFFFEE);
            tile.graphics.lineStyle(1, 0x000033);
            tile.graphics.drawRoundRect(0, 0, Fifteen.TILE_WIDTH, Fifteen.TILE_HEIGHT, 10, 10);

            var tf :TextField = new TextField();
            tf.selectable = false;
            tf.text = String(ii + 1);
            tf.setTextFormat(new TextFormat(null, 32, 0x000000, true, null, null, null, null,
                TextFormatAlign.CENTER));
            tf.width = Fifteen.TILE_WIDTH;
            tf.height = tf.textHeight + 4;
            tf.y = (Fifteen.TILE_HEIGHT - tf.height) / 2;
            tile.addChild(tf);
        }
    }
}

class ChoppingTileProvider extends TileProvider
{
    /**
     * Utility method for printing a bitmap into the tiles.
     * This assumes that the bitmap is the correct size.
     */
    protected function bitmapToTiles (bitmap :BitmapData) :void
    {
        for (var ii :int = 0; ii < _tiles.length - 1; ii++) {
            var tile :Sprite = _tiles[ii] as Sprite;
            // get the "natural" position of this tile, not it's current position
            var p :Point = _fifteen.computeTilePosition(ii);
            var matrix :Matrix = new Matrix();
            matrix.translate(-p.x, -p.y);
            tile.graphics.clear();
            tile.graphics.beginBitmapFill(bitmap, matrix);
            tile.graphics.drawRect(0, 0, Fifteen.TILE_WIDTH, Fifteen.TILE_HEIGHT);
            tile.graphics.endFill();
        }
    }
}

class UrlTileProvider extends TileProvider
{
    public function UrlTileProvider (url :String)
    {
        _req = new URLRequest(url);
    }

    override public function startup () :void
    {
        super.startup();

        for (var ii :int = 0; ii < _tiles.length - 1; ii++) {
            var tile :Sprite = _tiles[ii] as Sprite;
            // set up a mask so we only show the portion we want
            var mask :Sprite = new Sprite();
            mask.graphics.beginFill(0xFFFFFF);
            mask.graphics.drawRect(0, 0, Fifteen.TILE_WIDTH, Fifteen.TILE_HEIGHT);
            mask.graphics.endFill();
            tile.mask = mask;
            tile.addChild(mask);
            // fill in all pixels in the tile so that they're mouse hittable
            tile.graphics.beginFill(0x000000, 0);
            tile.graphics.drawRect(0, 0, Fifteen.TILE_WIDTH, Fifteen.TILE_HEIGHT);
            tile.graphics.endFill();

            // put the loader at the right location..
            var loader :Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleComplete);
            // load it into our own security domain so we get clicks on loaded SWFs
            try {
                loader.load(_req, new LoaderContext(false, new ApplicationDomain(null),
                    SecurityDomain.currentDomain));
            } catch (err :SecurityError) {
                // if we're running locally, we can't specify a SecurityDomain
                loader.load(_req, new LoaderContext(false, new ApplicationDomain(null)));
            }
            var p :Point = _fifteen.computeTilePosition(ii);
            loader.x = -p.x;
            loader.y = -p.y;
            tile.addChild(loader);

            // save the loader so we can stop it later
            _loaders.push(loader);
        }

        _req = null;
    }

    override public function shutdown () :void
    {
        super.shutdown();

        for each (var loader :Loader in _loaders) {
            try {
                loader.close();
            } catch (er :Error) {
                // ignore
            }
            loader.unload();
        }
    }

    protected function handleComplete (event :Event) :void
    {
        var loaderInfo :LoaderInfo = event.target as LoaderInfo;

        // scale the loader so that the content fits within the puzzle bounds
        loaderInfo.loader.scaleX = Fifteen.BOARD_WIDTH / loaderInfo.width;
        loaderInfo.loader.scaleY = Fifteen.BOARD_HEIGHT / loaderInfo.height;
    }

    protected var _req :URLRequest;

    protected var _loaders :Array = [];
}

class CameraTileProvider extends ChoppingTileProvider
{
    public function CameraTileProvider (cam :Camera)
    {
        _video = new Video(Fifteen.BOARD_WIDTH, Fifteen.BOARD_HEIGHT);
        _video.attachCamera(cam);
        _bmp = new BitmapData(Fifteen.BOARD_WIDTH, Fifteen.BOARD_HEIGHT, false);
    }

    override public function startup () :void
    {
        super.startup();
        _fifteen.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    override public function shutdown () :void
    {
        super.shutdown();
        _fifteen.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    protected function handleEnterFrame (event :Event) :void
    {
        // render the video into the bitmap
        _bmp.draw(_video);
        // render the bitmap onto the tiles
        bitmapToTiles(_bmp);
    }

    protected var _video :Video;

    protected var _bmp :BitmapData;
}
