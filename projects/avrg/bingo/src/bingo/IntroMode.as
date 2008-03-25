package bingo {

import com.whirled.contrib.simplegame.*;

import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class IntroMode extends AppMode
{
    override protected function setup () :void
    {
        var splashScreen :Bitmap = new Resources.IMG_SPLASHSCREEN();

        // center the splash screen
        var centerPt :Point = new Point();

        if (BingoMain.control.isConnected()) {
            var stageSize :Rectangle = BingoMain.control.getStageSize(true);
            centerPt.x = stageSize.x + (stageSize.width * 0.5);
            centerPt.y = stageSize.y + (stageSize.height * 0.5);
        } else {
            centerPt.x = 350;
            centerPt.y = 250;
        }

        splashScreen.x = centerPt.x - (splashScreen.width * 0.5);
        splashScreen.y = centerPt.y - (splashScreen.height * 0.5) - 50;

        _playButton = new SimpleButton(
            new Resources.IMG_PLAYENABLED(),
            new Resources.IMG_PLAYOVER(),
            new Resources.IMG_PLAYDOWN(),
            new Resources.IMG_PLAYENABLED());

        // position the play button below the splash screen
        _playButton.x = centerPt.x - (_playButton.width * 0.5);
        _playButton.y = splashScreen.y + 250;

        _playButton.addEventListener(MouseEvent.CLICK, handlePlayClicked, false, 0, true);

        this.modeSprite.addChild(_playButton);
        this.modeSprite.addChild(splashScreen);
    }

    override protected function destroy () :void
    {
        _playButton.removeEventListener(MouseEvent.CLICK, handlePlayClicked);
    }

    protected function handlePlayClicked (...ignored) :void
    {
        MainLoop.instance.changeMode(new GameMode());
    }

    protected var _playButton :SimpleButton;
}

}
