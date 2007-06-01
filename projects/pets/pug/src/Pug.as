//
// $Id$

package {

import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;

import com.threerings.util.EmbeddedSwfLoader;

import com.whirled.PetControl;

/**
 * Pug is a wee dog.
 */
[SWF(width="350", height="254")]
public class Pug extends Sprite
{
    public function Pug ()
    {
        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, function (event :Event) :void {
            loadedMovie(loader.getContent() as MovieClip);
        });
        loader.load(new MEDIA());

        addEventListener(Event.UNLOAD, handleUnload);
    }

    protected function loadedMovie (media :MovieClip) :void
    {
        addChild(_media = media);

        _ctrl = new PetControl(this);
        _body = new Body(_ctrl, _media);
        _brain = new Brain(_ctrl, _body);
    }

    protected function handleUnload (... ignored) :void
    {
        _brain.shutdown();
        _body.shutdown();
    }

    protected var _ctrl :PetControl;
    protected var _media :MovieClip;
    protected var _body :Body;
    protected var _brain :Brain;

    [Embed(source="../rsrc/pug.swf", mimeType="application/octet-stream")]
    protected static const MEDIA :Class;
}
}
