package bingo {
    
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

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
        
        g.lineStyle(1, 0x000000);
        
        g.beginFill(0xFFFFFF);
        g.drawRect(0, 0, width, height);
        g.endFill();
        
        for (var col :int = 1; col < cols; ++col) {
            g.moveTo(col * SQUARE_SIZE, 0);
            g.lineTo(col * SQUARE_SIZE, height);
        }
        
        for (var row :int = 1; row < rows; ++row) {
            g.moveTo(0, row * SQUARE_SIZE);
            g.lineTo(width, row * SQUARE_SIZE);
        }
        
        // draw the items
        
        for (row = 0; row < rows; ++row) {
            
            for (col = 0; col < cols; ++col) {
                
                var itemView :DisplayObject = this.createItemView(_card.getItemAt(col, row));
                itemView.x = (col + 0.5) * SQUARE_SIZE;
                itemView.y = (row + 0.5) * SQUARE_SIZE;
                
                this.addChild(itemView);
            }
        }
    }
    
    public function createItemView (item :BingoItem) :DisplayObject
    {
        var text :TextField = new TextField();
        text.text = (null == item ? "**FREE**" : item.name);
        text.autoSize = TextFieldAutoSize.LEFT;
        text.selectable = false;
        
        text.scaleX = 1;
        text.scaleY = 1;
        
        text.x = -(text.width * 0.5);
        text.y = -(text.height * 0.5);
        
        var sprite :Sprite = new Sprite();
        sprite.addChild(text);
        
        return sprite;
    }
    
    protected var _card :BingoCard;
    
    protected static const SQUARE_SIZE :Number = 60;
    
}

}