//
// $Id$

package com.threerings.betthefarm {

import flash.utils.setTimeout;

import com.whirled.WhirledGameControl;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.PropertyChangedEvent;

import com.threerings.util.Map;
import com.threerings.util.HashMap;

public class Model
{
    public static const QUESTION_IX :String = "qix";

    public static const ROUND_LIGHTNING :int = 1;
    public static const ROUND_BUZZ :int = 2;
    public static const ROUND_WAGER :int = 3;

    public static const MSG_ANSWER_MULTI :String = "answerMulti";
    public static const MSG_ANSWER_FREE :String = "answerFree";
    public static const MSG_ANSWERED :String = "answered";
    public static const MSG_BUZZ :String = "buzz";
    public static const MSG_BUZZ_CONTROL :String = "buzzControl";
    public static const MSG_QUESTION_DONE :String = "questionDone";

    public function Model (control :WhirledGameControl)
    {
        _control = control;

        // listen for property changed and message events
        _control.addEventListener(PropertyChangedEvent.TYPE, propertyChanged);
        _control.addEventListener(MessageReceivedEvent.TYPE, messageReceived);
    }

    public function setView (view :View) :void
    {
        _view = view;
    }

    public function gameDidStart () :void
    {
        _control.localChat("Setting up questions...");

        _multiQuestions = new Array();
        _multiCategories = new Object();
        var list :XMLList = MultipleChoice.QUESTIONS.MultipleChoice;
        for each (var item :XML in list) {
            var question :Question = new MultipleChoice(
                item.Category,
                Question.EASY,
                item.Question,
                item.Correct,
                toArray(item.Incorrect));
            _multiQuestions.push(question);
            var arr :Array = _multiCategories[question.category.toLowerCase()];
            if (!arr) {
                arr = _multiCategories[question.category.toLowerCase()] = new Array();
            }
            arr.push(question);
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
            _freeQuestions.push(question);
            arr = _freeCategories[question.category.toLowerCase()];
            if (!arr) {
                arr = _freeCategories[question.category.toLowerCase()] = new Array();
            }
            arr.push(question);
        }

        _playerCount = _control.seating.getPlayerIds().length;
    }

    public function gameDidEnd () :void
    {
    }

    public function roundDidStart () :void
    {
        if (_control.amInControl()) {
            _control.set(Model.QUESTION_IX, 0);
            _responses = new HashMap();
            _buzzer = -1;
        }
    }

    public function roundDidEnd () :void
    {
        if (_control.getRound() >= Content.ROUND_NAMES.length) {
            _control.endGame( [ ] );
        }
    }

    public function getCurrentRoundType () :int
    {
        return Content.ROUND_TYPES[_control.getRound()-1];
    }

    public function getQuestionArray () :Array
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
        return getQuestionArray()[_control.get(Model.QUESTION_IX) as int];
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
            setTimeout(nextQuestion, 1000);

        } else if (event.name == Model.MSG_ANSWER_MULTI) {
            if (_responses.get(value.player)) {
                throw new Error("Multiple answers from player: " + value.player);
            }
            if (value.correct) {
                if (_buzzer != -1) {
                    // ignore late-coming correct answers
                    _control.localChat("ignoring late-coming correct answer");
                    return;
                }
                _buzzer = value.player;
            }
            _responses.put(value.player, true);
            _control.sendMessage(Model.MSG_ANSWERED, value);
            _control.localChat("response size: " + _responses.size() + "/" + _playerCount);
            if (_responses.size() >= _playerCount) {
                _control.sendMessage(Model.MSG_QUESTION_DONE, { });
            }
            
        } else if (event.name == Model.MSG_ANSWER_FREE) {
            if (_buzzer != value.player) {
                _control.localChat("ignoring answer from non-buzzed player");
                return;
            }
            if (_responses[value.player]) {
                throw new Error("Multiple answers from player: " + value.player);
            }
            _responses[value.player] = true;
            _control.sendMessage(Model.MSG_ANSWERED, value);
        }
    }

    protected function nextQuestion () :void
    {
        if (_control.amInControl()) {
            _buzzer = -1;
            _responses = new HashMap();
            var nextIx :int = _control.get(Model.QUESTION_IX) + 1;
            if (nextIx >= getQuestionArray().length) {
                _control.endRound(3);
                return;
            }
            _control.set(Model.QUESTION_IX, nextIx);
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

    protected var _responses :Map;

    protected var _control :WhirledGameControl;
    protected var _view :View;

    protected var _buzzer :int;
}
}
