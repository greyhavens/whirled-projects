package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;

import flash.geom.Matrix;
import flash.geom.Rectangle;

import flash.media.Sound;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import flash.utils.getTimer; // function import

import com.threerings.util.ArrayUtil;
import com.threerings.util.Random;

import com.threerings.flash.ColorUtil;
import com.threerings.flash.FilterUtil;
import com.threerings.flash.SiningTextAnimation;
import com.threerings.flash.TextFieldUtil;

public class SeaDisplay extends Sprite
{
    /** The size of a tile. */
    public static const TILE_SIZE :int = 31;

    public function SeaDisplay ()
    {
        var extent :int = int(Math.ceil(SubAttack.VISION_TILES)) * 2 + 1;
        _soundRect = new Rectangle(0, 0, extent, extent);
    }

    /**
     * Configure the initial visualization of the sea.
     */
    public function setupSea (
        boardWidth :int, boardHeight :int,
        theBoard :Board = null, board :Array = null, rando :Random = null) :void
    {
        _boardWidth = boardWidth;
        _boardHeight = boardHeight;

        _grounds = [
            Bitmap(new GROUND1()).bitmapData,
            Bitmap(new GROUND2()).bitmapData,
            Bitmap(new GROUND3()).bitmapData
        ];

        _moss = [
            Bitmap(new MOSS1()).bitmapData,
            Bitmap(new MOSS2()).bitmapData
        ];

        _trees = [
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
            Bitmap(new ROCK4()).bitmapData,
            Bitmap(new TEMPLE()).bitmapData
        ];

        _panda = Bitmap(new PANDA()).bitmapData;
        _dodo = Bitmap(new DODO()).bitmapData;
        _dino = Bitmap(new DINO()).bitmapData;
        _unicorn = Bitmap(new UNICORN()).bitmapData;

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

                // draw in the background, if needed
                if (type == Board.BLANK || Board.isAnimal(type)) {
                    toDraw = pickBitmap(rando, theBoard.castsMoss(xx, yy - 1) ? _moss : _grounds);
                    data.draw(toDraw, matrix);
                }
                // draw in the foreground
                switch (type) {
                case Board.TREE:
                case Board.ROCK:
                    toDraw = pickBitmap(rando, (type == Board.TREE) ? _trees : rocks);
                    data.draw(toDraw, matrix);
                    break;

                default:
                    toDraw = animalToBitmap(type);
                    if (toDraw != null) {
                        data.draw(toDraw, matrix);
                    }
                    break;
                }
            }
        }
    }

    /**
     * Set the status message to be shown over the game board.
     */
    public function setStatus (msg :String, size :int = 24) :void
    {
        clearStatus();

        _status = new SiningTextAnimation(msg, {
            outlineColor: 0x673c0f, selectable: false,
            defaultTextFormat: TextFieldUtil.createFormat({
                font: "_sans", size: size, color: 0xfee610, bold: true
            })
        });
        _status.x = (SubAttack.VIEW_TILES * TILE_SIZE) / 2;
        _status.y = (SubAttack.VIEW_TILES * TILE_SIZE) / 2;
        parent.addChild(_status);
    }

    public function displayWaiting () :void
    {
        showStatus(WAITING);
    }

    public function displayGameOver () :void
    {
        showStatus(GAMEOVER);
    }

    /**
     * Clear any status message being shown.
     */
    public function clearStatus () :void
    {
        if (_status != null) {
            parent.removeChild(_status);
            _status = null;
        }
    }

    /**
     * Instantiate and center the specified class as our status.
     */
    protected function showStatus (clazz :Class) :void
    {
        clearStatus();

        _status = new clazz() as DisplayObject;
        _status.x = ((SubAttack.VIEW_TILES * TILE_SIZE) - _status.width) / 2;
        _status.y = ((SubAttack.VIEW_TILES * TILE_SIZE) - _status.height) / 2;
        parent.addChild(_status);
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

    public function applyGameOverAction (action :int) :void
    {
        switch (action) {
        case Action.LEFT:
            x = Math.min(x + TILE_SIZE, TILE_SIZE * SubAttack.VISION_TILES);
            break;

        case Action.RIGHT:
            x = Math.max(x - TILE_SIZE, TILE_SIZE * (SubAttack.VISION_TILES - (_boardWidth - 1)));
            break;

        case Action.UP:
            y = Math.min(y + TILE_SIZE, TILE_SIZE * SubAttack.VISION_TILES);
            break;

        case Action.DOWN:
            y = Math.max(y - TILE_SIZE, TILE_SIZE * (SubAttack.VISION_TILES - (_boardHeight - 1)));
            break;

        case Action.SHOOT:
            // recenter
            subUpdated(_followSub, _followSub.getX(), _followSub.getY());
            break;
        }
    }

    /**
     * Display the specified tile as now being traversable.
     */
    public function updateTraversable (xx :int, yy :int, value :int, board :Board) :void
    {
        var matrix :Matrix = new Matrix();
        matrix.translate(xx * TILE_SIZE, yy * TILE_SIZE);

        if (value == Board.BLANK) {
            // draw a blank square
            _tiles.bitmapData.draw(pickBitmap(null, board.castsMoss(xx, yy - 1) ? _moss : _grounds),
                matrix);

            if (board.isBlank(xx, yy + 1)) {
                matrix.translate(0, TILE_SIZE);
                _tiles.bitmapData.draw(pickBitmap(null, _grounds), matrix);
            }

        } else {
            var toDraw :BitmapData = animalToBitmap(value);
            if (toDraw != null) {
                _tiles.bitmapData.draw(toDraw, matrix);
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

        var extent :int = int(Math.ceil(SubAttack.VISION_TILES));
        _soundRect.x = xx - extent;
        _soundRect.y = yy - extent;
        x = (SubAttack.VISION_TILES - xx) * TILE_SIZE;
        y = (SubAttack.VISION_TILES - yy) * TILE_SIZE;
    }

    public function playSound (sound :Sound, xx :int, yy :int) :void
    {
        if (_soundRect.contains(xx, yy)) {
            sound.play();
        }
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

    protected function animalToBitmap (type :int) :BitmapData
    {
        switch (type) {
        case Board.PANDA:
            return _panda;

        case Board.DODO:
            return _dodo;

        case Board.DINOSAUR:
            return _dino;

        case Board.UNICORN:
            return _unicorn;

        default:
            return null;
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

    protected var _soundRect :Rectangle;

    protected var _tiles :Bitmap;

    protected var _panda :BitmapData;
    protected var _dodo :BitmapData;
    protected var _dino :BitmapData;
    protected var _unicorn :BitmapData;

    protected var _sub :Submarine;

    protected var _boardWidth :int;
    protected var _boardHeight :int;

    protected var _trees :Array;

    protected var _grounds :Array;

    protected var _moss :Array;

    /** Our status message. */
    protected var _status :DisplayObject;

    /** A custom status object for "waiting for players". */
    [Embed(source="rsrc/waiting_for_players.png")]
    protected static const WAITING :Class;

    /** A custom status object for "Game Over". */
    [Embed(source="rsrc/game_over.png")]
    protected static const GAMEOVER :Class;

    [Embed(source="rsrc/temple.png")]
    protected static const TEMPLE :Class;

    [Embed(source="rsrc/tree1.png")]
    protected static const TREE1 :Class;

    [Embed(source="rsrc/tree2.png")]
    protected static const TREE2 :Class;

    [Embed(source="rsrc/tree3.png")]
    protected static const TREE3 :Class;

    [Embed(source="rsrc/tree4.png")]
    protected static const TREE4 :Class;

    [Embed(source="rsrc/tree5.png")]
    protected static const TREE5 :Class;

    [Embed(source="rsrc/tree6.png")]
    protected static const TREE6 :Class;

    [Embed(source="rsrc/ground1.png")]
    protected static const GROUND1 :Class;

    [Embed(source="rsrc/ground2.png")]
    protected static const GROUND2 :Class;

    [Embed(source="rsrc/ground3.png")]
    protected static const GROUND3 :Class;

    [Embed(source="rsrc/ground4_moss.png")]
    protected static const MOSS1 :Class;

    [Embed(source="rsrc/ground5_moss.png")]
    protected static const MOSS2 :Class;

    [Embed(source="rsrc/rock1.png")]
    protected static const ROCK1 :Class;

    [Embed(source="rsrc/rock2.png")]
    protected static const ROCK2 :Class;

    [Embed(source="rsrc/rock3.png")]
    protected static const ROCK3 :Class;

    [Embed(source="rsrc/rock4.png")]
    protected static const ROCK4 :Class;

    [Embed(source="rsrc/animal_panda.png")]
    protected static const PANDA :Class;

    [Embed(source="rsrc/animal_dodo.png")]
    protected static const DODO :Class;

    [Embed(source="rsrc/animal_dinosaur.png")]
    protected static const DINO :Class;

    [Embed(source="rsrc/animal_unicorn.png")]
    protected static const UNICORN :Class;
}
}
