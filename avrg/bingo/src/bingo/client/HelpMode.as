package bingo.client {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

public class HelpMode extends AppMode
{
    override protected function setup () :void
    {
        _screen = SwfResource.instantiateMovieClip(ClientCtx.rsrcs, "help", "help_screen");

        // center the help screen
        var screenBounds :Rectangle = ClientCtx.getScreenBounds();
        _screen.x = (screenBounds.width * 0.5);
        _screen.y = (screenBounds.height * 0.5);

        // wire up buttons
        var exitButton :InteractiveObject = _screen["x_button"];
        registerListener(exitButton, MouseEvent.CLICK, handleExitButtonClick);

        this.modeSprite.addChild(_screen);
    }

    protected function handleExitButtonClick (...ignored) :void
    {
        ClientCtx.mainLoop.popMode();
    }

    protected var _screen :MovieClip;

}

}
