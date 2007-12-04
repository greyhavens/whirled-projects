package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

import flash.events.Event;

import flash.geom.Matrix;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import com.threerings.util.ArrayUtil;

import com.threerings.flash.ColorUtil;

public class SeaDisplay extends Sprite
{
    /** The size of a tile. */
    public static const TILE_SIZE :int = 29;

    public function SeaDisplay ()
    {
        // set up a status text area, to be centered in the main view
        _status = new TextField();
        _status.multiline = true;
        _status.background = true;
        _status.autoSize = TextFieldAutoSize.CENTER;
        _status.selectable = false;

        addChild(_foreground);
    }

    /**
     * Configure the initial visualization of the sea.
     */
    public function setupSea (boardWidth :int, boardHeight :int) :void
    {
        _boardWidth = boardWidth;

        _grounds = [
            Bitmap(new GROUND1()).bitmapData,
            Bitmap(new GROUND2()).bitmapData,
            Bitmap(new GROUND3()).bitmapData
        ];

        _trees = [
            Bitmap(new TREE1()).bitmapData,
            Bitmap(new TREE2()).bitmapData,
            Bitmap(new TREE3()).bitmapData,
            Bitmap(new TREE4()).bitmapData,
            Bitmap(new TREE5()).bitmapData,
            Bitmap(new TREE6()).bitmapData
        ];

        graphics.clear();
        for (var yy :int = -SubAttack.VISION_TILES;
                yy < boardHeight + SubAttack.VISION_TILES; yy++) {
            for (var xx :int = -SubAttack.VISION_TILES;
                    xx < boardWidth + SubAttack.VISION_TILES; xx++) {

                graphics.beginBitmapFill(pickBitmap(_grounds));
                graphics.drawRect(xx * TILE_SIZE, yy * TILE_SIZE, TILE_SIZE, TILE_SIZE);
                graphics.endFill();
            }
        }

        // draw a nice border around Mr. Game Area
        graphics.lineStyle(5, 0xFFFFFF);
        graphics.drawRect(-5, -5, boardWidth * TILE_SIZE + 10,
            boardHeight * TILE_SIZE + 10);
        graphics.lineStyle(0, 0, 0); // turn off lines

        // now draw trees into our foreground, randomizing the order of trees on each row
        var xs :Array = [];
        for (xx = 0; xx < boardWidth; xx++) {
            xs.push(xx);
        }
        for (yy = 0; yy < boardHeight; yy++) {
            var xArray :Array = xs.concat();
            ArrayUtil.shuffle(xArray);
            for (var ii :int = 0; ii < xArray.length; ii++) {
                xx = int(xArray[ii]);
                var bmp :Bitmap = new Bitmap(pickBitmap(_trees));
                _treeBitmaps[yy * boardWidth + xx] = bmp;
                bmp.x = xx * TILE_SIZE + TREE_OFFSET;
                bmp.y = yy * TILE_SIZE + TREE_OFFSET;
                _foreground.addChild(bmp);
            }
        }
    }

    /**
     * Set the status message to be shown over the game board.
     */
    public function setStatus (msg :String) :void
    {
        _status.htmlText = msg;
        _status.x =
            ((SubAttack.VIEW_TILES * TILE_SIZE) - _status.textWidth) / 2;
        _status.y = 
            ((SubAttack.VIEW_TILES * TILE_SIZE) - _status.textHeight) / 2;
        if (_status.parent == null) {
            parent.addChild(_status);
        }
    }

    /**
     * Clear any status message being shown.
     */
    public function clearStatus () :void
    {
        if (_status.parent != null) {
            parent.removeChild(_status);
        }
    }

    /**
     * Set the submarine that we focus on and follow.
     */
    public function setFollowSub (sub :Submarine) :void
    {
        _sub = sub;
//        _followSub = sub.getGhost();
//        if (_followSub == null) {
            _followSub = sub;
//        }
        subUpdated(_followSub, sub.getX(), sub.getY());
    }

    public function canQueueActions () :Boolean
    {
        return _sub.canQueueActions();
    }

    public function queueAction (now :Number, action :int) :void
    {
        _sub.queueAction(now, action);
    }

