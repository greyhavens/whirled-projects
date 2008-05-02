// $Id$

package {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;

import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;

import flash.geom.Point;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import com.threerings.util.Log;

import com.whirled.game.GameControl;

import com.whirled.contrib.EventHandlers;

public class ScoreBoard extends Sprite 
{
    // these are used as indexes into GameControl.seating.getPlayerIds()
    public static const MOON_PLAYER :int = 0;
    public static const SUN_PLAYER :int = 1;

    public function ScoreBoard (wgc :GameControl, gameEndedCallback :Function) 
    {
        addChild(_marbleLayer = new Sprite());
        var trough :Sprite = new TROUGH_OVERLAY() as Sprite;
        trough.x = -trough.width / 2;
        trough.y = 170;
        addChild(trough);
        _gameEndedCallback = gameEndedCallback;

        _leftFrame = new PLAYER_FRAME() as Sprite;
        _leftFrame.x = -241;
        _leftFrame.y = -233;
        _leftFrame.scaleX = -1; // invert horizontally
        addChild(_leftFrame);
        _rightFrame = new PLAYER_FRAME() as Sprite;
        _rightFrame.x = 242;
        _rightFrame.y = -233;
        addChild(_rightFrame);

        var playerIds :Array = wgc.game.seating.getPlayerIds();
        var playerNames :Array = wgc.game.seating.getPlayerNames();
        addHeadshot(MOON_PLAYER, wgc.local.getHeadShot(playerIds[MOON_PLAYER]));
        addLabel(MOON_PLAYER, playerNames[MOON_PLAYER]);
        if (playerIds.length > 1) {
            addHeadshot(SUN_PLAYER, wgc.local.getHeadShot(playerIds[SUN_PLAYER]));
            addLabel(SUN_PLAYER, playerNames[SUN_PLAYER]);
        }

        addChild(_coinsLayer = new Sprite());
    }

    public function get moonScore () :int
    {
        return _moonScore;
    }

    public function get sunScore () :int
    {
        return _sunScore;
    }

    public function reinit () :void
    {
        _moonScore = 0;
        _sunScore = 0;
        if (_victory != null) {
            removeChild(_victory);
            _victory = null;
        }
        removeChild(_marbleLayer);
        addChildAt(_marbleLayer = new Sprite(), 0);
        removeChild(_coinsLayer);
        addChild(_coinsLayer = new Sprite());
        _gameEnded = false;
    }

    public function scorePoint (player :int) :void
    {
        if (player == MOON_PLAYER) {
            scorePointAnimation(player, ++_moonScore);
            if (_moonScore == Locksmith.WIN_SCORE) {
                gameOver();
            }
        } else if (player == SUN_PLAYER) {
            scorePointAnimation(player, ++_sunScore);
            if (_sunScore == Locksmith.WIN_SCORE) {
                gameOver();
            }
        } else {
            log.debug("Asked to score point for unknown player [" + player + "]");
        }
    }

    public function displayVictory (player :int) :void
    {
        if (player != MOON_PLAYER && player != SUN_PLAYER) {
            log.debug("asked to display victory for unknown player [" + player + "]");
            return;
        }

        addChild(_victory = new ScoreBoard["WINNER_" + (player == MOON_PLAYER ? "MOON" : "SUN")]()
            as MovieClip);
        EventHandlers.registerEventListener(_victory, Event.ENTER_FRAME, 
            function (event :Event) :void {
                var targetMovie :MovieClip = event.target as MovieClip;
                if (_victory == null || targetMovie.currentFrame == targetMovie.totalFrames) {
                    targetMovie.stop();
                    EventHandlers.unregisterEventListener(
                        targetMovie, Event.ENTER_FRAME, arguments.callee);
                }
            });
        _victory.scaleX = _victory.scaleY = 0.33;
    }

    public function displayCoins (player :int, coins :int, digits :int) :void
    {
        var coinsDisplay :CoinsDisplay = new CoinsDisplay(coins, digits);
        if (player == MOON_PLAYER) {
            coinsDisplay.x = -316 + (5 - digits) * 13;
        } else if (player == SUN_PLAYER) {
            coinsDisplay.x = 265;
        } else {
            log.debug("asked to display coins for unknown player [" + player + "]");
            return;
        }
        coinsDisplay.y = -109;
        _coinsLayer.addChild(coinsDisplay);
    }

    protected function addHeadshot (player :int, headshot :DisplayObject) :void 
    {
        var headshotSprite :Sprite = new Sprite();
        var frame :Sprite = player == MOON_PLAYER ? _leftFrame : _rightFrame;
        headshot.x = frame.x + 7;
        if (headshot.x < 0) {
            headshot.x -= frame.width;
        }
        headshot.y = frame.y + 5;
        var scale :Number;
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0);
        if (headshot.width < headshot.height) {
            scale = 60 / headshot.width;
            var diff :Number = ((headshot.height - headshot.width) * scale) / 2;
            headshot.y -= diff;
            masker.graphics.drawRect(0, diff, 60 / scale, 60 / scale);
        } else {
            scale = 60 / headshot.height;
            diff = ((headshot.width - headshot.height) * scale) / 2;
            headshot.x -= diff;
            masker.graphics.drawRect(diff, 0, 60 / scale, 60 / scale);
        }
        headshot.scaleX = headshot.scaleY = scale;
        masker.graphics.endFill();
        headshotSprite.addChild(headshot);
        headshotSprite.addChild(masker);
        headshotSprite.mask = masker;
        addChildAt(headshotSprite, getChildIndex(frame));
    }

    protected function addLabel (player :int, name :String) :void
    {
        var frame :Sprite = player == MOON_PLAYER ? _leftFrame : _rightFrame;
        var format :TextFormat = new TextFormat();
        format.font = "Palatino Linotype";
        format.bold = true;
        format.color = 0x503A0B;
        format.leading = -3;
        format.size = 11;
        format.align = TextFormatAlign.CENTER
        var textField :TextField = new TextField();
        textField.y = frame.y + 78;
        textField.x = frame.x + 8;
        if (textField.x < 0) {
            textField.x -= frame.width;
        }
        textField.width = 57;
        textField.wordWrap = true;
        textField.defaultTextFormat = format;
        textField.selectable = false;
        textField.text = name;
        textField.filters = 
            [new GlowFilter(0xFFFFFF, 1, 2, 2, 3, BitmapFilterQuality.HIGH)];
        addChildAt(textField, getChildIndex(frame));
        while (textField.numLines > 2) {
            textField.text = textField.text.substring(0, textField.text.length - 4) + "...";
        }
        if (textField.numLines == 1) {
            textField.y += textField.textHeight / 2;
        }
    }

    protected function gameOver () :void
    {
        if (_gameEnded || _gameEndedCallback == null) {
            return;
        }

        _gameEndedCallback();
        _gameEnded = true;
    }

    protected function scorePointAnimation (player :int, point :int) :void
    {
        if (player == MOON_PLAYER) {
            var marble :MarbleMovie = new MarbleMovie(Marble.MOON);
            marble.x = MOON_RAMP_BEGIN.x + 22;
            marble.y = MOON_RAMP_BEGIN.y - 10;
            marble.rotation = 90;
            marble.gotoAndPlay((Math.random() * marble.totalFrames) + 1);
            _marbleLayer.addChild(marble);
            new RampAnimation(marble, MOON_RAMP_BEGIN.clone(), MOON_RAMP_END.clone(), point);
        } else {
            marble = new MarbleMovie(Marble.SUN);
            marble.x = SUN_RAMP_BEGIN.x - 22;
            marble.y = SUN_RAMP_BEGIN.y - 10;
            marble.rotation = -90;
            marble.gotoAndPlay((Math.random() * marble.totalFrames) + 1);
            _marbleLayer.addChild(marble);
            new RampAnimation(marble, SUN_RAMP_BEGIN.clone(), SUN_RAMP_END.clone(), point);
        }
    }

    private static const log :Log = Log.getLog(ScoreBoard);

    [Embed(source="../rsrc/locksmith_art.swf#trough_overlay")]
    protected static const TROUGH_OVERLAY :Class;
    [Embed(source="../rsrc/locksmith_art.swf#player_frame")]
    protected static const PLAYER_FRAME :Class;
    [Embed(source="../rsrc/locksmith_art.swf#winner_resolve_moon")]
    protected static const WINNER_MOON :Class;
    [Embed(source="../rsrc/locksmith_art.swf#winner_resolve_sun")]
    protected static const WINNER_SUN :Class;

    protected static const SUN_RAMP_BEGIN :Point = new Point(256, 38);
    protected static const SUN_RAMP_END :Point = new Point(313, 199);
    protected static const MOON_RAMP_BEGIN :Point = new Point(-257, 38);
    protected static const MOON_RAMP_END :Point = new Point(-312, 199);

    protected var _moonScore :int = 0;
    protected var _sunScore :int = 0;
    protected var _gameEndedCallback :Function;
    protected var _gameEnded :Boolean = false;
    protected var _marbleLayer :Sprite = new Sprite();
    protected var _coinsLayer :Sprite = new Sprite();

    protected var _leftFrame :Sprite;
    protected var _rightFrame :Sprite;
    protected var _victory :MovieClip;
}
}

