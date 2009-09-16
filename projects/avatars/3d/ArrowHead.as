//
// $Id$

package {

import flash.events.Event;

import flash.display.DisplayObject;
import flash.display.Sprite;

import com.threerings.util.Util;

public class ArrowHead extends Arrow
{
    public function ArrowHead ()
    {
        super();

        addEventListener(Event.ENTER_FRAME, Util.adapt(rotateHead));

        var head :DisplayObject = new HEAD_IMAGE();

        _head = new Sprite();
        head.scaleX = .5;
        head.scaleY = .5;
        head.x = -head.width/2;
        _head.addChild(head);

        _head.x = 200;
        _head.y = 50;
        addChild(_head);
    }

    protected function rotateHead () :void
    {
        _head.rotationY += 1;
    }

    protected var _head :Sprite;

    [Embed(source="300_excorcist.jpg")]
    protected static const HEAD_IMAGE :Class;
}
}
