//
// $Id$

package {

import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;

import com.threerings.util.EmbeddedSwfLoader;

import com.whirled.PetControl;

/**
 * Sally is a friendly little girl kept as a pet by monsters.
 */
[SWF(width="350", height="254")]
public class Sally extends Sprite
{
    public function Sally ()
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
        _body = new Body(_ctrl, _media, 350);
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

    [Embed(source="../rsrc/sally.swf", mimeType="application/octet-stream")]
    protected static const MEDIA :Class;
}
}
