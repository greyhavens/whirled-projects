package {

import flash.display.BlendMode;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import flash.geom.Matrix;
import flash.geom.Point;

import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;

import flash.utils.Dictionary;
import flash.utils.getTimer; // function import

import com.threerings.display.FloatingTextAnimation;
import com.threerings.display.FrameSprite;
import com.threerings.display.SiningTextAnimation;
import com.threerings.text.TextFieldUtil;

import com.whirled.MiniGameControl;

[SWF(width="80", height="50")]
public class Match3Overlay extends FrameSprite
{
    /** The number needed to match. */
    public static var MATCH :int = 3;

    /** The dimensions of the game. */
    public static const WIDTH :int = 80;
    public static const HEIGHT :int = 50;

    /** The size of blocks. */
    public static var BLOCK_WIDTH :int = 10;
    public static var BLOCK_HEIGHT :int = 10;

    /** The number of columns and rows that we get from the above two sizes. */
    public static var COLS :int = int(WIDTH / BLOCK_WIDTH);
    public static var ROWS :int = int(HEIGHT / BLOCK_HEIGHT);

    public static const ALL_FALL_LEFT :Boolean = false;

    public static var GRAVITY :Number = .00098;

    public static var COLORS_TO_USE :int = 5;

    /** Block colors. */
    public static const COLORS :Array = [
        0xFF00EE, // pink
        0xFFFB00, // yellow
        0x00FFF2, // cyan
        0x04FF00, // green
        0xFF0400, // red
        0x002BFF, // blue
        0xFFA600, // orange
        0xFFFFFF  // white
    ];

    public function Match3Overlay ()
    {
        COLS = int(WIDTH / BLOCK_WIDTH);
        ROWS = int(HEIGHT / BLOCK_HEIGHT);

        // create a background sprite that will also receive mouse events
        // even when no Block is in that place
        var bkg :Sprite = new Sprite();
        with (bkg.graphics) {
            beginFill(0x000000, 0);
            drawRect(0, 0, WIDTH, HEIGHT);
            endFill();
        }
        addChild(bkg);

        // the _board sprite contains pieces, so that all pieces are under the cursor
        addChild(_board);

        // the effects layer will contain score animations and the like
        addChild(_effects);

        // create the cursor
        _cursor = new Cursor();
        _cursor.x = 0;
        _cursor.y = 0;
        addChild(_cursor);

        // set up the board: create off-screen black blocks that will act
        // as "stoppers" for falling blocks.
        for (var yy :int = 0; yy < ROWS; yy++) {
            var xx :int = ALL_FALL_LEFT || (yy % 2 == 0) ? -1 : COLS;
            var block :Block = new Block(0x000000, 1, xx, yy, _blocks);
            // Note: no need to add it to the display, it's just needed
            // logically.
        }

        // configure a mask so that blocks coming in from the edges don't
        // paint-out
        var masker :Shape = new Shape();
        with (masker.graphics) {
            beginFill(0xFFFFFF);
            drawRect(0, 0, WIDTH, HEIGHT);
            endFill();
        }
        this.mask = masker;
        addChild(masker);

        addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
        addEventListener(MouseEvent.CLICK, handleMouseClick);
    }

    override protected function handleAdded (... ignored) :void
    {
        _ctrl = new MiniGameControl(this);
        _lastIdleStamp = getTimer();
        super.handleAdded();
    }

    override protected function handleFrame (... ignored) :void
    {
        var stamp :Number = getTimer();
        //trace("-----------: " + stamp);
        var yy :int;
        var xx :int;
        var dir :int;
        var block :Block;
        var other :Block;

        // first, ensure that there are blocks sitting in the off-screen
        // fall-in positions
        for (yy = 0; yy < ROWS; yy++) {
            dir = ALL_FALL_LEFT || (yy % 2 == 0) ? -1 : 1;
            xx = (dir == 1) ? 0 : COLS - 1;

            if ((null == _blocks.get(xx, yy)) && (null == _blocks.get(xx - dir, yy))) {
                //trace("Adding block at " + (xx - dir) + ", " + yy);
                block = new Block(pickBlockColor(yy), dir, xx - dir, yy, _blocks);
                _board.addChild(block);
            }
        }

        // then, look for blocks that are not moving with no adjacent
        // block in the fall direction
        for (yy = 0; yy < ROWS; yy++) {
            // figure out the direction of falling on this row
            dir = ALL_FALL_LEFT || (yy % 2 == 0) ? -1 : 1;

            // preload the first 'other' block
            block = _blocks.get((dir == 1) ? COLS : -1, yy);
            for (xx = (dir == 1) ? COLS - 1: 0; (dir == 1) ? (xx >= -1) : (xx <= COLS); xx -= dir) {

                // the previous block becomes 'other'
                other = block;
                block = _blocks.get(xx, yy);
                if (block != null && block.isStopped() &&
                        ((other == null) || other.isFalling())) {
                    block.setFalling(dir, stamp);
                }
            }
        }

        var allBlocks :Array = _blocks.getAll();
        // ok, then update each block
        for each (block in allBlocks) {
            if (block.isSwapping() || block.isBooming()) {
                _lastMovementStamp = stamp;
                block.update(stamp);
            }
        }

        for each (block in allBlocks) {
            if (block.isFalling()) {
                _lastMovementStamp = stamp;
                block.update(stamp);
            }
        }

        // now go find non-moving blocks and initiate any destructions
        var blowups :Dictionary = new Dictionary();
        var blowSequences :int = 0;
        for (yy = 0; yy < ROWS; yy++) {
            for (xx = 0; xx < COLS; xx++) {
                block = _blocks.get(xx, yy);
                if (block == null || !block.isStopped()) {
                    continue;
                }
                // otherwise, it's a candidate...
                var horzBlocks :Array = [];
                for (var x2 :int = xx + 1; x2 < COLS; x2++) {
                    other = _blocks.get(x2, yy);
                    if (other == null || !other.isStopped() || (block.color != other.color)) {
                        break;
                    }
                    // otherwise, it's good!
                    horzBlocks.push(other);
                }
                var vertBlocks :Array = [];
                for (var y2 :int = yy + 1; y2 < ROWS; y2++) {
                    other = _blocks.get(xx, y2);
                    if (other == null || !other.isStopped() || (block.color != other.color)) {
                        break;
                    }
                    // it's good!
                    vertBlocks.push(other);
                }
                if (horzBlocks.length >= (MATCH - 1)) {
                    for each (other in horzBlocks) {
                        blowups[other] = true;
                    }
                    blowups[block] = true;
                    blowSequences++;
                }
                if (vertBlocks.length >= (MATCH - 1)) {
                    for each (other in vertBlocks) {
                        blowups[other] = true;
                    }
                    blowups[block] = true;
                    blowSequences++;
                }
            }
        }
        // now, go through and start blowing up the blow-up blocks!
        var blowCount :int = 0;
        xx = 0;
        yy = 0;
        for (var bb :* in blowups) {
            block = (bb as Block);
            xx += block.x;
            yy += block.y;
            block.setDestroying(stamp);
            blowCount++;
        }
        if (blowCount > 0) {
            if (blowCount > 3) {
                var fta :FloatingTextAnimation = new FloatingTextAnimation(getScoreText(blowCount),
                    _scoreAnimProps);
                fta.x = (xx / blowCount) + BLOCK_WIDTH/2;
                fta.y = (yy / blowCount) + BLOCK_HEIGHT/2;
                _effects.addChild(fta);
            }

            _lastMovementStamp = stamp;

            var score :Number = (blowCount - 2) / (10 * (_clicks + 2));
            // no clicks, 3 breaks: .5
            // 1 click, 3 breaks: .3
            // 1 click, 5 breaks: 1
            // good enough for now...

            // style points are accumulated for keeping it going...
            var style :Number = Math.min(1, (stamp - _lastIdleStamp) / 10000);
            _ctrl.reportPerformance(score, style);
            _clicks = 0;
        }

        // if nothing is moving this tick, track it as our last idle stamp
        if (stamp != _lastMovementStamp) {
            _lastIdleStamp = stamp;
        }

//        // TEMP: look for lost blocks
//        allBlocks = _blocks.getAll();
//        for (var ii :int = _board.numChildren - 1; ii >= 0; ii--) {
//            block = (_board.getChildAt(ii) as Block);
//            if (allBlocks.indexOf(block) == -1) {
//                trace("Oh lordy! We have an orphan: " + block);
//            }
//        }
    }

    protected function handleMouseMove (event :MouseEvent) :void
    {
        var p :Point = globalToLocal(new Point(event.stageX, event.stageY));
        var xx :int = Math.floor(p.x / BLOCK_WIDTH);
        var yy :int = Math.min(ROWS - 2, Math.max(0, 
            Math.floor((p.y - (BLOCK_HEIGHT/2)) / BLOCK_HEIGHT)));

        _cursor.x = xx * BLOCK_WIDTH;
        _cursor.y = yy * BLOCK_HEIGHT;

        event.updateAfterEvent(); // for the snappyness
    }

    protected function handleMouseClick (event :MouseEvent) :void
    {
        var lx :int = _cursor.x / BLOCK_WIDTH;
        var ly :int = _cursor.y / BLOCK_HEIGHT;

        var b1 :Block = _blocks.get(lx, ly);
        var b2 :Block = _blocks.get(lx, ly + 1);
        if (b1 == null && b2 == null) {
            // nothing to do, move along
            return;
        }

        var stamp :Number = getTimer();
        for (var yy :int = 0; yy <= 1; yy++) {
            var block :Block = (yy == 0) ? b1 : b2;
            if (block == null) {
                // add a placeholder swap block
                block = new Block(Block.SWAPPER, 1, lx, ly + yy, _blocks);

            } else if (!block.isSwapping()) {
                block.setSwapping((yy == 0) ? 1 : -1, stamp);
            }
        }

        event.updateAfterEvent();
        _clicks++;
    }

    protected function pickBlockColor (yy :int) :uint
    {
        var pick :int;
        do {
            pick = Math.floor(Math.random() * COLORS_TO_USE);
        } while (pick == _lastInserted[yy]);
        _lastInserted[yy] = pick;
        return uint(COLORS[pick]);
    }

    protected function getScoreText (destroyed :int) :String
    {
        switch (destroyed) {
        case 4: return "Great!";
        case 5: return "Awesome!";
        case 6: return "Too sweet!";
        default: return "Stupendous!"
        }
    }

    protected var _ctrl :MiniGameControl;

    /** The cursor. */
    protected var _cursor :Cursor;

    protected var _board :Sprite = new Sprite();

    protected var _effects :Sprite = new Sprite();

    protected var _blocks :BlockMap = new BlockMap();

    protected var _lastMovementStamp :Number = 0;

    protected var _scoreAnimProps :Object = {
        outlineColor: 0x000000,
        defaultTextFormat: TextFieldUtil.createFormat({ bold: true, font: "System", color: 0xFFFFFF})
    };

    /** The timestamp at which the board was last idle. */
    protected var _lastIdleStamp :Number;

    /** Tracks the last-inserted color on each row. */
    protected var _lastInserted :Array = [];

    /** The number of clicks since the last block scoring. */
    protected var _clicks :int = 0;

    protected static const NO_MOVE_PROMPT_TIME :int = 2000;
}
}

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.filters.ColorMatrixFilter;
import flash.filters.GlowFilter;

