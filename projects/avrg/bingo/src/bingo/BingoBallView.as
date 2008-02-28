package bingo {
    
import flash.display.Graphics;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class BingoBallView extends Sprite
{
    public function BingoBallView (text :String)
    {
        var g :Graphics = this.graphics;
        
        g.lineStyle(1, 0x000000);
        g.beginFill(0xFFFFFF);
        g.drawCircle(0, 0, RADIUS);
        g.endFill();
        
        var textField :TextField = new TextField();
        textField.autoSize = TextFieldAutoSize.LEFT;
        textField.text = text;
        
        textField.scaleX = 2;
        textField.scaleY = 2;
        
        textField.x = -(textField.width * 0.5);
        textField.y = -(textField.height * 0.5);
        
        this.addChild(textField);
    }
    
    protected static const RADIUS :Number = 50;
}

}