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
    public static const ACT_BEGIN_ROUND :String = "beginRound";
    public static const ACT_END_ROUND :String = "endRound";
    public static const ACT_NEXT_QUESTION :String = "nextQuestion";
    public static const ACT_END_QUESTION :String = "endQuestion";
    public static const ACT_FAIL_QUESTION :String = "failQuestion";
    public static const ACT_PICK_CATEGORY :String = "pickCategory";

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
        setTimeout(ACT_BEGIN_ROUND, 4);
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
                handleTimeout(timeout.action);
            }
            return;
        }
        // if we're between rounds, we ignore all other messages */
        if (_control.getRound() < 0) {
            return;
        }
        handleMessage(event.name, event.value);
    }


    protected function handleTimeout(action :String) :void
    {
        if (action == ACT_BEGIN_ROUND) {
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

        } else if (action == ACT_END_ROUND) {
            doEndRound();

        } else if (action == ACT_NEXT_QUESTION) {
            nextQuestion();

        } else if (action == ACT_FAIL_QUESTION) {
            questionAnswered(_control.get(Model.BUZZER) as int, false, 0);

        } else if (action == ACT_END_QUESTION) {
            _control.sendMessage(Model.MSG_QUESTION_DONE, { });

        } else if (action == ACT_PICK_CATEGORY) {
            var categories :Array = _model.getQuestions().getCategories();
            var ix :int = BetTheFarm.random.nextInt(categories.length);
            var category :String = categories[ix];
            nextQuestion(category);

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
                setTimeout(ACT_FAIL_QUESTION, 10);
            }

        } else if (msg == Model.MSG_QUESTION_DONE) {
            _model.getQuestions().removeQuestion(_control.get(Model.QUESTION_IX) as int);

            if (_model.getRoundType() == Model.ROUND_LIGHTNING) {
                // in lightning round we automatically move forward
                setTimeout(ACT_NEXT_QUESTION, 1);

            } else if (_model.getRoundType() == Model.ROUND_BUZZ) {
                // in the buzz round we only do N questions
                if (_model.getQuestionCount() == _model.getDuration()) {
                    setTimeout(ACT_END_ROUND, 1);

                } else if (value.winner) {
                    // let the winner choose next category, just set up a timeout
                    setTimeout(ACT_PICK_CATEGORY, 4);

                } else {
                    // if there was no winner, we always pick the category
                    setTimeout(ACT_PICK_CATEGORY, 1);
                }

            } else {
                // if this is a wager round, immediately end it
                setTimeout(ACT_END_ROUND, 1);
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

    protected function setTimeout (action :String, delay :int) :void
    {
        _control.setImmediate(
            Model.TIMEOUT, { action: action, tick: _model.getLastTick() + delay });
    }

    protected function doEndRound () :void
    {
        if (_control.getRound() == Content.ROUND_NAMES.length) {
            _control.endGame([ ]);
            return;
        }

        if (_model.getRoundType() == Model.ROUND_INTRO) {
            _control.endRound(1);
            return;
        }

        _control.endRound(3);
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
        if (correct || done) {
            _control.sendMessage(Model.MSG_QUESTION_DONE, correct ? { winner: player } : { });

        } else {
            _control.sendMessage(Model.MSG_ANSWERED, { player: player, correct: correct });
        }
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
        setTimeout(ACT_END_QUESTION, 10);
    }


    protected var _control :WhirledGameControl;

    protected var _model :Model;

    protected var _playerCount :int;
}
}
