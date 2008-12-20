package flashmob.client {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import flashmob.*;
import flashmob.client.view.*;
import flashmob.data.*;

public class SpectaclePlayerMode extends GameDataMode
{
    override protected function setup () :void
    {
        _spectacle = ClientContext.spectacle;

        _tf = new TextField();
        _modeSprite.addChild(_tf);

        if (ClientContext.isPartyLeader) {
            _startButton = UIBits.createButton("Start!", 1.2);
            registerListener(_startButton, MouseEvent.CLICK, onStartClicked);

            _modeSprite.addChild(_startButton);
        }

        if (ClientContext.isPartyLeader) {
            setText("Drag the spectacle to its starting location, then press start!");
            _patternView = new PatternView(_spectacle.patterns[0], onSpectacleDragged);

            _spectacleOffsetThrottler = new MessageThrottler(Constants.MSG_SET_SPECTACLE_OFFSET);
            addObject(_spectacleOffsetThrottler);

        } else {
            _patternView = new PatternView(_spectacle.patterns[0]);
            setText("Waiting for the party leader to start the spectacle!");
        }

        addObject(_patternView, _modeSprite);

        // init data bindings
        _dataBindings.bindMessage(Constants.MSG_PLAYNEXTPATTERN, handleNextPattern);
        _dataBindings.bindMessage(Constants.MSG_PLAYSUCCESS, handleSuccess);
        _dataBindings.bindProp(Constants.PROP_SPECTACLE_OFFSET, handleNewSpectacleOffset,
            PatternLoc.fromBytes);
        _dataBindings.processAllProperties(ClientContext.props);
    }

    protected function onSpectacleDragged (newX :Number, newY :Number) :void
    {
        var roomLoc :Point =
            ClientContext.gameCtrl.local.paintableToRoom(new Point(newX, newY));

        _patternView.x = newX;
        _patternView.y = newY;
        _spectacleOffsetThrottler.value = (new PatternLoc(roomLoc.x, roomLoc.y).toBytes());
    }

    protected function handleNewSpectacleOffset (newOffset :PatternLoc) :void
    {
        _spectacleOffset = newOffset;

        if (!ClientContext.isPartyLeader) {
            updatePatternViewLoc(true);
        }
    }

    protected function updatePatternViewLoc (animate :Boolean = false) :void
    {
        var screenLoc :Point = ClientContext.gameCtrl.local.roomToPaintable(
                new Point(_spectacleOffset.x, _spectacleOffset.y));

        _patternView.removeAllTasks();
        if (animate) {
            _patternView.addTask(LocationTask.CreateSmooth(screenLoc.x, screenLoc.y, 0.5));

        } else {
            _patternView.x = screenLoc.x;
            _patternView.y = screenLoc.y;
        }
    }

    protected function checkPlayerPositions () :Boolean
    {
        var pattern :Pattern = this.curPattern;
        if (pattern == null) {
            return false;
        }

        var patternLocs :Array = pattern.locs.map(
            function (loc :PatternLoc, ...ignored) :Vector2 {
                return new Vector2(loc.x + _spectacleOffset.x, loc.y + _spectacleOffset.y);
            });

        var playerLocs :Array = ClientContext.playerIds.map(
            function (playerId :int, ...ignored) :Vector2 {
                return Vector2.fromPoint(ClientContext.getPlayerRoomLoc(playerId));
            });

        var epsilonSqr :Number = Constants.PATTERN_LOC_EPSILON * Constants.PATTERN_LOC_EPSILON;
        for each (var playerLoc :Vector2 in playerLocs) {
            var closestLoc :Vector2;
            var closestDistSqr :Number = Number.MAX_VALUE;
            for each (var patternLoc :Vector2 in patternLocs) {
                var distSqr :Number = patternLoc.subtract(playerLoc).lengthSquared;
                if (distSqr < closestDistSqr || closestLoc == null) {
                    closestDistSqr = distSqr;
                    closestLoc = patternLoc;
                }
            }

            if (closestDistSqr > epsilonSqr) {
                /*log.info("Not in position",
                    "closestDist", Math.sqrt(closestDistSqr),
                    "e", Constants.PATTERN_LOC_EPSILON);*/
                return false;
            }

            ArrayUtil.removeFirst(patternLocs, closestLoc);
        }

        return true;
    }

    protected function removePatternView () :void
    {
        if (_patternView != null) {
            _patternView.destroySelf();
            _patternView = null;
        }
    }

    protected function handleNextPattern () :void
    {
        log.info(_startButton ? "next pattern" : "first pattern");

        if (!_startedPlaying) {
            if (_spectacleOffsetThrottler != null) {
                _spectacleOffsetThrottler.destroySelf();
                _spectacleOffsetThrottler = null;
            }

            _startedPlaying = true;
        }

        ++_patternIndex;
        _patternRecognized = false;

        removePatternView();
        _patternView = new PatternView(this.curPattern);
        addObject(_patternView, _modeSprite);
        updatePatternViewLoc();

        setText(_patternIndex == 0 ?
            "The game will start when everyone is in the correct position!" :
            "Assemble into the next position!");

        if (_patternIndex > 0) {
            if (_timer == null) {
                _timer = new TimerView();
                _timer.x = 300;
                _timer.y = 20;
                addObject(_timer, _modeSprite);
            }

            _timer.time = this.curPattern.timeLimit;
        }
    }

    protected function handleSuccess () :void
    {
        log.info("Success!");
        setText("Success!");
        _completed = true;

        if (_timer != null) {
            _timer.destroySelf();
            _timer = null;
        }
    }

    protected function onStartClicked (...ignored) :void
    {
        if (_spectacleOffsetThrottler != null) {
            _spectacleOffsetThrottler.forcePendingMessage();
            _spectacleOffsetThrottler.destroySelf();
            _spectacleOffsetThrottler = null;
        }

        ClientContext.sendAgentMsg(Constants.MSG_STARTPLAYING);
        _startButton.visible = false;
    }

    protected function updateButtons () :void
    {
    }

    protected function setText (text :String) :void
    {
        UIBits.initTextField(_tf, text, 1.2, WIDTH - 10, 0xFFFFFF, TextFormatAlign.LEFT);

        if (_bg != null) {
            _bg.parent.removeChild(_bg);
        }

        _bg = new Shape();
        _modeSprite.addChildAt(_bg, 0);

        var height :Number = _tf.height + 10 + (_startButton != null ? _startButton.height : 0);
        var g :Graphics = _bg.graphics;
        g.clear();
        g.beginFill(0);
        g.drawRect(0, 0, WIDTH, Math.max(height, MIN_HEIGHT));
        g.endFill();

        _tf.x = (_bg.width - _tf.width) * 0.5;
        _tf.y = (_bg.height - _tf.height) * 0.5;

        if (_startButton != null) {
            _startButton.x = _bg.width - _startButton.width - 10;
            _startButton.y = _bg.height - _startButton.height - 10;
        }
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        if (_startedPlaying && !_completed && !_patternRecognized && ClientContext.isPartyLeader) {
            if (checkPlayerPositions()) {
                // Tell the server we were successful
                log.info("patternRecognized");
                _patternRecognized = true;
                ClientContext.outMsg.sendMessage(Constants.MSG_PATTERNCOMPLETE);
            }
        }
    }

    protected function get curPattern () :Pattern
    {
        return (_patternIndex >= 0 && _patternIndex < _spectacle.numPatterns ?
            _spectacle.patterns[_patternIndex] : null);
    }

    protected static function get log () :Log
    {
        return FlashMobClient.log;
    }

    protected var _spectacle :Spectacle;
    protected var _startButton :SimpleButton;
    protected var _tf :TextField;
    protected var _bg :Shape;

    protected var _patternIndex :int = -1;
    protected var _patternRecognized :Boolean;
    protected var _startedPlaying :Boolean;
    protected var _completed :Boolean;
    protected var _patternView :SceneObject;
    protected var _spectacleOffset :PatternLoc;
    protected var _spectacleOffsetThrottler :MessageThrottler;
    protected var _timer :TimerView;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}

import com.whirled.contrib.simplegame.SimObject;
import flashmob.client.ClientContext;

// Throttles an individual type of message
class MessageThrottler extends SimObject
{
    public function MessageThrottler (msgName :String, minUpdateTime :Number = 1)
    {
        _msgName = msgName;
        _minUpdateTime = minUpdateTime;
    }

    public function set value (newValue :*) :void
    {
        _value = newValue;
        _messagePending = true;
        if (_timeTillNextMessage <= 0) {
            sendMessage();
        }
    }

    public function forcePendingMessage () :void
    {
        if (_messagePending) {
            sendMessage();
        }
    }

    protected function sendMessage () :void
    {
        ClientContext.outMsg.sendMessage(_msgName, _value);
        _messagePending = false;
        _timeTillNextMessage = _minUpdateTime;
    }

    override protected function update (dt :Number) :void
    {
        _timeTillNextMessage = Math.max(0, _timeTillNextMessage - dt);
        if (_messagePending && _timeTillNextMessage <= 0) {
            sendMessage();
        }
    }

    protected var _msgName :String;
    protected var _minUpdateTime :Number;

    protected var _value :*;
    protected var _messagePending :Boolean;

    protected var _timeTillNextMessage :Number = 0;
}
