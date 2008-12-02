//
// $Id$

package {

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;
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
import fl.controls.TextInput;

import fl.events.ComponentEvent;

import fl.skins.DefaultButtonSkins;
import fl.skins.DefaultComboBoxSkins;
import fl.skins.DefaultTextInputSkins;

import caurina.transitions.Tweener;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.ValueEvent;
import com.threerings.util.Util;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

import com.whirled.contrib.ForkingToyState;
import com.whirled.contrib.PreferredCamera;

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
        _toy = new ForkingToyState(_ctrl, true, 15);
        _toy.addEventListener(ForkingToyState.STATE_UPDATED, handleStateUpdated);

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

    public function setLabel (text :String) :void
    {
        _label.text = text;
    }

    private static function refSkins () :void
    {
        DefaultButtonSkins;
        DefaultComboBoxSkins;
        DefaultTextInputSkins;
    }

    protected function initUI () :void
    {
        var mask :Sprite = new Sprite();
        mask.graphics.beginFill(0xFFFFFF);
        // 75 extra pixels tall so we don't mask when we slide _content
        mask.graphics.drawRect(0, 0, 220, 250 + 75);
        mask.graphics.endFill();
        addChild(mask);
        this.mask = mask;

        _content = new Sprite();
        addChild(_content);

        // draw the board background
        var g :Graphics = _content.graphics;
        g.beginFill(0xFFFFFF);
        g.lineStyle(0x000000, 1);
        g.drawRoundRect(0, 30, BOARD_WIDTH + 20, BOARD_HEIGHT + 20, 20, 20);

        g.beginFill(0x000000);
        g.lineStyle(0, 0, 0);
        g.drawRect(10, 40, BOARD_WIDTH, BOARD_HEIGHT);

        var tileHolder :Sprite = new Sprite();
        tileHolder.x = 10;
        tileHolder.y = 40;
        _content.addChild(tileHolder);

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

        _controls = new Sprite();
        _palette.addChild(_controls);

        var config :Button = createButton("Config");
        config.x = 220 - config.width;
        config.addEventListener(MouseEvent.CLICK, handleOpenConfig);
        _controls.addChild(config);

        // finally, let's set our tile provider
        if (_ctrl.isConnected()) {
            _skinData = _ctrl.getMemory("skin") as Array;
        }
        updateTileProvider();
    }

    /**
     * Convenience method for creating a button.
     */
    protected function createButton (label :String) :Button
    {
        var button :Button = new Button();
        button.label = label;
        button.validateNow();
        button.setSize(button.textField.textWidth + 15, 22);
        return button;
    }

    protected function handleOpenConfig (event :MouseEvent) :void
    {
        if (_sourceBox != null) {
            // already open. ignore.
            return;
        }

        _sourceBox = new ComboBox();
        _sourceBox.addItem({ label: "Numbers" });
        _sourceBox.addItem({ label: "Mona Lisa",
            data: [ SOURCE_URL,
                    "http://media.whirled.com/16ee8aa22ff39ee61a245c28d0b183d0c1b972dd.jpg" ] });
        _sourceBox.addItem({ label: "Tofu",
            data: [ SOURCE_URL,
                    "http://media.whirled.com/c95c59abc8da0ac99628fbc4c68799b93c129716.swf" ]});
        _sourceBox.addItem({ label: "Enter a URL...", data: [ SOURCE_URL, null ] });
        var camNames :Array = Camera.names;
        var camName :String;
        for each (camName in camNames) {
            _sourceBox.addItem({ label: "Camera: " + camName, data: [ SOURCE_CAMERA, camName ] });
        }

        // select the right source
        var found :Boolean = false;
        var skinData :Array = (_skinData == null) ? null : _skinData.concat(); // make a copy
        if (skinData != null && skinData[0] == SOURCE_CAMERA) {
            // try to find the right camera to match up
            camName = PreferredCamera.getPreferredCameraName();
            if (camNames.indexOf(camName) == -1) {
                // if not present, default to first
                camName = camNames[0];
            }
            skinData[1] = camName;
        }
        for (var ii :int = 0; ii < _sourceBox.length; ii++) {
            if (Util.equals(skinData, _sourceBox.getItemAt(ii).data)) {
                found = true;
                _sourceBox.selectedIndex = ii;
                break;
            }
        }
        if (!found && skinData != null && skinData[0] == SOURCE_URL) {
            var item :Object = { label: _skinData[1], data: _skinData };
            _sourceBox.addItem(item);
            _sourceBox.selectedItem = item;
        }

        var close :Button = createButton("Close");
        close.x = 220 + (220 - close.width);;
        close.addEventListener(MouseEvent.CLICK, handleCloseConfig)
        _controls.addChild(close);

        _sourceBox.addEventListener(Event.CHANGE, handleSourceSelected);
        _sourceBox.addEventListener(Event.OPEN, resetCloseTimer);
        _sourceBox.addEventListener(Event.CLOSE, resetCloseTimer);
        _sourceBox.setSize(220 - close.width, 22);
        _sourceBox.x = 220;
        _controls.addChild(_sourceBox);

        if (!_ctrl.isConnected() || _ctrl.canManageRoom()) {
            var reset :Button = createButton("Reset");
            reset.y = 25;
            reset.x = 220;
            reset.addEventListener(MouseEvent.CLICK, resetState);
            reset.addEventListener(MouseEvent.CLICK, resetCloseTimer);
            _controls.addChild(reset);

//            var scramble :Button = createButton("Scramble");
//            scramble.y = 25;
//            scramble.x = 440 - scramble.width;
//            scramble.addEventListener(MouseEvent.CLICK, shuffleState);
//            scramble.addEventListener(MouseEvent.CLICK, resetCloseTimer);
//            _controls.addChild(scramble);
        }

        _closeTimer = new Timer(20000, 1);
        _closeTimer.addEventListener(TimerEvent.TIMER, handleCloseConfig);
        _closeTimer.start();

        // then, actually open it
        Tweener.addTween(_palette, {time: 1, transition: TRANS, x: -220});

        if (!_ctrl.isConnected() || _ctrl.canManageRoom()) {
            Tweener.addTween(_content, {time: 1, transition: TRANS, y: 25});
        }
    }

    protected function handleSourceSelected (... ignored) :void
    {
        var skinData :Array = _sourceBox.selectedItem.data as Array;

        if (skinData != null && skinData[0] == SOURCE_URL && skinData[1] == null) {
            if (_controls.y != 0) {
                // we've already got the URL entry field showing...
                return;
            }

            // add a URL entry field above the other controls
            var label :Label = new Label();
            label.setSize(220, 22);
            label.text = "Enter a URL:";
            label.x = 220;
            label.y = -50;
            _controls.addChild(label);

            var url :TextInput = new TextInput();

            var submitURL :Function = function (event :Event) :void {
                setSkin( [ SOURCE_URL, url.text ] );
            };

            var ok :Button = createButton("OK");
            ok.y = -25;
            ok.x = 440 - ok.width;
            ok.addEventListener(MouseEvent.CLICK, submitURL);
            ok.addEventListener(MouseEvent.CLICK, resetCloseTimer);
            _controls.addChild(ok);

            url.setSize(220 - ok.width, 22);
            url.x = 220;
            url.y = -25;
            url.addEventListener(ComponentEvent.ENTER, submitURL);
            url.addEventListener(TextEvent.TEXT_INPUT, resetCloseTimer);
            _controls.addChild(url);

            Tweener.addTween(_palette, {time: .5, transition: TRANS, y: 50});
            var newContentY :Number = (!_ctrl.isConnected() || _ctrl.canManageRoom()) ? 75 : 50;
            Tweener.addTween(_content, {time: .5, transition: TRANS, y: newContentY}); 

        } else {
            setSkin(skinData);
        }
    }

    protected function resetCloseTimer (event :Event) :void
    {
        _closeTimer.reset();
        if (event.type != Event.OPEN) {
            _closeTimer.start();
        }
    }

    protected function setSkin (skinData :Array) :void
    {
        if (Util.equals(skinData, _skinData)) {
            // if no change, ignore
            return;
        }

        _skinData = skinData;
        _setOwnSkin = true;

        setLabel(""); // clear any old error?
        updateTileProvider();
        if (_ctrl.isConnected() && _ctrl.canManageRoom()) {
            _ctrl.setMemory("skin", _skinData);
        }
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
            if (arg != null) {
                PreferredCamera.setPreferredCamera(arg);
                // now, erase the camera-specific info..
                _skinData.length = 1;
            }
            var cam :Camera = PreferredCamera.getPreferredCamera(_ctrl);
            if (cam != null) {
                _tileProvider = new CameraTileProvider(cam);
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
        if (_closeTimer == null) {
            // already closing. Ignore.
            return;
        }
        _closeTimer.stop();
        _closeTimer = null;

        // defang the controls
        _sourceBox.removeEventListener(Event.CHANGE, handleSourceSelected);
        _sourceBox.removeEventListener(Event.OPEN, resetCloseTimer);
        _sourceBox.removeEventListener(Event.CLOSE, resetCloseTimer);

        Tweener.addTween([ _content, _palette ],
            { time: 1, transition: TRANS, onComplete: configWasClosed, x: 0, y: 0 });
    }

    protected function configWasClosed () :void
    {
        _sourceBox = null;

        // clean up controls
        while (_controls.numChildren > 1) {
            _controls.removeChildAt(1);
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
        // cancel any tweens
        if (_tileTweens > 0) {
            for (var jj :int = 0; jj < BLANK_TILE; jj++) {
                Tweener.removeTweens(_tiles[jj]);
            }
            _tileTweens = 0;
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

            tile.x = src.x;
            tile.y = src.y;
            Tweener.addTween(tile,
                { time: .25, transition: "linear", x: _blank.x, y: _blank.y,
                  onComplete: handleTweenComplete, onOverwrite: handleTweenCancelled });
            _tileTweens++;

            // and jump the blank tile to its new home
            _blank.x = src.x;
            _blank.y = src.y;
        }
    }

    protected function handleTweenCancelled () :void
    {
        _tileTweens--;
    }

    protected function handleTweenComplete () :void
    {
        _tileTweens--;

        // if we know that all the tiles are stopped, maybe transition to the next state
        if (_tileTweens == 0 && _stateQueue.length > 0) {
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

        if (_tileTweens > 0) {
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

    protected static const TRANS :String = "easeinoutcubic";

    protected static const BLANK_TILE :int = (SIZE * SIZE) - 1; 

    protected var _ctrl :FurniControl;

    protected var _toy :ForkingToyState;

    protected var _content :Sprite;

    protected var _blank :BlankTile;

    protected var _setOwnSkin :Boolean;

    protected var _skinData :Array;

    protected var _tileProvider :TileProvider;

    protected var _state :Array;

    protected var _stateQueue :Array = [];

    protected var _tiles :Array;

    protected var _tileTweens :int = 0;

    protected var _palette :Sprite;

    protected var _controls :Sprite;

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

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;

import flash.geom.Matrix;
import flash.geom.Point;

import flash.events.IOErrorEvent;
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

class UrlTileProvider extends TileProvider
{
    public function UrlTileProvider (url :String)
    {
        _req = new URLRequest(url);
    }

    override public function startup () :void
    {
        super.startup();

        var fill :BitmapData = new BitmapData(4, 4, false, 0x666666);
        var alt :uint = 0x333333;
        fill.setPixel(0, 0, alt);
        fill.setPixel(1, 0, alt);
        fill.setPixel(0, 1, alt);
        fill.setPixel(3, 1, alt);
        fill.setPixel(2, 2, alt);
        fill.setPixel(3, 2, alt);
        fill.setPixel(1, 3, alt);
        fill.setPixel(2, 3, alt);

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
            tile.graphics.beginBitmapFill(fill);
            tile.graphics.drawRect(0, 0, Fifteen.TILE_WIDTH, Fifteen.TILE_HEIGHT);
            tile.graphics.endFill();

            // put the loader at the right location..
            var loader :Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
                handleError);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleComplete);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleError);
            var swfRegExp :RegExp = /\.swf$/i;
            if (swfRegExp.test(_req.url)) {
                try {
                    loader.load(_req, new LoaderContext(false, new ApplicationDomain(null),
                        SecurityDomain.currentDomain));
                } catch (err :SecurityError) {
                    // if we're running locally, we can't specify a SecurityDomain
                    loader.load(_req, new LoaderContext(false, new ApplicationDomain(null)));
                }

            } else {
                // just load it plain
                loader.load(_req);
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
        try {
            loaderInfo.loader.scaleX = Fifteen.BOARD_WIDTH / loaderInfo.width;
            loaderInfo.loader.scaleY = Fifteen.BOARD_HEIGHT / loaderInfo.height;
        } catch (err :SecurityError) {
            // cope.
        }
    }

    protected function handleError (event :ErrorEvent) :void
    {
        _fifteen.setLabel("Error loading: " + event.text);
    }

    protected var _req :URLRequest;

    protected var _loaders :Array = [];
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
