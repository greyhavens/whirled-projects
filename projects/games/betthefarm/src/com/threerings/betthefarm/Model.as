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
    public static const ROUND_LIGHTNING :int = 1;
    public static const ROUND_BUZZ :int = 2;
    public static const ROUND_WAGER :int = 3;

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

        var question :Question;
        var item :XML;
        var arr :Array;

        _multiQuestions = new Array();
        _multiCategories = new Object();
        var list :XMLList = MultipleChoice.QUESTIONS.MultipleChoice;
        for each (item in list) {
            question = new MultipleChoice(
                item.Category,
                Question.EASY,
                item.Question,
                item.Correct,
                toArray(item.Incorrect));
            arr = _multiCategories[question.category.toLowerCase()];
            if (!arr) {
                arr = _multiCategories[question.category.toLowerCase()] = new Array();
            }
            arr.push(_multiQuestions.length);
            _multiQuestions.push(question);
        }

        _freeQuestions = new Array();
        _freeCategories = new Object();
        list = FreeResponse.QUESTIONS.FreeResponse;
        for each (item in list) {
            question = new FreeResponse(
                item.Category,
                Question.EASY,
                item.Question,
                toArray(item.Correct));
            arr = _freeCategories[question.category.toLowerCase()];
            if (!arr) {
                arr = _freeCategories[question.category.toLowerCase()] = new Array();
            }
            arr.push(_freeQuestions.length);
            _freeQuestions.push(question);
        }
    }

    public function setView (view :View) :void
    {
        _view = view;
    }

    public function gameDidStart () :void
    {
        _playerCount = _control.seating.getPlayerIds().length;
        _control.set(Model.SCORES, new Array(_playerCount));
    }

    public function gameDidEnd () :void
    {
    }

    public function roundDidStart () :void
    {
        if (_control.amInControl()) {
            if (getCurrentRoundType() == Model.ROUND_LIGHTNING) {
                var duration :int = Content.ROUND_DURATIONS[_control.getRound()-1];
                _roundTimeout = setTimeout(doEndRound, duration * 1000);
                _questionCount = 0;
            } else if (getCurrentRoundType() == Model.ROUND_BUZZ) {
                _roundTimeout = 0;
                _questionCount = Content.ROUND_DURATIONS[_control.getRound()-1];
            } else {
                _roundTimeout = _questionCount = 0;
            }
            nextQuestion();
        }
    }

    public function roundDidEnd () :void
    {
        if (_questionTimeout != 0) {
            clearTimeout(_questionTimeout);
        }
        if (_control.getRound() >= Content.ROUND_NAMES.length) {
            _control.endGame( [ ] );
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

    public function getCurrentRoundType () :int
    {
        return Content.ROUND_TYPES[_control.getRound()-1];
    }

    public function getQuestions () :Array
    {
        if (getCurrentRoundType() == ROUND_LIGHTNING || getCurrentRoundType() == ROUND_WAGER) {
            return _multiQuestions;
        }
        return _freeQuestions;
    }

    public function getCategories () :Array
    {
        var questions :Array = getQuestions();
        var map :HashMap = new HashMap();
        for (var ii :int = 0; ii < questions.length; ii ++) {
            map.put(questions[ii].category, true);
        }
        return map.keys();
    }


    /**
     * Called when our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == Model.QUESTION_IX) {
            debug("index: " + (event.newValue as int));
            debug("question set length: " + getQuestions().length);
            debug("question: " + getQuestions()[event.newValue as int]);
            _view.newQuestion(getQuestions()[event.newValue as int]);
        }
    }


    /**
     * Called when a message comes in.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        var value :Object = event.value;

        // first, events relevant to everyone
        if (event.name == Model.MSG_ANSWERED) {
            _view.questionAnswered(value.player, value.correct);

        } else if (event.name == Model.MSG_BUZZ_CONTROL) {
            _view.gainedBuzzControl(value.player);

        } else if (event.name == Model.MSG_QUESTION_DONE) {
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
//            getQuestions().remove(getCurrentQuestion());
            if (getCurrentRoundType() == ROUND_LIGHTNING) {
                // in lightning round we automatically move forward
                _questionTimeout = setTimeout(nextQuestion, 1000);
            } else if (getCurrentRoundType() == ROUND_BUZZ) {
                // in the buzz round we only do N questions
                _questionCount -= 1;
                if (_questionCount <= 0) {
                    _questionTimeout = setTimeout(doEndRound, 1000);
                } else if (!value.winner) {
                    // TODO: need a pause here
                    // if there was a winner, that winner will display the category choice UI
                    // otherwise we, as controllers, have to randomly select it here
                    var categories :Array = getCategories();
                    var ix :int = BetTheFarm.random.nextInt(categories.length);
                    var category :String = categories[ix];
                    debug("categories[" + ix + "] = " + category);
                    nextQuestion(category);
                }                
            }

        } else if (event.name == Model.MSG_CHOOSE_CATEGORY) {
            debug("Choosing category: " + value);
            nextQuestion(value as String);

        } else if (event.name == Model.MSG_ANSWER_MULTI) {
            if (_responses.containsKey(value.player)) {
                throw new Error("Multiple answers from player: " + value.player);
            }
            if (value.correct) {
                if (_buzzer != -1) {
                    // ignore late-coming correct answers
                    debug("ignoring late-coming correct answer");
                    return;
                }
                _buzzer = value.player;
            }
            _responses.put(value.player, true);

            _control.sendMessage(Model.MSG_ANSWERED, value);
            if (_responses.size() >= _playerCount) {
                _control.sendMessage(
                    Model.MSG_QUESTION_DONE, value.correct ? { winner: value.player } : { });
            }

        } else if (event.name == Model.MSG_ANSWER_FREE) {
            if (_buzzer != value.player) {
                debug("ignoring answer from non-buzzed player");
                return;
            }
            if (_responses.containsKey(value.player)) {
                throw new Error("Multiple answers from player: " + value.player);
            }
            _responses.put(value.player, true);

            _control.sendMessage(Model.MSG_ANSWERED, value);
            if (_responses.size() >= _playerCount) {
                _control.sendMessage(
                    Model.MSG_QUESTION_DONE, value.correct ? { winner: value.player } : { });
            }
        }
    }

    protected function doEndRound () :void
    {
        _roundTimeout = 0;
        _control.endRound(3);
    }

    protected function nextQuestion (category :String = null) :void
    {
        if (_control.amInControl()) {
            _questionTimeout = 0;
            _buzzer = -1;
            _responses = new HashMap();

            if (category == null) {
                var arr :Array = getQuestions();
                if (arr.length == 0) {
                    doEndRound();
                    return;
                }
                _control.set(Model.QUESTION_IX, BetTheFarm.random.nextInt(arr.length));
            } else {
                var keys :Array = _freeCategories[category.toLowerCase()];
                if (!keys) {
                    throw new Error("unknown category: " + category);
                }
                var ix :int = BetTheFarm.random.nextInt(keys.length);
                debug("keys[" + ix + "] = " + keys[ix]);
                _control.set(Model.QUESTION_IX, keys[ix]);
            }
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

    protected var _multiQuestions :Array;
    protected var _multiCategories :Object;
    protected var _freeQuestions :Array;
    protected var _freeCategories :Object;

    protected var _questionCount :uint;
    protected var _roundTimeout :uint = 0;

    protected var _responses :Map;

    protected var _questionTimeout :uint;

    protected var _control :WhirledGameControl;
    protected var _view :View;

    protected var _buzzer :int;
}
}
