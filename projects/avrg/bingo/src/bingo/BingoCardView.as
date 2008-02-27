package bingo {
    
import flash.display.Graphics;
import flash.display.Sprite;

public class BingoCardView extends Sprite
{
    public function BingoCardView (card :BingoCard)
    {
        _card = card;
        
        var cols :int = card.width;
        var rows :int = card.height;
        
        var width :Number = cols * SQUARE_SIZE;
        var height :Number = rows * SQUARE_SIZE;
        
        // draw a grid
        
        var g :Graphics = this.graphics;
        g.beginFill(0xFFFFFF);
        g.drawRect(0, 0, width, height);
        g.endFill();
        
        g.lineStyle(1, 0x000000);
        
        for (var col :int = 1; col < cols; ++col) {
            g.moveTo(col * SQUARE_SIZE, 0);
            g.lineTo(col * SQUARE_SIZE, height);
        }
        
        for (var row :int = 1; row < rows; ++row) {
            g.moveTo(0, row * SQUARE_SIZE);
            g.lineTo(width, row * SQUARE_SIZE);
        }
    }
    
    protected var _card :BingoCard;
    
    protected static const SQUARE_SIZE :Number = 60;
    
}

}