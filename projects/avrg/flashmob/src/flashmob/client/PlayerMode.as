package flashmob.client {

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Graphics;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import flashmob.*;
import flashmob.client.view.*;
import flashmob.data.*;

public class PlayerMode extends GameDataMode
{
    override protected function setup () :void
    {
        _spectacle = ClientContext.spectacle;

        var roomBounds :Rectangle = ClientContext.roomDisplayBounds;

        if (ClientContext.gameUIView == null) {
            ClientContext.gameUIView = new GameUIView();
            ClientContext.gameUIView.x = roomBounds.width * 0.5;
            ClientContext.gameUIView.y = roomBounds.height * 0.5;
        }

        _modeSprite.addChild(ClientContext.gameUIView);
        ClientContext.gameUIView.clockVisible = false;
        ClientContext.gameUIView.reset();

        // Make the UI draggable
        addObject(new Dragger(ClientContext.gameUIView.draggableObject, ClientContext.gameUIView));

        // Create the SpectaclePlacer
        _spectaclePlacer = new SpectaclePlacer(_spectacle,
            (ClientContext.isPartyLeader ? onSpectacleDragged : null));
        _spectaclePlacer.visible = ClientContext.isPartyLeader;
        DisplayUtil.positionBounds(_spectaclePlacer.displayObject,
            roomBounds.left + ((roomBounds.width - _spectaclePlacer.width) * 0.5),
            roomBounds.bottom - _spectaclePlacer.height - 20);
        addObject(_spectaclePlacer, _modeSprite);

        // Setup buttons
        registerListener(ClientContext.gameUIView.closeButton, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientContext.confirmQuit();
            });

        if (ClientContext.isPartyLeader) {
            _startButton = new GameButton("start_button");
            registerListener(_startButton.button, MouseEvent.CLICK, onStartClicked);

            _againButton = new GameButton("tryagain");
            registerListener(_againButton.button, MouseEvent.CLICK, onTryAgainClicked);

            _resetButton = new GameButton("reset");
            registerOneShotCallback(_resetButton.button, MouseEvent.CLICK, onTryAgainClicked);

            _mainMenuButton = new GameButton("mainmenu");
            registerOneShotCallback(_mainMenuButton.button, MouseEvent.CLICK, onMainMenuClicked);

            ClientContext.gameUIView.centerButton = _startButton;
            ClientContext.gameUIView.directionsText = "Place the Spectacle and press Start!";

            _spectacleOffsetThrottler = new MessageThrottler(Constants.MSG_CS_SET_SPECTACLE_OFFSET);
            addObject(_spectacleOffsetThrottler);

            onSpectacleDragged(_spectaclePlacer.x, _spectaclePlacer.y);

        } else {
            ClientContext.gameUIView.directionsText =
                "The party leader is preparing the Spectacle!";
        }

        // init data bindings
        _dataBindings.bindMessage(Constants.MSG_S_PLAYNEXTPATTERN, handleNextPattern);
        _dataBindings.bindMessage(Constants.MSG_S_PLAYSUCCESS, handleSuccess);
        _dataBindings.bindMessage(Constants.MSG_S_PLAYFAIL, handleFailure);
        _dataBindings.bindMessage(Constants.MSG_S_PLAYAGAIN, handlePlayAgain);
        _dataBindings.bindProp(Constants.PROP_SPECTACLE_OFFSET, handleNewSpectacleOffset,
            PatternLoc.fromBytes);
        _dataBindings.bindProp(Constants.PROP_PLAYERS, handlePlayersChanged);
        _dataBindings.processAllProperties(ClientContext.props);

        registerListener(ClientContext.gameCtrl.local, AVRGameControlEvent.SIZE_CHANGED,
            function (...ignored) :void {
                updatePatternViewLoc(false);
            });

        // setup sounds
        _soundControls = new AudioControls(
            AudioManager.instance.getControlsForSoundType(SoundResource.TYPE_SFX));
        _soundControls.retain();

        registerListener(ClientContext.roomBoundsMonitor, GameEvent.ROOM_BOUNDS_CHANGED,
            onRoomBoundsChanged);
    }

    override protected function destroy () :void
    {
        _soundControls.release();
    }

    override protected function enter () :void
    {
        super.enter();
        _modeSprite.visible = true;
    }

    override protected function exit () :void
    {
        super.exit();
        _modeSprite.visible = false;
    }

    protected function onRoomBoundsChanged (...ignored) :void
    {
        updatePatternViewLoc();
    }

    protected function playSound (name :String, loopCount :int = 0) :AudioChannel
    {
        return AudioManager.instance.playSoundNamed(name, _soundControls, loopCount);
    }

    protected function playSnareRoll (play :Boolean) :void
    {
        if (play && _snareRoll == null) {
            _snareRoll = playSound("snare_roll", AudioManager.LOOP_FOREVER);

        } else if (!play && _snareRoll != null) {
            _snareRoll.audioControls.fadeOut(0.5).stopAfter(0.5);
            _snareRoll = null;
        }
    }

    protected function handlePlayersChanged () :void
    {
        if (!ClientContext.players.allWearingAvatar(_spectacle.avatarId)) {
            ClientContext.mainLoop.pushMode(new AvatarErrorMode(_spectacle.avatarId));
        }
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

        var playerLocs :Array = [];
        ClientContext.players.players.forEach(
            function (playerId :int, playerInfo :PlayerInfo) :void {
                var roomLoc :Point = ClientContext.getPlayerRoomLoc(playerId);
                // roomLoc could be null if a player just left the game but we haven't
                // be notified about it yet
                playerLocs.push(roomLoc != null ? Vector2.fromPoint(roomLoc)
                    : new Vector2(Number.MIN_VALUE, Number.MIN_VALUE));
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

            if (inPosition) {
                ArrayUtil.removeFirst(patternLocs, closestLoc);
            }
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

        ClientContext.gameUIView.directionsText = (_patternIndex == 0 ?
            "First pose!" :
            "Next pose!");

        if (_patternIndex == 0) {
            playSnareRoll(true);

        } else {
            if (_gameTimer == null) {
                _gameTimer = new GameTimer(0, false,
                    function (timerText :String) :void {
                        ClientContext.gameUIView.clockText = timerText;
                    });
                addObject(_gameTimer);
            }

            _gameTimer.time = this.curPattern.timeLimit;
            ClientContext.gameUIView.animateShowClock(true);

            playSound("cymbal_hit");
        }
    }

    protected function handleSuccess () :void
    {
        log.info("Success!");
        ClientContext.gameUIView.directionsText = "Miraculous! Stupendous! SPECTACULAR!";
        handleCompleted();

        // show the Can-Can dancers
        var dancers :CanCanDancers = new CanCanDancers();
        dancers.displayObject.mask = this.roomMask;
        var roomBounds :Rectangle = ClientContext.roomDisplayBounds;
        dancers.x = roomBounds.left - dancers.width;
        dancers.y = roomBounds.top + ((roomBounds.height - dancers.height) * 0.5);
        dancers.addTask(new SerialTask(
            LocationTask.CreateLinear(roomBounds.right, dancers.y, Constants.SUCCESS_ANIM_TIME),
            new SelfDestructTask()));
        addObject(dancers, _modeSprite);

        // audio
        playSnareRoll(false);
        playSound("cymbal_hit");
    }

    protected function handleFailure () :void
    {
        log.info("Failed!");
        ClientContext.gameUIView.directionsText = "Out of time!";
        handleCompleted();

        // audio
        playSnareRoll(false);
        playSound("clown_horn");
    }

    protected function handlePlayAgain () :void
    {
        ClientContext.mainLoop.changeMode(new PlayerMode());
    }

    protected function handleCompleted () :void
    {
        _completed = true;

        if (_gameTimer != null) {
            _gameTimer.destroySelf();
            _gameTimer = null;
        }

        removePatternView();

        if (ClientContext.isPartyLeader) {
            ClientContext.gameUIView.rightButton = _againButton;
            ClientContext.gameUIView.leftButton = _mainMenuButton;
        }

        ClientContext.gameUIView.animateShowClock(false);
    }

    protected function onTryAgainClicked (...ignored) :void
    {
        ClientContext.outMsg.sendMessage(Constants.MSG_C_PLAYAGAIN);
    }

    protected function onMainMenuClicked (...ignored) :void
    {
        ClientContext.outMsg.sendMessage(Constants.MSG_C_RESETGAME);
    }

    protected function onStartClicked (...ignored) :void
    {
        if (_spectacleOffsetThrottler != null) {
            _spectacleOffsetThrottler.forcePendingMessage();
            _spectacleOffsetThrottler.destroySelf();
            _spectacleOffsetThrottler = null;
        }

        ClientContext.sendAgentMsg(Constants.MSG_C_STARTPLAYING);
        ClientContext.gameUIView.clearButtons();
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
                    var patternTime :Number = (_patternIndex > 0 ?
                        this.curPattern.timeLimit - _gameTimer.time :
                        0);

                    ClientContext.outMsg.sendMessage(Constants.MSG_C_PATTERNCOMPLETE, patternTime);

                } else if (_gameTimer != null && _gameTimer.time <= 0) {
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

    protected function get roomMask () :Shape
    {
        if (_roomMask == null) {
            var roomBounds :Rectangle = ClientContext.roomDisplayBounds;
            _roomMask = new Shape();
            var g :Graphics = _roomMask.graphics;
            g.beginFill(1, 0);
            g.drawRect(0, 0, roomBounds.width, roomBounds.height);
            g.endFill();
            _modeSprite.addChild(_roomMask);
        }

        return _roomMask;
    }

    protected static function get log () :Log
    {
        return FlashMobClient.log;
    }

    protected var _spectacle :Spectacle;
    protected var _startButton :GameButton;
    protected var _againButton :GameButton;
    protected var _resetButton :GameButton;
    protected var _mainMenuButton :GameButton;
    protected var _roomMask :Shape;

    protected var _patternIndex :int = -1;
    protected var _patternRecognized :Boolean;
    protected var _startedPlaying :Boolean;
    protected var _completed :Boolean;
    protected var _spectaclePlacer :SpectaclePlacer;
    protected var _patternView :PatternView;
    protected var _spectacleOffset :PatternLoc;
    protected var _spectacleOffsetThrottler :MessageThrottler;
    protected var _gameTimer :GameTimer;

    protected var _soundControls :AudioControls;
    protected var _snareRoll :AudioChannel;

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
