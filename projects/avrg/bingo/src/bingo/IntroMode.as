package bingo {

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
        var swf :SwfResourceLoader = BingoMain.resources.getResource("intro") as SwfResourceLoader;
        var introClass :Class = swf.getClass("Bingo_intro_symbol");
        _movie = new introClass();

        // center on screen
        var screenBounds :Rectangle = BingoMain.getScreenBounds();
        _movie.x = screenBounds.width * 0.5;
        _movie.y = screenBounds.height * 0.5;

        this.modeSprite.addChild(_movie);

        // wire up the buttons
        var playButton :InteractiveObject = _movie["inst_play_button"];
        playButton.addEventListener(MouseEvent.CLICK, handlePlayClicked);

        var quitButton :InteractiveObject = _movie["inst_quit_button"];
        quitButton.addEventListener(MouseEvent.CLICK, handleQuitClicked);

        var helpButton :InteractiveObject = _movie["inst_help_button"];
        helpButton.addEventListener(MouseEvent.CLICK, handleHelpClicked);
    }

    override protected function destroy () :void
    {
        // unwire the buttons
        var playButton :InteractiveObject = _movie["inst_play_button"];
        playButton.removeEventListener(MouseEvent.CLICK, handlePlayClicked);

        var quitButton :InteractiveObject = _movie["inst_quit_button"];
        quitButton.removeEventListener(MouseEvent.CLICK, handleQuitClicked);

        var helpButton :InteractiveObject = _movie["inst_help_button"];
        helpButton.removeEventListener(MouseEvent.CLICK, handleHelpClicked);
    }

    protected function handlePlayClicked (...ignored) :void
    {
        MainLoop.instance.changeMode(new GameMode());
    }

    protected function handleQuitClicked (...ignored) :void
    {
        BingoMain.quit();
    }

    protected function handleHelpClicked (...ignored) :void
    {
    }

    protected var _movie :MovieClip;
}

}
