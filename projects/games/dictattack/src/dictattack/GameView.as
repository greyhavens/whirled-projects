//
// $Id$

package dictattack {

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.display.Sprite;
import flash.events.KeyboardEvent;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.PropertyChangedEvent;

import com.whirled.WhirledGameControl;

/**
 * Manages the whole game view and user input.
 */
public class GameView extends Sprite
{
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
        _tip.y = _content.inputRect.y;

        // create the text field via which we'll accept player input
        _input = new TextField();
        _input.background = true;
        _input.backgroundColor = uint(0xFFFFFF);
        _input.defaultTextFormat = _content.makeInputFormat(uint(0x000000), true);
        _input.type = TextFieldType.INPUT;
        _input.x = _content.inputRect.x;
        _input.y = _content.inputRect.y;
        _input.width = _content.inputRect.width;
        _input.height = _content.inputRect.height;

        // listen for property changed and message events
        _control.addEventListener(PropertyChangedEvent.TYPE, propertyChanged);
        _control.addEventListener(MessageReceivedEvent.TYPE, messageReceived);
    }

    public function init (boardSize :int, playerCount :int) :void
    {
        _board = new Board(boardSize, _control, _model, _content);
        _board.x = Content.BOARD_BORDER;
        _board.y = Content.BOARD_BORDER;
        addChild(_board);

        // create a marquee that we'll use to display feedback
        marquee = new Marquee(_content.makeMarqueeFormat(),
                              Content.BOARD_BORDER + _board.getPixelSize()/2,
                              Content.BOARD_BORDER + _board.getPixelSize());
        addChild(marquee);

        var mypidx :int = _control.isConnected() ? _control.seating.getMyPosition() : 0;
        var psize :int = Content.BOARD_BORDER * 2 + _board.getPixelSize();
        for (var pidx :int = 0; pidx < playerCount; pidx++) {
            // the board is rotated so that our position is always at the bottom
            var posidx :int = POS_MAP[mypidx][pidx];
            var shooter :Shooter = new Shooter(_content, posidx, pidx);
            shooter.x = SHOOTER_X[posidx] * psize;
            shooter.y = SHOOTER_Y[posidx] * psize;
            // if this is ours (the one on the bottom), lower it a smidgen further
            if (posidx == 3) {
                shooter.y += 10;
            }
            addChild(shooter);
            _shooters[pidx] = shooter;
        }

        if (_control.isConnected()) {
            var help :TextField = new TextField();
            help.defaultTextFormat = _content.makeInputFormat(uint(0xFFFFFF));
            help.x = _board.getPixelSize() + 2*Content.BOARD_BORDER + 25;
            help.y = 50;
            help.autoSize = TextFieldAutoSize.LEFT;
            help.wordWrap = true;
            help.width = 200;
            help.htmlText = HELP_CONTENTS.replace(
                "MINLEN", _model.getMinWordLength()).replace(
                    "POINTS", _model.getWinningPoints()).replace(
                        "ROUNDS", _model.getWinningScore());
            addChild(help);
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
        _control.setChatEnabled(false);

        addChild(_tip);
        _tip.text = "Enter words:";
        _tip.x = _content.inputRect.x - _tip.width - 5;

        _input.selectable = false;
        addChild(_input);
        _input.text = "Type words here!";

        marquee.display("Round " + _control.getRound() + "...", 1000);
        Util.invokeLater(1000, function () :void {
            addEventListener(KeyboardEvent.KEY_UP, keyReleased);
            _input.selectable = true;
            _input.text = "";
            _input.stage.focus = _input;
            marquee.display("Start!", 1000);
        });
    }

    public function roundDidEnd () :void
    {
        _board.roundDidEnd();
        removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
        _input.stage.focus = null;
        removeChild(_input);
        removeChild(_tip);
        _control.setChatEnabled(true);
    }

    public function gameDidEnd (flow :int) :void
    {
        marquee.display(flow > 0 ? "Game over! You earned " + flow + " flow!" : "Game over!", 3000);
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
            if (event.index == -1) {
                // we got our board, update the playable letters display
                _model.updatePlayable(_board);
            }
        }
    }

    /**
     * Called when a message comes in.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == Model.WORD_PLAY) {
            var data :Array = (event.value as Array);
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
                _shooters[scidx].shootLetter(_board, xx, yy);
            }
        }
    }

    protected function keyReleased (event :KeyboardEvent) : void
    {
        if (event.keyCode == 13) {
            if (_model.submitWord(_board, _input.text)) {
                _input.text = "";
            }
        }
    }

    protected var _control :WhirledGameControl;
    protected var _model :Model;
    protected var _content :Content;

    protected var _tip :TextField;
    protected var _input :TextField;

    protected var _board :Board;
    protected var _shooters :Array = new Array();

    protected static const POS_MAP :Array = [
        [ 3, 1, 0, 2 ], [ 1, 3, 2, 0 ], [ 2, 0, 3, 1 ], [ 0, 2, 1, 3 ] ];

    protected static const SHOOTER_X :Array = [ 0, 0.5, 1, 0.5 ];
    protected static const SHOOTER_Y :Array = [ 0.5, 0, 0.5, 1 ];

    protected static const HELP_CONTENTS :String = "<b>How to Play</b>\n" +
        "Make words from the row of letters along the bottom of the board.\n\n" +
        "<font color='#0000ff'>Blue</font> squares multiply the word score by two.\n\n" +
        "<font color='#ff0000'>Red</font> squares multiply the word score by three.\n\n" +
        "Minimum word length: MINLEN.\n\n" +
        "Be the first to score POINTS points to win the round.\n\n" +
        "Win ROUNDS rounds to win the game.";
}

}
