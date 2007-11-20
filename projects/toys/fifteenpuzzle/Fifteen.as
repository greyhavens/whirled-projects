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

import fl.skins.DefaultButtonSkins;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;

import com.threerings.flash.path.Path;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

[SWF(width="420", height="450")]
public class Fifteen extends Sprite
{
    public function Fifteen ()
    {
        _ctrl = new FurniControl(this);

        if (_ctrl.isConnected()) {
            _state = _ctrl.lookupMemory("state") as Array;
            _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);
        }
        if (_state == null) {
            _state = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
            stateUpdated();
        }

        initUI();
        positionTiles();
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
        graphics.drawRoundRect(0, 30, 420, 420, 20, 20);

        graphics.beginFill(0x000000);
        graphics.lineStyle(0, 0, 0);
        graphics.drawRect(10, 40, 400, 400);

        var tileHolder :Sprite = new Sprite();
        tileHolder.x = 10;
        tileHolder.y = 40;
        addChild(tileHolder);

        // create our numbery sprites
        for (var ii :int = 0; ii < 15; ii++) {
            var tile :Sprite = makeTileSprite(String(ii + 1));
            _tiles.push(tile);
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
        _label.setSize(420, 22);
        addChild(_label);
        _label.visible = false;

        _shuffle = new Button();
        _shuffle.label = "Shuffle";
        _shuffle.setSize(_shuffle.textField.textWidth + 25, 22);
        _shuffle.x = (420 - _shuffle.width) / 2;
        addChild(_shuffle);
        _shuffle.addEventListener(MouseEvent.CLICK, shuffleState);
    }

    protected function positionTiles () :void
    {
        // cancel any paths
        for (var jj :int = _paths.length - 1; jj >= 0; jj--) {
            (_paths[jj] as Path).abort();
            // they'll be cleared, too
        }

        for (var ii :int = 0; ii < 16; ii++) {
            var number :int = int(_state[ii]);
            var tile :Sprite = _tiles[number] as Sprite;
            var p :Point = computeTilePosition(ii);
            tile.x = p.x;
            tile.y = p.y;
        }
    }

    protected function computeTilePosition (position :int) :Point
    {
        return new Point((position % 4) * 100, int(position / 4) * 100);
    }

    protected function makeTileSprite (number :String) :Sprite
    {
        var s :Sprite = new Sprite();
        s.graphics.beginFill(0xFFFFEE);
        s.graphics.lineStyle(1, 0x000033);
        s.graphics.drawRoundRect(0, 0, 100, 100, 10, 10);

        var tf :TextField = new TextField();
        tf.selectable = false;
        tf.text = number
        tf.setTextFormat(new TextFormat(null, 32, 0x000000, true, null, null, null, null,
            TextFormatAlign.CENTER));
        tf.width = 100;
        tf.height = tf.textHeight + 4;
        tf.y = (100 - tf.height) / 2;
        s.addChild(tf);

        s.addEventListener(MouseEvent.CLICK, handleClick);

        return s;
    }

    protected function handleClick (event :MouseEvent) :void
    {
        var tile :Sprite = event.currentTarget as Sprite;
        var number :int = identifyTile(tile);
        var position :int = findPosition(number);

        trySwap(position);
    }

    protected function trySwap (position :int) :void
    {
        var blankPosition :int = findPosition(BLANK_TILE);
        if (areAdjacent(position, blankPosition)) {
            var tile :Sprite = _tiles[_state[position]] as Sprite;

            // update our state
            _state[blankPosition] = _state[position];
            _state[position] = BLANK_TILE;
            stateUpdated();

            // animate the tile moving to the blank position
            var path :Path = Path.moveTo(tile, _blank.x, _blank.y, 250);
            path.setOnComplete(handlePathComplete);
            _paths.push(path);
            path.start();

            // and jump the blank tile to its new home
            var dest :Point = computeTilePosition(position);
            _blank.x = dest.x;
            _blank.y = dest.y;
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
        trySwap(int(p.x / 100) + 4 * int(p.y / 100));
    }

    protected function handleMouseUp (event :MouseEvent) :void
    {
        _blank.parent.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
        _blank.setMouseUp();
    }

    protected function identifyTile (tile :Sprite) :int
    {
        for (var ii :int = 0; ii < 16; ii++) {
            if (tile == _tiles[ii]) {
                return ii;
            }
        }

        Log.dumpStack();
        return -1;
    }

    protected function findPosition (tileId :int) :int
    {
        for (var ii :int = 0; ii < 16; ii++) {
            if (tileId == _state[ii]) {
                return ii;
            }
        }

        Log.dumpStack();
        return -1;
    }

    protected function areAdjacent (pos1 :int, pos2 :int) :Boolean
    {
        var x1 :int = (pos1 % 4);
        var y1 :int = int(pos1 / 4);
        var x2 :int = (pos2 % 4);
        var y2 :int = int(pos2 / 4);

        return ((x1 == x2) && (1 == Math.abs(y1 - y2))) ||
            ((y1 == y2) && (1 == Math.abs(x1 - x2)));
    }

    protected function stateUpdated () :void
    {
        if (_ctrl.isConnected()) {
            _ctrl.updateMemory("state", _state);
        }
    }

    protected function shuffleState (... ignored) :void
    {
        // TODO: this is actually invalid, because there is a "parity" issue with board states,
        // only half of them are solvable
        ArrayUtil.shuffle(_state);
        stateUpdated();

        positionTiles();
    }

    protected function handleMemoryChanged (event :ControlEvent) :void
    {
        // TODO
    }

    protected function handlePathComplete (path :Path) :void
    {
        _paths.slice(_paths.indexOf(path), 1);
    }

    protected static const BLANK_TILE :int = 15; 

    protected var _ctrl :FurniControl;

    protected var _blank :BlankTile;

    protected var _state :Array;

    protected var _tiles :Array = [];

    protected var _paths :Array = [];

    protected var _shuffle :Button;

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
        graphics.drawRect(0, 0, 100, 100);
        graphics.endFill();

        if (_over || _down) {
            graphics.lineStyle(5, _down ? 0x660000 : 0x000066);
            graphics.drawRoundRect(10, 10, 80, 80, 10, 10);
        }
    }

    protected var _over :Boolean;
    protected var _down :Boolean;

}
