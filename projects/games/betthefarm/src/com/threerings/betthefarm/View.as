//
// $Id$

package com.threerings.betthefarm {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
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
import flash.geom.ColorTransform;

import flash.media.Sound;
import flash.media.SoundChannel;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import flash.ui.Keyboard;

import flash.utils.Dictionary;
import flash.utils.setTimeout;

import com.whirled.WhirledGameControl;
import com.threerings.ezgame.UserChatEvent;

/**
 * Manages the whole game view and user input.
 */
public class View extends Sprite
{
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
//            addDebugFrames();

            _control.addEventListener(UserChatEvent.TYPE, userChat);

            trace("View created [playing=" + _playing + "]");
        }
    }

    protected function userChat (event :UserChatEvent) :void
    {
        var bubble :ChatBubble = _bubbles[event.speaker];
        if (bubble) {
            // TODO: these need to scroll up & away, not just get replaced...
            removeChild(bubble);
        }
        bubble = _bubbles[event.speaker] = new ChatBubble(event.message as String);
        bubble.x = _headshots[event.speaker].x;
        bubble.y = _headshots[event.speaker].x - 50;
        addChild(bubble);
    }

    public function gameDidStart () :void
    {
        var players :Array = _control.seating.getPlayerIds();
        trace("Players: " + players);
        _plaques = new Dictionary();
        _headshots = new Dictionary();
        _bubbles = new Dictionary();
        for (var ii :int = 0; ii < players.length; ii ++) {
            addPlaque(players[ii], ii);
            requestHeadshot(players[ii], ii);
        }
        trace("Game started.");
    }

    public function gameDidEnd () :void
    {
        trace("Game ended!");
    }

    public function roundDidStart () :void
    {
        trace("Beginning round: " + _control.getRound());
        doorClear();
        updateRound();

        if (_model.getRoundType() == Model.ROUND_INTRO) {
            showIntro();
            doPlay(_sndGameIntro, true);

        } else {
            doPlay(_sndRoundIntro, false);
        }
    }

    public function roundDidEnd () :void
    {
        if (_clockFace != null) {
            removeChild(_clockFace);
            _clockFace = null;
        }
        if (_control.getRound() != -Model.ROUND_INTRO) {
            doorClear();
            doorHeader(Content.IMG_ROUND_OVER);
        }

        _question = null;
    }

    public function shutdown () :void
    {
        if (_sndChannel) {
            _sndChannel.stop();
        }
        if (_clockFace) {
            _clockFace.shutdown();
        }
        if (_progressBar) {
            _progressBar.shutdown();
        }
    }

    public function newQuestion (question :Question, questionIx :int) :void
    {
        if (questionIx == 0 && _model.getRoundType() == Model.ROUND_LIGHTNING) {
            startTimer(Content.ROUND_DURATIONS[_control.getRound()-1]);
        }

        _question = question;
        _myWager = 0;

        var players :Array = _control.seating.getPlayerIds();
        for (var ii :int = 0; ii < players.length; ii ++) {
            _plaques[players[ii]].setState(Plaque.STATE_NORMAL);
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

    public function newTimeout (action :String, delay :uint, data :Object) :void
    {
        var y :Number = -1;

        // question timeouts are shown to all players
        if (action == Model.ACT_END_QUESTION) {
            y = 115;

        } else if (data.control == _myId) {
            // timeouts for when the player is typing an answer or picking the next category
            if (action == Model.ACT_FAIL_QUESTION) {
                y = 260;

            } else if (action == Model.ACT_PICK_CATEGORY) {
                chooseCategory();
                y = 260;
            }
        }
        if (y > 0) {
            if (_progressBar) {
                _doorArea.removeChild(_progressBar);
            }
            _progressBar = new ProgressBar(delay);
            _progressBar.width = Content.RECT_PROGRESS_BAR.width;
            _progressBar.height = Content.RECT_PROGRESS_BAR.height;
            _progressBar.x = Content.RECT_PROGRESS_BAR.left;
            _progressBar.y = y;
            _doorArea.addChild(_progressBar);
        }
    }

    protected function showIntro () :void
    {
        var cnt :int = Content.ROUND_NAMES.length - 1;
        addTextField(
            "This game has " + (cnt > 10 ? cnt : Content.NUMBERS[cnt]) + " rounds:",
            _doorArea, 0, 0, Content.DOOR_RECT.width, Content.DOOR_RECT.height, false, 18);

        for (var ii :int = 1; ii <= cnt; ii ++) {
            addImage(Content.ROUND_NAMES[ii], _doorArea, Content.DOOR_RECT.width/2, 60*ii);
        }
    }

    protected function showWagerUI (score :int) :void
    {
        doorClear();
        addTextField(_question.question, _doorArea, 0, 0, Content.DOOR_RECT.width,
                     Content.DOOR_RECT.height, true, 14);

        var ii :int = 0;
        if (score > 800) {
            addWagerButton(ii ++, Content.ANSWER_BUBBLE_1, score/8, false);
        }
        if (score > 400) {
            addWagerButton(ii ++, Content.ANSWER_BUBBLE_2, score/4, false);
        }
        if (score > 200) {
            addWagerButton(ii ++, Content.ANSWER_BUBBLE_3, score/2, false);
        }
        addWagerButton(ii ++, Content.ANSWER_BUBBLE_4, score, true);
    }

    protected function startTimer (duration :uint) :void
    {
        _clockFace = new ClockFace(duration);
        _clockFace.x = Content.TIMER_LOC.x;
        _clockFace.y = Content.TIMER_LOC.y;
        addChild(_clockFace);
    }

    protected function addWagerButton (
        pos :int, imgClass :Class, score :int, farm :Boolean) :void
    {
        score -= score % 100;

        var button :Button = new ImageTextButton(
            "Bet: " + (farm ? "The Farm!" : String(score)), imgClass,
            16, 0x003366, Content.ANSWER_BUBBLE_PADDING);
        button.add(_doorArea, Content.ANSWER_BUBBLES[pos].x, Content.ANSWER_BUBBLES[pos].y);
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
        addTextField(_question.question, _doorArea, 0, 0, Content.DOOR_RECT.width,
                     Content.DOOR_RECT.height, true, 14);

        if (_question is MultipleChoice) {
            var answers :Array = (_question as MultipleChoice).incorrect.slice();
            var ix : int = int((1 + answers.length) * Math.random());
            answers.splice(ix, 0, (_question as MultipleChoice).correct);
            if (answers.length > 4) {
                throw new Error("Too many answers: " + _question.question);
            }
            var imgArr :Array = [
                Content.ANSWER_BUBBLE_1,
                Content.ANSWER_BUBBLE_2,
                Content.ANSWER_BUBBLE_3,
                Content.ANSWER_BUBBLE_4
            ];
            for (var ii :int = 0; ii < 4; ii ++) {
                var button :Button = new ImageTextButton(
                    answers[ii], imgArr[ii], 16, 0x003366, Content.ANSWER_BUBBLE_PADDING);
                button.add(_doorArea, Content.ANSWER_BUBBLES[ii].x, Content.ANSWER_BUBBLES[ii].y);
                addMultiAnswerClickHandler(button, ii == ix);
                button.enabled = _playing;
            }

        } else {
            if (_playing) {
                _buzzButton = addImageButton(
                    Content.BUZZ_BUTTON, _doorArea, Content.BUZZ_LOC.x, Content.BUZZ_LOC.y);
                _buzzButton.addEventListener(MouseEvent.CLICK, buzzClick);

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
            doorHeader(Content.IMG_CORRECT);
            _sndCorrect.play();

        } else if (_answered) {
            doorHeader(Content.IMG_INCORRECT);
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
        _plaques[player].setState(correct ? Plaque.STATE_CORRECT : Plaque.STATE_INCORRECT);
    }

    public function gainedBuzzControl (player :int) :void
    {
        _plaques[player].setState(Plaque.STATE_TYPING);
        if (player == _myId) {
            // our buzz won!
            _freeArea.visible = true;
            stage.focus = _freeField;
        }
    }

    public function flowUpdated (oid :int, flow :int) :void
    {
        _plaques[oid].setFlow(flow);
    }

    protected function addPlaque (oid :int, ii :int) :void
    {
        var plaque :Plaque = _plaques[oid] = new Plaque( _control.getOccupantName(oid));
        plaque.x = (Content.PLAQUE_LOCS[ii] as Point).x - plaque.width/2;
        plaque.y = (Content.PLAQUE_LOCS[ii] as Point).y - plaque.height/2;
        addChild(plaque);
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

    protected function doorSetup () :void
    {
        _doorArea = new Sprite();
        _doorArea.x = Content.DOOR_RECT.left;
        _doorArea.y = Content.DOOR_RECT.top;
        addChild(_doorArea);
    }

    protected function doorClear () :void
    {
        if (_progressBar) {
            _progressBar.shutdown();
            _progressBar = null;
        }
        while (_doorArea.numChildren > 0) {
            _doorArea.removeChildAt(0);
        }
    }

    protected function doorHeader (header :Class) :void
    {
        addImage(header, _doorArea, Content.DOOR_RECT.width/2, 20);
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
        var x :uint = Content.DOOR_RECT.width/2;
        for (var ii :int = 0; ii < categories.length; ii ++) {
            var button :Button = new TextButton(categories[ii]);
            button.add(_doorArea, x, y);
            addCategoryClickHandler(button, categories[ii]);
            button.x -= button.width/2;
            y += button.height + 5;
        }
    }

    protected function addDebugFrames () :void
    {
        addFrame(Content.DOOR_RECT);
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
        _buzzButton.enabled = false;

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

    protected function updateRound (questionIx :int = 0) :void
    {
        if (_roundImage != null) {
            removeChild(_roundImage);
        }
        _roundImage = addImage(
            Content.ROUND_NAMES[_control.getRound()-1], this,
            (Content.ROUND_RECT.left + Content.ROUND_RECT.right)/2,
            (Content.ROUND_RECT.top + Content.ROUND_RECT.bottom)/2);

        if (_model.getRoundType() == Model.ROUND_BUZZ) {
            var txt :String = " (" + (questionIx+1) + "/" + _model.getDuration() + ")";
//            _roundText = addTextField(
//              "", this, Content.ROUND_RECT.left, Content.ROUND_RECT.top,
//              Content.ROUND_RECT.width, Content.ROUND_RECT.height, false, 20);
        }
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
        field.embedFonts = false;

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

    protected function addImage (
        imgClass :Class, parent :DisplayObjectContainer, x :Number, y :Number) :DisplayObject
    {
        var img :DisplayObject = new imgClass();
        img.x = x - img.width/2;
        img.y = y - img.height/2;
        parent.addChild(img);
        return img;
    }


    protected function addImageButton (
        imgClass :Class, parent :DisplayObjectContainer, x :Number, y :Number) :SimpleButton
    {
        var button :SimpleButton = new SimpleButton();

        // the upstate is just the image
        button.upState = new imgClass();

        // the downstate is the image shifted 3 pixels south
        button.downState = new imgClass();
        button.downState.transform.matrix = new Matrix(1, 0, 0, 1, 0, 3);

        // the hoverstate is the image brightened by 20%
        button.overState = new imgClass();
        button.overState.transform.colorTransform = new ColorTransform(1.2, 1.2, 1.2);

        button.hitTestState = button.upState;
        parent.addChild(button);
        button.x = x;
        button.y = y;

        return button;
    }

    protected var _myId :int;

    protected var _control :WhirledGameControl;

    protected var _model :Model;

    protected var _playing :Boolean;

    protected var _answered :Boolean;

    protected var _sndChannel :SoundChannel;

    protected var _clockFace :ClockFace;

    protected var _progressBar :ProgressBar;

    protected var _buzzButton :SimpleButton;

    protected var _question :Question;

    protected var _myWager :int;

    protected var _headshots :Dictionary;

    protected var _plaques :Dictionary;

    protected var _bubbles :Dictionary;

    protected var _doorArea :Sprite;

    protected var _freeArea :Sprite;

    protected var _freeField :TextField;

    protected var _roundImage :DisplayObject;

    protected var _sndGameIntro :Sound = (new Content.SND_GAME_INTRO() as Sound);

    protected var _sndRoundIntro :Sound = (new Content.SND_ROUND_INTRO() as Sound);

    protected var _sndCorrect :Sound = (new Content.SND_Q_CORRECT() as Sound);

    protected var _sndIncorrect :Sound = (new Content.SND_Q_INCORRECT() as Sound);
}
}
