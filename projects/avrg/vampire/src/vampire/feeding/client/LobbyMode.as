package vampire.feeding.client {

import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Log;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.avrg.RoomDragger;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.util.Rand;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.data.VConstants;
import vampire.feeding.*;
import vampire.feeding.net.*;

public class LobbyMode extends AppMode
{
    public static const LOBBY :int = 0;
    public static const WAIT_FOR_NEXT_ROUND :int = 1;

    public function LobbyMode (type :int, roundResults :RoundOverMsg = null) :void
    {
        _type = type;
        _results = roundResults;
    }

    override protected function setup () :void
    {
        super.setup();

        registerListener(ClientCtx.props, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        registerListener(ClientCtx.props, ElementChangedEvent.ELEMENT_CHANGED, onPropChanged);
        registerListener(ClientCtx.msgMgr, ClientMsgEvent.MSG_RECEIVED, onMsgReceived);

        _panelMovie = ClientCtx.instantiateMovieClip("blood", "popup_panel");
        _modeSprite.addChild(_panelMovie);

        var contents :MovieClip = _panelMovie["draggable"];

        // Make the lobby draggable
        addObject(new RoomDragger(ClientCtx.gameCtrl, contents, _panelMovie));
        ClientCtx.centerInRoom(_panelMovie);

        // Instructions
        var instructionsBasic :MovieClip = contents["instructions_basic"];
        var instructionsMultiplayer :MovieClip = contents["instructions_multiplayer"];
        var instructionsStrain :MovieClip = contents["instructions_strains"];
        instructionsBasic.visible = false;
        instructionsMultiplayer.visible = false;
        instructionsStrain.visible = false;

        if (this.isPreGameLobby && ClientCtx.playerData.timesPlayed == 0) {
            instructionsBasic.visible = true;
        } else if ((this.isPreGameLobby || Rand.nextBoolean(Rand.STREAM_COSMETIC)) &&
                   ClientCtx.playerCanCollectPreyStrain) {
            instructionsStrain.visible = true;
        } else {
            instructionsMultiplayer.visible = true;
        }

        // Quit button
        var quitBtn :SimpleButton = _panelMovie["button_done"];
        registerOneShotCallback(quitBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.quit(true);
            });

        // Start/Play Again/Status
        var startButton :SimpleButton = _panelMovie["button_start"];
        var replayButton :SimpleButton = _panelMovie["button_again"];
        startButton.visible = false;
        replayButton.visible = false;
        _startButton = (isPostRoundLobby ? replayButton : startButton);
        registerListener(_startButton, MouseEvent.CLICK,
            function (...ignored) :void {
                if (_startButton.visible) {
                    ClientCtx.msgMgr.sendMessage(new CloseLobbyMsg());
                }
            });

        _tfStatus = contents["feedback_text"];
        updateButtonsAndStatus();

        // Total score
        var total :MovieClip = contents["total"];
        if (this.isPostRoundLobby) {
            total.visible = true;
            var tfTotal :TextField = total["player_score"];
            tfTotal.text = String(_results.totalScore);
        } else {
            total.visible = false;
        }

        // Player list
        _playerList = new SimpleListController(
            [],
            contents,
            "player",
            [ "player_name", "player_score" ],
            _panelMovie["arrow_up"],
            _panelMovie["arrow_down"]);
        addObject(_playerList);
        updatePlayerList();

        updateBloodBondIndicator();

        showRoundTimer(false);
        if (this.isWaitingForNextRound) {
            // ask the server to tell us how much time is remaining in the current round (it
            // will respond with a RoundTimeLeftMsg with the value)
            ClientCtx.msgMgr.sendMessage(RoundTimeLeftMsg.create());

            // grayscale-ize the panel
            _panelMovie.filters = [ new ColorMatrix().makeGrayscale().createFilter() ];
        }
    }

    protected function showRoundTimer (show :Boolean, remainingTime :Number = 0) :void
    {
        var roundTimer :MovieClip = _panelMovie["round_timer"];
        roundTimer.visible = show;

        if (show && remainingTime > 0 && !_showedRoundTimer) {
            var elapsedTime :Number = Constants.GAME_TIME - remainingTime;
            var curFrame :int = (roundTimer.totalFrames * (elapsedTime / Constants.GAME_TIME)) + 1;
            curFrame = Math.min(curFrame, roundTimer.totalFrames);

            roundTimer.gotoAndStop(curFrame);

            log.info("showRoundTimer", "time", remainingTime, "curFrame", curFrame);

            var obj :SimObject = new SimObject();
            obj.addTask(new ShowFramesTask(roundTimer, curFrame, -1, remainingTime));
            addObject(obj);

            _showedRoundTimer = true;
        }
    }

    protected function updateButtonsAndStatus () :void
    {
        var statusText :String;
        if (this.isWaitingForNextRound) {
            _startButton.visible = false;
            statusText = "You will join when the current feeding ends.";

        } else if (ClientCtx.preyId == Constants.NULL_PLAYER && !ClientCtx.preyIsAi) {
            _startButton.visible = false;
            statusText = "Your Feast has wandered off.";

        } else if (ClientCtx.isLobbyLeader) {
            _startButton.visible = true;

        } else {
            _startButton.visible = false;
            var leaderName :String = ClientCtx.getPlayerName(ClientCtx.lobbyLeaderId);
            if (ClientCtx.playerIds.length == 1) {
                statusText = "All Feeders have left.";
            } else if (this.isPreGameLobby) {
                statusText = "Waiting for " + leaderName + " to start feeding.";
            } else {
                statusText = "Waiting for " + leaderName + " to feed again.";
            }

            TextFieldUtil.setMaximumTextWidth(_tfStatus, _tfStatus.width);
        }

        if (!this.isPreGameLobby && this.isBloodBondForming) {
            var partnerId :int = (ClientCtx.playerIds[0] != ClientCtx.localPlayerId ?
                                  ClientCtx.playerIds[0] :
                                  ClientCtx.playerIds[1]);
            var partnerName :String = ClientCtx.getPlayerName(partnerId);

            if (ClientCtx.bloodBondProgress >= VConstants.FEEDING_ROUNDS_TO_FORM_BLOODBOND) {
                if (statusText == null) {
                    statusText = "You and " + partnerName + " have forged a Blood Bond!";
                } else {
                    statusText = "You and " + partnerName + " have forged a Blood Bond!" +
                                 "\nWaiting to feed again.";
                }

            } else {
                var diff :int =
                    VConstants.FEEDING_ROUNDS_TO_FORM_BLOODBOND - ClientCtx.bloodBondProgress;
                var diffString :String = NUMBERS[diff];
                var feedingString :String = (diff == 1 ? "feeding" : "feedings");

                if (statusText == null) {
                    statusText = diffString + " more " + feedingString + " will forge a " +
                                 "Blood Bond with " + partnerName + ".";
                } else {
                    statusText += "\n" + diffString + " more will forge a Blood Bond.";
                }
            }
        }

        if (statusText != null) {
            _tfStatus.text = statusText;
            _tfStatus.visible = true;
        } else {
            _tfStatus.visible = false;
        }
    }

    protected function updatePlayerList () :void
    {
        var listData :Array = [];
        var obj :Object;
        var playerId :int;

        var contents :MovieClip = _panelMovie["draggable"];

        // Fill in the Prey data
        var preyInfo :MovieClip = contents["playerprey"];
        var tfName :TextField = preyInfo["player_name"];
        if (ClientCtx.preyIsAi || ClientCtx.isPlayer(ClientCtx.preyId)) {
            tfName.visible = true;
            tfName.text = (ClientCtx.preyIsAi ?
                            ClientCtx.aiPreyName :
                            ClientCtx.getPlayerName(ClientCtx.preyId));
        } else {
            tfName.visible = false;
        }

        var tfScore :TextField = preyInfo["player_score"];
        if (tfName.visible && this.isPostRoundLobby && !ClientCtx.preyIsAi) {
            tfScore.visible = true;
            tfScore.text = String(int(_results.scores.get(ClientCtx.preyId)));
        } else {
            tfScore.visible = false;
        }

        // Fill in the Predators list
        if (this.isPostRoundLobby) {
            _results.scores.forEach(
                function (playerId :int, score :int) :void {
                    if (playerId != ClientCtx.preyId && ClientCtx.isPlayer(playerId)) {
                        obj = {};
                        obj["player_name"] = ClientCtx.getPlayerName(playerId);
                        obj["player_score"] = score;
                        listData.push(obj);
                    }
                });

            // Anyone who joined the game while the round was in progress doesn't have a score
            for each (playerId in ClientCtx.playerIds) {
                if (playerId != ClientCtx.preyId && !_results.scores.containsKey(playerId)) {
                    obj = {};
                    obj["player_name"] = ClientCtx.getPlayerName(playerId);
                    listData.push(obj);
                }
            }

        } else {
            for each (playerId in ClientCtx.playerIds) {
                if (playerId != ClientCtx.preyId) {
                    obj = {};
                    obj["player_name"] = ClientCtx.getPlayerName(playerId);
                    listData.push(obj);
                }
            }
        }

        _playerList.data = listData;
    }

    protected function updateBloodBondIndicator () :void
    {
        var bloodBond :MovieClip = _panelMovie["blood_bond"];
        bloodBond.visible = false;
        if (this.isBloodBondForming && ClientCtx.bloodBondProgress > 0) {
            bloodBond.visible = true;
            bloodBond.gotoAndStop(1 +
                Math.min(ClientCtx.bloodBondProgress, VConstants.FEEDING_ROUNDS_TO_FORM_BLOODBOND));
        }
    }

    protected function get isBloodBondForming () :Boolean
    {
        return (this.isLobby && ClientCtx.playerIds.length == 2 && !ClientCtx.preyIsAi);
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == Props.ALL_PLAYERS) {
            updateButtonsAndStatus();
            updatePlayerList();
            updateBloodBondIndicator();
        } else if (e.name == Props.BLOOD_BOND_PROGRESS) {
            updateBloodBondIndicator();
        } else if (e.name == Props.LOBBY_LEADER || e.name == Props.PREY_ID) {
            updateButtonsAndStatus();
        }
    }

    protected function onMsgReceived (e :ClientMsgEvent) :void
    {
        if (this.isWaitingForNextRound && e.msg is RoundTimeLeftMsg) {
            showRoundTimer(true, RoundTimeLeftMsg(e.msg).seconds);
        }
    }

    protected function get isPostRoundLobby () :Boolean
    {
        return (_type == LOBBY && _results != null);
    }

    protected function get isPreGameLobby () :Boolean
    {
        return (_type == LOBBY && _results == null);
    }

    protected function get isLobby () :Boolean
    {
        return (_type == LOBBY);
    }

    protected function get isWaitingForNextRound () :Boolean
    {
        return (_type == WAIT_FOR_NEXT_ROUND);
    }

    protected var _panelMovie :MovieClip;
    protected var _startButton :SimpleButton;
    protected var _tfStatus :TextField;
    protected var _playerList :SimpleListController;

    protected var _type :int;
    protected var _results :RoundOverMsg;
    protected var _showedRoundTimer :Boolean;

    protected static const NUMBERS :Array = [
        "Zero", "One", "Two", "Three", "Four", "Five", "Six"
    ];

    protected static const log :Log = Log.getLog(LobbyMode);
}

}
