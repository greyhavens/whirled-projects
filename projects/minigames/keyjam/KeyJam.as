package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.KeyboardEvent;

import flash.text.TextField;

import flash.ui.Keyboard;

import flash.utils.getTimer;

import com.threerings.flash.ClearingTextField;

import com.whirled.MiniGameControl;

[SWF(width="450", height="100")]
public class KeyJam extends Sprite
{
    public function KeyJam (millisPerBeat :Number = 500)
    {
        _gameCtrl = new MiniGameControl(this);

        var bkg :DisplayObject = new BOOMBOX() as DisplayObject;
        addChild(bkg);

        // Question: why does Sprite claim to generate key events when
        // I have never seen it capable of doing so? Flash blows.
        var keyGrabber :TextField = new TextField();
        keyGrabber.selectable = false;
        keyGrabber.width = 450;
        keyGrabber.height = 100;
        addChild(keyGrabber);

        _label = new ClearingTextField();
        _label.background = true;
        _label.selectable = false;
        _label.width = 450;
        _label.setText("Welcome to KeyJam", 5);
        _label.height = _label.textHeight + 4; // flash blows: really
        _label.y = 100 - _label.height;
        addChild(_label);

        _timingBar = new TimingBar(200, 20, 2000);
        _timingBar.x = 127;
        _timingBar.y = 80;
        addChild(_timingBar);

        keyGrabber.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);

        setNewSequence();

