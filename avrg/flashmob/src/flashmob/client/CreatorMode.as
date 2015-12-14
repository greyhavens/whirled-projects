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
        if (ClientCtx.gameUIView == null) {
            ClientCtx.gameUIView = new GameUIView();
            var bounds :Rectangle = SpaceUtil.roomDisplayBounds;
            ClientCtx.gameUIView.x = bounds.width * 0.5;
            ClientCtx.gameUIView.y = bounds.height * 0.5;
        }

        _modeSprite.addChild(ClientCtx.gameUIView);
        ClientCtx.gameUIView.reset();

        // Make the UI draggable
        addObject(new Dragger(ClientCtx.gameUIView.draggableObject, ClientCtx.gameUIView));

        // Setup buttons
        registerListener(ClientCtx.gameUIView.closeButton, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.confirmQuit();
            });

        if (ClientCtx.isPartyLeader) {
            var chooseAvatarButton :GameButton = new GameButton("ok_button");
            registerListener(chooseAvatarButton.button, MouseEvent.CLICK,
                function (...ignored) :void {
                    ClientCtx.outMsg.sendMessage(Constants.MSG_C_CHOSEAVATAR,
                        ClientCtx.avatarMonitor.curAvatarId);
                });
            ClientCtx.gameUIView.centerButton = chooseAvatarButton;

            ClientCtx.gameUIView.directionsText =
                "Wear the Avatar you will perform this Spectacle with, and press OK!";

        } else {
            ClientCtx.gameUIView.directionsText =
                "The party leader is choosing an Avatar for the Spectacle!";
        }

        ClientCtx.gameUIView.clockVisible = false;

        _dataBindings.bindMessage(Constants.MSG_S_STARTCREATING, handleStartCreating);
        _dataBindings.bindProp(Constants.PROP_PLAYERS, handlePlayersChanged);
    }

    override protected function enter () :void
    {
        super.enter();
        _modeSprite.visible = true;
    }

    /*override protected function exit () :void
    {
        super.exit();
        _modeSprite.visible = false;
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);
        updateButtons();
    }*/

    protected function handleStartCreating (chosenAvatarId :int) :void
    {
        if (ClientCtx.isPartyLeader) {
            ClientCtx.gameUIView.clearButtons();

            _poseButton = new GameButton("firstpose");
            registerListener(_poseButton.button, MouseEvent.CLICK, onPoseClicked);

            _doneButton = new GameButton("done");
            registerListener(_doneButton.button, MouseEvent.CLICK, onDoneClicked);

            _doneButton.enabled = false;

            ClientCtx.gameUIView.leftButton = _doneButton;
            ClientCtx.gameUIView.rightButton = _poseButton;

            ClientCtx.gameUIView.directionsText =
                "Get everyone into position and press First Pose!";

            _spectacle = new Spectacle();
            _spectacle.numPlayers = ClientCtx.players.numPlayers
            _spectacle.creatingPartyId = ClientCtx.partyInfo.partyId;
            _spectacle.avatarId = ClientCtx.gameCtrl.player.getAvatarMasterItemId();

            updateButtons();

        } else {
            ClientCtx.gameUIView.directionsText = "Everybody! Arrange yourselves.";
        }

        _startedCreating = true;
        _chosenAvatarId = chosenAvatarId;
        handlePlayersChanged();
    }

    protected function handlePlayersChanged () :void
    {
        if (_startedCreating && !ClientCtx.players.allWearingAvatar(_chosenAvatarId)) {
            ClientCtx.mainLoop.pushMode(new AvatarErrorMode(_chosenAvatarId));
        }
    }

    protected function get canCapturePose () :Boolean
    {
        if (_spectacle.numPatterns >= Constants.MAX_SPECTACLE_PATTERNS) {
            return false;
        } else if (_spectacle.numPatterns > 0 &&
                   ClientCtx.timeNow - _lastSnapshotTime < Constants.MIN_SNAPSHOT_TIME) {
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
                    ClientCtx.gameUIView.clockText = timerText;
                });

            addObject(_gameTimer);
        }

        // capture the locations of all the players
        var pattern :Pattern = new Pattern();
        ClientCtx.players.players.forEach(
            function (playerInfo :PlayerInfo, ...ignored) :void {
                pattern.locs.push(SpaceUtil.getAvatarLogicalLoc(playerInfo.id));
            });

        //log.info("Pose", "pattern", pattern);

        if (!Constants.DEBUG_ALLOW_DUPLICATE_POSES &&
            _spectacle.patterns.length > 0 &&
            pattern.isSimilar(_spectacle.patterns[_spectacle.patterns.length - 1])) {
            ClientCtx.mainLoop.pushMode(new BasicErrorMode("This pose is too similar to " +
                "the last one!", true));
            return;
        }

        ClientCtx.gameUIView.animateShowClock(true);
        _gameTimer.time = 0;

        var now :Number = ClientCtx.timeNow;
        var dt :Number = now - _lastSnapshotTime;
        pattern.timeLimit = (_spectacle.numPatterns == 0 ? 0 : Math.ceil(dt));

        _spectacle.patterns.push(pattern);
        _lastSnapshotTime = now;

        if (_spectacle.patterns.length == 1) {
            // We just captured our first pose. Swap in the "Next Pose" button.
            _poseButton = new GameButton("nextpose");
            registerListener(_poseButton.button, MouseEvent.CLICK, onPoseClicked);
            ClientCtx.gameUIView.rightButton = _poseButton;
        }

        ClientCtx.gameUIView.directionsText = "Press Next Pose when everyone's in position!";

        updateButtons();
    }

    protected function onDoneClicked (...ignored) :void
    {
        if (!this.canFinish) {
            return;
        }

        ClientCtx.gameUIView.clearButtons();
        ClientCtx.gameUIView.animateShowClock(false);

        ClientCtx.gameUIView.directionsText = "Name your Spectacle!";
        var textBox :MovieClip = SwfResource.instantiateMovieClip(ClientCtx.rsrcs, "Spectacle_UI", "inputspecname");
        textBox.x = 0;
        textBox.y = -5;
        ClientCtx.gameUIView.addDisplayElement(textBox);

        var inputText :TextField = textBox["input_text"];
        inputText.setSelection(0, inputText.text.length);
        inputText.maxChars = Constants.MAX_SPEC_NAME_LENGTH;
        TextFieldUtil.setFocusable(inputText);

        ClientCtx.gameUIView.clearButtons();
        var okButton :GameButton = new GameButton("ok_button");
        ClientCtx.gameUIView.centerButton = okButton;
        registerOneShotCallback(okButton.button, MouseEvent.CLICK,
            function (...ignored) :void {
                _spectacle.name = inputText.text;
                //_spectacle.normalize();
                ClientCtx.sendAgentMsg(Constants.MSG_C_DONECREATING, _spectacle.toBytes());
                _done = true;
                ClientCtx.gameUIView.clearButtons();
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

    protected var _poseButton :GameButton;
    protected var _doneButton :GameButton;

    protected var _spectacle :Spectacle;
    protected var _startedCreating :Boolean;
    protected var _lastSnapshotTime :Number = 0;
    protected var _gameTimer :GameTimer;
    protected var _chosenAvatarId :int;

    protected var _done :Boolean;

    protected static var log :Log = Log.getLog(CreatorMode);

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}
