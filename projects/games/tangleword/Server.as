package {

import flash.display.DisplayObject;
import flash.utils.Dictionary;

import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.StateChangedEvent;

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
    public static const BONUS :String = "Bonus";

    public static const SCOREBOARD :String = "Scores";

    protected static const WORD_NAMESPACE :String = "word:";
    protected static const BONUS_CAP_RATIO :Number = 0.5;

    public function Server ()
    {
        trace("Server starting");

        _gameCtrl = new GameControl(new DisplayObject());

        _model = new Model(_gameCtrl);
        _scoreboard = new Scoreboard(_gameCtrl, SCOREBOARD);

        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);
        _gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
    }

    protected function gameDidStart (event :StateChangedEvent) :void
    {
        _gameCtrl.services.startTicker(COUNTDOWN, 1000);

        for each (var i :String in _gameCtrl.net.getPropertyNames(WORD_NAMESPACE)) {
            _gameCtrl.net.set(i, null);
        }

        _firsts = [];
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
        var totalWords :Number = (_gameCtrl.net.getPropertyNames(WORD_NAMESPACE) || []).length;

        var playerBonuses :Array = [];
        for (var pid :Object in _firsts) {
            playerBonuses[pid] = Math.min(_firsts[pid], BONUS_CAP_RATIO*totalWords);
            _gameCtrl.net.sendMessage(BONUS, playerBonuses[pid], pid as int);
        }

        var playerIds :Array = [];
        var scores :Array = [];
        for each (var playerId :int in _gameCtrl.game.getOccupantIds()) {
            var score :int = _scoreboard.getScore(playerId);

            if (playerId in playerBonuses) {
                score += playerBonuses[playerId];
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
            var score :Number = _model.getWordScore(word);

            if (first) {
                _firsts[playerId] = (_firsts[playerId] != null ? _firsts[playerId] : 0) + 1;
            }

            result = RESULT_SUCCESS;
            param = {
                word: word,
                first: first,
                points: points,
                score: score
            };

            addWord(playerId, word, score);

            trace(word + ": "+_gameCtrl.net.get(WORD_NAMESPACE+word));

        } else {
            result = RESULT_DUPLICATE;
        }

        _gameCtrl.net.sendMessage(result, param, playerId);
    }

    protected function handleReady (playerId :int) :void
    {
        trace("Handling ready for " +playerId);
        var i :int = _unreadyPlayers.indexOf(playerId);

        if (i != -1) {
            _unreadyPlayers.splice(i, 1);

            if (_unreadyPlayers.length == 0) {
                nextRound();
            }
        }
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

    protected function occupantLeft (event :OccupantChangedEvent) :void
    {
        // If the player leaves, mark them as ready for the next round
        handleReady(event.occupantId);
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == SUBMIT) {
            var points :Array = _model.validate(event.value as String);
            var success :Function = function (word :String, isvalid :Boolean) :void {
                handleWordSubmit(event.senderId, word, points, isvalid);
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
            handleReady(int(event.value));
        }
    }

    protected var _scoreboard :Scoreboard;
    protected var _model :Model;

    protected var _unreadyPlayers :Array;
    protected var _firsts :Array;

    protected var _gameCtrl :GameControl;
}

}
