package popcraft.sp.endless {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Bitmap;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import mx.effects.easing.*;

import popcraft.*;
import popcraft.data.*;
import popcraft.ui.*;
import popcraft.util.SpriteUtil;

public class EndlessInterstitialMode extends AppMode
{
    public function EndlessInterstitialMode (multiplierStartLoc :Vector2)
    {
        _multiplierStartLoc = multiplierStartLoc;
        _mapIndex = EndlessGameContext.mapIndex + 1;
    }

    override protected function setup () :void
    {
        super.setup();

        var nextMap :EndlessMapData = EndlessGameContext.level.getMapData(_mapIndex);
        var cycleNumber :int = EndlessGameContext.level.getMapCycleNumber(_mapIndex);

        // create the background, which will fade to black, pause, and fade back out
        var bgSprite :Sprite = SpriteUtil.createSprite();
        var g :Graphics = bgSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();
        var bgObj :SceneObject = new SimpleSceneObject(bgSprite);
        bgObj.alpha = 0;
        bgObj.addTask(new SerialTask(
            new TimedTask(FADE_IN_PAUSE_TIME),
            new AlphaTask(1, FADE_IN_TIME),
            new FunctionTask(function () :void {
                // remove the old game mode, beneath this one, and insert the new one in its
                // place
                AppContext.mainLoop.removeMode(-2);
                AppContext.mainLoop.insertMode(
                    new EndlessGameMode(EndlessGameContext.level, null, false), -1);
            }),
            new TimedTask(FADE_OUT_PAUSE_TIME),
            new AlphaTask(0, FADE_OUT_TIME),
            new FunctionTask(AppContext.mainLoop.popMode)));

        this.addObject(bgObj, _modeSprite);

        // create the title
        var mapName :String = EndlessGameContext.level.getMapNumberedDisplayName(_mapIndex);
        var titleText :TextField = UIBits.createText(mapName, 3, 0, 0xFFFFFF);
        titleText.x = TITLE_LOC.x - (titleText.width * 0.5);
        titleText.y = TITLE_LOC.y;
        bgSprite.addChild(titleText);

        // create the skulls
        if (cycleNumber > 0) {
            var cycleSprite :Sprite = SpriteUtil.createSprite();
            for (var ii :int = 0; ii < cycleNumber; ++ii) {
                var cycleMovie :MovieClip = SwfResource.instantiateMovieClip("splashUi", "cycle");
                cycleMovie.x = cycleSprite.width + (cycleMovie.width * 0.5);
                cycleSprite.addChild(cycleMovie);
            }

            cycleSprite.x = CYCLE_SPRITE_LOC.x - (cycleSprite.width * 0.5);
            cycleSprite.y = CYCLE_SPRITE_LOC.y;
            bgSprite.addChild(cycleSprite);
        }

        // thumbnail
        var mapNumber :int = _mapIndex % EndlessGameContext.level.mapSequence.length;
        var thumbnail :Bitmap =
            ImageResource.instantiateBitmap("endlessThumb" + String(mapNumber + 1));
        thumbnail.x = THUMBNAIL_LOC.x - (thumbnail.width * 0.5);
        thumbnail.y = THUMBNAIL_LOC.y;
        bgSprite.addChild(thumbnail);

        // create the multiplier object, which will move to the center of the screen, pause,
        // and then move to its location in the new level
        _multiplierMovie = SwfResource.instantiateMovieClip("infusions", "infusion_multiplier");
        var multiplierObj :SceneObject = new SimpleSceneObject(_multiplierMovie);
        multiplierObj.x = _multiplierStartLoc.x;
        multiplierObj.y = _multiplierStartLoc.y;
        multiplierObj.visible = false;
        multiplierObj.addTask(new SerialTask(
            new TimedTask(MULTIPLIER_IN_PAUSE_TIME),
            new VisibleTask(true),
            new ParallelTask(
                new AdvancedLocationTask(
                    MULTIPLIER_TITLE_LOC.x,
                    MULTIPLIER_TITLE_LOC.y,
                    MULTIPLIER_IN_MOVE_TIME,
                    mx.effects.easing.Linear.easeNone,
                    mx.effects.easing.Cubic.easeOut),
                new ScaleTask(2, 2, MULTIPLIER_IN_MOVE_TIME)),
            new TimedTask(MULTIPLIER_OUT_PAUSE_TIME),
            new ParallelTask(
                new AdvancedLocationTask(
                    nextMap.multiplierDropLoc.x,
                    nextMap.multiplierDropLoc.y,
                    MULTIPLIER_OUT_TIME,
                    mx.effects.easing.Linear.easeNone,
                    mx.effects.easing.Cubic.easeIn),
                new ScaleTask(1, 1, MULTIPLIER_OUT_TIME))));

        this.addObject(multiplierObj, _modeSprite);

    }

    protected var _mapIndex :int;
    protected var _multiplierStartLoc :Vector2;
    protected var _multiplierMovie :MovieClip;

    protected static const FADE_IN_PAUSE_TIME :Number = 1.5;
    protected static const FADE_IN_TIME :Number = 0.8;
    protected static const FADE_OUT_PAUSE_TIME :Number = 3;
    protected static const FADE_OUT_TIME :Number = 1;

    protected static const MULTIPLIER_IN_PAUSE_TIME :Number = 1.4;
    protected static const MULTIPLIER_IN_MOVE_TIME :Number = 1.9;
    protected static const MULTIPLIER_OUT_PAUSE_TIME :Number = 2;
    protected static const MULTIPLIER_OUT_TIME :Number = 1;

    protected static const MULTIPLIER_TITLE_LOC :Point = new Point(350, 100);
    protected static const CYCLE_SPRITE_LOC :Point = new Point(350, 160);
    protected static const TITLE_LOC :Point = new Point(350, 170);
    protected static const THUMBNAIL_LOC :Point = new Point(350, 250);
}

}
