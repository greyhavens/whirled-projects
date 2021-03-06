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
    public static const BUZZER :String = "buzzer";
    public static const RESPONSES :String = "responses";
    public static const SCORES :String = "scores";
    public static const TIMEOUT :String = "timeout";
    public static const ROUND_TIMEOUT :String = "roundTimeout";

    public static const ACT_BEGIN_ROUND :String = "beginRound";
    public static const ACT_END_ROUND :String = "endRound";
    public static const ACT_NEXT_QUESTION :String = "nextQuestion";
    public static const ACT_END_QUESTION :String = "endQuestion";
    public static const ACT_FAIL_QUESTION :String = "failQuestion";
    public static const ACT_AFTER_QUESTION :String = "afterQuestion";
    public static const ACT_PICK_CATEGORY :String = "pickCategory";

    public static const MSG_TICK :String = "tick";
    public static const MSG_ANSWER_MULTI :String = "answerMulti";
    public static const MSG_ANSWER_FREE :String = "answerFree";
    public static const MSG_ANSWERED :String = "answered";
    public static const MSG_BUZZ :String = "buzz";
    public static const MSG_QUESTION_DONE :String = "questionDone";
    public static const MSG_CHOOSE_CATEGORY :String = "chooseCategory";

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
        _lastTick = 0;
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
    }

    public function gameDidEnd () :void
    {
    }

    public function roundDidStart () :void
    {
        _questionCount = 0;
    }

    public function roundDidEnd () :void
    {
    }

    public function shutdown () :void
    {
    }

    public function betweenRounds () :Boolean
    {
        return _control.getRound() < 0;
    }

    public function getLastTick() :int
    {
        return _lastTick;
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

    public function getQuestion () :Question
    {
        return getQuestions().getQuestion(_control.get(QUESTION_IX) as int);
    }

    public function getQuestions () :QuestionSet
    {
        if (getRoundType() == ROUND_LIGHTNING || getRoundType() == ROUND_WAGER) {
            return _multiQuestions;
        }
        return _freeQuestions;
    }

    public function getQuestionCount () :int
    {
        return _questionCount;
    }

    /**
     * Called when our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        var value :Object= event.newValue;
        if (event.name == TIMEOUT) {
            if (value) {
                _view.newTimeout(
                    value.action as String, Math.max(1, value.tick - _lastTick), value);
            }

        } else if (event.name == QUESTION_IX) {
            if (!betweenRounds()) {
                _view.newQuestion(getQuestions().getQuestion(value as int),
                                  _questionCount);
            }

        } else if (event.name == BUZZER && !betweenRounds() && value > 0 &&
                   getRoundType() == ROUND_BUZZ) {
            _view.gainedBuzzControl(value as int);

        } else if (event.name == SCORES && event.index != -1) {
            _view.flowUpdated(_control.seating.getPlayerIds()[event.index], value as int);
        }
    }

    /**
     * Called when a message comes in.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        var value :Object = event.value;

        if (event.name == MSG_TICK) {
            _lastTick = event.value as int;
        }

        // if we're between rounds, we ignore absolutely all messages
        if (betweenRounds()) {
            return;
        }

        if (event.name == MSG_ANSWERED) {
            _view.questionAnswered(value.player, value.correct);

        } else if (event.name == MSG_QUESTION_DONE) {
            _questionCount += 1;
            _view.questionDone(value.winner);
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

    protected var _lastTick :int;

    protected var _multiQuestions :QuestionSet;
    protected var _freeQuestions :QuestionSet;

    protected var _questionCount :uint;

    protected var _control :WhirledGameControl;
    protected var _view :View;
}
}