        addEventListener(Event.ADDED_TO_STAGE, handleAddRemove);
        addEventListener(Event.REMOVED_FROM_STAGE, handleAddRemove);
    }

    protected function handleAddRemove (event :Event) :void
    {
        if (event.type == Event.ADDED_TO_STAGE) {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        } else {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        }
    }

    protected function setNewSequence () :void
    {
        var keySprite :KeySprite;

        // clear any existing keys
        for each (keySprite in _keySprites) {
            removeChild(keySprite);
        }
        _keySprites.length = 0; // truncate

        // generate a new sequence
        var seq :Array = generateKeySequence(
            Math.min(MAX_SEQUENCE_LENGTH, _level + 3));

        var startX :int = (450 - (KeySprite.WIDTH * seq.length)) / 2;

        for (var ii :int = 0; ii < seq.length; ii++) {
            var key :int = int(seq[ii]);
            keySprite = new KeySprite(key, classForKey(key));
            keySprite.setMode((ii == 0) ? MODE_NEXT : MODE_CLEAR);
            _keySprites.push(keySprite);
            keySprite.y = 5;
            keySprite.x = startX + ii * (KeySprite.WIDTH);
            addChild(keySprite);
        }
        _seqIndex = 0;

        // grab the timestamp
        _seqStartStamp = getTimer();
    }

    protected function classForKey (key :int) :Class
    {
        switch (key) {
        default:
        case Keyboard.UP:
            return UP_ARROW;

        case Keyboard.DOWN:
            return DOWN_ARROW;

        case Keyboard.LEFT:
            return LEFT_ARROW;

        case Keyboard.RIGHT:
            return RIGHT_ARROW;
        }
    }


    protected function handleKeyDown (event :KeyboardEvent) :void
    {
        var code :int = event.keyCode;
        if (_seqIndex < _keySprites.length) {
            // see if the key pressed is the correct next one in the sequence
            var keySprite :KeySprite = (_keySprites[_seqIndex] as KeySprite);
            if (keySprite.getKey() == code) {
                // yay
                keySprite.setMode(MODE_HIT);
                _seqIndex++;
                if (_keySprites.length > _seqIndex) {
                    keySprite = (_keySprites[_seqIndex] as KeySprite);
                    keySprite.setMode(MODE_NEXT);
                }

            } else {
                // uh-ok, they booched it!
                resetSequenceProgress();
            }

        } else {
            if (code == Keyboard.SPACE) {
                // the sequence was generated!
                finishLevel();

            } else {
                // total booch!
                resetSequenceProgress();
            }
        }

        // macrodobe can chew my sack for not making this the default
        event.updateAfterEvent(); // flash blows
    }

    protected function resetSequenceProgress () :void
    {
        var keySprite :KeySprite;
        while (_seqIndex >= 0) {
            if (_seqIndex < _keySprites.length) {
                keySprite = (_keySprites[_seqIndex] as KeySprite);
                keySprite.setMode((_seqIndex == 0) ? MODE_NEXT : MODE_CLEAR);
            }
            _seqIndex--;
        }
        _seqIndex = 0;

        _booches++;
        _label.setText("Oh, ye booched it!", 5);
    }

    /**
     * Generate a new key sequence.
     */
    protected function generateKeySequence (length :int = 3) :Array
    {
        var seq :Array = [];
        while (length-- > 0) {
            seq.push(ARROW_KEYS[int(Math.random() * ARROW_KEYS.length)]);
        }
        return seq;
    }

    /**
     * The user hit the space bar after duping the sequence, let's
     * see how they did.
     */
    protected function finishLevel () :void
    {
        var results :Array = _timingBar.checkNeedle();
        var result :Number = results[0];
        var wraps :int  = results[1];
        var time :Number = getTimer() - _seqStartStamp;
        trace("Result: " + result + ", time: " + time + ", wraps: " + wraps +
            ", booches: " + _booches);
        // TODO: come up with some sort of rating based on these completely uninteresting metrics

        var score :Number;
        if (wraps < SCORE_SCALING.length) {
            score = result * SCORE_SCALING[wraps];

        } else {
            score = 0;
        }

        // some crappy feedback..
        var feedback :String;
        if (result == 1) {
            feedback = "PERFECT!";

        } else if (result >= .98) {
            feedback = "Outstanding!";

        } else if (result >= .95) {
            feedback = "Great!";

        } else if (result >= .9) {
            feedback = "Good";

        } else if (result >= .8) {
            feedback = "Nice";

        } else if (result >= .5) {
            feedback = "okay";

        } else if (result >= .1) {
            feedback = "poor";

        } else {
            feedback = "piss-poor";
        }

//        // Figure out the score to report to whirled...
//        // From the time it took the user, subtract half a second and
//        // bound into the 0 - 2sec range
//        var normalizedTime :Number = Math.min(MAX_EXPECTED_TIME, Math.max(0, time - MIN_EXPECTED_TIME));
//        var timeScore :Number = (MAX_EXPECTED_TIME - normalizedTime) / MAX_EXPECTED_TIME;
//        var accScore :Number = result / (_booches + 1);
//        var score :Number = timeScore * accScore;

        _gameCtrl.reportPerformance(score);

        // issue feedback, fade out the timer
        _label.setText(feedback, 5);

        // move to the next level
        _booches = 0;
        _level++;
        setNewSequence();
    }

    /** The control for reporting performance back to whirled. */
    protected var _gameCtrl :MiniGameControl;

    protected var _keySprites :Array = [];

    /** The position in the sequence we're waiting for. */
    protected var _seqIndex :int = 0;

    /** The time at which the current sequence was started. */
    protected var _seqStartStamp :Number;

    /** Which level is the user on? */
    protected var _level :int = 0;

    /** The number of booches on the current level. */
    protected var _booches :int = 0;

    /** A label where we give encouragement and ridicule to yon user. */
    protected var _label :ClearingTextField;

    /** The timing bar. */
    protected var _timingBar :TimingBar;

    protected static const PAD :int = 10;

    protected static const ARROW_KEYS :Array = [
        Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT ];

    protected static const MAX_SEQUENCE_LENGTH :int = 7;

    protected static const MODE_CLEAR :int = 1;
    protected static const MODE_NEXT :int = 2;
    protected static const MODE_HIT :int = 3;

    protected static const MAX_EXPECTED_TIME :int = 6000;
    protected static const MIN_EXPECTED_TIME :int = 500;

    protected static const SCORE_SCALING :Array = [
        1, .9, .8, .7, .55, .40, .25, .10 ];

    [Embed(source="resources.swf#boombox")]
    protected static const BOOMBOX :Class;

    [Embed(source="resources.swf#up")]
    protected static const UP_ARROW :Class;

    [Embed(source="resources.swf#down")]
    protected static const DOWN_ARROW :Class;

    [Embed(source="resources.swf#left")]
    protected static const LEFT_ARROW :Class;

    [Embed(source="resources.swf#right")]
    protected static const RIGHT_ARROW :Class;
}
}
