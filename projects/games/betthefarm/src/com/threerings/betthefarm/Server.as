//
// $Id$

package com.threerings.betthefarm {

import flash.utils.setTimeout;
import flash.utils.clearTimeout;

import com.whirled.WhirledGameControl;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.PropertyChangedEvent;

import com.threerings.util.Map;
import com.threerings.util.HashMap;

public class Server
{
    public function debug (str :String) :void
    {
        if (BetTheFarm.DEBUG) {
            trace(str);
            _control.localChat(str);
        }
    }

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
        if (_model.getRoundType() == Model.ROUND_INTRO) {
            _roundTimeout = setTimeout(doEndRound, _model.getDuration() * 1000);

        } else {
            _roundTimeout = setTimeout(actuallyBeginRound, 4000);
        }
    }

    public function roundDidEnd () :void
    {
        if (_questionTimeout != 0) {
            clearTimeout(_questionTimeout);
        }
    }

    public function shutdown () :void
    {
        if (_questionTimeout != 0) {
            clearTimeout(_questionTimeout);
        }
        if (_roundTimeout != 0) {
            clearTimeout(_roundTimeout);
        }
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
        var value :Object = event.value;

        // if we're between rounds, we ignore absolutely all messages
        if (_control.getRound() < 0) {
            return;
        }

        if (event.name == Model.MSG_ANSWERED) {
            _buzzer = -1;

        } else if (event.name == Model.MSG_BUZZ) {
            if (_buzzer == -1) {
                _buzzer = value.player;
                _control.sendMessage(Model.MSG_BUZZ_CONTROL, value);
            }

        } else if (event.name == Model.MSG_QUESTION_DONE) {
            _model.getQuestions().removeQuestion(_control.get(Model.QUESTION_IX) as int);

            if (_model.getRoundType() == Model.ROUND_LIGHTNING) {
                // in lightning round we automatically move forward
                _questionTimeout = setTimeout(nextQuestion, 1000);

            } else if (_model.getRoundType() == Model.ROUND_BUZZ) {
                // in the buzz round we only do N questions
                if (_questionIx == _model.getDuration()) {
                    _questionTimeout = setTimeout(doEndRound, 1000);

                } else if (!value.winner) {
                    // if there was a winner, that winner will display the category choice UI
                    // otherwise we, as controllers, have to randomly select it here
                    _questionTimeout = setTimeout(chooseRandomCategory, 1000);
                }                

            } else {
                // if this is a wager round, immediately end it
                _questionTimeout = setTimeout(doEndRound, 1000);
            }

        } else if (event.name == Model.MSG_CHOOSE_CATEGORY) {
            nextQuestion(value as String);

        } else if (event.name == Model.MSG_ANSWER_MULTI) {
            if (value.correct) {
                if (_buzzer != -1) {
                    // ignore late-coming correct answers
                    debug("ignoring late-coming correct answer");
                    return;
                }
                _buzzer = value.player;
            }
            questionAnswered(value.player, value.correct, value.wager);

        } else if (event.name == Model.MSG_ANSWER_FREE) {
            if (_buzzer != value.player) {
                debug("ignoring answer from non-buzzed player");
                return;
            }
            questionAnswered(value.player, value.correct, value.wager);
        }
    }

    protected function chooseRandomCategory () :void
    {
        var categories :Array = _model.getQuestions().getCategories();
        var ix :int = BetTheFarm.random.nextInt(categories.length);
        var category :String = categories[ix];
        nextQuestion(category);
    }

    protected function questionAnswered (player :int, correct :Boolean, wager :int) :void
    {
        var question :Question =
            _model.getQuestions().getQuestion(_control.get(Model.QUESTION_IX) as int);

        if (_responses.containsKey(player)) {
            throw new Error("Multiple answers from player: " + player);
        }
        _responses.put(player, true);

        var ix :int = _control.seating.getPlayerPosition(player);
        if (ix == -1) {
            throw new Error("non-seated answer");
        }

        var score :int = _control.get(Model.SCORES, ix) as int;            
        var mod :int;
        if (correct) {
            if (_model.getRoundType() == Model.ROUND_WAGER) {
                if (wager < 0) {
                    // player bet the farm; wins 1x, 2x, 4x or 8x their wager
                    mod = -wager * question.getDifficultyFactor();
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
        _control.set(Model.SCORES, Math.max(score + mod, 0), ix);

        if (correct || _responses.size() >= _playerCount) {
            _control.sendMessage(Model.MSG_QUESTION_DONE, correct ? { winner: player } : { });

        } else {
            _control.sendMessage(Model.MSG_ANSWERED, { player: player, correct: correct });
        }
    }

    protected function doEndRound () :void
    {
        _roundTimeout = 0;
        if (_control.getRound() == Content.ROUND_NAMES.length) {
            _control.endGame( [ ] );

        } else if (_model.getRoundType() == Model.ROUND_INTRO) {
            _control.endRound(0.01);

        } else {
            _control.endRound(3);
        }
    }

    protected function actuallyBeginRound () :void
    {
        if (_model.getRoundType() == Model.ROUND_LIGHTNING) {
            _roundTimeout = setTimeout(doEndRound, _model.getDuration() * 1000);
        }
        _questionIx = 0;
        nextQuestion();
    }

    protected function nextQuestion (category :String = null) :void
    {
        _questionTimeout = 0;
        _buzzer = -1;
        _responses = new HashMap();

        var keys :Array = (category != null) ?
            _model.getQuestions().getCategoryIxSet(category) :
            _model.getQuestions().getQuestionIxSet();
        if (keys.length == 0) {
            doEndRound();
            return;
        }
        _control.set(Model.QUESTION_IX, keys[BetTheFarm.random.nextInt(keys.length)]);
    }


    protected var _control :WhirledGameControl;

    protected var _model :Model;

    protected var _playerCount :int;

    protected var _questionIx :uint;

    protected var _roundTimeout :uint = 0;

    protected var _questionTimeout :uint;

    protected var _responses :Map;

    protected var _buzzer :int;
}
}
