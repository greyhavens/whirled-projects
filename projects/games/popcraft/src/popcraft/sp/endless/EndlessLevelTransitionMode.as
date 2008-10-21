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
        _nextMap = EndlessGameContext.level.getMapData(EndlessGameContext.mapIndex + 1);
    }

    override protected function setup () :void
    {
        super.setup();

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
        var titleText :TextField = UIBits.createText(_nextMap.displayName, 3, 0, 0xFFFFFF);
        titleText.x = (Constants.SCREEN_SIZE.x - titleText.width) * 0.5;
        titleText.y = 200;
        bgSprite.addChild(titleText);

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
                MULTIPLIER_ARC_TIME,
                mx.effects.easing.Linear.easeNone,
                mx.effects.easing.Cubic.easeOut),
            new TimedTask(TITLE_TIME),
            new AdvancedLocationTask(
                _nextMap.multiplierDropLoc.x,
                _nextMap.multiplierDropLoc.y,
                MULTIPLIER_ARC_TIME,
                mx.effects.easing.Linear.easeNone,
                mx.effects.easing.Cubic.easeIn)));

        this.addObject(multiplierObj, _modeSprite);

    }

    protected var _nextMap :EndlessMapData;
    protected var _multiplierStartLoc :Vector2;
    protected var _multiplierMovie :MovieClip;

    protected const FADE_IN_TIME :Number = 1;
    protected const TITLE_TIME :Number = 2;
    protected const FADE_OUT_TIME :Number = 1;
    protected const MULTIPLIER_ARC_TIME :Number = 1;
    protected const MULTIPLIER_TITLE_LOC :Point = new Point(350, 100);
}

}
