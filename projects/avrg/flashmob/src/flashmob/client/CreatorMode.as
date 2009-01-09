package flashmob.client {

import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Log;
import com.whirled.avrg.*;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.MovieClip;
import flash.display.SimpleButton;
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

        // Setup buttons
        registerListener(ClientContext.gameUIView.closeButton, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientContext.confirmQuit();
            });

        if (ClientContext.isPartyLeader) {
            _poseButton = SwfResource.instantiateButton("Spectacle_UI", "firstpose");
            registerListener(_poseButton, MouseEvent.CLICK, onPoseClicked);

            _doneButton = SwfResource.instantiateButton("Spectacle_UI", "done");
            registerListener(_doneButton, MouseEvent.CLICK, onDoneClicked);

            ClientContext.gameUIView.rightButton = _poseButton;
            ClientContext.gameUIView.leftButton = _doneButton;

            ClientContext.gameUIView.directionsText = "Wait for everybody to get into " +
                "position and press First Pose!";

            _spectacle = new Spectacle();
            _spectacle.numPlayers = ClientContext.playerIds.length;
            _spectacle.creatingPartyId = ClientContext.partyId;
            _spectacle.avatarId = ClientContext.gameCtrl.player.getAvatarMasterItemId();

            updateButtons();

        } else {
            ClientContext.gameUIView.directionsText = "Everybody! Arrange yourselves.";
        }

        ClientContext.gameUIView.timerVisible = false;

        // Make the UI draggable
        addObject(new Dragger(ClientContext.gameUIView.draggableObject, ClientContext.gameUIView));
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);
        updateButtons();
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
                    ClientContext.gameUIView.timerText = timerText;
                });

            addObject(_gameTimer);
        }

        ClientContext.gameUIView.timerVisible = true;
        _gameTimer.time = 0;

        var now :Number = ClientContext.timeNow;
        var dt :Number = now - _lastSnapshotTime;

        // capture the locations of all the players
        var pattern :Pattern = new Pattern();
        pattern.timeLimit = (_spectacle.numPatterns == 0 ? 0 : Math.ceil(dt));
        for each (var playerId :int in ClientContext.playerIds) {
            var roomLoc :Point = ClientContext.getPlayerRoomLoc(playerId);
            pattern.locs.push(new PatternLoc(roomLoc.x, roomLoc.y));
        }

        _spectacle.patterns.push(pattern);
        _lastSnapshotTime = now;

        if (_spectacle.patterns.length == 1) {
            // We just captured our first pose. Swap in the "Next Pose" button.
            _poseButton = SwfResource.instantiateButton("Spectacle_UI", "nextpose");
            registerListener(_poseButton, MouseEvent.CLICK, onPoseClicked);
            ClientContext.gameUIView.rightButton = _poseButton;
        }

        ClientContext.gameUIView.directionsText = (this.canFinish ?
            "Press Next Pose when everyone's in position, or Done if the Spectacle is complete!" :
            "Press Next Pose when everyone's in position!");

        updateButtons();
    }

    protected function onDoneClicked (...ignored) :void
    {
        if (!this.canFinish) {
            return;
        }

        ClientContext.gameUIView.clearButtons();
        ClientContext.gameUIView.timerVisible = false;

        ClientContext.gameUIView.directionsText = "Name your Spectacle!";
        var textBox :MovieClip = SwfResource.instantiateMovieClip("Spectacle_UI", "inputspecname");
        textBox.x = 0;
        textBox.y = 0;
        ClientContext.gameUIView.addChild(textBox);

        var inputText :TextField = textBox["input_text"];
        TextFieldUtil.setFocusable(inputText);

        var okButton :SimpleButton = SwfResource.instantiateButton("Spectacle_UI", "ok_button");
        registerOneShotCallback(okButton, MouseEvent.CLICK,
            function (...ignored) :void {
                _spectacle.name = inputText.text;
                _spectacle.normalize();
                ClientContext.sendAgentMsg(Constants.MSG_C_DONECREATING, _spectacle.toBytes());
                _done = true;
                ClientContext.gameUIView.clearButtons();
            });

        ClientContext.gameUIView.clearButtons();
        ClientContext.gameUIView.rightButton = okButton;
    }

    protected function updateButtons () :void
    {
        if (_doneButton != null) {
            _doneButton.visible = this.canFinish;
        }

        if (_poseButton != null) {
            _poseButton.visible = this.canCapturePose;
        }
    }

    protected function get log () :Log
    {
        return FlashMobClient.log;
    }

    protected var _poseButton :SimpleButton;
    protected var _doneButton :SimpleButton;

    protected var _spectacle :Spectacle;
    protected var _lastSnapshotTime :Number = 0;
    protected var _gameTimer :GameTimer;

    protected var _done :Boolean;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}
