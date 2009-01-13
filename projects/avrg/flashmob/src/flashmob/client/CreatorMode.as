package flashmob.client {

import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Log;
import com.whirled.avrg.*;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

import flashmob.*;
import flashmob.client.view.*;
import flashmob.data.*;

public class CreatorMode extends GameDataMode
{
    override protected function setup () :void
    {
        if (ClientContext.gameUIView == null) {
            ClientContext.gameUIView = new GameUIView();
            var bounds :Rectangle = ClientContext.roomDisplayBounds;
            ClientContext.gameUIView.x = bounds.width * 0.5;
            ClientContext.gameUIView.y = bounds.height * 0.5;
        }

        _modeSprite.addChild(ClientContext.gameUIView);
        ClientContext.gameUIView.reset();

        // Make the UI draggable
        addObject(new Dragger(ClientContext.gameUIView.draggableObject, ClientContext.gameUIView));

        // Setup buttons
        registerListener(ClientContext.gameUIView.closeButton, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientContext.confirmQuit();
            });

        if (ClientContext.isPartyLeader) {
            var chooseAvatarButton :GameButton = new GameButton("ok_button");
            registerListener(chooseAvatarButton.button, MouseEvent.CLICK,
                function (...ignored) :void {
                    ClientContext.outMsg.sendMessage(Constants.MSG_C_CHOSEAVATAR,
                        ClientContext.avatarMonitor.curAvatarId);
                });
            ClientContext.gameUIView.centerButton = chooseAvatarButton;

            ClientContext.gameUIView.directionsText =
                "Wear the Avatar you will perform this Spectacle with, and press OK!";

        } else {
            ClientContext.gameUIView.directionsText =
                "The party leader is choosing an Avatar for the Spectacle!";
        }

        ClientContext.gameUIView.clockVisible = false;

        _dataBindings.bindMessage(Constants.MSG_S_STARTCREATING, handleStartCreating);
        _dataBindings.bindProp(Constants.PROP_PLAYERS, handlePlayersChanged);
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

    override public function update (dt :Number) :void
    {
        super.update(dt);
        updateButtons();
    }

    protected function handleStartCreating (chosenAvatarId :int) :void
    {
        if (ClientContext.isPartyLeader) {
            ClientContext.gameUIView.clearButtons();

            _poseButton = new GameButton("firstpose");
            registerListener(_poseButton.button, MouseEvent.CLICK, onPoseClicked);

            _doneButton = new GameButton("done");
            registerListener(_doneButton.button, MouseEvent.CLICK, onDoneClicked);

            _doneButton.enabled = false;

            ClientContext.gameUIView.leftButton = _doneButton;
            ClientContext.gameUIView.rightButton = _poseButton;

            ClientContext.gameUIView.directionsText =
                "Get everyone into position and press First Pose!";

            _spectacle = new Spectacle();
            _spectacle.numPlayers = ClientContext.players.numPlayers
            _spectacle.creatingPartyId = ClientContext.partyId;
            _spectacle.avatarId = ClientContext.gameCtrl.player.getAvatarMasterItemId();

            updateButtons();

        } else {
            ClientContext.gameUIView.directionsText = "Everybody! Arrange yourselves.";
        }

        _startedCreating = true;
        _chosenAvatarId = chosenAvatarId;
        handlePlayersChanged();
    }

    protected function handlePlayersChanged () :void
    {
        if (_startedCreating && !ClientContext.players.allWearingAvatar(_chosenAvatarId)) {
            ClientContext.mainLoop.pushMode(new AvatarErrorMode(_chosenAvatarId));
        }
    }

    protected function get canCapturePose () :Boolean
    {
        if (ClientContext.waitingForPlayers) {
            return false;
        } else if (_spectacle.numPatterns >= Constants.MAX_SPECTACLE_PATTERNS) {
            return false;
        } else if (_spectacle.numPatterns > 0 &&
                   ClientContext.timeNow - _lastSnapshotTime < Constants.MIN_SNAPSHOT_TIME) {
            return false;
        }

        return true;
    }

    protected function get canFinish () :Boolean
    {
        return (!_done && _spectacle.numPatterns >= Constants.MIN_SPECTACLE_PATTERNS);
    }

    protected function onPoseClicked (...ignored) :void
    {
        if (!this.canCapturePose) {
            return;
        }

        if (_gameTimer == null) {
            _gameTimer = new GameTimer(0, true,
                function (timerText :String) :void {
                    ClientContext.gameUIView.clockText = timerText;
                });

            addObject(_gameTimer);
        }

        ClientContext.gameUIView.animateShowClock(true);
        _gameTimer.time = 0;

        var now :Number = ClientContext.timeNow;
        var dt :Number = now - _lastSnapshotTime;

        // capture the locations of all the players
        var pattern :Pattern = new Pattern();
        pattern.timeLimit = (_spectacle.numPatterns == 0 ? 0 : Math.ceil(dt));
        ClientContext.players.players.forEach(
            function (playerId :int, playerInfo :PlayerInfo) :void {
                var roomLoc :Point = ClientContext.getPlayerRoomLoc(playerId);
                pattern.locs.push(new PatternLoc(roomLoc.x, roomLoc.y));
            });

        _spectacle.patterns.push(pattern);
        _lastSnapshotTime = now;

        if (_spectacle.patterns.length == 1) {
            // We just captured our first pose. Swap in the "Next Pose" button.
            _poseButton = new GameButton("nextpose");
            registerListener(_poseButton.button, MouseEvent.CLICK, onPoseClicked);
            ClientContext.gameUIView.rightButton = _poseButton;
        }

        ClientContext.gameUIView.directionsText = "Press Next Pose when everyone's in position!";

        updateButtons();
    }

    protected function onDoneClicked (...ignored) :void
    {
        if (!this.canFinish) {
            return;
        }

        ClientContext.gameUIView.clearButtons();
        ClientContext.gameUIView.animateShowClock(false);

        ClientContext.gameUIView.directionsText = "Name your Spectacle!";
        var textBox :MovieClip = SwfResource.instantiateMovieClip("Spectacle_UI", "inputspecname");
        textBox.x = 0;
        textBox.y = -5;
        ClientContext.gameUIView.addDisplayElement(textBox);

        var inputText :TextField = textBox["input_text"];
        inputText.setSelection(0, inputText.text.length);
        inputText.maxChars = Constants.MAX_SPEC_NAME_LENGTH;
        TextFieldUtil.setFocusable(inputText);

        ClientContext.gameUIView.clearButtons();
        var okButton :GameButton = new GameButton("ok_button");
        ClientContext.gameUIView.centerButton = okButton;
        registerOneShotCallback(okButton.button, MouseEvent.CLICK,
            function (...ignored) :void {
                _spectacle.name = inputText.text;
                _spectacle.normalize();
                ClientContext.sendAgentMsg(Constants.MSG_C_DONECREATING, _spectacle.toBytes());
                _done = true;
                ClientContext.gameUIView.clearButtons();
            });

        okButton.enabled = isTextOk();
        registerListener(inputText, Event.CHANGE,
            function () :void {
                okButton.enabled = isTextOk();
            });

        function isTextOk () :Boolean {
            return inputText.text.length > 0;
        }
    }

    protected function updateButtons () :void
    {
        if (_doneButton != null) {
            _doneButton.enabled = this.canFinish;
        }

        if (_poseButton != null) {
            _poseButton.enabled = this.canCapturePose;
        }
    }

    protected function get log () :Log
    {
        return FlashMobClient.log;
    }

    protected var _poseButton :GameButton;
    protected var _doneButton :GameButton;

    protected var _spectacle :Spectacle;
    protected var _startedCreating :Boolean;
    protected var _lastSnapshotTime :Number = 0;
    protected var _gameTimer :GameTimer;
    protected var _chosenAvatarId :int;

    protected var _done :Boolean;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}
