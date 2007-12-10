package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;

import flash.geom.Matrix;
import flash.geom.Rectangle;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import flash.utils.getTimer; // function import

import com.threerings.util.ArrayUtil;
import com.threerings.util.Random;

import com.threerings.flash.ColorUtil;
import com.threerings.flash.FilterUtil;

public class SeaDisplay extends Sprite
{
    /** The size of a tile. */
    public static const TILE_SIZE :int = 31;

    public function SeaDisplay ()
    {
        // set up a status text area, to be centered in the main view
        _status = new TextField();
        _status.multiline = true;
        _status.background = true;
        _status.autoSize = TextFieldAutoSize.CENTER;
        _status.selectable = false;
    }

    /**
     * Configure the initial visualization of the sea.
     */
    public function setupSea (
        boardWidth :int, boardHeight :int, board :Array = null, rando :Random = null) :void
    {
        _boardWidth = boardWidth;

        _grounds = [
            Bitmap(new GROUND1()).bitmapData,
            Bitmap(new GROUND2()).bitmapData,
            Bitmap(new GROUND3()).bitmapData
        ];

        _moss = [
            Bitmap(new MOSS1()).bitmapData,
            Bitmap(new MOSS2()).bitmapData
        ];

        var trees :Array = [
            Bitmap(new TREE1()).bitmapData,
            Bitmap(new TREE2()).bitmapData,
            Bitmap(new TREE3()).bitmapData,
            Bitmap(new TREE4()).bitmapData,
            Bitmap(new TREE5()).bitmapData,
            Bitmap(new TREE6()).bitmapData
        ];

        var rocks :Array = [
            Bitmap(new ROCK1()).bitmapData,
            Bitmap(new ROCK2()).bitmapData,
            Bitmap(new ROCK3()).bitmapData,
            Bitmap(new ROCK4()).bitmapData
        ];

        if (rando == null) {
            rando = new Random(int(getTimer()));
        }

        var data :BitmapData = new BitmapData(boardWidth * TILE_SIZE, boardHeight * TILE_SIZE,
            true, 0);
        _tiles = new Bitmap(data);
        addChild(_tiles);

        graphics.clear();

        var xx :int;
        var yy :int;
        var toDraw :BitmapData;
        var matrix :Matrix;

        for (yy = 0; yy < boardHeight; yy++) {
            for (xx = 0; xx < boardWidth; xx++) {
                var type :int = (board == null) ? Board.TREE : int(board[xx + yy * boardWidth]);
                matrix = new Matrix();
                matrix.translate(xx * TILE_SIZE, yy * TILE_SIZE);

                // draw in the background
                switch (type) {
                case Board.TREE:
                    // no background needed
                    break;

                case Board.BLANK:
                    // if we're blank, we need to be either moss or ground, depending on what's
                    // above us.
                    if (yy == 0 || (Board.BLANK == int(board[xx * (yy - 1) * boardWidth]))) {
                        toDraw = pickBitmap(rando, _grounds);
                    } else {
                        toDraw = pickBitmap(rando, _moss);
                    }
                    data.draw(toDraw, matrix);
                    break;

                default:
                    toDraw = pickBitmap(rando, _grounds);
                    data.draw(toDraw, matrix);
                    break;
                }
                // draw in the foreground
                switch (type) {
                case Board.TREE:
                case Board.ROCK:
                    toDraw = pickBitmap(rando, (type == Board.TREE) ? trees : rocks);
                    data.draw(toDraw, matrix);
                    break;
                }
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

    public function addFactory (factory :Factory) :void
    {
        // factories need to be added so that they are in front of factories with a lower y
        // since there aren't many factories, we can do this dumbly
        var insertionPoint :int = 1;
        while (true) {
            var otherFact :DisplayObject = getChildAt(insertionPoint);
            if (otherFact.name == "factory" && otherFact.y < factory.y) {
                insertionPoint++;
            } else {
                break;
            }
        }
        addChildAt(factory, insertionPoint);
    }

    /**
     * Display the specified tile as now being traversable.
     */
    public function updateTraversable (
        xx :int, yy :int, value :int,
        aboveIsBlank :Boolean, belowIsBlank :Boolean) :void
    {
        if (value == Board.BLANK) {
            // draw a blank square
            var matrix :Matrix = new Matrix();
            matrix.translate(xx * TILE_SIZE, yy * TILE_SIZE);
            _tiles.bitmapData.draw(pickBitmap(null, aboveIsBlank ? _grounds : _moss), matrix);

            if (belowIsBlank) {
                matrix.translate(0, TILE_SIZE);
                _tiles.bitmapData.draw(pickBitmap(null, _grounds), matrix);
            }
        }
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
    protected function pickBitmap (rando :Random, choices :Array) :BitmapData
    {
        var pick :int = (rando != null) ? rando.nextInt(choices.length)
                                        : int(Math.random() * choices.length);
        return BitmapData(choices[pick]);
    }

    /** The submarine that we're following. */
    protected var _followSub :Submarine;

    protected var _tiles :Bitmap;

    protected var _sub :Submarine;

    protected var _boardWidth :int;

    protected var _grounds :Array;

    protected var _moss :Array;

    /** Our status message. */
    protected var _status :TextField;

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

    [Embed(source="ground4_moss.png")]
    protected static const MOSS1 :Class;

    [Embed(source="ground5_moss.png")]
    protected static const MOSS2 :Class;

    [Embed(source="rock1.png")]
    protected static const ROCK1 :Class;

    [Embed(source="rock2.png")]
    protected static const ROCK2 :Class;

    [Embed(source="rock3.png")]
    protected static const ROCK3 :Class;

    [Embed(source="rock4.png")]
    protected static const ROCK4 :Class;
}
}
