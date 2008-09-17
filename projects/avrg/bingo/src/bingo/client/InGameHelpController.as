package bingo.client {

import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.events.MouseEvent;

public class InGameHelpController extends SceneObject
{
    public function InGameHelpController ()
    {
        _screen = SwfResource.instantiateMovieClip("help", "help_screen");

        // center the help screen
        var screenBounds :Rectangle = ClientContext.getScreenBounds();
        _screen.x = (screenBounds.width * 0.5);
        _screen.y = (screenBounds.height * 0.5);

        // wire up buttons
        var exitButton :InteractiveObject = _screen["x_button"];
        exitButton.addEventListener(MouseEvent.CLICK, handleExitButtonClick);
    }

    override public function get displayObject () :DisplayObject
    {
        return _screen;
    }

    protected function handleExitButtonClick (...ignored) :void
    {
        var gameMode :GameMode = (this.db as GameMode);

        gameMode.hideHelpScreen();
    }

    protected var _screen :MovieClip;

}

}
