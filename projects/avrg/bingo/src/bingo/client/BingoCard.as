package bingo.client {

import bingo.*;

import com.threerings.util.ArrayUtil;

public class BingoCard
{
    public function BingoCard ()
    {
        _width = Constants.CARD_WIDTH;
        _height = Constants.CARD_HEIGHT;

        var size :int = _width * _height;

        var freeSpaceIndex :int = this.xyToIndex(Constants.FREE_SPACE.x, Constants.FREE_SPACE.y);

        var numItems :int = (_width * _height) + (freeSpaceIndex >= 0 ? -1 : 0);
        var items :Array;

        // generate unique items to fill the card?
        if (Constants.CARD_ITEMS_ARE_UNIQUE && numItems <= ClientBingoItems.ITEMS.length) {
            items = ClientBingoItems.ITEMS.slice();
            ArrayUtil.shuffle(items);

        } else {
            items = new Array(numItems);
            for (var i :int = 0; i < numItems; ++i) {
                items[i] = ClientContext.items.getRandomItem();
            }
        }

        // create the card
        _squares = new Array(size);
        var itemIndex :int = 0;
        for (i = 0; i < size; ++i) {

            var item :ClientBingoItem = (i == freeSpaceIndex ? null : items[itemIndex++]);
            var square :Square = new Square(item);

            if (i == freeSpaceIndex) {
                square.isFilled = true;
            }

            _squares[i] = square;
        }
    }

    public function getItemAt (x :int, y :int) :ClientBingoItem
    {
        return (_squares[this.xyToIndex(x, y)] as Square).item;
    }

    public function isFilledAt (x :int, y :int) :Boolean
    {
        return (_squares[this.xyToIndex(x, y)] as Square).isFilled;
    }

    public function setFilledAt (x :int, y :int) :void
    {
        (_squares[this.xyToIndex(x, y)] as Square).isFilled = true;

        if (!_isComplete) {
            _isComplete = this.checkComplete();
            ClientContext.model.dispatchEvent(new LocalStateChangedEvent(
                LocalStateChangedEvent.CARD_COMPLETED));
        }
    }

    protected function xyToIndex (x :int, y :int) :int
    {
        if (x < 0 || x >= _width || y < 0 || y >= _height) {
            return -1;
        }

        return (y * _width) + x;
    }

    public function get isComplete () :Boolean
    {
        return _isComplete;
    }

    public function get winningConfigurations () :Array
    {
        // if the card is a winner, this returns an Array of Arrays of the items
        // that form the winning configurations (there may be more than one)

        var configs :Array = [];

        var potentialConfig :Array;

        function checkConfig (xFrom :int, xLim :int, xOffset :int, yFrom :int, yLim :int,
            yOffset :int) :void {

            potentialConfig = [];
            var x :int = xFrom;
            var y :int = yFrom;
            while (x != xLim && y != yLim) {
                if (!isFilledAt(x, y)) {
                    potentialConfig = null;
                    break;
                }

                if (x != Constants.FREE_SPACE.x || y != Constants.FREE_SPACE.y) {
                    potentialConfig.push(getItemAt(x, y));
                }

                x += xOffset;
                y += yOffset;
            }

            if (potentialConfig != null) {
                configs.push(potentialConfig);
            }
        }

        // check for completed rows
        for (var y :int = 0; y < _height; ++y) {
            checkConfig(0, _width, 1, y, y + 1, 0);
        }

        // check for completed columns
        for (var x :int = 0; x < _width; ++x) {
            checkConfig(x, x + 1, 0, 0, _height, 1);
        }

        // check for completed diagonals
        if (_width == _height) {
            // top-left to bottom-right
            checkConfig(0, _width, 1, 0, _height, 1);

            // top-right to bottom-left
            checkConfig(_width - 1, -1, -1, 0, _height, 1);
        }

        return configs;
    }

    protected function checkComplete () :Boolean
    {
        return this.winningConfigurations.length > 0;
    }

    public function get width () :int
    {
        return _width;
    }

    public function get height () :int
    {
        return _height;
    }

    protected var _squares :Array;
    protected var _width :int;
    protected var _height :int;
    protected var _isComplete :Boolean;

}

}

import bingo.*;
import bingo.client.ClientBingoItem;

class Square
{
    public var isFilled :Boolean;
    public var item :ClientBingoItem;

    public function Square (item :ClientBingoItem)
    {
        this.item = item;
    }
}