import flash.display.BlendMode;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;

import flash.geom.Matrix;
import flash.geom.Point;

import com.threerings.util.Log;

import com.whirled.contrib.EventHandlers;

import MarbleMovie;

class RampAnimation
{
    public function RampAnimation (marble :MarbleMovie, rampTop :Point, rampBottom :Point, 
        myScore :int)
    {
        _marble = marble;
        _startX = _marble.x;
        _startY = _marble.y;
        _rampTop = rampTop;
        _rampBottom = rampBottom;
        _phase = PHASE_DELAY;
        _myScore = myScore;

        // replace the marble on the marble's parent with a layer that only shows the ramp top hole
        // via masking so that the marble seems to roll into place at the hole.
        var mask :Sprite = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawCircle(rampTop.x, rampTop.y + 2, MARBLE_RADIUS * 0.9);
        mask.graphics.drawRect(rampTop.x - MARBLE_RADIUS * 0.9, rampTop.y, MARBLE_RADIUS * 1.8,
                                    MARBLE_RADIUS * 2);
        mask.graphics.endFill();
        var marbleLayer :Sprite = new Sprite();
        marbleLayer.mask = mask;
        marbleLayer.addChild(mask);
        var parent :DisplayObjectContainer = _marble.parent;
        parent.removeChild(_marble);
        marbleLayer.addChild(_marble);
        parent.addChildAt(marbleLayer, 0);
        _darkness = new Sprite();
        _darkness.graphics.beginFill(0, 0.01);
        _darkness.graphics.drawCircle(0, 0, MARBLE_RADIUS * 1.5);
        _darkness.graphics.endFill();
        _darkness.blendMode = BlendMode.ALPHA;
        _marble.addChild(_darkness);

        EventHandlers.registerEventListener(_marble, Event.ENTER_FRAME, enterFrame);
    }

