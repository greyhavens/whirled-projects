package {

import flash.display.Sprite;
import flash.text.*;
import flash.net.*;
import flash.events.MouseEvent;

import com.threerings.util.Command;

public class Label extends Sprite
{
    public function Label (text :String, link :String = null)
    {
        var tf :TextField = new TextField();
        tf.htmlText = text;
        tf.autoSize = TextFieldAutoSize.LEFT;

        if (link) {
            tf.mouseEnabled = false;
            this.buttonMode = true;
            Command.bind(this, MouseEvent.CLICK, navigateToURL, new URLRequest(link));
        }

        addChild(tf);
    }
}

}
