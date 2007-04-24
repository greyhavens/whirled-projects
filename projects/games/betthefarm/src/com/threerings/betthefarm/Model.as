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
                _view.newQuestion(getQuestions().getQuestion(event.newValue as int),
                                  _questionCount);
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

        if (event.name == Model.MSG_ANSWERED) {
            _view.questionAnswered(value.player, value.correct);

        } else if (event.name == Model.MSG_BUZZ_CONTROL) {
            _view.gainedBuzzControl(value.player);

        } else if (event.name == Model.MSG_QUESTION_DONE) {
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

    protected var _multiQuestions :QuestionSet;
    protected var _freeQuestions :QuestionSet;

    protected var _questionCount :uint;

    protected var _control :WhirledGameControl;
    protected var _view :View;
}
}
