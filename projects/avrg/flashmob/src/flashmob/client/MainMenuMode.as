package flashmob.client {

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;

import flashmob.client.view.Dragger;

public class MainMenuMode extends GameDataMode
{
    override protected function setup () :void
    {
        super.setup();

        // create the main UI and make it draggable
        _ui = SwfResource.instantiateMovieClip("Spectacle_UI", "mainUI");
        _modeSprite.addChild(_ui);
        addObject(new Dragger(_ui));

        _ui.scaleX = _ui.scaleY = 0.7;
        DisplayUtil.positionBounds(_ui, 0, -50);

        _ui.gotoAndStop(60);

        // wire up
        var creatorModeButton :SimpleButton = _ui["makeyourown"];
        /*registerOneShotCallback(creatorModeButton, MouseEvent.CLICK,
            function (...ignored) :void {
                log.info("Make Your Own!");
            });*/
    }

    protected function get log () :Log
    {
        return FlashMobClient.log;
    }

    protected var _ui :MovieClip;
}

}
