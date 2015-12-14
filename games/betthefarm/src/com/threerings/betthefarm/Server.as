//
// $Id$

package com.threerings.betthefarm {

import flash.utils.ByteArray;

import com.whirled.WhirledGameControl;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.PropertyChangedEvent;

import com.threerings.util.Map;
import com.threerings.util.HashMap;

public class Server
{
    public function Server (control :WhirledGameControl, model :Model)
    {
        _control = control;
        _model = model;

        // listen for property changed and message events
        _control.addEventListener(PropertyChangedEvent.TYPE, propertyChanged);
        _control.addEventListener(MessageReceivedEvent.TYPE, messageReceived);

        _playerCount = _control.seating.getPlayerIds().length;
    }

    public function gameDidStart () :void
    {
        _control.set(Model.SCORES, new Array(_control.seating.getPlayerIds()));
    }

    public function gameDidEnd () :void
    {
    }

    public function roundDidStart () :void
    {
        setTimeout(Model.ACT_BEGIN_ROUND, 4);
    }

    public function roundDidEnd () :void
    {
    }

    public function shutdown () :void
    {
    }

    /**
     * Called when our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
    }

    /**
     * Called when a message comes in.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == Model.MSG_TICK) {
            var rndEnd :int = _control.get(Model.ROUND_TIMEOUT) as int;
            if (rndEnd > 0 && rndEnd <= _model.getLastTick()) {
                _control.setImmediate(Model.ROUND_TIMEOUT, -1);
                _control.setImmediate(Model.TIMEOUT, null);
                doEndRound();
                return;
            }
            var timeout :Object = _control.get(Model.TIMEOUT);
            if (timeout && timeout.tick < _model.getLastTick()) {
                _control.setImmediate(Model.TIMEOUT, null);
                handleTimeout(timeout.action, timeout);
            }
            return;
        }
        // if we're between rounds, we ignore all other messages */
        if (_control.getRound() < 0) {
            return;
        }
        handleMessage(event.name, event.value);
    }


    protected function handleTimeout(action :String, data :Object) :void
    {
        if (_model.betweenRounds()) {
            return;
        }
        if (action == Model.ACT_BEGIN_ROUND) {
            if (_model.getRoundType() == Model.ROUND_LIGHTNING) {
                _control.setImmediate(
                    Model.ROUND_TIMEOUT, _model.getLastTick() + _model.getDuration());

            } else {
                _control.setImmediate(Model.ROUND_TIMEOUT, -1);
                if (_model.getRoundType() == Model.ROUND_INTRO) {
                    doEndRound();
                    return;
                }
            }
            nextQuestion();

        } else if (action == Model.ACT_END_ROUND) {
            doEndRound();

        } else if (action == Model.ACT_NEXT_QUESTION) {
            nextQuestion();

        } else if (action == Model.ACT_FAIL_QUESTION) {
            questionAnswered(_control.get(Model.BUZZER) as int, false, 0);

        } else if (action == Model.ACT_AFTER_QUESTION) {
            if (_model.getRoundType() == Model.ROUND_LIGHTNING) {
                // in lightning round we automatically move forward
                nextQuestion();

            } else if (_model.getRoundType() == Model.ROUND_BUZZ) {
                // in the buzz round we only do N questions
                if (_model.getQuestionCount() == _model.getDuration()) {
                    doEndRound();

                } else if (data.winner) {
                    // let the winner choose next category, just set up a timeout
                    setTimeout(Model.ACT_PICK_CATEGORY, 4, { control: data.winner });

                } else {
                    // if there was no winner, we always pick the category
                    doPickCategory();
                }

            } else {
                // if this is a wager round, immediately end it
                doEndRound();
            }

        } else if (action == Model.ACT_END_QUESTION) {
            questionDone();

        } else if (action == Model.ACT_PICK_CATEGORY) {
            doPickCategory();

        } else {
            throw new Error("Unknown timeout action: " + action);
        }
    }

    protected function handleMessage(msg :String, value :Object) :void
    {
        if (msg == Model.MSG_ANSWERED) {
            _control.setImmediate(Model.BUZZER, -1);

        } else if (msg == Model.MSG_BUZZ) {
            if (_control.get(Model.BUZZER) == -1) {
                _control.setImmediate(Model.BUZZER, value.player);
                setTimeout(Model.ACT_FAIL_QUESTION, 10, { control: value.player });
            }

        } else if (msg == Model.MSG_CHOOSE_CATEGORY) {
            nextQuestion(value as String);

        } else if (msg == Model.MSG_ANSWER_MULTI) {
            if (value.correct) {
                if (_control.get(Model.BUZZER) != -1) {
                    // ignore late-coming correct answers
                    trace("ignoring late-coming correct answer");
                    return;
                }
                _control.setImmediate(Model.BUZZER, value.player);
            }
            questionAnswered(value.player, value.correct, value.wager);

        } else if (msg == Model.MSG_ANSWER_FREE) {
            if (_control.get(Model.BUZZER) != value.player) {
                trace("ignoring answer from non-buzzed player");
                return;
            }
            questionAnswered(value.player, value.correct, value.wager);
        }
    }

    protected function setTimeout (action :String, delay :int, data :Object = null) :void
    {
        if (!data) {
            data = new Object();
        }
        data["action"] = action;
        data["tick"] = _model.getLastTick() + delay;
        _control.setImmediate(Model.TIMEOUT, data);
    }

    protected function doEndRound () :void
    {
        if (_control.getRound() == Content.ROUND_NAMES.length) {
            var players :Array = _control.seating.getPlayerIds();
            var winners :Array = [ ];
            var maxScore :int = -1;
            for (var ii :int = 0; ii < players.length; ii ++) {
                var score :int = _control.get(Model.SCORES, ii) as int;
                if (score > maxScore) {
                    maxScore = score;
                    winners = [ players[ii] ];

                } else if (score == maxScore) {
                    // if several people share top score, report them all as winners
                    winners.push(players[ii]);
                }
            }

            _control.endGame(winners);
            return;
        }

        if (_model.getRoundType() == Model.ROUND_INTRO) {
            _control.endRound(1);
            return;
        }

        _control.endRound(3);
    }

    protected function doPickCategory () :void
    {
        var categories :Array = _model.getQuestions().getCategories();
        var ix :int = BetTheFarm.random.nextInt(categories.length);
        var category :String = categories[ix];
        nextQuestion(category);
    }

    protected function questionAnswered (player :int, correct :Boolean, wager :int) :void
    {
        var question :Question = _model.getQuestion();

        var pIx :int = _control.seating.getPlayerPosition(player);
        if (pIx == -1) {
            throw new Error("non-seated answer from: " + player);
        }

        if (_control.get(Model.RESPONSES, pIx)) {
            throw new Error("Multiple answers from player: " + player);
        }
        _control.setImmediate(Model.RESPONSES, true, pIx);

        var score :int = _control.get(Model.SCORES, pIx) as int;            
        var mod :int;
        if (correct) {
            if (_model.getRoundType() == Model.ROUND_WAGER) {
                if (wager < 0) {
                    // player bet the farm; wins 1x, 2x, 4x or 8x their wager
                    mod = score * question.getDifficultyFactor();
                } else if (wager > 0) {
                    // player bet conservatively, just wins bet
                    mod = wager;
                }
            } else {
                // non-wager question, fixed 100 point win
                mod = 100;
            }

        } else {
            if (_model.getRoundType() == Model.ROUND_WAGER) {
                if (wager < 0) {
                    // player bet the farm and lost, alas
                    mod = -score;
                } else if (wager > 0) {
                    // player bet conservatively, just loses bet
                    mod = -wager;
                }
            } else {
                // non-wager question, fixed 50 point loss
                mod = -50;
            }
        }
        _control.set(Model.SCORES, Math.max(score + mod, 0), pIx);

        var done :Boolean = true;
        for (var ii :int = 0; ii < _playerCount; ii ++) {
            done &&= _control.get(Model.RESPONSES, ii);
        }
        _control.sendMessage(Model.MSG_ANSWERED, { player: player, correct: correct });
        if (correct || done) {
            questionDone(correct ? player : -1);
        }
    }

    protected function questionDone (winner :int = -1) :void
    {
        _control.sendMessage(Model.MSG_QUESTION_DONE, winner >= 0 ? { winner: winner } : { });
        _model.getQuestions().removeQuestion(_control.get(Model.QUESTION_IX) as int);
        setTimeout(Model.ACT_AFTER_QUESTION, 2, { winner: winner });
    }

    protected function nextQuestion (category :String = null) :void
    {
        _control.setImmediate(Model.BUZZER, -1);
        _control.setImmediate(Model.RESPONSES, [ ]);

        var keys :Array = (category != null) ?
            _model.getQuestions().getCategoryIxSet(category) :
            _model.getQuestions().getQuestionIxSet();
        if (keys.length == 0) {
            doEndRound();
            return;
        }
        _control.set(Model.QUESTION_IX, keys[BetTheFarm.random.nextInt(keys.length)]);
        // we always begin a timeout here, though it may be extended in buzz rounds
        setTimeout(Model.ACT_END_QUESTION, 10);
    }

    protected var _control :WhirledGameControl;

    protected var _model :Model;

    protected var _playerCount :int;
}
}
