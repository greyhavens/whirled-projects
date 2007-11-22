//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.geom.Point;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import fl.controls.Button;
import fl.controls.Label;
import fl.controls.ScrollPolicy;
import fl.controls.TextArea;

import fl.skins.DefaultButtonSkins;
import fl.skins.DefaultTextAreaSkins;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.ValueEvent;

import com.threerings.flash.path.Path;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

[SWF(width="420", height="450")]
public class Fifteen extends Sprite
{
    public static const BOARD_WIDTH :int = 400;
    public static const BOARD_HEIGHT :int = 400;

    /** How many tiles per side should we use? */
    public static const SIZE :int = 4;

    public static const TILE_WIDTH :int = int(BOARD_WIDTH / SIZE);
    public static const TILE_HEIGHT :int = int(BOARD_HEIGHT / SIZE);

    public function Fifteen ()
    {
        _ctrl = new FurniControl(this);
        _toy = new ToyState(_ctrl, true, 15);
        _toy.addEventListener(ToyState.STATE_UPDATED, handleStateUpdated);

        initUI();
        readState();
    }

    private static function refSkins () :void
    {
        DefaultButtonSkins;
    }

    protected function initUI () :void
    {
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

        // create the normal tile sprites
        _tiles = makeTileSprites();
        for each (var tile :Sprite in _tiles) {
            tile.addEventListener(MouseEvent.CLICK, handleClick);
            tileHolder.addChild(tile);
        }

        // make the blank sprite
        _blank = new BlankTile();
        _tiles.push(_blank);
        tileHolder.addChildAt(_blank, 0); // lowest drawn
        _blank.addEventListener(MouseEvent.MOUSE_DOWN, handleBlankDown);

        tileHolder.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);

        // create the button and label
        _label = new Label();
        _label.text = "";
        _label.setSize(420, 22);
        addChild(_label);
//        _label.visible = false;

        if (!_ctrl.isConnected() || _ctrl.canEditRoom()) {
            _button = new Button();
            _button.label = "Reset";
            _button.setSize(_button.textField.textWidth + 25, 22);
            _button.x = 420 - _button.width;
            addChild(_button);
            _button.addEventListener(MouseEvent.CLICK, resetState);
        }
    }

    protected function readState () :void
    {
        _state = _toy.getState() as Array;
        // detect an invalid state and reset
        if (_state == null || _state.length != (SIZE * SIZE)) {
            _state = [];
            for (var ii :int = 0; ii < (SIZE * SIZE); ii++) {
                _state.push(ii);
            }
        }
        positionTiles();
        updateModifierName(_toy.getUsernameOfState());
    }

    protected function updateModifierName (name :String) :void
    {
        _label.text = (name == null) ? "" : (name + " is modifying the puzzle.");
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

    protected function computeTilePosition (position :int) :Point
    {
        return new Point((position % SIZE) * TILE_WIDTH, int(position / SIZE) * TILE_HEIGHT);
    }

    protected function makeTileSprites () :Array
    {
        var tiles :Array = [];
        for (var ii :int = 0; ii < BLANK_TILE; ii++) {
            var s :Sprite = new Sprite();
            s.graphics.beginFill(0xFFFFEE);
            s.graphics.lineStyle(1, 0x000033);
            s.graphics.drawRoundRect(0, 0, TILE_WIDTH, TILE_HEIGHT, 10, 10);

            var tf :TextField = new TextField();
            tf.selectable = false;
            tf.text = String(ii + 1);
            tf.setTextFormat(new TextFormat(null, 32, 0x000000, true, null, null, null, null,
                TextFormatAlign.CENTER));
            tf.width = TILE_WIDTH;
            tf.height = tf.textHeight + 4;
            tf.y = (TILE_HEIGHT - tf.height) / 2;
            s.addChild(tf);

            tiles.push(s);
        }
        return tiles;
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
                _label.text = "YOU are modifying the puzzle.";
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

    protected static const BLANK_TILE :int = (SIZE * SIZE) - 1; 

    protected var _ctrl :FurniControl;

    protected var _toy :ToyState;

    protected var _blank :BlankTile;

    protected var _state :Array;

    protected var _stateQueue :Array = [];

    protected var _tiles :Array;

    protected var _paths :Array = [];

    protected var _button :Button;

    protected var _label :Label;
}
}

import flash.display.Sprite;

import flash.events.MouseEvent;

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
