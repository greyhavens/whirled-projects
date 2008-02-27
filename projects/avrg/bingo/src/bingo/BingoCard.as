package bingo {
    
public class BingoCard
{
    public function BingoCard ()
    {
        _width = Constants.CARD_WIDTH;
        _height = Constants.CARD_HEIGHT;
        
        var size :int = _width * _height;
        
        var freeSpaceIndex :int = this.xyToIndex(Constants.FREE_SPACE.x, Constants.FREE_SPACE.y);
        
        _squares = new Array(size);
        for (var i :int = 0; i < size; ++i) {
            
            var item :BingoItem = (i == freeSpaceIndex ? null : BingoItemManager.instance.getRandomItem());
            
            _squares[i] = new Square(item);
        }
    }
    
    public function getItemAt (x :int, y :int) :BingoItem
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
    }
    
    protected function xyToIndex (x :int, y :int) :int
    {
        if (x < 0 || x >= _width || y < 0 || y >= _height) {
            return -1;
        }
        
        return (y * _width) + x;
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

}

}

import bingo.*;

class Square
{
    public var isFilled :Boolean;
    public var item :BingoItem;
    
    public function Square (item :BingoItem)
    {
        this.item = item;
    }
}