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

    public static const RESULT_SUCCESS :String = "ResultSuccess";
    public static const RESULT_UNRECOGNIZED :String = "ResultUnrecognized";
    public static const RESULT_DUPLICATE :String = "ResultDuplicate";

    public static const SCOREBOARD :String = "Scores";

    protected static const FIRST_FINDS :String = "firstFinds";
    protected static const WORD_NAMESPACE :String = "word:";
    protected static const BONUS_CAP_RATIO :Number = 0.5;

    public function Server ()
    {
        trace("Server starting");

        _gameCtrl = new GameControl(new DisplayObject());

        _scoreboard = new Scoreboard(_gameCtrl, SCOREBOARD);

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

    protected function handleWordSubmit (playerId :int, word :String, points :Array, recognized :Boolean) :void
    {
        var result :String;
        var param :Object = word;

        if ( ! recognized) {
            result = RESULT_UNRECOGNIZED;

        } else if ( ! isWordClaimed(playerId, word)) {
            var first :Boolean = (_gameCtrl.net.get(WORD_NAMESPACE+word) == null);

            if (first) {
                var firsts :Dictionary = _gameCtrl.net.get(FIRST_FINDS) as Dictionary;

                if (firsts != null && playerId in firsts) {
                    _gameCtrl.net.setIn(FIRST_FINDS, playerId, firsts[playerId]+1);
                } else {
                    _gameCtrl.net.setIn(FIRST_FINDS, playerId, 1);
                }
            }

            // Broadcast success
            result = RESULT_SUCCESS;
            param = {
                word: word,
                first: first,
                score: 123
            };

            addWord(playerId, word, 123);

        } else {
            result = RESULT_DUPLICATE;
        }

        _gameCtrl.net.sendMessage(result, param, playerId);
        //trace("Player " + playerId + " submitted " + word);
    }

    /** If this word was already claimed by the given player, returns true; otherwise false. */
    public function isWordClaimed (playerId :int, word :String) :Boolean
    {
        var claim :Array = _gameCtrl.net.get(WORD_NAMESPACE+word) as Array || [ ];

        return claim.indexOf(playerId) != -1;
    }

    /** Marks the /word/ as claimed, and adds the /score/ to the player's total. */
    public function addWord (playerId :int, word :String, score :Number) :void
    {
        var claims :Array = _gameCtrl.net.get(WORD_NAMESPACE+word) as Array || [ ];

        if (claims.indexOf(playerId) == -1) {
            claims.push(playerId);
        }
        _gameCtrl.net.set(WORD_NAMESPACE+word, claims);

        _scoreboard.addToScore(playerId, score);
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        trace("Server got message: " + event);
        if (event.name == SUBMIT) {
            // TODO: Validate this word is on the board, correct length...
            var success :Function = function (word :String, isvalid :Boolean) :void {
                handleWordSubmit(event.senderId, word, [], isvalid);
            }
            _gameCtrl.services.checkDictionaryWord(Properties.LOCALE, null, event.value as String, success);
        } else if (event.name == COUNTDOWN) {
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
