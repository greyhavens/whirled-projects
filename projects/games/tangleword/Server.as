package {

import flash.display.DisplayObject;
import flash.utils.Dictionary;

import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.MessageReceivedEvent;

import com.whirled.contrib.Scoreboard;

public class Server
{
    public static const SUBMIT :String = "Submit";
    public static const READY :String = "Ready";

    public static const COUNTDOWN :String = "Countdown";
    public static const RESTART :String = "Restart";

    public static const SUBMIT_RESULT :String = "SubmitResult";

    protected static const FIRST_FINDS :String = "firstFinds";
    protected static const WORD_NAMESPACE :String = "word:";
    protected static const BONUS_CAP_RATIO :Number = 0.5;

    public function Server ()
    {
        trace("Server starting");

        _gameCtrl = new GameControl(new DisplayObject());

        _scoreboard = new Scoreboard(_gameCtrl);

        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
    }

    protected function gameDidStart (event :StateChangedEvent) :void
    {
        _gameCtrl.services.startTicker(COUNTDOWN, 1000);

        for each (var i :String in _gameCtrl.net.getPropertyNames(WORD_NAMESPACE)) {
            _gameCtrl.net.set(i, null);
        }

        _gameCtrl.net.set(FIRST_FINDS, null);
        _scoreboard.clearAll();
    }

    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        _gameCtrl.services.stopTicker(COUNTDOWN);
        _gameCtrl.services.startTicker(RESTART, 1000);

        _unreadyPlayers = _scoreboard.getPlayerIds();
        trace("Game over: Waiting on " + _unreadyPlayers);
    }

    protected function endGame () :void
    {
        var firsts :Dictionary = _gameCtrl.net.get(FIRST_FINDS) as Dictionary;
        var totalWords :Number = (_gameCtrl.net.getPropertyNames(WORD_NAMESPACE) || []).length;

        var _playerBonuses :Array = [];
        for (var pid :Object in firsts) {
            _playerBonuses[pid] = Math.min(firsts[pid], BONUS_CAP_RATIO*totalWords);
        }

        var playerIds :Array = [];
        var scores :Array = [];
        for each (var playerId :int in _gameCtrl.game.getOccupantIds()) {
            var score :int = _scoreboard.getScore(playerId);

            if (playerId in _playerBonuses) {
                score += _playerBonuses[playerId];
                _scoreboard.setScore(playerId, score);
            }

            if (score > 0) {
                playerIds.push(playerId);
                scores.push(score);
            }
        }

        _gameCtrl.game.endGameWithScores(playerIds, scores, GameSubControl.PROPORTIONAL);
    }

    protected function nextRound () :void
    {
        _gameCtrl.game.restartGameIn(1);
        _gameCtrl.services.stopTicker(RESTART);
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        trace("Server got message: " + event);
        if (event.name == COUNTDOWN) {
            var elapsed :int = int(event.value);
            if (elapsed >= Properties.ROUND_LENGTH) {
                endGame();
            }
        } else if (event.name == RESTART) {
            elapsed = int(event.value);
            if (elapsed >= Properties.PAUSE_LENGTH) {
                nextRound();
            }
        } else if (event.name == READY) {
            var player :int = int(event.value);
            var i :int = _unreadyPlayers.indexOf(player);

            if (i != -1) {
                _unreadyPlayers.splice(i, 1);

                if (_unreadyPlayers.length == 0) {
                    nextRound();
                }
            }
        }
    }

    protected var _scoreboard :Scoreboard;

    protected var _unreadyPlayers :Array;
    protected var _gameCtrl :GameControl;
}

}
