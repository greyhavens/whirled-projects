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

public class GameFrame extends Sprite
{
    public function GameFrame ()
    {
        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, handleLoaded);
        loader.load(ByteArray(new FRAME()));
    }

    public function frameContent (content :DisplayObject) :void
    {
        if (_content != null) {
            this.removeChild(_content);
        }
        _content = content;
        if (_content != null) {
            if (_clip == null) {
                throw new Error("not ready for content");
            }
            var bounds :Rectangle = _content.getBounds(_content);

            // figure out the content's dimensions relative our own
            var contentRatioX :Number = bounds.width / INSIDE.width;
            var contentRatioY :Number = bounds.height / INSIDE.height;

            // stretch the content at a lockless ratio in the dimension where it fits
            var contentRatio :Number = Math.max(contentRatioX, contentRatioY);
            content.scaleX = content.scaleY = 1 / contentRatio;

            // then adjust the frame's ratio -- one of these will be 1.0, the other one
            // smaller, linearly proportional to the smaller dimension of the content
            _clip.scaleX = contentRatioX / contentRatio;
            _clip.scaleY = contentRatioY / contentRatio;

            this.addChild(_content);
        }
    }

    protected function mediaReady () :void
    {
    }

    protected function handleLoaded (evt :Event) :void
    {
        _clip = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        this.addChild(_clip);

        // shift the clip so the content can go at (0, 0)
        _clip.x = INSIDE.left;
        _clip.y = INSIDE.top;

        // let subclassers know we're done
        mediaReady();
    }

    protected var _clip :MovieClip;
    protected var _content :DisplayObject;

    // relative the frame's coordinate system, where can we place the framed material?
    protected static const INSIDE :Rectangle = new Rectangle(-235, -149, 465, 301);

    [Embed(source="../../../rsrc/minigame_border.swf", mimeType="application/octet-stream")]
    protected static const FRAME :Class;
}
}
