package popcraft.sp {

import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextFormatAlign;

import popcraft.*;
import popcraft.ui.UIBits;

public class EpilogueMode extends TransitionMode
{
    override protected function setup () :void
    {
        var bg :Shape = new Shape();
        var g :Graphics = bg.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();
        _modeLayer.addChild(bg);

        // if the player clicks on the screen, they can advance things faster, but only
        // after a little bit of time has elapsed
        this.addObject(new SimpleTimer(IGNORE_CLICK_TIME, null, false, IGNORE_CLICK_TIMER_NAME));
        this.modeSprite.addEventListener(MouseEvent.CLICK, onScreenClicked);

        // skip button, to skip the entire epilogue sequence
        _skipButton = UIBits.createButton("OK", 1.2);
        _skipButton.x = Constants.SCREEN_SIZE.x - _skipButton.width - 15;
        _skipButton.y = Constants.SCREEN_SIZE.y - _skipButton.height - 15;
        _skipButton.addEventListener(MouseEvent.CLICK, onSkipClicked);

        _modeLayer.addChild(_skipButton);

        this.startEpilogue();
    }

    protected function onSkipClicked (...ignored) :void
    {
        this.endEpilogue();
    }

    protected function onScreenClicked (...ignored) :void
    {
        // when the screen is clicked, advance to the next character
        if (null == this.getObjectNamed(IGNORE_CLICK_TIMER_NAME)) {
            if (_verseIndex < VERSE_LOCS.length) {
                this.showNextVerse();
            }
        }
    }

    protected function startEpilogue () :void
    {
        this.showNextVerse();
    }

    protected function endEpilogue () :void
    {
        _epilogueEnding = true;
        _skipButton.parent.removeChild(_skipButton);

        if (null != _verseObj) {
            _verseObj.removeAllTasks();
        }

        this.fadeOutToMode(new LevelSelectMode());
    }

    protected function showNextVerse () :void
    {
        if (null != _verseObj) {
            _verseObj.removeAllTasks();
            _verseObj.alpha = 1;
        }

        // create the new verse
        var thisVerseIndex :int = _verseIndex++;
        var verse :String = AppContext.introOutroData.outroVerses[thisVerseIndex];
        var verseSprite :Sprite = UIBits.createTextPanel(
            verse, 1.3, 0, false, TextFormatAlign.LEFT, 0xFFFFFF);

        var sprite :Sprite = new Sprite();
        verseSprite.x = -verseSprite.width * 0.5;
        sprite.addChild(verseSprite);

        var loc :Point = VERSE_LOCS[thisVerseIndex];
        _verseObj = new SimpleSceneObject(sprite);
        _verseObj.x = loc.x;
        _verseObj.y = loc.y;
        _verseObj.alpha = 0;
        this.addObject(_verseObj, _modeLayer);

        // fade in the new character portrait
        var verseTask :SerialTask = new SerialTask();
        verseTask.addTask(new AlphaTask(1, CHAR_FADE_TIME));
        verseTask.addTask(new TimedTask(CHAR_TIME));
        if (_verseIndex < VERSE_LOCS.length) {
            verseTask.addTask(new FunctionTask(showNextVerse));
        }

        _verseObj.addTask(verseTask);
    }

    protected var _verseObj :SceneObject;
    protected var _verseIndex :int;
    protected var _epilogueEnding :Boolean;
    protected var _skipButton :SimpleButton;

    protected static const CHAR_FADE_TIME :Number = 1;
    protected static const CHAR_TIME :Number = 7;

    protected static const IGNORE_CLICK_TIME :Number = 1.5;
    protected static const IGNORE_CLICK_TIMER_NAME :String = "IgnoreClick";

    protected static const VERSE_LOCS :Array = [
        new Point(130, 230), new Point(340, 230), new Point(550, 230) ];

}

}
