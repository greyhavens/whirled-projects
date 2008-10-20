package popcraft.sp.endless {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
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

        // create the background, which will fade to black
        var bgSprite :Sprite = SpriteUtil.createSprite();
        var g :Graphics = bgSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();
        var bgObj :SceneObject = new SimpleSceneObject(bgSprite);
        bgObj.alpha = 0;
        bgObj.addTask(new SerialTask(
            new AlphaTask(1, FADE_IN_TIME),
            new FunctionTask(transitionOut)));
        this.addObject(bgObj, _modeSprite);

        // create the title
        var titleText :TextField = UIBits.createText(_nextMap.displayName, 3, 0, 0xFFFFFF);
        titleText.x = (Constants.SCREEN_SIZE.x - titleText.width) * 0.5;
        titleText.y = 200;
        bgSprite.addChild(titleText);

        // create the multiplier object, which will move to the center of the screen
        _multiplierMovie = SwfResource.instantiateMovieClip("infusions", "infusion_multiplier");
        var multiplierObj :SceneObject = new SimpleSceneObject(_multiplierMovie);
        multiplierObj.x = _multiplierStartLoc.x;
        multiplierObj.y = _multiplierStartLoc.y;
        multiplierObj.addTask(new AdvancedLocationTask(
            MULTIPLIER_TITLE_LOC.x,
            MULTIPLIER_TITLE_LOC.y,
            MULTIPLIER_ARC_TIME,
            mx.effects.easing.Linear.easeNone,
            mx.effects.easing.Quintic.easeOut));

        this.addObject(multiplierObj, _modeSprite);

    }

    protected function transitionOut () :void
    {
        // pop this mode and the last level mode, push the next level mode, and push the
        // transition-out mode on top of it
        AppContext.mainLoop.unwindToMode(new EndlessGameMode(EndlessGameContext.level, null, false));
        AppContext.mainLoop.pushMode(new EndlessLevelTransitionOutMode(_nextMap, _multiplierMovie));
    }

    protected var _nextMap :EndlessMapData;
    protected var _multiplierStartLoc :Vector2;
    protected var _multiplierMovie :MovieClip;
}

}

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.MovieClip;
import flash.geom.Point;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.text.TextField;

import popcraft.*;
import popcraft.sp.endless.*;
import com.threerings.flash.Vector2;
import mx.effects.easing.Quintic;
import popcraft.ui.UIBits;
import popcraft.data.EndlessMapData;
import popcraft.util.SpriteUtil;

const FADE_IN_TIME :Number = 2;
const TITLE_TIME :Number = 2;
const FADE_OUT_TIME :Number = 2;
const MULTIPLIER_ARC_TIME :Number = 1;
const MULTIPLIER_TITLE_LOC :Point = new Point(350, 100);

class EndlessLevelTransitionOutMode extends AppMode
{
    public function EndlessLevelTransitionOutMode (nextMap :EndlessMapData, multiplierMovie :MovieClip)
    {
        _nextMap = nextMap;
        _multiplierMovie = multiplierMovie;
    }

    override protected function setup () :void
    {
        super.setup();

        // create the background, which will fade from black
        var bgSprite :Sprite = SpriteUtil.createSprite();
        var g :Graphics = bgSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();
        var bgObj :SceneObject = new SimpleSceneObject(bgSprite);
        bgObj.alpha = 1;
        bgObj.addTask(new SerialTask(
            new TimedTask(TITLE_TIME),
            new AlphaTask(0, FADE_OUT_TIME),
            new FunctionTask(AppContext.mainLoop.popMode)));
        this.addObject(bgObj, _modeSprite);

        // create the title
        var titleText :TextField = UIBits.createText(_nextMap.displayName, 3, 0, 0xFFFFFF);
        titleText.x = (Constants.SCREEN_SIZE.x - titleText.width) * 0.5;
        titleText.y = 200;
        bgSprite.addChild(titleText);

        // create the multiplier object and move it to where it will be in the next level
        var multiplierObj :SceneObject = new SimpleSceneObject(_multiplierMovie);
        multiplierObj.x = MULTIPLIER_TITLE_LOC.x;
        multiplierObj.y = MULTIPLIER_TITLE_LOC.y;
        multiplierObj.addTask(new SerialTask(
            new TimedTask(TITLE_TIME),
            new AdvancedLocationTask(
                _nextMap.multiplierDropLoc.x,
                _nextMap.multiplierDropLoc.y,
                MULTIPLIER_ARC_TIME,
                mx.effects.easing.Linear.easeNone,
                mx.effects.easing.Quintic.easeIn)));

        this.addObject(multiplierObj, _modeSprite);

    }

    protected var _nextMap :EndlessMapData;
    protected var _multiplierMovie :MovieClip;
}
