//
// $Id$

package dictattack {

import flash.geom.Rectangle;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import mx.containers.VBox;
import mx.controls.Button;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.PropertyChangedEvent;

import com.whirled.WhirledGameControl;

/**
 * Manages the whole game view and user input.
 */
public class GameView extends Sprite
{
    public static const INPUT_HEIGHT :int = 50;

    public var marquee :Marquee;

    public function GameView (control :WhirledGameControl, model :Model, content :Content)
    {
        _control = control;
        _model = model;
        _content = content;

        // position ourselves a smidgen away from the edge
        x = 5;
        y = 5;

        // add text that says "Type here:"
        _tip = new TextField();
        _tip.selectable = false;
        // _tip.embedFonts = true;
        _tip.defaultTextFormat = _content.makeInputFormat(uint(0xFFFFFF), true);
        _tip.autoSize = TextFieldAutoSize.RIGHT;

        // create the text field via which we'll accept player input
        _input = new TextField();
        _input.background = true;
        _input.backgroundColor = uint(0xFFFFFF);
        _input.defaultTextFormat = _content.makeInputFormat(uint(0x000000), true);
        _input.type = TextFieldType.INPUT;
        _input.x = _content.inputRect.x;
        _input.width = _content.inputRect.width;
        _input.height = _content.inputRect.height;
        _input.restrict = "[A-Za-z]"; // only allow letters to be typed; TODO: i18n?

        // listen for property changed and message events
        _control.addEventListener(PropertyChangedEvent.TYPE, propertyChanged);
        _control.addEventListener(MessageReceivedEvent.TYPE, messageReceived);
    }

    public function init (playerCount :int) :void
    {
        _board = new Board(_control, _model, _content);
        _board.x = Content.BOARD_BORDER;
        _board.y = Content.BOARD_BORDER;
        addChild(_board);

        var isMulti :Boolean = _control.isConnected() ? _model.isMultiPlayer() : true;
        var mypidx :int = _control.isConnected() ? _control.seating.getMyPosition() : 0;
        var psize :int = Content.BOARD_BORDER * 2 + _board.getPixelSize();
        for (var pidx :int = 0; pidx < playerCount; pidx++) {
            // the board is rotated so that our position is always at the bottom (if we're a
            // non-player use position 0)
            var posidx :int = POS_MAP[Math.max(mypidx, 0)][pidx];
            var shooter :Shooter = new Shooter(this, _content, posidx, pidx, isMulti);
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
        marquee = new Marquee(_content.makeMarqueeFormat(),
                              Content.BOARD_BORDER + _board.getPixelSize()/2,
                              Content.BOARD_BORDER + _board.getPixelSize());
        addChild(marquee);

        if (_control.isConnected()) {
            // create our sidebar
            var sidebar :VBox = new VBox();
            sidebar.x = _board.getPixelSize() + 2*Content.BOARD_BORDER + 25;
            sidebar.y = 5;
            sidebar.width = 250;
            sidebar.height = 300;
            addChild(sidebar);

            var help :Button = new Button();
            help.label = "How to Play";
            help.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                showHelp();
            });
//             help.x = _board.getPixelSize() + 2*Content.BOARD_BORDER + 25;
//             help.y = 50;
            sidebar.addChild(help);

            _hiscores = new TextField();
            _hiscores.defaultTextFormat = _content.makeInputFormat(uint(0xFFFFFF));
//             _hiscores.x = _board.getPixelSize() + 2*Content.BOARD_BORDER + 25;
//             _hiscores.y = help.y + help.height + 10;
            _hiscores.autoSize = TextFieldAutoSize.LEFT;
            _hiscores.width = HELP_WIDTH;
            sidebar.addChild(_hiscores);

            // relocate the chat view out of the way
            var bsize :int = Content.BOARD_BORDER * 2 + _board.getPixelSize();
            var bounds :Rectangle = _control.getStageBounds();
            bounds.x = bsize;
            bounds.y = sidebar.y + 10;
            bounds.width -= bsize;
            bounds.height = bounds.height - sidebar.height - 15;
            _control.setChatBounds(bounds);
        }
    }

    public function getBoard () :Board
    {
        return _board;
    }

    public function getModel () :Model
    {
        return _model;
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
    }

    public function gameDidStart () :void
    {
        var names :Array = _control.seating.getPlayerNames();
        for (var ii :int = 0; ii < names.length; ii++) {
            _shooters[ii].setName(names[ii]);
        }
    }

    public function roundDidStart () :void
    {
        _board.roundDidStart();

        for each (var shooter :Shooter in _shooters) {
            shooter.setSaucers(_model.getChangesAllowed());
        }

        addChild(_tip);
        _tip.text = "Enter words:";
        _tip.x = _content.inputRect.x - _tip.width - 5;

        _input.y = _control.getStageBounds().height - _input.height -
            (INPUT_HEIGHT - _input.height)/2;
        _tip.y = _input.y;
        _input.selectable = false;
        addChild(_input);
        _input.text = "Type words here!";

        var ready :String = (_model.getWinningScore() > 1) ?
            "Round " + _control.getRound() + "..." : "Ready...";
        marquee.display(ready, 1000);
        Util.invokeLater(1000, function () :void {
            _input.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
            _input.addEventListener(Event.CHANGE, textChanged);
            _input.selectable = true;
            _input.text = "";
            _input.stage.focus = _input;
            marquee.display("Start!", 1000);
        });
    }

    public function roundDidEnd (scorer :String) :void
    {
        if (_shotsInProgress > 0) {
            _roundEndPending = true;
        } else {
            _board.roundDidEnd();
        }

        var text :String = "";
        if (isMultiPlayer()) {
            if (_model.getWinningScore() > 1) {
                text = "Round over. ";
            }
            text += "Point to " + scorer + ".";
        } else if (_model.nonEmptyColumns() == 0) {
            text = "Board clear! Excellent!";
        } else {
            text = "No more words possible.";
        }
        marquee.display(text, 2000);

        _input.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
        _input.removeEventListener(Event.CHANGE, textChanged);
        _input.stage.focus = null;
        removeChild(_input);
        removeChild(_tip);
    }

    public function gameDidEnd (flow :int) :void
    {
        Util.invokeLater(2000, function () :void {
            showGameOver(flow);
        });
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

    protected function isMultiPlayer () :Boolean
    {
        return (_control.seating.getPlayerNames().length > 1);
    }

    protected function showGameOver (flow :int) :void
    {
        var text :TextField = new TextField();
        text.autoSize = TextFieldAutoSize.LEFT;
        text.selectable = false;
        text.defaultTextFormat = _content.makeMarqueeFormat();
        text.embedFonts = true;
        text.gridFitType = GridFitType.PIXEL;
        text.sharpness = 400;

        var msg :String = "Game over!";
        if (flow > 0) {
            msg += "\nYou earned " + flow + " flow!";
        }
        text.text = msg;

        var overifc :Dialog = new Dialog(text);

        var restart :SimpleButton = _content.makeButton("Play Again");
        restart.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            removeChild(overifc);
            _control.playerReady();
        });
        overifc.addButton(restart, Dialog.LEFT);

        var leave :SimpleButton = _content.makeButton("To Whirled");
        leave.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            removeChild(overifc);
            _control.backToWhirled();
        });
        overifc.addButton(leave, Dialog.RIGHT);

        overifc.show(this);
    }

    protected function showHelp () :void
    {
        var help :TextField = new TextField();
        help.defaultTextFormat = _content.makeInputFormat(uint(0xFFFFFF));
        help.autoSize = TextFieldAutoSize.LEFT;
        help.wordWrap = true;
        help.width = HELP_WIDTH;
        var htext :String = HELP_CONTENTS;
        if (isMultiPlayer()) {
            htext += HELP_MULTI.replace(
                "MINLEN", _model.getMinWordLength()).replace(
                    "POINTS", _model.getWinningPoints()).replace(
                        "ROUNDS", _model.getWinningScore());
        } else {
            htext += HELP_SINGLE.replace(
                "MINLEN", _model.getMinWordLength());
        }
        help.htmlText = htext;

        var dialog :Dialog = new Dialog(help);
        var dismiss :SimpleButton = _content.makeButton("Dismiss");
        dismiss.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            removeChild(dialog);
        });
        dialog.addButton(dismiss, Dialog.CENTER);
        dialog.show(this);
    }

    /**
     * Called when our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        var ii :int; // fucking ActionScript
        if (event.name == Model.POINTS) {
            if (event.index == -1) {
                for (ii = 0; ii < _shooters.length; ii++) {
                    _shooters[ii].setPoints(0, _model.getWinningPoints());
                }
            } else {
                _shooters[event.index].setPoints(int(event.newValue), _model.getWinningPoints());
            }

        } else if (event.name == Model.SCORES) {
            if (event.index == -1) {
                for (ii = 0; ii < _shooters.length; ii++) {
                    _shooters[ii].setScore(0);
                }
            } else {
                _shooters[event.index].setScore(int(event.newValue));
            }

        } else if (event.name == Model.BOARD_DATA) {
            if (event.index != -1 && event.newValue != Model.BLANK) {
                // map the global position into to our local coordinates
                var xx :int = _model.getReverseX(event.index);
                var yy :int = _model.getReverseY(event.index);
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
            handleWordPlay(event.value as Array);
        } else if (event.name == Model.LETTER_CHANGE) {
            handleLetterChange(event.value as Array);
        }
    }

    protected function handleWordPlay (data :Array) :void
    {
        var scidx :int = int(data[0]);
        var scorer :String = _control.seating.getPlayerNames()[scidx];
        var word :String = (data[1] as String);
        var points :int = int(data[2]);
        var mult :int = int(data[3]);
        if (mult > 1) {
            marquee.display(scorer + ": " + word + " x" + mult + " for " + points, 1000);
        } else {
            marquee.display(scorer + ": " + word + " for " + points, 1000);
        }

        var wpos :Array = (data[4] as Array);
        for (var ii :int = 0; ii < wpos.length; ii++) {
            // map the global position into to our local coordinates
            var xx :int = _model.getReverseX(int(wpos[ii]));
            var yy :int = _model.getReverseY(int(wpos[ii]));
            // when the shooting is finished the column will be marked as playable
            _shotsInProgress++;
            _shooters[scidx].shootLetter(_board, xx, yy);
        }
    }

    protected function handleLetterChange (data :Array) :void
    {
        var pidx :int = _control.seating.getPlayerPosition(int(data[0]));
        var xx :int = _model.getReverseX(int(data[1]));
        var yy :int = _model.getReverseY(int(data[1]));
        _shooters[pidx].flySaucer(_board, xx, yy);
    }

    protected function keyPressed (event :KeyboardEvent) : void
    {
        switch (event.keyCode) {
        case 13:
            _model.submitWord(_board, _input.text, function (text :String) :void {
                marquee.display(text, 1000);
            });
            _input.text = "";
            break;
        }
    }

    protected function textChanged (event :Event) :void
    {
        _model.highlightWord(_board, _input.text);
    }

    protected var _control :WhirledGameControl;
    protected var _model :Model;
    protected var _content :Content;

    protected var _tip :TextField;
    protected var _input :TextField;

    protected var _board :Board;
    protected var _shooters :Array = new Array();

    protected var _roundEndPending :Boolean;
    protected var _shotsInProgress :int;

    protected var _hiscores :TextField;

    protected static const POS_MAP :Array = [
        [ 3, 1, 0, 2 ], [ 1, 3, 2, 0 ], [ 2, 0, 3, 1 ], [ 0, 2, 1, 3 ] ];

    protected static const SHOOTER_X :Array = [ 0, 0.5, 1, 0.5 ];
    protected static const SHOOTER_Y :Array = [ 0.5, 0, 0.5, 1 ];

    protected static const CHAT_HEIGHT :int = 200;

    protected static const HELP_WIDTH :int = 300;
    protected static const HELP_CONTENTS :String = "<b>How to Play</b>\n" +
        "Make words from the row of letters along the bottom of the board.\n\n" +
        "<font color='#0000ff'><b>Blue</b></font> squares multiply the word score by two.\n" +
        "<font color='#ff0000'><b>Red</b></font> squares multiply the word score by three.\n" +
        "Only one multiplier per word will count.\n\n";

    protected static const HELP_MULTI :String =
        "Minimum word length: MINLEN. The first to score POINTS points wins the round.\n\n" +
        "Win ROUNDS rounds to win the game.\n\n" +
        "Click a flying saucer to change a letter into a wildcard (*) if you can't find a word.";

    protected static const HELP_SINGLE :String =
        "Minimum word length: MINLEN.\n\n" +
        "Clear the board using long words to get a high score!\n\n" +
        "Click a flying saucer to change a letter into a wildcard (*) if you can't find a word.";
}

}