import flash.utils.getTimer; // function import

import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.threerings.display.ColorUtil;

class Cursor extends Sprite
{
    public function Cursor ()
    {
        alpha = .4;
        blendMode = BlendMode.LAYER;

        for (var ii :int = 0; ii < 2; ii++) {
            with (graphics) {
                if (ii == 0) {
                    lineStyle(1, 0x000000);
                } else {
                    lineStyle(.1, 0xFF0000);
                }

                var y3 :Number = Match3Overlay.BLOCK_HEIGHT / 3;
                var h :Number = Match3Overlay.BLOCK_HEIGHT * 2;

                moveTo(0, y3);
                lineTo(0, 0);
                lineTo(Match3Overlay.BLOCK_WIDTH, 0);
                lineTo(Match3Overlay.BLOCK_WIDTH, y3);


                moveTo(0, h - y3);
                lineTo(0, h);
                lineTo(Match3Overlay.BLOCK_WIDTH, h);
                lineTo(Match3Overlay.BLOCK_WIDTH, h - y3);
            }
        }
    }

}

class BlockMap
{
    public function add (block :Block) :void
    {
        if (undefined !== _map.put(keyFor(block.lx, block.ly), block)) {
            throw new Error("Already a block at (" + block.lx + ", " + block.ly + ")");
        }
    }

