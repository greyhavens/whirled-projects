package bingo.client {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

public class IntroMode extends AppMode
{
    override protected function setup () :void
    {
        _movie = SwfResource.instantiateMovieClip("intro", "Bingo_intro_symbol");

        // center on screen
        var screenBounds :Rectangle = ClientContext.getScreenBounds();
        _movie.x = screenBounds.width * 0.5;
        _movie.y = screenBounds.height * 0.5;

        this.modeSprite.addChild(_movie);

        // wire up the buttons
        var playButton :InteractiveObject = _movie["inst_play_button"];
        registerEventListener(playButton, MouseEvent.CLICK, handlePlayClicked);

        var quitButton :InteractiveObject = _movie["inst_quit_button"];
        registerEventListener(quitButton, MouseEvent.CLICK, handleQuitClicked);

        var helpButton :InteractiveObject = _movie["inst_help_button"];
        registerEventListener(helpButton, MouseEvent.CLICK, handleHelpClicked);
    }

    protected function handlePlayClicked (...ignored) :void
    {
        MainLoop.instance.changeMode(new GameMode());
    }

    protected function handleQuitClicked (...ignored) :void
    {
        ClientContext.quit();
    }

    protected function handleHelpClicked (...ignored) :void
    {
        MainLoop.instance.pushMode(new HelpMode());
    }

    protected var _movie :MovieClip;
}

}
