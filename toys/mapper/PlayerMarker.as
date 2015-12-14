package {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.filters.DropShadowFilter;

import com.yahoo.maps.api.markers.Marker; 

import com.threerings.util.Command;


/**
 * This is pretty much all snarfed from
 * http://www.flexer.info/2008/08/14/how-to-add-a-custom-marker-on-yahoo-maps/
 */
public class PlayerMarker extends Marker
{
    public var memberId :int;

    public function PlayerMarker (memberId :int, name :String)
    {
        this.memberId = memberId;
        var format :TextFormat = new TextFormat();
        format.size = 11;
        format.color = 0x7bbee3;
        format.bold = true;
        format.font = "Arial";

        // add title object
        var text :TextField = new TextField();
        text.width = 1;
        text.height = 1;
        text.autoSize = TextFieldAutoSize.CENTER;
        text.text = name;
        text.setTextFormat(format);
        text.selectable = false;
			
        var radius:Number = 8;
        var padding:Number = 1;

        // setting position based on the above calculations
        text.x += padding/2;
        text.y = -text.height - padding - 7;
        
        // draw custom marker shape
        var bubble :Sprite = createBubble(text.width, text.height, padding, radius);
        bubble.addChild(text);

        addChild(bubble);

        Command.bind(this, MouseEvent.CLICK, navigateToURL, new URLRequest("/#people-" + memberId));
        Command.bind(this, MouseEvent.MOUSE_MOVE, promoteToTop);
    }

    private function createBubble(w:uint = 20, 
            h:uint = 20, padding:uint = 1, radius:uint = 4):Sprite
    {
        var tmpSprite:Sprite = new Sprite();
        // shape coords
        var tipShape:Array;
        tipShape = [
            [0, 0], 
            [7, -7], 
            [w / 2, -7], 
            [w / 2 + radius + padding, -7, 
                    w / 2 + radius + padding, -7 - radius], 
            [w / 2 + radius + padding, -h], 
            [w / 2 + padding + radius, 
                    -radius-h, w / 2, -radius-h], 
            [-w / 2 - padding , -radius-h], 
            [-w / 2 -padding -radius, -radius-h, 
                    -w / 2 -padding -radius, -h],
            [-w/2 -padding -radius, -7-radius],
            [-w / 2 - padding -radius, -7, -w /2 - padding, -7], 
            [-7, -7], 
            [0,0]];
        // setting line style
        tmpSprite.graphics.lineStyle(2,0xFFFFFF);
        // setting fill
        tmpSprite.graphics.beginFill(0x26333b,0.6);
        // drawing the shape
        var len:uint = tipShape.length;
        for (var i:int = 0; i < len; i++) 
        {
            if (i == 0) 
            {
                    // if is the first entry we move to that point
                    tmpSprite.graphics.moveTo(tipShape[i][0], tipShape[i][1]);
            }
            else if (tipShape[i].length == 2) 
            {
                    // if there are 2 coords for this entry we draw a line
                    tmpSprite.graphics.lineTo(tipShape[i][0], tipShape[i][1]);
            }
            else if (tipShape[i].length == 4) 
            {
                    // if there are 4 coords we draw a curve
                    tmpSprite.graphics.curveTo(tipShape[i][0], 
                            tipShape[i][1], tipShape[i][2], tipShape[i][3]);
            }
        }
        tmpSprite.graphics.endFill();
        // setting drop shadow filter 
        tmpSprite.filters = [ new DropShadowFilter(3, 45, 0x000000, .7, 2, 2, 1, 3) ];
        
        tmpSprite.useHandCursor = false;
        
        return tmpSprite;
    }
}

}
