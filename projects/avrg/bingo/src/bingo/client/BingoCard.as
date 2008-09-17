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

    protected function checkComplete () :Boolean
    {
        // check for completed rows
        for (var y :int = 0; y < _height; ++y) {
            for (var x :int = 0; x < _width; ++x) {
                if (!this.isFilledAt(x, y)) {
                    break;
                } else if (x == _width - 1) {
                    return true;
                }
            }
        }

        // check for completed columns
        for (x = 0; x < _width; ++x) {
            for (y = 0; y < _height; ++y) {
                if (!this.isFilledAt(x, y)) {
                    break;
                } else if (y == _height - 1) {
                    return true;
                }
            }
        }

        // check for completed diagonals
        if (_width == _height) {

            // top-left to bottom-right
            for (x = 0, y = 0; x < _width; ++x, ++y) {
                if (!this.isFilledAt(x, y)) {
                    break;
                } else if (x == _width - 1) {
                    return true;
                }
            }

            // top-right to bottom-left
            for (x = _width - 1, y = 0; x >= 0; --x, ++y) {
                if (!this.isFilledAt(x, y)) {
                    break;
                } else if (x == 0) {
                    return true;
                }
            }

        }

        return false;
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
