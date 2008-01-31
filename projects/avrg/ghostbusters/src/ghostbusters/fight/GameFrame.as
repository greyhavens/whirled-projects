//
// $Id$

package ghostbusters.fight {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.utils.ByteArray;

import flash.events.Event;

import flash.geom.Rectangle;

import com.threerings.util.EmbeddedSwfLoader;

import ghostbusters.ClipHandler;
import ghostbusters.Content;
import ghostbusters.Game;

public class GameFrame extends ClipHandler
{
    public function GameFrame ()
    {
        super(ByteArray(new Content.FRAME()), handleLoaded);
    }

    public function frameContent (content :DisplayObject) :void
    {
        if (_content != null) {
            this.removeChild(_content);
        }
        _content = content;
        if (_content != null) {
            this.addChild(_content);
            _content.x = INSIDE.left;
            _content.y = INSIDE.right;
        }
    }

    protected function mediaReady () :void
    {
    }

    protected function handleLoaded (clip :MovieClip) :void
    {
        // let subclassers know we're done
        mediaReady();
    }

    protected var _clipHolder :Sprite;
    protected var _content :DisplayObject;

    // relative the frame's coordinate system, where can we place the framed material?
    protected static const INSIDE :Rectangle = new Rectangle(22, 102, 305, 300);
}
}
