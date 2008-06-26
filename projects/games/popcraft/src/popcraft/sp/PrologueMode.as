package popcraft.sp {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextFormatAlign;

import popcraft.*;
import popcraft.ui.UIBits;

public class PrologueMode extends AppMode
{
    override protected function setup () :void
    {
        var darknessShape :Sprite = new Sprite();
        var g :Graphics = darknessShape.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        _prologueObj = new SimpleSceneObject(darknessShape);
        this.addObject(_prologueObj, this.modeSprite);

        // if the player clicks on the screen, they can advance things faster, but only
        // after a little bit of time has elapsed
        this.addObject(new SimpleTimer(IGNORE_CLICK_TIME, null, false, IGNORE_CLICK_TIMER_NAME));
        this.modeSprite.addEventListener(MouseEvent.CLICK, onScreenClicked);

        // skip button, to skip the entire prologue sequence
        _skipButton = UIBits.createButton("Skip", 1.2);
        _skipButton.x = Constants.SCREEN_SIZE.x - _skipButton.width - 15;
        _skipButton.y = Constants.SCREEN_SIZE.y - _skipButton.height - 15;
        _skipButton.addEventListener(MouseEvent.CLICK, onSkipClicked);

        this.modeSprite.addChild(_skipButton);

        this.startPrologue();
    }

    protected function onSkipClicked (...ignored) :void
    {
        this.endPrologue();
    }

    protected function onScreenClicked (...ignored) :void
    {
        // when the screen is clicked, advance to the next character
        if (null == this.getObjectNamed(IGNORE_CLICK_TIMER_NAME)) {
            if (_charIndex < CHAR__LIMIT) {
                this.showNextChar();
            } else if (!_prologueEnding) {
                this.endPrologue();
            }
        }
    }

    protected function startPrologue () :void
    {
        // show the class photo
        var photo :MovieClip = SwfResource.instantiateMovieClip("classphoto", "photo");
        photo.cacheAsBitmap = true;
        photo.x = 15;
        photo.y = (Constants.SCREEN_SIZE.y * 0.5) - (photo.height * 0.5);
        DisplayObjectContainer(_prologueObj.displayObject).addChild(photo);

        this.showNextChar();
    }

    protected function endPrologue () :void
    {
        _prologueEnding = true;

        _skipButton.parent.removeChild(_skipButton);

        if (null != _charObj) {
            _charObj.destroySelf();
        }

        // fade out and pop mode
        _prologueObj.removeAllTasks();
        _prologueObj.addTask(new SerialTask(
            new AlphaTask(0, SCREEN_FADE_TIME),
            new FunctionTask(function () :void { AppContext.mainLoop.unwindToMode(new LevelSelectMode()); })));
    }

    protected function showNextChar () :void
    {
        if (null != _charObj) {
            _charObj.removeAllTasks();

            // fade out the old character portrait
            _charObj.addTask(new SerialTask(
                new AlphaTask(0, CHAR_FADE_TIME),
                new SelfDestructTask()));
        }

        // create the new character portrait
        var thisCharIndex :int = _charIndex++;
        var portrait :DisplayObject = ImageResource.instantiateBitmap(PORTRAIT_NAMES[thisCharIndex]);
        var introVerse :String = AppContext.introOutroData.introVerses[thisCharIndex];
        var verseSprite :Sprite = UIBits.createTextPanel(
            introVerse, 1.1, 0, false, TextFormatAlign.LEFT, 0xFFFFFF);

        var sprite :Sprite = new Sprite();
        if (null != portrait) {
            portrait.x = -portrait.width * 0.5;
            sprite.addChild(portrait);
        }
        verseSprite.x = -verseSprite.width * 0.5;
        verseSprite.y = sprite.height + 5;
        sprite.addChild(verseSprite);

        _charObj = new SimpleSceneObject(sprite);
        _charObj.x = 650;
        _charObj.y = 100;
        _charObj.alpha = 0;
        this.addObject(_charObj, _prologueObj.displayObject as DisplayObjectContainer);

        // fade in the new character portrait
        var charTask :SerialTask = new SerialTask();
        charTask.addTask(new AlphaTask(1, CHAR_FADE_TIME));
        charTask.addTask(new TimedTask(CHAR_TIME));
        if (_charIndex < CHAR__LIMIT) {
            charTask.addTask(new FunctionTask(showNextChar));
        } else {
            charTask.addTask(new FunctionTask(endPrologue));
        }

        _charObj.addTask(charTask);
    }

    protected var _prologueObj :SceneObject;
    protected var _charObj :SceneObject;
    protected var _charIndex :int;
    protected var _prologueEnding :Boolean;
    protected var _skipButton :SimpleButton;

    protected static const SCREEN_FADE_TIME :Number = 1.5;
    protected static const CHAR_FADE_TIME :Number = 1;
    protected static const CHAR_TIME :Number = 7;

    protected static const IGNORE_CLICK_TIME :Number = SCREEN_FADE_TIME + 0.25;
    protected static const IGNORE_CLICK_TIMER_NAME :String = "IgnoreClick";

    protected static const CHAR_WEARDD :int = 0;
    protected static const CHAR_JACK :int = 1;
    protected static const CHAR_RALPH :int = 2;
    protected static const CHAR__LIMIT :int = 3;

    protected static const PORTRAIT_NAMES :Array = [ "portrait_weardd", "portrait_jack", "portrait_ralph" ];
}

}
