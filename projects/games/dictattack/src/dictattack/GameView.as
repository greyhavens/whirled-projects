//
// $Id$

package dictattack {

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import com.threerings.flash.TextFieldUtil;

import com.whirled.net.ElementChangedEvent;
import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

/**
 * Manages the whole game view and user input.
 */
public class GameView extends Sprite
{
    public static const INPUT_HEIGHT :int = 50;

    public var marquee :Marquee;

    public function GameView (ctx :Context)
    {
        _ctx = ctx;

        // position ourselves a smidgen away from the edge
        x = 5;
        y = 5;

        // create the text field via which we'll accept player input
        _input = TextFieldUtil.createField("",
            {
                background: true,
                backgroundColor: 0xFFFFFF,
                defaultTextFormat: _ctx.content.makeInputFormat(uint(0x000000), true),
                type: TextFieldType.INPUT,
                restrict: "[A-Za-z]", // only allow letters to be typed; TODO: i18n?
                width: _ctx.content.inputRect.width,
                height: _ctx.content.inputRect.height
            });

        // listen for property changed and message events
        _ctx.control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        _ctx.control.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        _ctx.control.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
    }

    public function init (playerCount :int) :void
    {
        _board = new Board(_ctx);
        _board.x = Content.BOARD_BORDER;
        _board.y = Content.BOARD_BORDER;
        addChild(_board);

        var isMulti :Boolean = _ctx.control.isConnected() ? _ctx.model.isMultiPlayer() : true;
        var mypidx :int = _ctx.control.isConnected() ? _ctx.control.game.seating.getMyPosition() : 0;
        var psize :int = Content.BOARD_BORDER * 2 + _board.getPixelSize();
        for (var pidx :int = 0; pidx < playerCount; pidx++) {
            // the board is rotated so that our position is always at the bottom (if we're a
            // non-player use position 0)
            var posidx :int = POS_MAP[Math.max(mypidx, 0)][pidx];
            var shooter :Shooter = new Shooter(_ctx, posidx, pidx, isMulti);
            shooter.x = SHOOTER_X[posidx] * psize;
            shooter.y = SHOOTER_Y[posidx] * psize;
            // if this is ours (the one on the bottom), lower it a smidgen further
            if (posidx == 3) {
                shooter.y += 10;
            }
            addChild(shooter);
            _shooters[pidx] = shooter;
        }

        // create a marquee that we'll use to display feedback
        marquee = new Marquee(_ctx.content.makeMarqueeFormat(),
                              Content.BOARD_BORDER + _board.getPixelSize()/2,
                              Content.BOARD_BORDER + _board.getPixelSize());
        addChild(marquee);

        if (_ctx.control.isConnected()) {
            var xpos :int = _board.getPixelSize() + 2*Content.BOARD_BORDER + 25;
            var help :SimpleButton = _ctx.content.makeButton("How to Play");
            help.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                showHelp();
            });
            help.x = xpos;
            help.y = 50;
            addChild(help);

            var trophies :SimpleButton = _ctx.content.makeButton("Trophies");
            trophies.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                _ctx.control.local.showTrophies();
            });
            trophies.x = xpos;
            trophies.y = help.y + help.height + 10;
            addChild(trophies);

            _hiscores = new TextField();
            _hiscores.defaultTextFormat = _ctx.content.makeInputFormat(uint(0xFFFFFF));
            _hiscores.x = xpos;
            _hiscores.y = trophies.y + trophies.height + 10;
            _hiscores.autoSize = TextFieldAutoSize.LEFT;
            _hiscores.width = 150;
            addChild(_hiscores);
        }
    }

    public function getBoard () :Board
    {
        return _board;
    }

    public function attractMode () :void
    {
        // for now just show a board with ? letters
        _board.roundDidStart();
    }

    public function gotUserCookie (cookie :Object) :void
    {
        var hiscores :Array = cookie["highscores"] as Array;
        if (hiscores != null) {
            var text :String = "<b>Your High Scores:</b>\n";
            var date :Date = new Date();
            for (var ii :int = 0; ii < hiscores.length; ii++) {
                var data :Array = hiscores[ii] as Array;
                date.setTime(data[1] as Number);
                text += data[0] + " on " + (date.getMonth()+1) + "/" + date.getDate() + "\n";
            }
            _hiscores.htmlText = text;
        }

        var seenHelp :Boolean = (cookie["seen_help"] as Boolean);
        if (!seenHelp) {
            showHelp();
            cookie["seen_help"] = true;
            _ctx.control.player.setCookie(cookie)
        }
    }

    public function gameDidStart () :void
    {
        var names :Array = _ctx.control.game.seating.getPlayerNames();
        for (var ii :int = 0; ii < names.length; ii++) {
            _shooters[ii].setName(names[ii]);
        }

        // we might have one of these lingering about
        clearOverView();
    }

    public function roundDidStart () :void
    {
        for each (var shooter :Shooter in _shooters) {
            shooter.setSaucers(_ctx.model.getChangesAllowed());
        }

        // clear any inter-round view
        clearOverView();

        // this will contain all of our input bits
        if (_inputBox == null) {
            _inputBox = new Sprite();

            // add text that says "Type here:"
            var tip :TextField = new TextField();
            tip.selectable = false;
            // tip.embedFonts = true;
            tip.defaultTextFormat = _ctx.content.makeInputFormat(uint(0xFFFFFF), true);
            tip.autoSize = TextFieldAutoSize.RIGHT;
            tip.text = "Enter word:";

            _inputBox.addChild(tip);

            _input.x = tip.x + tip.width + 5;
            _inputBox.addChild(_input);

            var go :SimpleButton = _ctx.content.makeButton("Go!");
            go.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                submitWord();
            });
            go.x = _input.x + _input.width + 5;
            go.y = (_input.height - go.height) / 2;
            _inputBox.addChild(go);

            _inputBox.x = _ctx.content.inputRect.x - tip.width - 5;
            _inputBox.y = _ctx.control.local.getSize().y - _input.height -
                (INPUT_HEIGHT - _input.height)/2;
        }
        addChild(_inputBox);
        
        _input.selectable = false;
        _input.text = "Type words here!";

        if (_ctx.model.getWinningScore() > 1) {
            Util.invokeLater(1000, function () :void {
                showBetweenRound();
            });

        } else {
            _board.roundDidStart();
            marquee.display("Start!", 1000);
            enableInput();
        }
    }

    public function saucerClicked (event :MouseEvent) :void
    {
        _ctx.model.requestChange();
        // refocus the input text box because they clicked outside it
        focusInput(true);
    }

    public function roundDidEnd () :void
    {
        if (_shotsInProgress > 0) {
            _roundEndPending = true;
        } else {
            _board.roundDidEnd();
        }

        for (var ii :int = 0; ii < _shooters.length; ii++) {
            _shooters[ii].roundDidEnd();
        }

        if (_ctx.model.isMultiPlayer()) {
            _overifc = new EndRoundMulti(_ctx);
            _overifc.show();

        } else {
            var text :String = "";
            if (_ctx.model.nonEmptyColumns() == 0) {
                text = "Board clear! Excellent!";
            } else if (_ctx.model.nonEmptyColumns() < _ctx.model.getMinWordLength()) {
                text = "No more words possible.";
            } else {
                text = "Game over.";
            }
            marquee.display(text, 2000);
        }

        _input.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
        _input.removeEventListener(Event.CHANGE, textChanged);
        focusInput(false);
        if (_inputBox != null) {
            removeChild(_inputBox);
        }
    }

    public function gameDidEnd (coins :int) :void
    {
        _coinsAward = coins;

        if (!_ctx.model.isMultiPlayer()) {
            Util.invokeLater(2000, function () :void {
                showGameOver();
            });
        }
    }

    /**
     * Called when a shooter finishes its shot.
     */
    public function shotTaken (shooter :Shooter) :void
    {
        if (--_shotsInProgress == 0 && _roundEndPending) {
            _board.roundDidEnd();
            _roundEndPending = false;
        }
    }

    public function focusInput (focus :Boolean) :void
    {
        if (_input.stage != null) {
            _input.stage.focus = focus ? _input : null;
        }
    }

    public function clearOverView () :void
    {
        if (_overifc != null) {
            if (_overifc.parent != null) {
                _overifc.clear();
            }
            _overifc = null;
        }
    }

    public function showGameOver () :void
    {
        try {
            if (_ctx.model.isMultiPlayer()) {
                _overifc = new EndGameMulti(_ctx, _coinsAward);
                _overifc.show(false);
            } else {
                _overifc = new EndGameSingle(_ctx, _coinsAward);
                _overifc.show();
            }
        } catch (e :Error) {
            _ctx.control.local.feedback("Oh noez: " + e);
            trace("Oh noez " + e);
        }
    }

    protected function showBetweenRound () :void
    {
        try {
            var tweenRound :MovieClip =
                _ctx.content.createBetweenRound(_ctx.control.game.getRound());
            tweenRound.x = 219;
            tweenRound.y = 258;
            tweenRound.addEventListener(Event.ENTER_FRAME, function (event :Event) :void {
                    if (tweenRound.currentFrame == tweenRound.totalFrames) {
                        tweenRound.removeEventListener(Event.ENTER_FRAME, arguments.callee);
                        removeChild(tweenRound);
                        _board.roundDidStart();
                        marquee.display("Start!", 1000);
                        enableInput();
                    }
                });
            addChild(tweenRound);
        } catch (e :Error) {
            _ctx.control.local.feedback("Oh noez: " + e);
            trace("Oh noez " + e);
        }
    }

    protected function enableInput () :void
    {
        _input.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
        _input.addEventListener(Event.CHANGE, textChanged);
        _input.selectable = true;
        _input.text = "";
        focusInput(true);
    }

    protected function showHelp () :void
    {
        HelpView.show(_ctx);
    }

    protected function submitWord () :void
    {
        if (_input.text.length == 0) {
            return;
        }
        _ctx.model.submitWord(_board, _input.text, function (text :String) :void {
            marquee.display(text, 1000);
        });
        _input.text = "";
        focusInput(true);
    }

    /**
     * Called when a property in our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        var ii :int; // fucking ActionScript
        if (event.name == Model.POINTS) {
            for (ii = 0; ii < _shooters.length; ii++) {
                _shooters[ii].setPoints(0, _ctx.model.getWinningPoints());
            }

        } else if (event.name == Model.SCORES) {
            for (ii = 0; ii < _shooters.length; ii++) {
                _shooters[ii].setScore(0);
            }
        }
    }

    /**
     * Called when an element of an array-valued property in our distributed game state changes.
     */
    protected function elementChanged (event :ElementChangedEvent) :void
    {
        if (event.name == Model.POINTS) {
            _shooters[event.index].setPoints(int(event.newValue), _ctx.model.getWinningPoints());

        } else if (event.name == Model.SCORES) {
            _shooters[event.index].setScore(int(event.newValue));

        } else if (event.name == Model.BOARD_DATA) {
            if (event.newValue != Model.BLANK) {
                // map the global position into to our local coordinates
                var xx :int = _ctx.model.getReverseX(event.index);
                var yy :int = _ctx.model.getReverseY(event.index);
                // TODO: animate a spaceship flying over and changing the letter
                _board.getLetterAt(xx, yy).setText(String(event.newValue));
            }
        }
    }

    /**
     * Called when a message comes in.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == Model.WORD_PLAY) {
            handleWordPlay(WordPlay.unflatten(event.value as Array));
        } else if (event.name == Model.LETTER_CHANGE) {
            handleLetterChange(event.value as Array);
        }
    }

    protected function handleWordPlay (play :WordPlay) :void
    {
        var scorer :String = _ctx.control.game.seating.getPlayerNames()[play.pidx];
        var mult :int = play.getMultiplier();
        var points :int = play.getPoints(_ctx.model);

        if (mult > 1) {
            marquee.display(scorer + ": " + play.word + " x" + mult + " for " + points, 1000);
        } else {
            marquee.display(scorer + ": " + play.word + " for " + points, 1000);
        }

        for (var ii :int = 0; ii < play.positions.length; ii++) {
            // map the global position into to our local coordinates
            var xx :int = _ctx.model.getReverseX(int(play.positions[ii]));
            var yy :int = _ctx.model.getReverseY(int(play.positions[ii]));
            // when the shooting is finished the column will be marked as playable
            _shotsInProgress++;
            _shooters[play.pidx].shootLetter(_board, xx, yy);
        }
    }

    protected function handleLetterChange (data :Array) :void
    {
        if (_ctx.control.game.seating.getMyPosition() < 0) {
            return; // do nothing if we're an observer
        }
        var pidx :int = _ctx.control.game.seating.getPlayerPosition(int(data[0]));
        var xx :int = _ctx.model.getReverseX(int(data[1]));
        var yy :int = _ctx.model.getReverseY(int(data[1]));
        _shooters[pidx].flySaucer(_board, xx, yy);
    }

    protected function keyPressed (event :KeyboardEvent) : void
    {
        switch (event.keyCode) {
        case 13:
            submitWord();
            break;
        }
    }

    protected function textChanged (event :Event) :void
    {
        _ctx.model.highlightWord(_board, _input.text);
    }

    protected var _ctx :Context;

    protected var _inputBox :Sprite;
    protected var _input :TextField;

    protected var _board :Board;
    protected var _shooters :Array = new Array();

    protected var _roundEndPending :Boolean;
    protected var _shotsInProgress :int;

    protected var _hiscores :TextField;

    protected var _overifc :Dialog;
    protected var _coinsAward :int;

    protected static const POS_MAP :Array = [
        [ 3, 1, 0, 2 ], [ 1, 3, 2, 0 ], [ 2, 0, 3, 1 ], [ 0, 2, 1, 3 ] ];

    protected static const SHOOTER_X :Array = [ 0, 0.5, 1, 0.5 ];
    protected static const SHOOTER_Y :Array = [ 0.5, 0, 0.5, 1 ];

    protected static const CHAT_HEIGHT :int = 200;
}
}
