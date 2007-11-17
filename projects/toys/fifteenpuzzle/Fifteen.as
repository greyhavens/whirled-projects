//
// $Id$

package {

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
            _state = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, null];
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
            if (_state[ii] != null) {
                var number :int = int(_state[ii]);
                var tile :Sprite = _tiles[number] as Sprite;
                var p :Point = computeTilePosition(ii);
                tile.x = p.x;
                tile.y = p.y;
            }
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

        var blankPosition :int = findPosition(null);
        if (areAdjacent(position, blankPosition)) {
            // update our state
            _state[blankPosition] = number;
            _state[position] = null;
            stateUpdated();

            // animate the tile moving to the blank position
            var dest :Point = computeTilePosition(blankPosition);
            var path :Path = Path.moveTo(tile, dest.x, dest.y, 250);
            path.setOnComplete(handlePathComplete);
            _paths.push(path);
            path.start();
        }
    }

    protected function identifyTile (tile :Sprite) :int
    {
        for (var ii :int = 0; ii < 15; ii++) {
            if (tile == _tiles[ii]) {
                return ii;
            }
        }

        Log.dumpStack();
        return -1;
    }

    protected function findPosition (tileId :Object) :int
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

    protected var _ctrl :FurniControl;

    protected var _state :Array;

    protected var _tiles :Array = [];

    protected var _paths :Array = [];

    protected var _shuffle :Button;

    protected var _label :Label;
}
}