    protected function enterFrame (evt :Event) :void
    {
        switch(_phase) {
        case PHASE_DELAY: delayTick(); break;
        case PHASE_MOVE_TO_RAMP: moveTowardsRamp(); break;
        case PHASE_MOVE_DOWN_RAMP: moveDownRamp(); break;
        default:
            log.debug("Unknown phase [" + _phase + "]");
            EventHandlers.unregisterEventListener(_marble, Event.ENTER_FRAME, enterFrame);
        }
    }

    protected function delayTick () :void
    {
        if (++_phaseTime >= DELAY_TIME) {
            _phase = PHASE_MOVE_TO_RAMP;
            _phaseTime = 0;
        }
    }

    protected function moveTowardsRamp () :void
    {
        if (++_phaseTime < FADE_IN_TIME) {
            _marble.x = (_phaseTime / FADE_IN_TIME) * (_rampTop.x - _startX) + _startX;
            _marble.y = (_phaseTime / FADE_IN_TIME) * (_rampTop.y - _startY) + _startY;
            _darkness.graphics.clear();
            _darkness.graphics.beginFill(0, _phaseTime / FADE_IN_TIME);
            _darkness.graphics.drawCircle(0, 0, MARBLE_RADIUS * 1.5);
            _darkness.graphics.endFill();
        } else {
            _marble.removeChild(_darkness);
            _marble.x = _rampTop.x;
            _marble.y = _rampTop.y;
            _phase = PHASE_MOVE_DOWN_RAMP;
            _phaseTime = 0;
            var parent :DisplayObjectContainer = _marble.parent.parent;
            parent.removeChild(_marble.parent);
            _marble.parent.removeChild(_marble);
            parent.addChildAt(_marble, 0);
        }
    }

