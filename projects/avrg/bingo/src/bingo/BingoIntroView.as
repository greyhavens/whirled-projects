package bingo {

import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

public class BingoIntroView extends Sprite
{
    public function BingoIntroView ()
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

        this.addChild(_playButton);
        this.addChild(splashScreen);
    }

    public function get playButton () :SimpleButton
    {
        return _playButton;
    }

    protected var _playButton :SimpleButton;

}

}