    public function get (lx :int, ly :int) :Block
    {
        return (_map.get(keyFor(lx, ly)) as Block);
    }

    public function move (oldx :int, oldy :int, block :Block) :void
    {
        removeTolerant(oldx, oldy, block);
        // and we are allowed to overwrite another block..
        _map.put(keyFor(block.lx, block.ly), block);
    }

    public function remove (block :Block) :void
    {
        if (block !== _map.remove(keyFor(block.lx, block.ly))) {
            throw new Error("Removed block not at (" + block.lx + ", " + block.ly + ")");
        }
    }

    public function removeTolerant (oldx :int, oldy :int, block :Block) :void
    {
        // here we are extremely forgiving- the block may not be in the old loc
        var oldKey :int = keyFor(oldx, oldy);
        if (block === _map.get(oldKey)) {
            _map.remove(oldKey);
        }
    }

    public function setDestroying (block :Block) :void
    {
    //    remove(block);
        //_destroying.push(block);
    }

    public function finishDestroy (block :Block) :void
    {
        remove(block);

//        var dex :int = _destroying.indexOf(block);
//        if (dex != -1) {
//            _destroying.splice(dex, 1);
//            remove(block);
//
//        } else {
//            throw new Error("Could not find destroying block " + 
//                "(" + block.lx + ", " + block.ly + ")");
//        }
    }

