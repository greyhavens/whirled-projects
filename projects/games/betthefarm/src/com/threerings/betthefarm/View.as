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

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.SimpleButton;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import flash.filters.GlowFilter;

import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import flash.media.Sound;
import flash.media.SoundChannel;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.AntiAliasType;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import flash.ui.Keyboard;

import flash.utils.Dictionary;
import flash.utils.getTimer;
import flash.utils.setInterval;
import flash.utils.clearInterval;
import flash.utils.setTimeout;

import com.whirled.WhirledGameControl;

/**
 * Manages the whole game view and user input.
 */
public class View extends Sprite
{
    public function debug (str :String) :void
    {
        if (BetTheFarm.DEBUG) {
            trace(str);
            _control.localChat(str);
        }
    }

    public function View (control :WhirledGameControl, model :Model)
    {
        _control = control;
        _model = model;
        _model.setView(this);

        var background :DisplayObject = new Content.BACKGROUND();
        addChild(background);

        if (_control.isConnected()) {
            _playing = _control.seating.getMyPosition() != -1;
            _myId = _control.getMyId();

            doorSetup();
            roundSetup();
//        addDebugFrames();

            _endTime = 0;

            debug("View created [playing=" + _playing + "]");
        }
    }

    public function gameDidStart () :void
    {
        var players :Array = _control.seating.getPlayerIds();
        debug("Players: " + players);
        _plaqueTexts = new Dictionary();
        _headshots = new Dictionary();
        for (var ii :int = 0; ii < players.length; ii ++) {
            addPlaque(players[ii], ii);
            requestHeadshot(players[ii], ii);
        }
        _updateTimer = setInterval(updateTimer, 100);
        debug("Game started.");
    }

    public function gameDidEnd () :void
    {
        debug("Game ended!");
    }

    public function roundDidStart () :void
    {
        debug("Beginning round: " + _control.getRound());
        updateRound();

        if (_model.getRoundType() == Model.ROUND_INTRO) {
            showIntro();
            doPlay(_sndGameIntro, true);

        } else {
            doPlay(_sndRoundIntro, false);
        }
    }

    public function beginCountdown () :void
    {
        _endTime = getTimer()/1000 + Content.ROUND_DURATIONS[_control.getRound()-1];
    }

    public function roundDidEnd () :void
    {
        _endTime = 0;
        if (_control.getRound() != -Model.ROUND_INTRO) {
            doorClear();
            doorHeader("Round Over!");
        }

        _question = null;
    }

    public function shutdown () :void
    {
        if (_updateTimer != 0) {
            clearInterval(_updateTimer);
        }
        if (_sndChannel != null) {
            _sndChannel.stop();
        }
    }

    public function newQuestion (question :Question, questionIx :int) :void
    {
        _question = question;
        _myWager = 0;

        for each (var shot :Sprite in _headshots) {
            shot.filters = [
                new GlowFilter(0xFFFFFF, 1, 10, 10)
                ];
        }
        _answered = false;

        updateRound(questionIx);

        if (_model.getRoundType() == Model.ROUND_WAGER) {
            var score :int = _control.get(Model.SCORES, _control.seating.getMyPosition()) as int;
            if (score == 0) {
                // TODO: We have to add a PASS answer.
                _control.sendMessage(Model.MSG_ANSWER_MULTI, { player: _myId, correct: false });

            } else {
                showWagerUI(score);
            }

        } else {
            showAnswerUI();
        }
    }

    protected function showIntro () :void
    {
        doorClear();

        // skip the INTRO round
        var cnt :int = Content.ROUND_NAMES.length - 1;
        var intro :String =
            "This game has " + (cnt > 10 ? cnt : Content.NUMBERS[cnt]) + " rounds:\n\n\n";
        for (var ii :int = 0; ii < cnt; ii ++) {
            intro += Content.ROUND_NAMES[ii] + "\n\n";
        }
        addTextField(intro, _doorArea, 0, 0, Content.QUESTION_RECT.width,
                     Content.QUESTION_RECT.height, false, 18);
    }