    /**
     * Display the specified tile as now being traversable.
     */
    public function updateTraversable (
        xx :int, yy :int, value :int,
        aboveIsBlank :Boolean, belowIsBlank :Boolean) :void
    {
        if (value == Board.BLOCKED) {
//            _foreground.graphics.beginBitmapFill(pickBitmap(_trees));
//            _foreground.graphics.drawRect(
//                xx * TILE_SIZE + TREE_OFFSET, yy * TILE_SIZE + TREE_OFFSET,
//                TREE_SIZE, TREE_SIZE);

        } else if (value < Board.BLANK) {
            var playerIdx :int = int(value / -100);
            var level :int = -value % 100;
            var scheme :Array = (Submarine.SCHEMES[playerIdx] as Array);
            var color :uint = (uint(scheme[0] * 255) << 16) | (uint(scheme[1] * 255) << 8) |
                uint(scheme[2] * 255);
            if (level == 1) {
                // if damaged, draw darker
                color = ColorUtil.blend(color, 0, .8);
            }
            graphics.beginFill(color);
            graphics.drawRect(xx * TILE_SIZE, yy * TILE_SIZE, TILE_SIZE, TILE_SIZE);
            graphics.endFill();

//        } else if (!aboveIsBlank) {
//            graphics.beginBitmapFill(_downWall);
//        } else {
//            pickBitmap(_downs);
//        }

        } else {
            // kill a tree
            var index :int = yy * _boardWidth + xx;
            var bmp :Bitmap = Bitmap(_treeBitmaps[index]);
            if (bmp != null) {
                _treeBitmaps[index] = null;
                _foreground.removeChild(bmp);

            } else {
                // repaint the ground right there
                graphics.beginBitmapFill(pickBitmap(_grounds));
                graphics.drawRect(xx * TILE_SIZE, yy * TILE_SIZE, TILE_SIZE, TILE_SIZE);
                graphics.endFill();
            }
        }

//
//        graphics.drawRect(xx * TILE_SIZE, yy * TILE_SIZE, TILE_SIZE, TILE_SIZE);
//
//        if (value == 0 && belowIsBlank) {
//            pickBitmap(_downs);
//            graphics.drawRect(xx * TILE_SIZE, (yy + 1) * TILE_SIZE,
//                TILE_SIZE, TILE_SIZE);
//        }
    }

    /**
     * Called by subs when their location changes.
     */
    public function subUpdated (sub :Submarine, xx :int, yy :int) :void
    {
        if (_followSub != sub) {
            return;
        }

        x = (SubAttack.VISION_TILES - xx) * TILE_SIZE;
        y = (SubAttack.VISION_TILES - yy) * TILE_SIZE;
    }

    /**
     * Called by subs when their death state changes.
     */
    public function deathUpdated (sub :Submarine) :void
    {
        // we only care if it's the sub we're watching
        if (sub != _sub) {
            return;
        }

        var isDead :Boolean = sub.isDead();
        if (isDead) {
            setStatus("Press ENTER to respawn.");
        } else {
            clearStatus();
        }
    }

    /**
     * Set the graphics to begin filling a bitmap picked from the
     * specified set.
     */
    protected function pickBitmap (choices :Array) :BitmapData
    {
        return BitmapData(choices[int(Math.random() * choices.length)]);
    }

    /** The submarine that we're following. */
    protected var _followSub :Submarine;

    protected var _sub :Submarine;

    protected var _foreground :Sprite = new Sprite();

    protected var _boardWidth :int;

    protected var _treeBitmaps :Array = [];

    protected var _grounds :Array;

    protected var _trees :Array;

    /** Our status message. */
    protected var _status :TextField;

//    /** The frequency with which to pick each bitmap. Must add to 1.0 */
//    protected static const PICKS :Array = [ 0.10, 0.20, 0.30, 0.40 ];

    protected static const TREE_SIZE :int = 43;

    protected static const TREE_OFFSET :int = (TILE_SIZE - TREE_SIZE) / 2;

    [Embed(source="tree1.png")]
    protected static const TREE1 :Class;

    [Embed(source="tree2.png")]
    protected static const TREE2 :Class;

    [Embed(source="tree3.png")]
    protected static const TREE3 :Class;

    [Embed(source="tree4.png")]
    protected static const TREE4 :Class;

    [Embed(source="tree5.png")]
    protected static const TREE5 :Class;

    [Embed(source="tree6.png")]
    protected static const TREE6 :Class;

    [Embed(source="ground1.png")]
    protected static const GROUND1 :Class;

    [Embed(source="ground2.png")]
    protected static const GROUND2 :Class;

    [Embed(source="ground3.png")]
    protected static const GROUND3 :Class;
}
}
