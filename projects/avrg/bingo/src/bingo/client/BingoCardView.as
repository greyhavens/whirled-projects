package bingo.client {

import bingo.*;

import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class BingoCardView extends SceneObject
{
    public static const NAME :String = "BingoCardController";

    public function BingoCardView (card :BingoCard)
    {
        _card = card;

        _cardView = SwfResource.instantiateMovieClip("board", "Bingo_Board");

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

    override public function get objectName () :String
    {
        return NAME;
    }

    override public function get displayObject () :DisplayObject
    {
        return _cardView;
    }

    override protected function addedToDB () :void
    {
        ClientContext.model.addEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        ClientContext.gameCtrl.local.addEventListener(AVRGameControlEvent.SIZE_CHANGED,
            handleSizeChanged, false, 0, true);

        this.handleSizeChanged();
    }

    override protected function removedFromDB () :void
    {
        ClientContext.model.removeEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        ClientContext.gameCtrl.local.removeEventListener(AVRGameControlEvent.SIZE_CHANGED,
            handleSizeChanged);
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
        if (!ClientContext.model.roundInPlay ||
            (!Constants.ALLOW_CHEATS && _numMatchesThisBall >= Constants.MAX_MATCHES_PER_BALL)) {
            return;
        }

        if (!_card.isFilledAt(col, row)) {

            var item :BingoItem = _card.getItemAt(col, row);

            if (null != item && (Constants.ALLOW_CHEATS || item.containsTag(ClientContext.model.curState.ballInPlay))) {
                _card.setFilledAt(col, row);

                gridSquare.gotoAndStop(2);

                _numMatchesThisBall += 1;
            }
        }
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var loc :Point = this.properLocation;

        this.x = loc.x;
        this.y = loc.y;
    }

    protected function get properLocation () :Point
    {
        var screenBounds :Rectangle = ClientContext.getScreenBounds();

        return new Point(
            screenBounds.right + Constants.CARD_SCREEN_EDGE_OFFSET.x,
            screenBounds.top + Constants.CARD_SCREEN_EDGE_OFFSET.y);
    }

    public function createItemView (item :ClientBingoItem) :DisplayObject
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

    protected function handleNewBall (...ignored) :void
    {
        _numMatchesThisBall = 0;
    }

    protected var _cardView :MovieClip;
    protected var _card :BingoCard;
    protected var _numMatchesThisBall :int;

    protected static const TARGET_TEXT_WIDTH :Number = 56;

}

}
