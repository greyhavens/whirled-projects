package vampire.feeding.client {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

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

        var panelMovie :MovieClip = ClientCtx.instantiateMovieClip("blood", "popup_panel");
        panelMovie.x = 300;
        panelMovie.y = 200;
        _modeSprite.addChild(panelMovie);

        // Instructions
        var instructions0 :MovieClip = panelMovie["instructions_basic"];
        var instructions1 :MovieClip = panelMovie["instructions_multiplayer"];
        instructions0.visible = true;
        instructions1.visible = false;

        // Quit button
        var quitBtn :SimpleButton = panelMovie["button_close"];
        registerOneShotCallback(quitBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.quit(true);
            });

        // Done/Start/Play Again
        var doneButton :SimpleButton = panelMovie["button_done"];
        var startButton :SimpleButton = panelMovie["button_start"];
        var replayButton :SimpleButton = panelMovie["button_again"];
        doneButton.visible = false;
        startButton.visible = false;
        replayButton.visible = false;
        _startButton = (isPostRoundLobby ? replayButton : startButton);
        registerListener(_startButton, MouseEvent.CLICK,
            function (...ignored) :void {
                if (_startButton.visible) {
                    ClientCtx.msgMgr.sendMessage(new CloseLobbyMsg());
                }
            });

        _waitingText = panelMovie["waiting_text"];
        updateButton();

        // Total score
        var total :MovieClip = panelMovie["total"];
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
            panelMovie,
            "player",
            [ "player_name", "player_score" ],
            "arrow_up",
            "arrow_down");
        addObject(_playerList);
        updatePlayerList();
    }

    protected function updateButton () :void
    {
        if (ClientCtx.isLobbyLeader) {
            _startButton.visible = true;
            _waitingText.visible = false;
        } else {
            _startButton.visible = false;
            _waitingText.visible = true;
            _waitingText.text = (ClientCtx.playerIds.length == 1 ?
                "Waiting for a predator!" :
                "The prime predator is waiting...");
        }
    }

    protected function updatePlayerList () :void
    {
        var listData :Array = [];
        var obj :Object;
        var playerId :int;
        if (this.isPostRoundLobby) {
            _results.scores.forEach(
                function (playerId :int, score :int) :void {
                    obj = {};
                    obj["player_name"] = ClientCtx.getPlayerName(playerId);
                    obj["player_score"] = score;
                    listData.push(obj);
                });

            // Anyone who joined the game while the round was in progress has a score of 0
            for each (playerId in ClientCtx.playerIds) {
                if (!_results.scores.containsKey(playerId)) {
                    obj = {};
                    obj["player_name"] = ClientCtx.getPlayerName(playerId);
                    obj["player_score"] = 0;
                    listData.push(obj);
                }
            }

        } else {
            for each (playerId in ClientCtx.playerIds) {
                obj = {};
                obj["player_name"] = ClientCtx.getPlayerName(playerId);
                listData.push(obj);
            }
        }

        _playerList.data = listData;
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == Props.ALL_PLAYERS) {
            updatePlayerList();
        } else if (e.name == Props.LOBBY_LEADER) {
            updateButton();
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

    protected var _startButton :SimpleButton;
    protected var _waitingText :TextField;
    protected var _playerList :SimpleListController;

    protected var _results :RoundOverMsg;
}

}