    protected function moveDownRamp () :void
    {
        var percent :Number = ++_phaseTime / ROLL_DOWN_TIME;
        percent = Math.pow(percent, 2);
        if (percent >= (1 - (_myScore - 1) / Locksmith.WIN_SCORE)) {
            EventHandlers.unregisterEventListener(_marble, Event.ENTER_FRAME, enterFrame);
            _marble.stop();
            percent = 1 - (_myScore - 1) / Locksmith.WIN_SCORE;
        } 
        var factorX :Number = Math.pow(percent, 1.8);
        _marble.x = factorX * (_rampBottom.x - _rampTop.x) + _rampTop.x;
        var factorY :Number = 1 - Math.pow(1 - percent, 1.5);
        _marble.y = factorY * (_rampBottom.y - _rampTop.y) + _rampTop.y;
        _marble.scaleX = _marble.scaleY = ((factorX + factorY) / 2) * (FINAL_SCALE - 1) + 1;
    }

    protected static const PHASE_DELAY :int = 1;
    protected static const PHASE_MOVE_TO_RAMP :int = 2;
    protected static const PHASE_MOVE_DOWN_RAMP :int = 3;

    protected static const DELAY_TIME :int = 10; // in frames;
    protected static const FADE_IN_TIME :int = 15; // in frames;
    protected static const ROLL_DOWN_TIME :int = 15; // in frames;

    protected static const FINAL_SCALE :Number = 1.3;

    protected static const MARBLE_RADIUS :Number = 20;

    protected var _marble :MarbleMovie;
    protected var _rampTop :Point;
    protected var _rampBottom :Point;
    protected var _phase :int;
    protected var _darkness :Sprite;
    protected var _phaseTime :int = 0;
    protected var _startX :int;
    protected var _startY :int;
    protected var _myScore :int;

    private static const log :Log = Log.getLog(RampAnimation);
}

class CoinsDisplay extends Sprite
{
    public function CoinsDisplay (coins :int, digits :int) 
    {
        log.debug("displaying coins [" + coins + ", " + digits + "]");
        for (var ii :int = 0; ii < digits; ii++) {
            if (coins == 0 && ii != 0) {
                _digits.unshift(-1);
            } else {
                _digits.unshift(coins - Math.floor(coins / 10) * 10);
                coins = Math.floor(coins / 10);
            }
        }
        if (coins > 0) {
            log.debug("not giving enough digits to display coins value [" + coins + "]");
        }

        EventHandlers.registerEventListener(this, Event.ENTER_FRAME, enterFrame);
    }

    protected function enterFrame (event :Event) :void
    {
        var digitSprite :CoinsDigit = new CoinsDigit(_digits.shift());
        digitSprite.x = width;
        addChild(digitSprite);

        if (_digits.length == 0) {
            EventHandlers.unregisterEventListener(this, Event.ENTER_FRAME, enterFrame);
        }
    }

    private static const log :Log = Log.getLog(CoinsDisplay);

    protected var _digits :Array = [];
}

class CoinsDigit extends Sprite
{
    public function CoinsDigit (digit :int) 
    {
        if (digit > 9 || digit < -1) {
            log.debug("digit is invalid [" + digit + "]");
            return;
        }

        _digitNum = digit;
        addChild(_digit = new FLOW_DIGIT() as MovieClip);
        EventHandlers.registerEventListener(_digit, Event.ENTER_FRAME, enterFrame);
    }

    protected function enterFrame (event :Event) :void
    {
        if (_digit.currentFrame == 3) {
            if (_digitNum == -1) {
                _digit["flow_digit"]["digit"].text = "";
            } else {
                _digit["flow_digit"]["digit"].text = _digitNum;
            }
        }

        if (_digit.currentFrame == _digit.totalFrames) {
            _digit.stop();
            EventHandlers.unregisterEventListener(_digit, Event.ENTER_FRAME, enterFrame);
        }
    }

    private static const log :Log = Log.getLog(CoinsDigit);

    [Embed(source="../rsrc/locksmith_art.swf#digit")]
    protected const FLOW_DIGIT :Class;

    protected var _digit :MovieClip; 
    protected var _digitNum :int;
}
