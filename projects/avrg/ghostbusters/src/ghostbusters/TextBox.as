//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;

import mx.controls.Button;
import mx.events.FlexEvent;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Log;

[SWF(width="700", height="500")]
public class TextBox extends Sprite
{
    public function TextBox ()
    {
    }

    [Embed(source="../../rsrc/text_box.swf#textbox_appear")]
    protected static const TEXT_BOX_APPEAR :Class;
    [Embed(source="../../rsrc/text_box.swf#textbox")]
    protected static const TEXT_BOX :Class;
    [Embed(source="../../rsrc/text_box.swf#textbox_disappear")]
    protected static const TEXT_BOX_DISAPPEAR :Class;
}
}
