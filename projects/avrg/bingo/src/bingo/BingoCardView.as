package bingo {
    
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
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
        
        this.addEventListener(MouseEvent.MOUSE_DOWN, handleClick);
    }
    
    public function createItemView (item :BingoItem) :DisplayObject
    {
        var text :TextField = new TextField();
        text.text = (null == item ? "FREE!" : item.name);
        text.textColor = (null == item ? 0xFF0000 : 0x000000);
        text.autoSize = TextFieldAutoSize.LEFT;
        text.selectable = false;
        text.mouseEnabled = false;
        
        var scale :Number = TARGET_TEXT_WIDTH / text.width;
        
        text.scaleX = scale;
        text.scaleY = scale;
        
        text.x = -(text.width * 0.5);
        text.y = -(text.height * 0.5);
        
        var sprite :Sprite = new Sprite();
        sprite.mouseEnabled = false;
        sprite.mouseChildren = false;
        sprite.addChild(text);
        
        return sprite;
    }
    
    protected function handleClick (e :MouseEvent) :void
    {
        var col :int = (e.localX / SQUARE_SIZE);
        var row :int = (e.localY / SQUARE_SIZE);
        
        if (!(col >= 0 && col < _card.width && row >= 0 && row < _card.height)) {
            return;
        }
        
        if (!_card.isFilledAt(col, row)) {
        
            var item :BingoItem = _card.getItemAt(col, row);
            
            if (null != item && (Constants.ALLOW_CHEATS || item.containsTag(BingoMain.model.curState.ballInPlay))) {
                _card.setFilledAt(col, row);
                
                // draw a little stamp
                var stamp :Shape = new Shape();
                var g :Graphics = stamp.graphics;
                
                g.beginFill(0x00FFFF, 0.7);
                g.drawCircle(0, 0, STAMP_RADIUS);
                g.endFill();
                
                // make sure the stamp doesn't extend too far outside the square it's marking
                var x :Number = Math.max(e.localX, (col * SQUARE_SIZE) + STAMP_RADIUS - ALLOWED_STAMP_BLEED);
                x = Math.min(x, ((col + 1) * SQUARE_SIZE) - STAMP_RADIUS + ALLOWED_STAMP_BLEED);
                
                var y :Number = Math.max(e.localY, (row * SQUARE_SIZE) + STAMP_RADIUS - ALLOWED_STAMP_BLEED);
                y = Math.min(y, ((row + 1) * SQUARE_SIZE) - STAMP_RADIUS + ALLOWED_STAMP_BLEED);
                
                stamp.x = x;
                stamp.y = y;
                
                this.addChild(stamp);
                
                BingoMain.controller.updateBingoButton();
            }
        }
       
    }
    
    protected var _card :BingoCard;
    
    protected static const SQUARE_SIZE :Number = 60;
    protected static const TARGET_TEXT_WIDTH :Number = 56;
    protected static const STAMP_RADIUS :Number = 20;
    
    protected static const ALLOWED_STAMP_BLEED :Number = 0;
    
}

}