package vampire.feeding.client {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.feeding.Constants;
import vampire.feeding.net.CloseLobbyMsg;
import vampire.feeding.net.Props;
import vampire.feeding.net.RoundOverMsg;

public class LobbyMode extends AppMode
{
    public function LobbyMode (roundResults :RoundOverMsg = null) :void
    {
        _results = roundResults;
    }

    override protected function setup () :void
    {
        super.setup();

        registerListener(ClientCtx.props, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        registerListener(ClientCtx.props, ElementChangedEvent.ELEMENT_CHANGED, onPropChanged);

        _panelMovie = ClientCtx.instantiateMovieClip("blood", "popup_panel");
        _panelMovie.x = 300;
        _panelMovie.y = 200;
        _modeSprite.addChild(_panelMovie);

        // Instructions
        var instructions0 :MovieClip = _panelMovie["instructions_basic"];
        var instructions1 :MovieClip = _panelMovie["instructions_multiplayer"];
        var showBasic :Boolean = (this.isPreGameLobby && ClientCtx.playerData.timesPlayed == 0);
        instructions0.visible = showBasic;
        instructions1.visible = !showBasic;

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

        _tfStatus = _panelMovie["feedback_text"];
        updateButtonsAndStatus();

        // Total score
        var total :MovieClip = _panelMovie["total"];
        if (this.isPreGameLobby) {
            total.visible = false;
        } else {
            total.visible = true;
            var tfTotal :TextField = total["player_score"];
            tfTotal.text = String(_results.totalScore);
        }

        // Player list
        _playerList = new SimpleListController(
            [],
            _panelMovie,
            "player",
            [ "player_name", "player_score" ],
            "arrow_up",
            "arrow_down");
        addObject(_playerList);
        updatePlayerList();
    }

    protected function updateButtonsAndStatus () :void
    {
        if (ClientCtx.preyId == Constants.NULL_PLAYER && !ClientCtx.preyIsAi) {
            _startButton.visible = false;
            _tfStatus.visible = true;
            _tfStatus.text = "Your Feast has wandered off";

        } else if (ClientCtx.isLobbyLeader) {
            _startButton.visible = true;
            _tfStatus.visible = false;

        } else {
            _startButton.visible = false;
            _tfStatus.visible = true;
            if (ClientCtx.playerIds.length == 1) {
                _tfStatus.text = "All Feeders have left";
            } else if (this.isPreGameLobby) {
                _tfStatus.text = "Waiting on the Leader to start feeding";
            } else {
                _tfStatus.text = "Waiting on the Leader to feed again";
            }
        }
    }

    protected function updatePlayerList () :void
    {
        var listData :Array = [];
        var obj :Object;
        var playerId :int;

        // Fill in the Prey
        var preyInfo :MovieClip = _panelMovie["playerprey"];
        if (ClientCtx.preyId == Constants.NULL_PLAYER) {
            preyInfo.visible = false;
        } else {
            preyInfo.visible = true;
            var tfName :TextField = preyInfo["player_name"];
            tfName.text = ClientCtx.getPlayerName(ClientCtx.preyId);
            var tfScore :TextField = preyInfo["player_score"];
            if (this.isPostRoundLobby) {
                tfScore.visible = true;
                tfScore.text = String(_results.scores.get(ClientCtx.preyId));
            } else {
                tfScore.visible = false;
            }
        }

        // Fill in the Predators list
        if (this.isPostRoundLobby) {
            _results.scores.forEach(
                function (playerId :int, score :int) :void {
                    if (playerId != ClientCtx.preyId) {
                        obj = {};
                        obj["player_name"] = ClientCtx.getPlayerName(playerId);
                        obj["player_score"] = score;
                        listData.push(obj);
                    }
                });

            // Anyone who joined the game while the round was in progress has a score of 0
            for each (playerId in ClientCtx.playerIds) {
                if (playerId != ClientCtx.preyId && !_results.scores.containsKey(playerId)) {
                    obj = {};
                    obj["player_name"] = ClientCtx.getPlayerName(playerId);
                    obj["player_score"] = 0;
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

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == Props.ALL_PLAYERS) {
            updateButtonsAndStatus();
            updatePlayerList();
        } else if (e.name == Props.LOBBY_LEADER || e.name == Props.PREY_ID) {
            updateButtonsAndStatus();
        }
    }

    protected function get isPostRoundLobby () :Boolean
    {
        return (_results != null);
    }

    protected function get isPreGameLobby () :Boolean
    {
        return (!isPostRoundLobby);
    }

    protected var _panelMovie :MovieClip;
    protected var _startButton :SimpleButton;
    protected var _tfStatus :TextField;
    protected var _playerList :SimpleListController;

    protected var _results :RoundOverMsg;
}

}
