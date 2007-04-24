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

public class Model
{
    public static const ROUND_INTRO :int = 1;
    public static const ROUND_LIGHTNING :int = 2;
    public static const ROUND_BUZZ :int = 3;
    public static const ROUND_WAGER :int = 4;

    public static const QUESTION_IX :String = "qIx";
    public static const SCORES :String = "scores";

    public static const MSG_ANSWER_MULTI :String = "answerMulti";
    public static const MSG_ANSWER_FREE :String = "answerFree";
    public static const MSG_ANSWERED :String = "answered";
    public static const MSG_BUZZ :String = "buzz";
    public static const MSG_BUZZ_CONTROL :String = "buzzControl";
    public static const MSG_QUESTION_DONE :String = "questionDone";
    public static const MSG_CHOOSE_CATEGORY :String = "chooseCategory";

    public function debug (str :String) :void
    {
        if (BetTheFarm.DEBUG) {
            trace(str);
            _control.localChat(str);
        }
    }

    public function Model (control :WhirledGameControl)
    {
        _control = control;

        // listen for property changed and message events
        _control.addEventListener(PropertyChangedEvent.TYPE, propertyChanged);
        _control.addEventListener(MessageReceivedEvent.TYPE, messageReceived);

        var item :XML;

        _multiQuestions = new QuestionSet();
        var list :XMLList = MultipleChoice.QUESTIONS.MultipleChoice;
        for each (item in list) {
            _multiQuestions.addQuestion(new MultipleChoice(
                item.Category,
                Question.EASY,
                item.Question,
                item.Correct,
                toArray(item.Incorrect)));
        }

        _freeQuestions = new QuestionSet();
        list = FreeResponse.QUESTIONS.FreeResponse;
        for each (item in list) {
            _freeQuestions.addQuestion(new FreeResponse(
                item.Category,
                Question.EASY,
                item.Question,
                toArray(item.Correct)));
        }
    }

    public function setView (view :View) :void
    {
        _view = view;
    }

    public function gameDidStart () :void
    {
        var ids :Array = _control.seating.getPlayerIds();
        _playerCount = ids.count;
        for (var ii :int = 0; ii < _playerCount; ii ++) {
            _view.flowUpdated(ids[ii], 0);
        }
        _control.set(Model.SCORES, new Array(_playerCount));
    }

    public function gameDidEnd () :void
    {
    }

    public function roundDidStart () :void
    {
        if (getRoundType() == Model.ROUND_INTRO) {
            if (_control.amInControl()) {
                _roundTimeout = setTimeout(doEndRound, getDuration() * 1000);
            }

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

    public function betweenRounds () :Boolean
    {
        return _control.getRound() < 0;
    }

    public function getRoundType () :int
    {
        if (betweenRounds()) {
            throw new Error("round type requested between rounds");
        }
        return Content.ROUND_TYPES[_control.getRound()-1];
    }

    public function getDuration () :int
    {
        if (betweenRounds()) {
            throw new Error("round duration requested between rounds");
        }
        return Content.ROUND_DURATIONS[_control.getRound()-1];
    }

    public function getQuestions () :QuestionSet
    {
        if (getRoundType() == ROUND_LIGHTNING || getRoundType() == ROUND_WAGER) {
            return _multiQuestions;
        }
        return _freeQuestions;
    }

    /**
     * Called when our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == Model.QUESTION_IX) {
            if (!betweenRounds()) {
                _view.newQuestion(getQuestions().getQuestion(event.newValue as int), _questionIx);
            }

        } else if (event.name == Model.SCORES && event.index != -1) {
            _view.flowUpdated(_control.seating.getPlayerIds()[event.index], event.newValue as int);
        }
    }

    /**
     * Called when a message comes in.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        var value :Object = event.value;

        // if we're between rounds, we ignore absolutely all messages
        if (betweenRounds()) {
            return;
        }

        // first, events relevant to everyone
        if (event.name == Model.MSG_ANSWERED) {
            _view.questionAnswered(value.player, value.correct);

        } else if (event.name == Model.MSG_BUZZ_CONTROL) {
            _view.gainedBuzzControl(value.player);

        } else if (event.name == Model.MSG_QUESTION_DONE) {
            _questionIx += 1;

            _view.questionDone(value.winner);
        }

        if (!_control.amInControl()) {
            return;
        }

        // then, faux-server control
        if (event.name == Model.MSG_ANSWERED) {
            _buzzer = -1;

        } else if (event.name == Model.MSG_BUZZ) {
            if (_buzzer == -1) {
                _buzzer = value.player;
                _control.sendMessage(Model.MSG_BUZZ_CONTROL, value);
            }

        } else if (event.name == Model.MSG_QUESTION_DONE) {
            getQuestions().removeQuestion(_control.get(Model.QUESTION_IX) as int);

            if (getRoundType() == ROUND_LIGHTNING) {
                // in lightning round we automatically move forward
                _questionTimeout = setTimeout(nextQuestion, 1000);

            } else if (getRoundType() == ROUND_BUZZ) {
                // in the buzz round we only do N questions
                if (_questionIx == getDuration()) {
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
        var categories :Array = getQuestions().getCategories();
        var ix :int = BetTheFarm.random.nextInt(categories.length);
        var category :String = categories[ix];
        nextQuestion(category);
    }

    protected function questionAnswered (player :int, correct :Boolean, wager :int) :void
    {
        var question :Question =
            getQuestions().getQuestion(_control.get(Model.QUESTION_IX) as int);

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
            if (getRoundType() == ROUND_WAGER) {
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
            if (getRoundType() == ROUND_WAGER) {
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

        } else if (getRoundType() == Model.ROUND_INTRO) {
            _control.endRound(0.01);

        } else {
            _control.endRound(3);
        }
    }

    protected function actuallyBeginRound () :void
    {
        if (getRoundType() == Model.ROUND_LIGHTNING) {
            _view.beginCountdown();
        }

        if (_control.amInControl()) {
            if (getRoundType() == Model.ROUND_LIGHTNING) {
                _roundTimeout = setTimeout(doEndRound, getDuration() * 1000);
            }
            _questionIx = 0;
            nextQuestion();
        }
    }

    protected function nextQuestion (category :String = null) :void
    {
        if (_control.amInControl()) {
            _questionTimeout = 0;
            _buzzer = -1;
            _responses = new HashMap();

            var keys :Array = (category != null) ?
                getQuestions().getCategoryIxSet(category) : getQuestions().getQuestionIxSet();
            if (keys.length == 0) {
                doEndRound();
                return;
            }
            _control.set(Model.QUESTION_IX, keys[BetTheFarm.random.nextInt(keys.length)]);
        }
    }

    protected function toArray (list :XMLList) :Array
    {
        var result :Array = new Array();
        for each (var item :XML in list) {
            if (item.hasComplexContent()) {
                throw new Error("XML item is not simple.");
            }
            result.push(String(item));
        }
        return result;
    }

    protected var _playerCount :int;

    protected var _multiQuestions :QuestionSet;
    protected var _freeQuestions :QuestionSet;

    protected var _questionIx :uint;
    protected var _roundTimeout :uint = 0;

    protected var _responses :Map;

    protected var _questionTimeout :uint;

    protected var _control :WhirledGameControl;
    protected var _view :View;

    protected var _buzzer :int;
}
}
