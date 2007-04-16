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
        var set :Map;

        _multiQuestions = new HashMap();
        _multiCategories = new Object();
        var list :XMLList = MultipleChoice.QUESTIONS.MultipleChoice;
        for each (item in list) {
            question = new MultipleChoice(
                item.Category,
                Question.EASY,
                item.Question,
                item.Correct,
                toArray(item.Incorrect));
            _multiQuestions.put(question, true);
            set = _multiCategories[question.category.toLowerCase()];
            if (!set) {
                set = _multiCategories[question.category.toLowerCase()] = new HashMap();
            }
            set.put(question, true);
        }

        _freeQuestions = new HashMap();
        _freeCategories = new Object();
        list = FreeResponse.QUESTIONS.FreeResponse;
        for each (item in list) {
            question = new FreeResponse(
                item.Category,
                Question.EASY,
                item.Question,
                toArray(item.Correct));
            _freeQuestions.put(question, true);
            set = _freeCategories[question.category.toLowerCase()];
            if (!set) {
                set = _freeCategories[question.category.toLowerCase()] = new HashMap();
            }
            set.put(question, true);
        }
    }

    public function setView (view :View) :void
    {
        _view = view;
    }

    public function gameDidStart () :void
    {
        _playerCount = _control.seating.getPlayerIds().length;
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

    public function getQuestionSet () :HashMap
    {
        if (getCurrentRoundType() == ROUND_LIGHTNING || getCurrentRoundType() == ROUND_WAGER) {
            return _multiQuestions;
        }
        return _freeQuestions;
    }

    public function getMultiCategories () :Array
    {
        var result :Array = new Array();
        for (var category :String in _multiCategories) {
            result.push(category);
        }
        return result;
    }

    public function getCurrentQuestion () :Question
    {
        var keys :Array = getQuestionSet().keys();
        return keys[_control.get(Model.QUESTION_IX) as int];
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
        if (!_control.amInControl()) {
            return;
        }
        var value :Object = event.value;
        if (event.name == Model.MSG_BUZZ) {
            if (_buzzer == -1) {
                _buzzer = value.player;
                _control.sendMessage(Model.MSG_BUZZ_CONTROL, value);
            }

        } else if (event.name == Model.MSG_QUESTION_DONE) {
            // TODO: Make sure the "current question" is in fact what was answered
            getQuestionSet().remove(getCurrentQuestion());
            if (getCurrentRoundType() == ROUND_LIGHTNING) {
                // in lightning round we automatically move forward
                _questionTimeout = setTimeout(nextQuestion, 1000);
            } else if (getCurrentRoundType() == ROUND_BUZZ) {
                // in the buzz round we only do N questions
                _questionCount -= 1;
                if (_questionCount <= 0) {
                    doEndRound();
                }
                // if there was a winner, that winner will display the category choice UI
                // otherwise we, as controllers, have to randomly select it here
                if (!value.winner) {
                    var categories :Array = getMultiCategories();
                    var category :String = categories[BetTheFarm.random.nextInt(categories.length)];
                    _control.sendMessage(Model.MSG_CHOOSE_CATEGORY, category);
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
            debug("response size: " + _responses.size() + "/" + _playerCount);
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
            var keys :Array;
            if (category == null) {
                keys = getQuestionSet().keys();
            } else {
                var catset :HashMap = _multiCategories[category];
                if (!catset) {
                    throw new Error("unknown category: " + category);
                }
                keys = catset.keys();
            }
            if (keys.length == 0) {
                doEndRound();
                return;
            }
            _control.set(Model.QUESTION_IX, BetTheFarm.random.nextInt(keys.length));
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

    protected var _multiQuestions :HashMap;
    protected var _multiCategories :Object;
    protected var _freeQuestions :HashMap;
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