    protected function showWagerUI (score :int) :void
    {
        doorClear();
        addTextField(_question.question, _doorArea, 0, 0, Content.QUESTION_RECT.width,
                     Content.QUESTION_RECT.height, true, 14);

        var ii :int = 0;
        if (score > 800) {
            addWagerButton(ii ++, score/8, false);
        }
        if (score > 400) {
            addWagerButton(ii ++, score/4, false);
        }
        if (score > 200) {
            addWagerButton(ii ++, score/2, false);
        }
        addWagerButton(ii ++, score, true);
    }

    protected function addWagerButton (pos :int, score :int, farm :Boolean) :void
    {
        score -= score % 100;

        var button :SimpleButton = addTextButton(
            "Bet: " + (farm ? "The Farm!" : String(score)), _doorArea,
            Content.ANSWER_RECTS[pos].left, Content.ANSWER_RECTS[pos].top,
            Content.ANSWER_RECTS[pos].width, Content.ANSWER_RECTS[pos].height);
        addWagerClickHandler(button, score, farm);
    }

    protected function addWagerClickHandler(
        button :SimpleButton, score :int, farm :Boolean) :void
    {
        button.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _myWager = farm ? score : -score;
            showAnswerUI();
        });
    }

    protected function showAnswerUI () :void
    {
        doorClear();
        addTextField(_question.question, _doorArea, 0, 0, Content.QUESTION_RECT.width,
                     Content.QUESTION_RECT.height, true, 14);

        if (_question is MultipleChoice) {
            var answers :Array = (_question as MultipleChoice).incorrect.slice();
            var ix : int = int((1 + answers.length) * Math.random());
            answers.splice(ix, 0, (_question as MultipleChoice).correct);
            if (answers.length > 4) {
                throw new Error("Too many answers: " + _question.question);
            }
            for (var ii :int = 0; ii < 4; ii ++) {
                var button :SimpleButton = addTextButton(
                    answers[ii], _doorArea, Content.ANSWER_RECTS[ii].left,
                    Content.ANSWER_RECTS[ii].top, Content.ANSWER_RECTS[ii].width,
                    Content.ANSWER_RECTS[ii].height);
                addMultiAnswerClickHandler(button, ii == ix);
                button.enabled = _playing;
            }

        } else {
            if (_playing) {
                var buzzButton :SimpleButton = addTextButton(
                    "Buzz!", _doorArea, Content.BUZZBUTTON_RECT.x, Content.BUZZBUTTON_RECT.y,
                    0, 0, false, 32, 0xDDDDDD, 0xEE4444, 0xFFFFFF);
                buzzButton.addEventListener(MouseEvent.CLICK, buzzClick);

                _freeArea = new Sprite();
                _freeArea.x = Content.FREE_RESPONSE_RECT.left;
                _freeArea.y = Content.FREE_RESPONSE_RECT.top;
                _freeArea.graphics.drawRect(
                    0, 0, Content.FREE_RESPONSE_RECT.width, Content.FREE_RESPONSE_RECT.height);
                _freeArea.width = Content.FREE_RESPONSE_RECT.width;
                _freeArea.height = Content.FREE_RESPONSE_RECT.height;
                _freeArea.visible = false;

                var field :TextField = addTextField(
                     "Enter your answer here:", _freeArea, 10, 0,
                     Content.FREE_RESPONSE_RECT.width - 20, 40);

                _freeField = addTextField(
                     "", _freeArea, 10, 40, Content.FREE_RESPONSE_RECT.width - 20, 40);
                _freeField.border = true;
                _freeField.borderColor = 0x000000;
                _freeField.type = TextFieldType.INPUT;
                _freeField.addEventListener(KeyboardEvent.KEY_DOWN, freeInput);

                _doorArea.addChild(_freeArea);
            }

        }
    }

    public function questionDone (winner :int) :void
    {
        doorClear();

        if (winner == _myId) {
            doorHeader("Correct!");
            _sndCorrect.play();
            if (_model.getRoundType() == Model.ROUND_BUZZ) {
                setTimeout(chooseCategory, 1000);
            }

        } else if (_answered) {
            doorHeader("Incorrect!");
            _sndIncorrect.play();

        } else {
            // show anything if we didn't answer?
        }

        if (winner) {
            doorBody("The correct answer was given by " +
                     _control.getOccupantName(winner) + ":\n\n" +
                     "\"" + _question.getCorrectAnswer() + "\"");
        } else {
            doorBody("The correct answer was:\n\n" +
                     "\"" + _question.getCorrectAnswer() + "\"");
        }
    }

    public function questionAnswered (player :int, correct :Boolean) :void
    {
        _headshots[player].filters = [
            new GlowFilter(correct ? 0x00FF00 : 0xFF0000, 1, 10, 10)
        ];
    }

    public function gainedBuzzControl (player :int) :void
    {
        _headshots[player].filters = [
            new GlowFilter(0xFF00FF, 1, 10, 10)
        ];
        if (player == _myId) {
            // our buzz won!
            _freeArea.visible = true;
            stage.focus = _freeField;
        }
    }

    public function flowUpdated (oid :int, flow :int) :void
    {
        (_plaqueTexts[oid] as TextField).text = _control.getOccupantName(oid) + "\n" + flow;
    }

    protected function addPlaque (oid :int, ii :int) :void
    {
        _plaqueTexts[oid] = addTextField(
            _control.getOccupantName(oid), this,
            (Content.PLAQUE_LOCS[ii] as Point).x - 40,
            (Content.PLAQUE_LOCS[ii] as Point).y - 15,
            75, 50, false, 10);
    }

    protected function requestHeadshot (oid :int, ii :int) :void
    {
        var callback :Function = function (headshot :DisplayObject, success :Boolean) :void {
            var scale :Number = Math.min(90/headshot.width, 90/headshot.height);
            headshot.scaleX = headshot.scaleY = scale;
            headshot.x = (Content.HEADSHOT_LOCS[ii] as Point).x - headshot.width/2;
            headshot.y = (Content.HEADSHOT_LOCS[ii] as Point).y - headshot.height/2;
            addChild(headshot);
            _headshots[oid] = headshot;
            headshot.filters = [
                new GlowFilter(0xFFFFFF, 1, 10, 10)
            ]
        };
        _control.getHeadShot(oid, callback);
    }

    protected function roundSetup () :void
    {
        _roundText = addTextField(
              "", this, Content.ROUND_RECT.left, Content.ROUND_RECT.top,
              Content.ROUND_RECT.width, Content.ROUND_RECT.height, false, 20);
    }

    protected function doorSetup () :void
    {
        _doorArea = new Sprite();
        _doorArea.x = Content.QUESTION_RECT.left;
        _doorArea.y = Content.QUESTION_RECT.top;
        addChild(_doorArea);
    }

    protected function doorClear () :void
    {
        while (_doorArea.numChildren > 0) {
            _doorArea.removeChildAt(0);
        }
    }

    protected function doorHeader (header :String) :void
    {
        addTextField(header, _doorArea, 0, 0, Content.ANSWER_RECT.width,
                     Content.ANSWER_RECT.height, true, 24);
    }

    protected function doorBody (body :String) :void
    {
        addTextField(body, _doorArea, 0, 60, Content.ANSWER_RECT.width,
                     Content.ANSWER_RECT.height, true, 16);
    }

    protected function chooseCategory () :void
    {
        var categories :Array = _model.getQuestions().getCategories();

        doorClear();

        var y :uint = 20;
        var x :uint = Content.QUESTION_RECT.width/2;
        for (var ii :int = 0; ii < categories.length; ii ++) {
            var button :SimpleButton = addTextButton(categories[ii], _doorArea, x, y);
            addCategoryClickHandler(button, categories[ii]);
            button.x -= button.width/2;
            y += button.height + 5;
        }
    }

    protected function addDebugFrames () :void
    {
        addFrame(Content.QUESTION_RECT);
        addFrame(Content.ROUND_RECT);
        for (var ii :int = 0; ii < 4; ii ++) {
//            addFrame(Content.ANSWER_RECTS[ii], _questionArea);
        }
    }

    protected function addFrame (rect :Rectangle, to :DisplayObjectContainer = null) :void
    {
        var bit :Sprite = new Sprite();
        bit.graphics.lineStyle(2, 0xFF0000);
        bit.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
        (to != null ? to : this).addChild(bit);
    }

    protected function addCategoryClickHandler (button :SimpleButton, category :String) :void
    {
        button.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _control.sendMessage(Model.MSG_CHOOSE_CATEGORY, category);
        });
    }

    protected function addMultiAnswerClickHandler (button :SimpleButton, correct :Boolean) :void
    {
        button.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            if (_answered) {
                return;
            }
            _answered = true;
            _control.sendMessage(
                Model.MSG_ANSWER_MULTI, { player: _myId, correct: correct, wager: _myWager });
        });
    }

    protected function buzzClick (event :MouseEvent) :void
    {
        _control.sendMessage(Model.MSG_BUZZ, { player: _myId });
    }

    protected function freeInput (event :KeyboardEvent) :void
    {
        if (_answered || event.keyCode != Keyboard.ENTER || _question == null) {
            return;
        }
        _answered = true;

        var answer :String = _freeField.text.toLowerCase();
        _freeArea.visible = false;

        var answers :Array = (_question as FreeResponse).correct;
        var correct :Boolean = false;
        for (var ii :int = 0; ii < answers.length; ii ++) {
            if (answers[ii].toLowerCase() == answer) {
                _control.sendMessage(Model.MSG_ANSWER_FREE, { player: _myId, correct: true });
                return;
            }
        }
        _control.sendMessage(Model.MSG_ANSWER_FREE, { player: _myId, correct: false });
    }

    protected function updateTimer () :void
    {
        if (_endTime > 0) {
            updateRound();
         }
    }

    protected function updateRound (questionIx :int = 0) :void
    {
        var txt :String = Content.ROUND_NAMES[_control.getRound()-1];
        if (_model.getRoundType() == Model.ROUND_LIGHTNING && _endTime > 0) {
            txt += " (" + toTime(Math.max(0, _endTime - uint(getTimer()/1000))) + ")";
        } else if (_model.getRoundType() == Model.ROUND_BUZZ) {
            txt += " (" + (questionIx+1) + "/" + _model.getDuration() + ")";
        }
        _roundText.text = txt;
    }

    protected function doPlay (snd :Sound, loop :Boolean) :void
    {
        if (_sndChannel != null) {
            // TODO: Start a fade-out here instead of just brutally stopping.
            _sndChannel.stop();
        }
        _sndChannel = snd.play(0, loop ? 1000 : 0);
    }

    protected function toTime (seconds :int) :String
    {
        var secs :int = int(seconds % 60);

        return int(seconds / 60) + (secs < 10 ? ":0" : ":") + secs;
    }

    protected function addTextField(
        txt :String, parent :DisplayObjectContainer, x :Number, y :Number, width :Number = 0,
        height :Number = 0, wordWrap :Boolean = true, fontSize :int = 16) :TextField
    {
        var field :TextField = new TextField();
        field.x = x;
        field.y = y;
        if (width > 0 && height > 0) {
            field.width = width;
            field.height = height;
            field.autoSize = TextFieldAutoSize.NONE;
        } else {
            field.autoSize = TextFieldAutoSize.CENTER;
        }
        field.wordWrap = wordWrap;

        var format :TextFormat = new TextFormat();
        format.size = fontSize;
        format.font = Content.FONT_NAME;
        format.color = Content.FONT_COLOR;
        format.align = TextFormatAlign.CENTER;
        field.defaultTextFormat = format;

        field.text = txt;
        if (parent != null) {
            parent.addChild(field);
        }
        return field;
    }

    protected function addTextButton(
        txt :String, parent :DisplayObjectContainer, x :Number, y :Number, width :Number = 0,
        height :Number = 0, wordWrap :Boolean = true, fontSize :int = 16,
        foreground :uint = 0x003366, background :uint = 0x6699CC,
        highlight :uint = 0x0066Ff, padding :Number = 5) :SimpleButton
    {
        var static :Boolean = width > 0 && height > 0;
        var button :SimpleButton = new SimpleButton();
        button.upState = makeButtonFace(
            makeButtonLabel(txt, width, height, wordWrap, fontSize, foreground),
            foreground, background, padding, static);
        button.overState = makeButtonFace(
            makeButtonLabel(txt, width, height, wordWrap, fontSize, highlight),
            highlight, background, padding, static);
        button.downState = makeButtonFace(
            makeButtonLabel(txt, width, height, wordWrap, fontSize, background),
            background, highlight, padding, static);
        button.hitTestState = button.upState;
        parent.addChild(button);
        button.x = x;
        button.y = y;

        return button;
    }

    protected function makeButtonLabel (
        txt :String, width :Number, height :Number, wordWrap :Boolean, fontSize :int,
        foreground :uint) :TextField
    {
        var field :TextField = new TextField();
        field.x = x;
        field.y = y;
        if (width > 0 && height > 0) {
            field.width = width;
            field.height = height;
            field.autoSize = TextFieldAutoSize.NONE;
        } else {
            field.autoSize = TextFieldAutoSize.CENTER;
        }
        field.wordWrap = wordWrap;

        var format :TextFormat = new TextFormat();
        format.size = fontSize;
        format.color = foreground;
        field.defaultTextFormat = format;

        field.text = txt;
        return field;
    }

    protected function makeButtonFace (
        label :TextField, foreground :uint, background :uint,
        padding :int, static :Boolean) :Sprite
    {
        var face :Sprite = new Sprite();

        var w :Number = label.width + (!static ? 2*padding : 0);
        var h :Number = label.height + (!static ? 2*padding : 0);

        // create our button background (and outline)
        var button :Shape = new Shape();
        button.graphics.beginFill(background);
        button.graphics.drawRoundRect(0, 0, w, h, padding, padding);
        button.graphics.endFill();
        button.graphics.lineStyle(1, foreground);
        button.graphics.drawRoundRect(0, 0, w, h, padding, padding);

        face.addChild(button);

        label.x = padding;
        label.y = padding;
        face.addChild(label);

        return face;
    }

    protected var _myId :int;

    protected var _control :WhirledGameControl;

    protected var _model :Model;

    protected var _playing :Boolean;

    protected var _updateTimer :uint;

    protected var _answered :Boolean;

    protected var _sndChannel :SoundChannel = null;

    protected var _endTime :uint;

    protected var _question :Question;

    protected var _myWager :int;

    protected var _headshots :Dictionary;

    protected var _plaqueTexts :Dictionary;

    protected var _doorArea :Sprite;

    protected var _freeArea :Sprite;

    protected var _freeField :TextField;

    protected var _roundText :TextField;

    protected var _sndGameIntro :Sound = (new Content.SND_GAME_INTRO() as Sound);

    protected var _sndRoundIntro :Sound = (new Content.SND_ROUND_INTRO() as Sound);

    protected var _sndCorrect :Sound = (new Content.SND_Q_CORRECT() as Sound);

    protected var _sndIncorrect :Sound = (new Content.SND_Q_INCORRECT() as Sound);
}
}
