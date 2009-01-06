package flashmob.client {

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
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
            _spectaclePlacer = new SpectaclePlacer(_spectacle, onSpectacleDragged);

            _spectacleOffsetThrottler = new MessageThrottler(Constants.MSG_CS_SET_SPECTACLE_OFFSET);
            addObject(_spectacleOffsetThrottler);

            // position the SpectaclePlacer in the middle of the screen
            var bounds :Rectangle = ClientContext.gameCtrl.local.getPaintableArea(true);
            DisplayUtil.positionBounds(_spectaclePlacer.displayObject,
                bounds.left + ((bounds.width - _spectaclePlacer.width) * 0.5),
                bounds.top + ((bounds.height - _spectaclePlacer.height) * 0.5));
            onSpectacleDragged(_spectaclePlacer.x, _spectaclePlacer.y);

        } else {
            _spectaclePlacer = new SpectaclePlacer(_spectacle);
            _spectaclePlacer.visible = false; // will become visible on first location update
            setText("Waiting for the party leader to start the spectacle!");
        }

        addObject(_spectaclePlacer, _modeSprite);

        // init data bindings
        _dataBindings.bindMessage(Constants.MSG_S_PLAYNEXTPATTERN, handleNextPattern);
        _dataBindings.bindMessage(Constants.MSG_S_PLAYSUCCESS, handleSuccess);
        _dataBindings.bindMessage(Constants.MSG_S_PLAYFAIL, handleFailure);
        _dataBindings.bindProp(Constants.PROP_SPECTACLE_OFFSET, handleNewSpectacleOffset,
            PatternLoc.fromBytes);
        _dataBindings.processAllProperties(ClientContext.props);

        registerListener(ClientContext.gameCtrl.local, AVRGameControlEvent.SIZE_CHANGED,
            function (...ignored) :void {
                updatePatternViewLoc(false);
            });
    }

    protected function onSpectacleDragged (newX :Number, newY :Number) :void
    {
        var roomLoc :Point =
            ClientContext.gameCtrl.local.paintableToRoom(new Point(newX, newY));

        _spectaclePlacer.x = newX;
        _spectaclePlacer.y = newY;
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

        if (_spectaclePlacer != null) {
            _spectaclePlacer.removeAllTasks();
            if (animate) {
                _spectaclePlacer.addTask(LocationTask.CreateSmooth(screenLoc.x, screenLoc.y, 0.5));

            } else {
                _spectaclePlacer.x = screenLoc.x;
                _spectaclePlacer.y = screenLoc.y;
            }

            _spectaclePlacer.visible = true;
        }

        if (_patternView != null) {
            _patternView.removeAllTasks();
            if (animate) {
                _patternView.addTask(LocationTask.CreateSmooth(screenLoc.x, screenLoc.y, 0.5));

            } else {
                _patternView.x = screenLoc.x;
                _patternView.y = screenLoc.y;
            }

            _patternView.visible = true;
        }
    }

    protected function checkPlayerPositions () :Boolean
    {
        var pattern :Pattern = this.curPattern;
        if (pattern == null) {
            return false;
        }

        var patternLocs :Array = pattern.locs.map(
            function (loc :PatternLoc, index :int, ...ignored) :LocInfo {
                return new LocInfo(
                    new Vector2(loc.x + _spectacleOffset.x, loc.y + _spectacleOffset.y),
                    index);
            });

        var playerLocs :Array = ClientContext.playerIds.map(
            function (playerId :int, ...ignored) :Vector2 {
                return Vector2.fromPoint(ClientContext.getPlayerRoomLoc(playerId));
            });

        var epsilonSqr :Number = Constants.PATTERN_LOC_EPSILON * Constants.PATTERN_LOC_EPSILON;
        var inPositionFlags :Array = ArrayUtil.create(patternLocs.length, false);
        var allInPosition :Boolean = true;
        for each (var playerLoc :Vector2 in playerLocs) {
            var closestLoc :LocInfo;
            var closestDistSqr :Number = Number.MAX_VALUE;

            for each (var patternLoc :LocInfo in patternLocs) {
                var distSqr :Number = patternLoc.loc.subtract(playerLoc).lengthSquared;
                if (distSqr < closestDistSqr || closestLoc == null) {
                    closestDistSqr = distSqr;
                    closestLoc = patternLoc;
                }
            }

            var inPosition :Boolean = (closestDistSqr <= epsilonSqr);
            allInPosition &&= inPosition;
            inPositionFlags[closestLoc.index] = inPosition;

            ArrayUtil.removeFirst(patternLocs, closestLoc);
        }

        if (_patternView != null) {
            _patternView.showInPositionIndicators(inPositionFlags);
        }

        return allInPosition;
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
        log.info(_startedPlaying ? "next pattern" : "first pattern");

        if (!_startedPlaying) {
            if (_spectacleOffsetThrottler != null) {
                _spectacleOffsetThrottler.destroySelf();
                _spectacleOffsetThrottler = null;
            }

            _spectaclePlacer.destroySelf();
            _spectaclePlacer = null;

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
            if (_timerView == null) {
                _timerView = new TimerView();
                _timerView.x = 300;
                _timerView.y = 20;
                addObject(_timerView, _modeSprite);
            }

            _timerView.time = this.curPattern.timeLimit;
        }
    }

    protected function handleSuccess () :void
    {
        log.info("Success!");
        setText("Success!");
        handleCompleted();
    }

    protected function handleFailure () :void
    {
        log.info("Failed!");
        setText("Out of time!");
        handleCompleted();
    }

    protected function handleCompleted () :void
    {
        _completed = true;

        if (_timerView != null) {
            _timerView.destroySelf();
            _timerView = null;
        }

        removePatternView();

        if (ClientContext.isPartyLeader) {
            _againButton = UIBits.createButton("Again?", 1.5);
            _modeSprite.addChild(_againButton);
            registerOneShotCallback(_againButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    ClientContext.outMsg.sendMessage(Constants.MSG_C_PLAYAGAIN);
                });

            updateButtons();
        }
    }

    protected function onStartClicked (...ignored) :void
    {
        if (_spectacleOffsetThrottler != null) {
            _spectacleOffsetThrottler.forcePendingMessage();
            _spectacleOffsetThrottler.destroySelf();
            _spectacleOffsetThrottler = null;
        }

        ClientContext.sendAgentMsg(Constants.MSG_C_STARTPLAYING);
        _startButton.parent.removeChild(_startButton);
        _startButton = null;
    }

    protected function updateButtons () :void
    {
        var button :SimpleButton = (_startButton != null ? _startButton : _againButton);
        if (button != null) {
            button.x = _bg.width - button.width - 10;
            button.y = _bg.height - button.height - 10;
        }
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
        g.lineStyle(2, 0);
        g.beginFill(0, 0.7);
        g.drawRoundRect(0, 0, WIDTH, Math.max(height, MIN_HEIGHT), 15, 15);
        g.endFill();

        _tf.x = (_bg.width - _tf.width) * 0.5;
        _tf.y = (_bg.height - _tf.height) * 0.5;

        updateButtons();
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        if (_startedPlaying && !_completed && !_patternRecognized) {

            // checkPlayerPositions checks to see which positions still need to be filled, and
            // updates the PatternView with this information so that players can keep track.
            var patternRecognized :Boolean = checkPlayerPositions();

            if (ClientContext.isPartyLeader) {
                if (patternRecognized) {
                    // Tell the server we were successful
                    log.info("patternRecognized");
                    _patternRecognized = true;
                    ClientContext.outMsg.sendMessage(Constants.MSG_C_PATTERNCOMPLETE);

                } else if (_timerView != null && _timerView.time <= 0) {
                    log.info("Out of time!");
                    _completed = true;
                    ClientContext.outMsg.sendMessage(Constants.MSG_C_OUTOFTIME);
                }
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
    protected var _againButton :SimpleButton;
    protected var _tf :TextField;
    protected var _bg :Shape;

    protected var _patternIndex :int = -1;
    protected var _patternRecognized :Boolean;
    protected var _startedPlaying :Boolean;
    protected var _completed :Boolean;
    protected var _spectaclePlacer :SpectaclePlacer;
    protected var _patternView :PatternView;
    protected var _spectacleOffset :PatternLoc;
    protected var _spectacleOffsetThrottler :MessageThrottler;
    protected var _timerView :TimerView;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}

import com.whirled.contrib.simplegame.SimObject;
import flashmob.client.ClientContext;
import flashmob.data.PatternLoc;
import com.threerings.flash.Vector2;

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

class LocInfo
{
    public var loc :Vector2;
    public var index :int;

    public function LocInfo (loc :Vector2, index :int)
    {
        this.loc = loc;
        this.index = index;
    }
}
