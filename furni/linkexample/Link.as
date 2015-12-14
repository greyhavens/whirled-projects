//
//

package {

import flash.display.Sprite;

import flash.events.MouseEvent;
import flash.events.TextEvent;

import flash.net.URLRequest;

import flash.text.TextField;

import com.whirled.FurniControl;

[SWF(width="50", height="50")]
public class Link extends Sprite
{
    public function Link ()
    {
        _ctrl = new FurniControl(this);

        // something to click on
        var s :Sprite = new Sprite();
        s.graphics.beginFill(0xFF0000);
        s.graphics.drawCircle(25, 25, 25);
        s.graphics.endFill();
        addChild(s);
        s.addEventListener(MouseEvent.CLICK, handleClick);
    }

    protected function handleClick (event :MouseEvent) :void
    {
        var tf :TextField = new TextField();
        tf.htmlText = "Hello there, it's a <a href=\"event:http://google.com/\">link</a>.";
        tf.width = 500;
        tf.height = 20;
        tf.addEventListener(TextEvent.LINK, handleLink);

        _ctrl.showPopup("It's a popup", tf, 500, 20);
    }

    protected function handleLink (event :TextEvent) :void
    {
        flash.net.navigateToURL(new URLRequest(event.text));
    }

    protected var _ctrl :FurniControl;
}
}
