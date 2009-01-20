package flashmob.client {

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import flashmob.*;
import flashmob.client.view.*;
import flashmob.data.*;
import flashmob.util.SpriteUtil;

public class PlayerMode extends GameDataMode
{
    override protected function setup () :void
    {
        _dancersLayer = SpriteUtil.createSprite();
        _uiLayer = SpriteUtil.createSprite(true);
        _modeSprite.addChild(_dancersLayer);
        _modeSprite.addChild(_uiLayer);

        _spectacle = ClientContext.spectacle;
        _spectacleBounds = _spectacle.getBounds();

        var roomBounds :Rectangle = SpaceUtil.roomDisplayBounds;

        if (ClientContext.gameUIView == null) {
            ClientContext.gameUIView = new GameUIView();
            ClientContext.gameUIView.x = roomBounds.width * 0.5;
            ClientContext.gameUIView.y = roomBounds.height * 0.5;
        }

        _uiLayer.addChild(ClientContext.gameUIView);
        ClientContext.gameUIView.clockVisible = false;
        ClientContext.gameUIView.reset();

        // Make the UI draggable
        addObject(new Dragger(ClientContext.gameUIView.draggableObject, ClientContext.gameUIView));

        // Create the SpectaclePlacer
        _spectaclePlacer = new SpectaclePlacer(_spectacle,
            (ClientContext.isPartyLeader ? onPlacerDragged : null));
        _spectaclePlacer.visible = ClientContext.isPartyLeader;
        addObject(_spectaclePlacer, _uiLayer);
        DisplayUtil.positionBoundsRelative(_spectaclePlacer.displayObject, _uiLayer,
            (roomBounds.width - _spectaclePlacer.width) * 0.5,
            roomBounds.bottom - _spectaclePlacer.height - 20);

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

            _specCenterThrottler = new MessageThrottler(Constants.MSG_C_SET_SPEC_CENTER);
            addObject(_specCenterThrottler);

            onPlacerDragged(_spectaclePlacer.x, _spectaclePlacer.y);

        } else {
            ClientContext.gameUIView.directionsText =
                "The party leader is preparing the Spectacle!";
        }

        // init data bindings
        _dataBindings.bindMessage(Constants.MSG_S_PLAYNEXTPATTERN, handleNextPattern);
        _dataBindings.bindMessage(Constants.MSG_S_PLAYSUCCESS, handleSuccess);
        _dataBindings.bindMessage(Constants.MSG_S_PLAYFAIL, handleFailure);
        _dataBindings.bindMessage(Constants.MSG_S_PLAYAGAIN, handlePlayAgain);
        _dataBindings.bindProp(Constants.PROP_SPECTACLE_CENTER, handleNewSpectacleCenter,
            Vec3D.fromBytes);
        _dataBindings.bindProp(Constants.PROP_PLAYERS, handlePlayersChanged);

        // setup sounds
        _soundControls = new AudioControls(
            AudioManager.instance.getControlsForSoundType(SoundResource.TYPE_SFX));
        _soundControls.retain();

        registerListener(ClientContext.roomBoundsMonitor, GameEvent.ROOM_BOUNDS_CHANGED,
            onRoomBoundsChanged);
    }

    override protected function destroy () :void
    {
        super.destroy();
        _soundControls.release();
    }

    /*override protected function enter () :void
    {
        super.enter();
        _modeSprite.visible = true;
    }

    override protected function exit () :void
    {
        super.exit();
        _modeSprite.visible = false;
    }*/

    protected function onRoomBoundsChanged (...ignored) :void
    {
        updateSpectaclePlacerLoc();
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

    protected function onPlacerDragged (newX :Number, newY :Number) :void
    {
        _spectaclePlacer.x = newX;
        _spectaclePlacer.y = newY;

        _specCenterThrottler.value =
            SpaceUtil.paintableToLogicalAtDepth(new Point(newX, newY), 0).toBytes();
    }

    protected function handleNewSpectacleCenter (newCenter :Vec3D) :void
    {
        _specCenter = newCenter;

        if (!ClientContext.isPartyLeader) {
            updateSpectaclePlacerLoc(true);
        }
    }

    protected function updateSpectaclePlacerLoc (animate :Boolean = false) :void
    {
        var screenLoc :Point = SpaceUtil.logicalToPaintable(_specCenter);
        screenLoc.y += Constants.SPEC_CENTER_Y_FUDGE;
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
    }

    protected function checkPlayerPositions () :Boolean
    {
        var pattern :Pattern = this.curPattern;
        if (pattern == null) {
            return false;
        }

        var patternLocs :Array = pattern.locs.map(
            function (loc :Vec3D, index :int, ...ignored) :LocInfo {
                return new LocInfo(loc, index);
            });

        var playerLocs :Array = [];
        ClientContext.players.players.forEach(
            function (playerInfo :PlayerInfo, ...ignored) :void {
                var loc :Vec3D = SpaceUtil.getAvatarLogicalLoc(playerInfo.id);
                // roomLoc could be null if a player just left the game but we haven't
                // been notified about it yet
                playerLocs.push(loc != null ? loc : new Vec3D());
            });

        var epsilon2 :Number = Constants.PATTERN_LOC_EPSILON * Constants.PATTERN_LOC_EPSILON;
        var inPositionFlags :Array = ArrayUtil.create(patternLocs.length, false);
        var allInPosition :Boolean = true;
        for each (var playerLoc :Vec3D in playerLocs) {

            var inPosition :Boolean = false;
            for (var ii :int = 0; ii < patternLocs.length; ++ii) {
                var patternLoc :LocInfo = patternLocs[ii];
                var dist2 :Number = patternLoc.loc.subtract(playerLoc).length2;
                if (dist2 <= epsilon2) {
                    inPosition = true;
                    patternLocs.splice(ii, 1);
                    inPositionFlags[patternLoc.index] = true;
                    break;
                }
            }

            allInPosition &&= inPosition;
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
            if (_specCenterThrottler != null) {
                _specCenterThrottler.destroySelf();
                _specCenterThrottler = null;
            }

            _spectaclePlacer.destroySelf();
            _spectaclePlacer = null;

            var oldCenter :Vec3D = _spectacle.getCenter();
            _specCenter.z = oldCenter.z;
            _spectacle.setCenter(_specCenter);

            _startedPlaying = true;
        }

        ++_patternIndex;
        _patternRecognized = false;

        removePatternView();
        _patternView = new PatternView(this.curPattern, onPatternLocClicked);
        addObject(_patternView, _uiLayer);
        updateSpectaclePlacerLoc();

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

    protected function onPatternLocClicked (patternLoc :Vec3D) :void
    {
        var avInfo :AVRGameAvatar =
            ClientContext.gameCtrl.room.getAvatarInfo(ClientContext.localPlayerId);

        //log.info("Moving", "from", new Vec3D(avInfo.x, avInfo.y, avInfo.z), "to", patternLoc);
        ClientContext.gameCtrl.player.setAvatarLocation(
            patternLoc.x,
            patternLoc.y,
            patternLoc.z,
            avInfo.orientation);
    }

    protected function handleSuccess () :void
    {
        log.info("Success!");
        ClientContext.gameUIView.directionsText = "Miraculous! Stupendous! SPECTACULAR!";
        handleCompleted();

        // show the Can-Can dancers
        var dancers :CanCanDancers = new CanCanDancers();
        dancers.displayObject.mask = this.roomMask;
        var roomBounds :Rectangle = SpaceUtil.roomDisplayBounds;
        dancers.x = roomBounds.left - dancers.width;
        dancers.y = roomBounds.top + ((roomBounds.height - dancers.height) * 0.5);
        dancers.addTask(new SerialTask(
            LocationTask.CreateLinear(roomBounds.right, dancers.y, Constants.SUCCESS_ANIM_TIME),
            new SelfDestructTask()));
        addObject(dancers, _dancersLayer);

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
        playSound("fail");
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
        if (_specCenterThrottler != null) {
            _specCenterThrottler.forcePendingMessage();
            _specCenterThrottler.destroySelf();
            _specCenterThrottler = null;
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
            var roomBounds :Rectangle = SpaceUtil.roomDisplayBounds;
            _roomMask = new Shape();
            var g :Graphics = _roomMask.graphics;
            g.beginFill(1, 0);
            g.drawRect(0, 0, roomBounds.width, roomBounds.height);
            g.endFill();
            _modeSprite.addChild(_roomMask);
        }

        return _roomMask;
    }

    protected var _uiLayer :Sprite;
    protected var _dancersLayer :Sprite;

    protected var _spectacle :Spectacle;
    protected var _spectacleBounds :Rect3D;
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
    protected var _specCenter :Vec3D;
    protected var _specCenterThrottler :MessageThrottler;
    protected var _gameTimer :GameTimer;

    protected var _soundControls :AudioControls;
    protected var _snareRoll :AudioChannel;

    protected static var log :Log = Log.getLog(PlayerMode);

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}

import com.whirled.contrib.simplegame.SimObject;
import flashmob.client.ClientContext;
import flashmob.data.Vec3D;
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
    public var loc :Vec3D;
    public var index :int;

    public function LocInfo (loc :Vec3D, index :int)
    {
        this.loc = loc;
        this.index = index;
    }
}