    public function getAll () :Array
    {
        var arr :Array = _map.values();
        var len :int = arr.length;
        for each (var thing :* in _destroying) {
            arr.push(thing);
        }
        return arr;
    }

    protected function keyFor (lx :int, ly :int) :int
    {
        // we multiply by 1000 to spread things out, since our
        // x coordinates can vary from -1 to ROWS + 1.
        return ly * 1000 + lx;
    }

    protected var _map :Map = Maps.newMapOf(int);

    protected var _destroying :Array = [];
}

class Block extends Sprite
{
    /** The color of the block. */
    public var color :uint;

    /** The block's logical X. */
    public var lx :int;

    /** The block's logical Y. */
    public var ly :int;

    public static const SWAPPER :uint = 0xdeadbe;

    /**
     * Create a block of the specified color.
     */
    public function Block (color :uint, drawDir :int, lx :int, ly :int, map :BlockMap)
    {
        alpha = .4;
        blendMode = BlendMode.LAYER;

        this.color = color;
        _drawDir = drawDir;
        this.lx = lx;
        this.ly = ly;
        _map = map;

        this.x = lx * Match3Overlay.BLOCK_WIDTH;
        this.y = ly * Match3Overlay.BLOCK_HEIGHT;
        
        // try adding ourselves to the map
        map.add(this);

        updateVisual();
    }

    public function isStopped () :Boolean
    {
        return (_movement == NONE);
    }

    public function isFalling () :Boolean
    {
        return (_movement == FALL);
    }

    public function isSwapping () :Boolean
    {
        return (_movement == SWAP);
    }

    public function isBooming () :Boolean
    {
        return (_movement == BOOM);
    }

    /**
     */
    public function setFalling (direction :Number, stamp :Number) :void
    {
        startMove(FALL, direction, stamp);
    }

    public function setSwapping (direction :Number, stamp :Number) :void
    {
        // bump X to its precise value
        x = lx * Match3Overlay.BLOCK_WIDTH;

        startMove(SWAP, direction, stamp);
    }

    public function setDestroying (stamp :Number) :void
    {
        _map.setDestroying(this);

        parent.setChildIndex(this, parent.numChildren - 1);

        startMove(BOOM, 0, stamp);
        updateVisual();
    }

