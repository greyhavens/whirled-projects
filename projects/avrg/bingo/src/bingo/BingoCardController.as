package bingo {

import com.whirled.AVRGameControlEvent;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class BingoCardController extends SceneObject
{
    public function BingoCardController (card :BingoCard)
    {
        _card = card;

        var cardViewClass :Class = BingoMain.resourcesDomain.getDefinition("Bingo_Board") as Class;
        _cardView = new cardViewClass();

        // draw the items
        for (var row :int = 0; row < card.height; ++row) {

            for (var col :int = 0; col < card.width; ++col) {

                var instanceName :String = "inst_r" + String(row + 1) + "c" + String(col + 1);
                var gridSquare :MovieClip = _cardView[instanceName];

                if (null != gridSquare) {

                    gridSquare.gotoAndStop(1);

                    var itemView :DisplayObject = this.createItemView(_card.getItemAt(col, row));
                    itemView.x = gridSquare.width * 0.5;
                    itemView.y = gridSquare.height * 0.5;

                    gridSquare.mouseChildren = false;

                    gridSquare.addEventListener(
                        MouseEvent.MOUSE_DOWN,
                        this.createGridSquareMouseHandler(gridSquare, col, row));

                    gridSquare.addChild(itemView);
                }
            }
        }
    }

    protected function createGridSquareMouseHandler (gridSquare :MovieClip, col :int, row :int) :Function
    {
        return function (...ignored) :void {
            handleClick(gridSquare, col, row);
        }
    }

    protected function handleClick (gridSquare :MovieClip, col :int, row :int) :void
    {
        // if the round is over, or we've already reached our
        // max-clicks-per-ball limit, don't accept clicks
        if (!BingoMain.model.roundInPlay || (!Constants.ALLOW_CHEATS && _numMatchesThisBall >= Constants.MAX_MATCHES_PER_BALL)) {
            return;
        }

        if (!_card.isFilledAt(col, row)) {

            var item :BingoItem = _card.getItemAt(col, row);

            if (null != item && (Constants.ALLOW_CHEATS || item.containsTag(BingoMain.model.curState.ballInPlay))) {
                _card.setFilledAt(col, row);

                gridSquare.gotoAndStop(2);

                _numMatchesThisBall += 1;
            }
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _cardView;
    }

    override protected function addedToDB () :void
    {
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        BingoMain.control.addEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged, false, 0, true);

        this.handleSizeChanged();
    }

    override protected function removedFromDB () :void
    {
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        BingoMain.control.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged);
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var loc :Point = this.properLocation;

        this.x = loc.x;
        this.y = loc.y;
    }

    protected function get properLocation () :Point
    {
        var loc :Point;

        if (BingoMain.control.isConnected()) {
            var stageSize :Rectangle = BingoMain.control.getStageSize(false);

            loc = (null != stageSize
                    ? new Point(stageSize.right + SCREEN_EDGE_OFFSET.x, stageSize.top + SCREEN_EDGE_OFFSET.y)
                    : new Point(0, 0));

        } else {
            loc = new Point(700 + SCREEN_EDGE_OFFSET.x, SCREEN_EDGE_OFFSET.y);
        }

        return loc;
    }

    public function createItemView (item :BingoItem) :DisplayObject
    {
        var sprite :Sprite = new Sprite();
        sprite.mouseChildren = false;
        sprite.mouseEnabled = false;

        if (null != item) {

            var bitmap :Bitmap = new item.itemClass();
            bitmap.x = -(bitmap.width * 0.5);
            bitmap.y = -(bitmap.height * 0.5);

            // does the item require recoloring?
            if (item.requiresTint) {
                var cm :ColorMatrix = new ColorMatrix();
                cm.tint(item.tintColor, item.tintAmount);
                bitmap.filters = [ cm.createFilter() ];
            }

            sprite.addChild(bitmap);
        }

        return sprite;
    }

    /*protected function handleClick (e :MouseEvent) :void
    {
        // if the round is over, or we've already reached our
        // max-clicks-per-ball limit, don't accept clicks
        if (!BingoMain.model.roundInPlay || (!Constants.ALLOW_CHEATS && _numMatchesThisBall >= Constants.MAX_MATCHES_PER_BALL)) {
            return;
        }

        var col :int = (this.mouseX - UL_OFFSET.x) / SQUARE_SIZE;
        var row :int = (this.mouseY - UL_OFFSET.y) / SQUARE_SIZE;

        if (!(col >= 0 && col < _card.width && row >= 0 && row < _card.height)) {
            return;
        }

        if (!_card.isFilledAt(col, row)) {

            var item :BingoItem = _card.getItemAt(col, row);

            if (null != item && (Constants.ALLOW_CHEATS || item.containsTag(BingoMain.model.curState.ballInPlay))) {
                _card.setFilledAt(col, row);

                // highlight the space
                var highlightClass :Class;
                var offset :Point = new Point();

                // ugh.
                if (col == 0 && row == 0) {
                    highlightClass = Resources.IMG_TOPLEFTHIGHLIGHT;
                } else if (col == _card.width - 1 && row == 0) {
                    highlightClass = Resources.IMG_TOPRIGHTHIGHLIGHT;
                } else if (col == 0 && row == _card.height - 1) {
                    highlightClass = Resources.IMG_BOTTOMLEFTHIGHLIGHT;
                } else if (col == _card.width - 1 && row == _card.height - 1) {
                    highlightClass = Resources.IMG_BOTTOMRIGHTHIGHLIGHT;
                } else {
                    highlightClass = Resources.IMG_CENTERHIGHLIGHT;
                    offset.x = 1;
                    offset.y = 1;
                }

                var hilite :Bitmap = new highlightClass();
                hilite.x = UL_OFFSET.x + offset.x + (col * SQUARE_SIZE);
                hilite.y = UL_OFFSET.y + offset.y + (row * SQUARE_SIZE);

                _bgSprite.addChild(hilite);

                _numMatchesThisBall += 1;
            }
        }

    }*/

    protected function handleNewBall (e :Event) :void
    {
        _numMatchesThisBall = 0;
    }

    protected var _cardView :MovieClip;
    protected var _card :BingoCard;
    protected var _numMatchesThisBall :int;

    protected static const TARGET_TEXT_WIDTH :Number = 56;

    protected static const SCREEN_EDGE_OFFSET :Point = new Point(-500, 220);

}

}
