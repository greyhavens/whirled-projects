package popcraft.sp.endless {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

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

public class EndlessLevelTransitionMode extends AppMode
{
    public function EndlessLevelTransitionMode (multiplierStartLoc :Vector2)
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
            new AlphaTask(1, FADE_IN_TIME),
            new FunctionTask(function () :void {
                // remove the old game mode, beneath this one, and insert the new one in its
                // place
                AppContext.mainLoop.removeMode(-2);
                AppContext.mainLoop.insertMode(
                    new EndlessGameMode(EndlessGameContext.level, null, false), -1);
            }),
            new TimedTask(TITLE_TIME),
            new AlphaTask(0, FADE_OUT_TIME),
            new FunctionTask(AppContext.mainLoop.popMode)));

        this.addObject(bgObj, _modeSprite);

        // create the title
        var mapName :String = EndlessGameContext.level.getMapNumberedDisplayName(_mapIndex);
        var titleText :TextField = UIBits.createText(mapName, 3, 0, 0xFFFFFF);
        titleText.x = (Constants.SCREEN_SIZE.x - titleText.width) * 0.5;
        titleText.y = 200;
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

        // create the multiplier object, which will move to the center of the screen, pause,
        // and then move to its location in the new level
        _multiplierMovie = SwfResource.instantiateMovieClip("infusions", "infusion_multiplier");
        var multiplierObj :SceneObject = new SimpleSceneObject(_multiplierMovie);
        multiplierObj.x = _multiplierStartLoc.x;
        multiplierObj.y = _multiplierStartLoc.y;
        multiplierObj.addTask(new SerialTask(
            new AdvancedLocationTask(
                MULTIPLIER_TITLE_LOC.x,
                MULTIPLIER_TITLE_LOC.y,
                FADE_IN_TIME,
                mx.effects.easing.Cubic.easeInOut,
                mx.effects.easing.Cubic.easeOut),
            new TimedTask(TITLE_TIME),
            new AdvancedLocationTask(
                nextMap.multiplierDropLoc.x,
                nextMap.multiplierDropLoc.y,
                FADE_OUT_TIME,
                mx.effects.easing.Cubic.easeInOut,
                mx.effects.easing.Cubic.easeIn)));

        this.addObject(multiplierObj, _modeSprite);

    }

    protected var _mapIndex :int;
    protected var _multiplierStartLoc :Vector2;
    protected var _multiplierMovie :MovieClip;

    protected static const FADE_IN_TIME :Number = GameMode.FADE_OUT_TIME;
    protected static const FADE_OUT_TIME :Number = 1;
    protected static const TITLE_TIME :Number = 2;
    protected static const MULTIPLIER_TITLE_LOC :Point = new Point(350, 100);
    protected static const CYCLE_SPRITE_LOC :Point = new Point(350, 190);
}

}
