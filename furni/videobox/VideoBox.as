//
// $Id$

package {

import flash.display.Loader;
import flash.display.Sprite;

import flash.text.TextField;
import flash.text.TextFieldType;

import flash.events.Event;
import flash.events.KeyboardEvent;

import flash.ui.Keyboard;

[SWF(width="450", height="420")]
public class VideoBox extends Sprite
{
    public function VideoBox ()
    {
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _tagField = new TextField();
        _tagField.type = TextFieldType.INPUT;
        addChild(_tagField);
        _tagField.addEventListener(KeyboardEvent.KEY_DOWN, handleKey);

        _loader = new Loader();
        _loader.y = 50;
        addChild(_loader);
    }

    protected function handleVideosByTag (evt :YouTubeServiceEvent) :void
    {
        trace("Got data: " + evt.data);
    }

    protected function handleKey (event :KeyboardEvent) :void
    {
        if (event.keyCode == Keyboard.ENTER) {
            var tag :String = _tagField.text;
            _youtube.videos.listByTag(tag);
        }
    }

    /**
     * Take care of releasing resources when we unload.
     */
    protected function handleUnload (event :Event) :void
    {
    }

    protected var _tagField :TextField;

    protected var _youtube :YouTubeService;
}
}
