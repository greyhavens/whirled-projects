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
        _movie = SwfResource.instantiateMovieClip(ClientCtx.rsrcs, "intro", "Bingo_intro_symbol");

        // center on screen
        var screenBounds :Rectangle = ClientCtx.getScreenBounds();
        _movie.x = screenBounds.width * 0.5;
        _movie.y = screenBounds.height * 0.5;

        this.modeSprite.addChild(_movie);

        // wire up the buttons
        var playButton :InteractiveObject = _movie["inst_play_button"];
        registerListener(playButton, MouseEvent.CLICK, handlePlayClicked);

        var quitButton :InteractiveObject = _movie["inst_quit_button"];
        registerListener(quitButton, MouseEvent.CLICK, handleQuitClicked);

        var helpButton :InteractiveObject = _movie["inst_help_button"];
        registerListener(helpButton, MouseEvent.CLICK, handleHelpClicked);
    }

    protected function handlePlayClicked (...ignored) :void
    {
        ClientCtx.mainLoop.changeMode(new GameMode());
    }

    protected function handleQuitClicked (...ignored) :void
    {
        ClientCtx.quit();
    }

    protected function handleHelpClicked (...ignored) :void
    {
        ClientCtx.mainLoop.pushMode(new HelpMode());
    }

    protected var _movie :MovieClip;
}

}