    public function update (stamp :Number) :void
    {
        if (_movement == NONE) {
            return;
        }

        var elapsed :Number = stamp - _moveStamp;

        if (_movement == FALL) {
            // calculate a new X
            var newX :Number = _orig + (Match3Overlay.GRAVITY * _dir * elapsed * elapsed);

            // check to see if there's a hard limit to where we'll fall
            var other :Block = _map.get(lx + _dir, ly);
            if (other != null) {// && !other.isFalling()) {
                var xlimit :Number = lx * Match3Overlay.BLOCK_WIDTH;
                var doStop :Boolean = (_dir == 1) ? (newX >= xlimit) : (newX <= xlimit);
                if (doStop) {
                    newX = xlimit;
                    _movement = NONE;
                }
            }

            // assign the new x coordinate
            x = newX;

            // see if we need to update our logical position
            var newlx :int;
            if (newX < 0) {
                newlx = (newX - Match3Overlay.BLOCK_WIDTH/2) / Match3Overlay.BLOCK_WIDTH;
            } else {
                newlx = (newX + Match3Overlay.BLOCK_WIDTH/2) / Match3Overlay.BLOCK_WIDTH;
            }
            if (newlx != lx) {
                if (newlx != (lx + _dir)) {
                    // don't let it move too much in one tick
                    newlx = lx + _dir;
                    x = newlx * Match3Overlay.BLOCK_WIDTH;
                    if (_movement == NONE) {
                        throw new Error("ACk! This shouldn't happen");
                    }
                }
                var oldlx :int = lx;
                lx = newlx;
                _map.move(oldlx, ly, this);
            }

        } else if (_movement == SWAP) {
            var newY :Number = _orig + (_dir * SWAP_VELOCITY * elapsed);
            //trace("Swap newY: " + newY);
            var ylimit :Number = _orig + (_dir * Match3Overlay.BLOCK_HEIGHT);
            if ((_dir == 1) ? (newY >= ylimit) : (newY <= ylimit)) {
                newY = ylimit;
                _movement = NONE; // maybe falling next tick...
            }

            y = newY;

            var newly :int = (newY + Match3Overlay.BLOCK_HEIGHT/2 + (_dir * .001)) / Match3Overlay.BLOCK_HEIGHT;
            if (newly != ly) {
                var oldly :int = ly;
                ly = newly;
                if (color == SWAPPER) {
                    _map.removeTolerant(lx, oldly, this);
                    // the swapper just goes away
                } else {
                    _map.move(lx, oldly, this);
                }

                _drawDir = -_drawDir;
                updateVisual();
            }

        } else if (_movement == BOOM) {
            var perc :Number = elapsed / BOOM_DURATION;

            if (perc >= 1) {
                if (parent != null) {
                    parent.removeChild(this);
                }
                _map.finishDestroy(this);

            } else {
                this.filters = [
                    new GlowFilter(0xFFFFFF, 1, perc * 64, perc * 64)
                ];
            }
        }
    }

    override public function toString () :String
    {
        return "Block[x=" + x.toFixed(2) + ", y=" + y.toFixed(2) +
            ", lx=" + lx + ", ly=" + ly + ", movement=" + _movement + "]";
    }

    protected function startMove (movement :int, dir :Number, stamp :Number) :void
    {
        _movement = movement;
        _dir = dir;
        _moveStamp = stamp;
        _orig = (movement == FALL) ? (lx * Match3Overlay.BLOCK_WIDTH)
                                   : (ly * Match3Overlay.BLOCK_HEIGHT);
    }

    protected function updateVisual () :void
    {
        var g :Graphics = this.graphics;
        g.clear();

        if (_movement == BOOM) {
            g.beginFill(0xFFFFFF);
            g.drawRect(0, 0, Match3Overlay.BLOCK_WIDTH, Match3Overlay.BLOCK_HEIGHT);
            g.endFill();
            alpha = 1;
            blendMode = BlendMode.NORMAL;
            return;
        }

        if (color != SWAPPER) {
            g.beginFill(color);
            g.lineStyle(.1, 0);
            g.drawRect(0, 0, Match3Overlay.BLOCK_WIDTH, Match3Overlay.BLOCK_HEIGHT);
            g.endFill();

            // draw a directional chevron
            g.lineStyle(2, ColorUtil.blend(color, 0, .75));
            var x1 :Number = Match3Overlay.BLOCK_WIDTH - CHEVRON_X_PAD;
            var x2 :Number;
            if (_drawDir == 1) {
                x2 = x1;
                x1 = CHEVRON_X_PAD;
            } else {
                x2 = CHEVRON_X_PAD;
            }

            g.moveTo(x1, CHEVRON_Y_PAD);
            g.lineTo(x2, Match3Overlay.BLOCK_HEIGHT / 2);
            g.lineTo(x1, Match3Overlay.BLOCK_HEIGHT - CHEVRON_Y_PAD);
        }
    }

    protected var _map :BlockMap;

    /** Movement types. */
    protected static const NONE :int = 0;
    protected static const FALL :int = 1;
    protected static const SWAP :int = 2;
    protected static const BOOM :int = 3;

    protected var _movement :int = NONE;

    /** The original x or y, depending on whether we're falling or swapping. */
    protected var _orig :int;

    protected var _dir :Number;

    protected var _drawDir :int;

    /** The stamp at which we started moving. */
    protected var _moveStamp :Number;

    protected static const SWAP_VELOCITY :Number = Match3Overlay.BLOCK_HEIGHT / 200;

    protected static const BOOM_DURATION :Number = 200;

    protected static const CHEVRON_X_PAD :int = 6;
    protected static const CHEVRON_Y_PAD :int = 3;
}
