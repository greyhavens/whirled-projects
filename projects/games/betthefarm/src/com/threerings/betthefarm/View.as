//
// $Id$
//
// TODO:
//  - Display a CORRECT / INCORRECT heading on the barn door for either kind of
//    question. When the right answer comes in, display it along with who got it
//    right, and possibly the 'info' field.
//  - Implement the 'category choice' widget.
//  - Implement the entire wager round!

package com.threerings.betthefarm {

import flash.display.Sprite;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import flash.filters.GlowFilter;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import flash.ui.Keyboard;

import flash.utils.Dictionary;
import flash.utils.getTimer;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import com.whirled.WhirledGameControl;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.MessageReceivedEvent;

/**
 * Manages the whole game view and user input.
 */
public class View extends Sprite
{
    public function debug (str :String) :void
    {
        if (BetTheFarm.DEBUG) {
            _control.localChat(str);
        }
    }

    public function View (control :WhirledGameControl, model :Model)
    {
        _control = control;
        _model = model;
        _model.setView(this);

        // listen for property changed and message events
        _control.addEventListener(PropertyChangedEvent.TYPE, propertyChanged);
        _control.addEventListener(MessageReceivedEvent.TYPE, messageReceived);

        var background :DisplayObject = new Content.BACKGROUND();
        addChild(background);

        if (_control.isConnected()) {
            _playing = _control.seating.getMyPosition() != -1;

            addQuestionArea();
            if (_playing) {
                addAnswerArea();
            }
            addRoundArea();
//        addDebugFrames();

            _endTime = 0;

            debug("View created [playing=" + _playing + "]");
        }
    }

    public function gameDidStart () :void
    {
        var players :Array = _control.seating.getPlayerIds();
        debug("Players: " + players);
        _headshots = new Dictionary();
        for (var ii :int = 0; ii < players.length; ii ++) {
            requestHeadshot(players[ii], ii);
        }
        setInterval(updateTimer, 100);
        debug("Game started.");
    }

    public function gameDidEnd () :void
    {
        debug("Game ended!");
    }

    public function roundDidStart () :void
    {
        debug("Beginning round: " + _control.getRound());
        _roundText.text = Content.ROUND_NAMES[_control.getRound()-1];
        var duration :int = Content.ROUND_DURATIONS[_control.getRound()-1];
        if (duration > 0) {
            _endTime = getTimer()/1000 + duration;
        } else {
            _endTime = 0;
        }
    }

    public function roundDidEnd () :void
    {
        _questionArea.visible = false;
        _answerArea.visible = true;
        _answerText.text = "ROUND OVER"; // TODO
        _winnerText.text = "";
    }

    /**
     * Called when our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        debug("Property change: " + event);
        if (event.name == Model.QUESTION_IX) {
            var question :Question = _model.getCurrentQuestion();
            var ii :int;
            debug("Showing question: " + question.question);

            // reset everything
            _freeArea.visible = false;
            for (ii = 0; ii < 4; ii ++) {
                _multiAnswer[ii].visible = false;
            }
            for each (var shot :Sprite in _headshots) {
                shot.filters = [
                    new GlowFilter(0xFFFFFF, 1, 10, 10)
                ];
             }
            _buzzButton.visible = false;
            _answered = false;

            _answerArea.visible = false;
            _questionArea.visible = true;
            _questionText.text = question.question;

            if (question is MultipleChoice) {
                var answers :Array = (question as MultipleChoice).incorrect.slice();
                var ix : int = int((1 + answers.length) * Math.random());
                answers.splice(ix, 0, (question as MultipleChoice).correct);
                if (answers.length > 4) {
                    throw new Error("Too many answers: " + question.question);
                }
                for (ii = 0; ii < answers.length; ii ++) {
                    _multiAnswer[ii].text = answers[ii];
                    _multiAnswer[ii].visible = true;
                }
            } else {
                _buzzButton.visible = true;
            }
        }
    }

    /**
     * Called when a message comes in.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        var value :Object = event.value;

        if (event.name == Model.MSG_QUESTION_DONE) {
            _questionArea.visible = false;
            _answerArea.visible = true;
            if (value.winner == _control.getMyId()) {
                _answerText.text = "CORRECT!";
            } else if (_answered) {
                _answerText.text = "INCORRECT!";
            } else {
                // show anything if we didn't answer?
            }

            if (value.winner > 0) {
                _winnerText.text =
                    "The correct answer was given by " +
                    _control.getOccupantName(value.player) + ":\n\n" +
                    "\"" + _model.getCurrentQuestion().getCorrectAnswer() + "\"";
            } else {
                _winnerText.text =
                    "The correct answer was:\n\n" +
                    "\"" + _model.getCurrentQuestion().getCorrectAnswer() + "\"";
            }

            if (_model.getCurrentRoundType() == Model.ROUND_BUZZ) {
                setTimeout(chooseCategory, 1000);
            }

        } else if (event.name == Model.MSG_ANSWERED) {
            _headshots[value.player].filters = [
                new GlowFilter(value.correct ? 0x00FF00 : 0xFF0000, 1, 10, 10)
            ];

        } else if (event.name == Model.MSG_BUZZ_CONTROL) {
            _headshots[value.player].filters = [
                new GlowFilter(0xFF00FF, 1, 10, 10)
            ];
            if (value.player == _control.getMyId()) {
                // our buzz won!
                _freeArea.visible = true;
                stage.focus = _freeField;
            }
        }
    }

    protected function requestHeadshot (oid :int, ii :int) :void
    {
        var callback :Function = function (headshot :DisplayObject, success :Boolean) :void {
            var scale :Number = Math.min(90/headshot.width, 90/headshot.height);
            headshot.scaleX = headshot.scaleY = scale;
            headshot.x = (Content.HEADSHOT_LOCS[ii] as Point).x - headshot.width/2;
            headshot.y = (Content.HEADSHOT_LOCS[ii] as Point).y - headshot.height/2;
            addChild(headshot);
            debug("Setting headshot for OID " + oid);
            _headshots[oid] = headshot;
            headshot.filters = [
                new GlowFilter(0xFFFFFF, 1, 10, 10)
            ]
        };
        _control.getHeadShot(oid, callback);
    }

    protected function addQuestionArea () :void
    {
        _questionArea = new Sprite();
        _questionArea.x = Content.QUESTION_RECT.left;
        _questionArea.y = Content.QUESTION_RECT.top;
        _questionArea.visible = false;

        var format :TextFormat = new TextFormat();
        format.size = 16;
        format.font = Content.FONT_NAME;
        format.color = Content.FONT_COLOR;

        _questionText = new TextField();
        _questionText.width = Content.QUESTION_RECT.width ;
        _questionText.height = Content.QUESTION_RECT.height;
        _questionText.autoSize = TextFieldAutoSize.NONE;
        _questionText.wordWrap = true;
        _questionText.defaultTextFormat = format;

        _questionArea.addChild(_questionText);

        _multiAnswer = new Array();
        for (var ii :int = 0; ii < 4; ii ++) {
            _multiAnswer[ii] = new TextField();
            _multiAnswer[ii].x = Content.ANSWER_RECTS[ii].left;
            _multiAnswer[ii].y = Content.ANSWER_RECTS[ii].top;
            _multiAnswer[ii].width = Content.ANSWER_RECTS[ii].width;
            _multiAnswer[ii].height = Content.ANSWER_RECTS[ii].height;
            _multiAnswer[ii].autoSize = TextFieldAutoSize.NONE;
            _multiAnswer[ii].wordWrap = true;
            _multiAnswer[ii].defaultTextFormat = format;
            if (_playing) {
                _multiAnswer[ii].addEventListener(MouseEvent.CLICK, multiAnswerClick);
            }

            _questionArea.addChild(_multiAnswer[ii]);
        }

        if (_playing) {
            _buzzButton = new Sprite();
            _buzzButton.x = Content.BUZZBUTTON_RECT.x;
            _buzzButton.y = Content.BUZZBUTTON_RECT.y;
            _buzzButton.graphics.beginFill(0xcc2020);
            _buzzButton.graphics.drawRect(
                0, 0, Content.BUZZBUTTON_RECT.width, Content.BUZZBUTTON_RECT.height);
            _buzzButton.addEventListener(MouseEvent.CLICK, buzzClick);

            format = new TextFormat();
            format.size = 24;
            format.font = Content.FONT_NAME;
            format.color = Content.FONT_COLOR;

            var buzzText :TextField = new TextField();
            buzzText.autoSize = TextFieldAutoSize.CENTER;
            buzzText.wordWrap = false;
            buzzText.text = "BUZZ!";
            buzzText.y = (_buzzButton.height - buzzText.height)/2;
            _buzzButton.addChild(buzzText);

            _questionArea.addChild(_buzzButton);

            _freeArea = new Sprite();
            _freeArea.x = Content.FREE_RESPONSE_RECT.left;
            _freeArea.y = Content.FREE_RESPONSE_RECT.top;
            _freeArea.graphics.drawRect(
                0, 0, Content.FREE_RESPONSE_RECT.width, Content.FREE_RESPONSE_RECT.height);
            _freeArea.width = Content.FREE_RESPONSE_RECT.width;
            _freeArea.height = Content.FREE_RESPONSE_RECT.height;

            var freeText :TextField = new TextField();
            freeText.autoSize = TextFieldAutoSize.CENTER;
            freeText.wordWrap = false;
            freeText.text = "Enter your answer here:";
            _freeArea.addChild(freeText);

            _freeField = new TextField();
            _freeField.x = 10;
            _freeField.y = freeText.height + 5;
            _freeField.width = Content.FREE_RESPONSE_RECT.width - 20;
            _freeField.height = 40;
            _freeField.border = true;
            _freeField.borderColor = 0x000000;
            _freeField.type = TextFieldType.INPUT;
            _freeField.addEventListener(KeyboardEvent.KEY_DOWN, freeInput);
            _freeArea.addChild(_freeField);

            _questionArea.addChild(_freeArea);
        }

        addChild(_questionArea);
    }

    protected function chooseCategory () :void
    {
        var categories :Array = _model.getMultiCategories();
        var category :String = categories[BetTheFarm.random.nextInt(categories.length)];
        _control.sendMessage(
            Model.MSG_CHOOSE_CATEGORY, { player: _control.getMyId(), category: category });
    }

    protected function addAnswerArea () :void
    {
        _answerArea = new Sprite();
        _answerArea.x = Content.ANSWER_RECT.left;
        _answerArea.y = Content.ANSWER_RECT.top;
        _answerArea.visible = false;

        var format :TextFormat = new TextFormat();
        format.size = 36;
        format.font = Content.FONT_NAME;
        format.color = Content.FONT_COLOR;

        _answerText = new TextField();
        _answerText.width = Content.ANSWER_RECT.width;
        _answerText.height = Content.ANSWER_RECT.height;
        _answerText.autoSize = TextFieldAutoSize.CENTER;
        _answerText.wordWrap = false;
        _answerText.defaultTextFormat = format;
        _answerArea.addChild(_answerText);

        format = new TextFormat();
        format.size = 18;
        format.font = Content.FONT_NAME;
        format.color = Content.FONT_COLOR;

        _winnerText = new TextField();
        _winnerText.y = _answerText.y + 60;
        _winnerText.width = Content.ANSWER_RECT.width;
        _winnerText.height = Content.ANSWER_RECT.height;
        _winnerText.autoSize = TextFieldAutoSize.CENTER;
        _winnerText.wordWrap = false;
        _winnerText.defaultTextFormat = format;
        _answerArea.addChild(_winnerText);


        addChild(_answerArea);
    }

    protected function addRoundArea () :void
    {
        _roundText = new TextField();
        _roundText.x = Content.ROUND_RECT.left;
        _roundText.y = Content.ROUND_RECT.top;
        _roundText.width = Content.ROUND_RECT.width ;
        _roundText.height = Content.ROUND_RECT.height;
        _roundText.autoSize = TextFieldAutoSize.NONE;
        _roundText.wordWrap = false;

        var format :TextFormat = new TextFormat();
        format.size = 20;
        format.align = TextFormatAlign.CENTER;
        format.font = Content.FONT_NAME;
        format.color = Content.FONT_COLOR;
        _roundText.defaultTextFormat = format;

        addChild(_roundText);
    }

    protected function addDebugFrames () :void
    {
        addFrame(Content.QUESTION_RECT);
        addFrame(Content.ROUND_RECT);
        for (var ii :int = 0; ii < 4; ii ++) {
            addFrame(Content.ANSWER_RECTS[ii], _questionArea);
        }
    }

    protected function addFrame (rect :Rectangle, to :DisplayObjectContainer = null) :void
    {
        var bit :Sprite = new Sprite();
        bit.graphics.lineStyle(2, 0xFF0000);
        bit.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
        (to != null ? to : this).addChild(bit);
    }

    protected function multiAnswerClick (event :MouseEvent) :void
    {
        if (_answered) {
            // ignore multiple clicks
            return;
        }
        var field :TextField = event.target as TextField;
        _answered = true;
        var correct :Boolean =
            (field.text.toLowerCase() ==
             (_model.getCurrentQuestion() as MultipleChoice).correct.toLowerCase());
        _control.sendMessage(
            Model.MSG_ANSWER_MULTI, { player: _control.getMyId(), correct: correct });
    }

    protected function buzzClick (event :MouseEvent) :void
    {
        _control.sendMessage(Model.MSG_BUZZ, { player: _control.getMyId() });
    }

    protected function freeInput (event :KeyboardEvent) :void
    {
        if (event.keyCode != Keyboard.ENTER) {
            return;
        }
        _answered = true;
        _freeField.text = "";

        var answer :String = _freeField.text.toLowerCase();
        var answers :Array = (_model.getCurrentQuestion() as FreeResponse).correct;
        var correct :Boolean = false;
        for (var ii :int = 0; ii < answers.length; ii ++) {
            if (answers[ii].toLowerCase() == answer) {
                _control.sendMessage(
                    Model.MSG_ANSWER_FREE, { player: _control.getMyId(), correct: true });
                return;
            }
        }
        _control.sendMessage(
            Model.MSG_ANSWER_FREE, { player: _control.getMyId(), correct: false });
    }

    protected function updateTimer () :void
    {
        if (_endTime == 0) {
            return;
        }
        var timer :int = getTimer()/1000;
        if (timer < _endTime) {
            _roundText.text = Content.ROUND_NAMES[_control.getRound()-1] + 
                " (" + (_endTime - timer) + ")";
            return;
        }
        _roundText.text = "";
        _endTime = 0;
        if (_control.amInControl()) {
            _control.endRound(3);
        }
    }

    protected var _control :WhirledGameControl;
    protected var _model :Model;

    protected var _playing :Boolean;
    protected var _answered :Boolean;

    protected var _endTime :int;

    protected var _headshots :Dictionary;

    protected var _questionArea :Sprite;
    protected var _questionText :TextField;

    protected var _answerArea :Sprite;
    protected var _answerText :TextField;
    protected var _winnerText :TextField;

    protected var _roundText :TextField;

    protected var _buzzButton :Sprite;

    protected var _freeArea :Sprite;
    protected var _freeField :TextField;

    protected var _multiAnswer :Array;
}
}
