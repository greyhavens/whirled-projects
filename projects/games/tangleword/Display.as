package
{

import flash.display.Sprite;
import flash.display.Stage;
import flash.display.SimpleButton;
import flash.display.DisplayObject;
import flash.display.Graphics;

import fl.controls.ScrollBar;

import flash.media.Sound;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.ColorUtil;
import caurina.transitions.Tweener;

import com.threerings.util.Assert;
import com.threerings.util.StringUtil;

import com.whirled.game.GameControl;
import com.whirled.contrib.Scoreboard;

import com.threerings.util.KeyboardCodes;

/**
 * The Display class represents the game visualization, including UI
 * and game state display.
 */
public class Display extends Sprite
    implements Observer
{
    // PUBLIC FUNCTIONS

    /** Initializes the board and everything on it */
    public function Display (gameCtrl :GameControl, controller :Controller,
                             version :String) :void
    {
        // Copy parameters
        _controller = controller;
        _gameCtrl = gameCtrl;

        // Initialize the background bitmap
        _background = new Resources.background();
        Assert.isNotNull(_background, "Background bitmap failed to initialize!");
        addChild(_background);

        // Initialize empty letters
        initializeLetters();

        // Initialize UI elements for selection
        initializeUI(version);

        // Register for events
        addEventListener(MouseEvent.CLICK, clickHandler);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
        addEventListener(KeyboardEvent.KEY_DOWN, typingHandler);

        _logger.log(version);

        _word = new Array();
    }

    /** Shutdown handler */
    public function handleUnload (event :Event) :void
    {
        removeEventListener(MouseEvent.CLICK, clickHandler);
        removeEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
        removeEventListener(KeyboardEvent.KEY_DOWN, typingHandler);

        Audio.stopAll();
    }

    /** Called when the round starts - enables display. */
    public function roundStarted (duration :int) :void
    {
        if (_wordfield.text == "") {
            _wordfield.stage.focus = _wordfield;
        }

        _logger.clear();

        logRoundStarted();
        setEnableState(true);

        Audio.playMusic(Audio.theme);
    }

    /** Called when the round ends - disables display. */
    public function roundEnded (model :Model, board :Scoreboard) :void
    {
        removeAllSelectedLetters();

        setEnableState(false);

        var topPlayers :Array = board.getWinnerIds().map(model.getName);

        _logger.log();
        _logger.log("Winners (" + board.getTopScore() + " pts): " + topPlayers.join(", "), Logger.SUMMARY_H1);
        logSummary(model, model.getWords());
        _logger.log("Next round will begin shortly...");

        // Disabled for now -- Bruno
        //_stats.show(model, board);

        Audio.playMusic(Audio.bubbles);
    }

    /** If this board letter is already selected as part of the word, returns true.  */
    public function isLetterSelectedAtPosition (position :Point) :Boolean
    {
        var pointMatches :Function = function (item :Point, index :int, array :Array) :Boolean {
                return (item.equals(position));
            };

        return _word.some(pointMatches);
    }

    /** Returns coordinates of the most recently added word, or null. */
    public function getLastLetterPosition () :Point
    {
        if (_word.length > 0) {
            return _word[_word.length - 1] as Point;
        }

        return null;
    }

    /** Adds a new letter to the word (by adding a pair of coordinates) */
    public function selectLetterAtPosition (position :Point) :void
    {
        _word.push(position);
        updateLetterSelection(_word);

        Audio.click.play();
    }

    /** Removes last selected letter from the word (if applicable) */
    public function removeLastSelectedLetter () :void
    {
        if (_word.length > 0) {
            _word.pop();
            updateLetterSelection(_word);
        }
    }

    /** Removes all selected letters, resetting the word. */
    public function removeAllSelectedLetters () :void
    {
        _word = new Array();
        updateLetterSelection(_word);
    }


    /** Called from the model, this accessor modifies the display /text/
        for one letter at specified board /position/. */
    public function letterDidChange (position :Point, text :String) :void
    {
        Assert.isTrue(isValidBoardPosition(position),
                     "Bad position received in Display:setText");
        _letters[position.x][position.y].setText(text);
    }

    /** Retrieves the text label from one letter at specified board /position/. */
    public function getLetter (position :Point) :String
    {
        Assert.isTrue(isValidBoardPosition(position),
                     "Bad position received in Display:getText");
        return _letters[position.x][position.y].getText();
    }

    /** Called from the model, this accessor takes an array of /points/,
        marks letters at those positions as selected, and all others as deselected,
        and updates the text box. */
    // TODO: This should not be called when the word is submitted
    public function updateLetterSelection (points :Array) :void
    {
        Assert.isNotNull(points, "Invalid points array!");

        // First, deselect everything
        for (var x :int = 0; x < _letters.length; x++) {
            for (var y :int = 0; y < _letters[x].length; y++) {
                _letters[x][y].setSelection(false);
            }
        }

        // Now select just the word - and, at the same time,
        // assemble the word string.
        var word :String = "";
        for each (var p :Point in points) {
            var l :Letter = _letters[p.x][p.y];
            l.setSelection(true);
            word += l.getText();
        }

        // Finally, update the word
        _wordfield.text = word;
    }

    public function logBonus (bonus :Number) :void
    {
        _logger.log();
        _logger.log("First-found Bonus: +" + bonus + " pts", Logger.SUMMARY_H2);
    }

    protected static function pulsate (tf :TextField, from :uint, to :uint, duration :Number) :void
    {
        // Because Tweener doesn't seem to like doing uint color tweens on arbitrary properties:
        // We have to fudge it by having this update listener do the actual color change
        var colorTween :Function = function () :void {
            tf.textColor = ColorUtil.blend(to, from, this.prog);
        };

        // Fade to pulse color
        Tweener.addTween({prog: 0}, { prog: 1, time: duration, onUpdate: colorTween,
                transition: "easeOutExpo" });

        // Fade back to normal
        Tweener.addTween({prog: 1}, { prog: 0, delay: duration,
                time: duration, onUpdate: colorTween,
                transition: "easeInExpo" });
    }

    public function logSuccess (word :String, score :Number, bonus :Number, points :Array) :void
    {
        var msg :String = word + " (" + score + ")";

        _logger.logListItem(msg, (bonus > 0 ? Logger.FOUND_WORD_FIRST : Logger.FOUND_WORD));

        // Visibly pulse the word on the board
        for each (var p :Point in points) {
            pulsate(_letters[p.x][p.y]._label,
                    Resources.TEXT_COLOR_NORMAL, Resources.TEXT_COLOR_PULSE, Resources.PULSE_DURATION);
        }

        Audio.success.play();
    }

    /** Updates the log with a failure message */
    public function logAlreadyClaimed (word :String) :void
    {
        _logger.logListItem(word, Logger.DUPLICATE_WORD);
        Audio.error.play();
    }

    /** Updates the log with an invalid word message */
    public function logInvalidWord (word :String) :void
    {
        _logger.logListItem(word, Logger.INVALID_WORD);
        Audio.error.play();
    }

    /** Adds a "please wait" message */
    public function logPleaseWait () :void
    {
        _logger.log("Please wait for");
        _logger.log("   the next round.");
    }

    /** Adds a "round started" message */
    public function logRoundStarted () :void
    {
        _logger.log("New round started!");
    }

    public function logSummary (model :Model, words :Object) :void
    {
        //var featured :Array = words.sortOn("score", Array.DESCENDING | Array.NUMERIC).slice(0, 5);
        var all :Array = words.sortOn(["score", "word"], [Array.DESCENDING | Array.NUMERIC, null]);

        _logger.log();
        _logger.log("Top words this round:", Logger.SUMMARY_H2);
        for each (var w :Object in all.slice(0, 5)) {
            _logger.log(w.word + " (" + w.score + "): " + w.playerIds.map(model.getName).join(", "));
        }
        _logger.log();
        _logger.log("All words found:", Logger.SUMMARY_H2);
        for each (var m :Object in all) {
            _logger.logListItem(m.word);
        }
        _logger.log();
    }

    /** Sets scores based on the scoreboard. */
    public function updateScores (board :Scoreboard) :void
    {
        //_gameCtrl.local.clearScores();
        //_gameCtrl.local.setMappedScores(board.getScores());
    }

    /** Sets timer based on specified number. */
    public function setTimer (remainingsecs :Number) :void
    {
        var minutes :Number = Math.floor(remainingsecs / 60);
        var seconds :Number = Math.abs(remainingsecs % 60);

        var mm :String = StringUtil.prepad(minutes.toString(), 2, "0");
        var ss :String = StringUtil.prepad(seconds.toString(), 2, "0");
        _timerbox.text = mm + ":" + ss;

        // Pulse every 30 seconds, and every second at 10 seconds left
        if (seconds == 30 || (minutes == 0 && seconds <= 10)) {
            pulsate(_timerbox, Resources.COUNTDOWN_COLOR, 0xffa500, 0.2);
        }
        // check if we need to start hiding the inter-round display
        //if (! getEnableState() && int(remainingsecs) == Stats.HIDE_DELAY) {
        //    _stats.hide();
        //}
    }
    
    // PRIVATE EVENT HANDLERS

    private function clickHandler (event :MouseEvent) :void
    {
        var p :Point = new Point(event.stageX, event.stageY);
        var i :Point = screenToBoard(p);
        if (i != null) {
            tryAddLetter(i);
        }
    }

    private function mouseHandler (event :MouseEvent) :void
    {
        var p :Point = new Point(event.stageX, event.stageY);
        var i :Point = screenToBoard(p);
        setCursor(i);
    }

    /**
     * Called when the user types a letter inside the word field.
     */
    public function processKeystroke (event :KeyboardEvent) :void
    {
        // The user typed in some character. Typing is incompatible
        // with mouse selection, so if there's already anything selected
        // by clicking, clear it all, and start afresh.
    }

    protected function submitWord () :void
    {
        try {
            _controller.tryScoreWord(_wordfield.text);
        } catch (e :TangleWordError) {
            _logger.log(e.message, Logger.INVALID_WORD);
            Audio.error.play();
        }

        removeAllSelectedLetters();
    }

    /** Called when the user clicks the Ready button. */
    protected function handleReady (... etc) :void
    {
        _gameCtrl.net.agent.sendMessage(Server.READY, _gameCtrl.game.getMyId());
        _readyButton.visible = false;
    }

    /** Called when the user types a letter inside the word field. */
    public function typingHandler (event :KeyboardEvent) :void
    {
        switch (event.keyCode) {
        case KeyboardCodes.ENTER:
            // If it's an ENTER, try scoring.
            if (_wordfield.text != "") {
                submitWord();
            }
            break;

        // Instaclear the line when you hit escape
        case KeyboardCodes.ESCAPE:
            _wordfield.text = "";
            break;

        default:
            // It's just a regular keystroke. Let the controller know.
            processKeystroke(event);
            if (getLastLetterPosition() != null) {
                removeAllSelectedLetters();
            }
            Audio.click.play();
            break;
        }
    }



    // PRIVATE HELPER FUNCTIONS

    /** Initializes storage, and creates letters at specified positions on the board */
    private function initializeLetters () :void
    {
        // Create the 2D array
        var count :int = Properties.LETTERS;
        _letters = new Array(count);
        for (var x :int = 0; x < count; x++) {
            _letters[x] = new Array(count);
            for (var y :int = 0; y < count; y++) {
                var l :Letter = new Letter(this);   // make a new instance
                var p :Point = boardToScreen(new Point(x, y));
                l.x = p.x;
                l.y = p.y;
                addChild(l);          // add to display
                _letters[x][y] = l;    // add to list
            }
        }
    }

    /** Initializes word display, countdown timer, etc. */
    private function initializeUI (version :String) :void
    {
        _okbutton = new Button(new Resources.buttonOkOver(),
                               new Resources.buttonOkOut(),
                               submitWord);
        doPosition(_okbutton, Properties.OKBUTTON);
        addChild(_okbutton);

        _readyButton = new SimpleTextButton("Ready!");
        _readyButton.addEventListener(MouseEvent.CLICK, handleReady);
        doPosition(_readyButton, Properties.READYBUTTON);
        addChild(_readyButton);

        _wordfield = new TextField();
        _wordfield.defaultTextFormat = Resources.makeFormatForUI();
        _wordfield.borderColor = Resources.defaultBorderColor;
        _wordfield.type = TextFieldType.INPUT;
        _wordfield.text = INPUT_HINT;
        _wordfield.restrict = "A-Za-z";

        var callback :Function = function (... ignore): void {
            _wordfield.text = "";
            _wordfield.removeEventListener(FocusEvent.FOCUS_IN, callback);
        };
        _wordfield.addEventListener(FocusEvent.FOCUS_IN, callback);

        doLayout(_wordfield, Properties.WORDFIELD);
        addChild(_wordfield);

        var tf :TextField = new TextField();
        doLayout(tf, Properties.LOGFIELD);
        tf.x = tf.y = 0;
        tf.width -= ScrollBar.WIDTH; // Shrink a bit to avoid spilling under the scrollbar
        _logger = new Logger(tf);
        doLayout(_logger, Properties.LOGFIELD);
        addChild(_logger);

        /*
        _timer = new CountdownTimer();
        doLayout(_timer, Properties.TIMER);
        addChild(_timer);
        */

        _timerbox = new TextField();
        _timerbox.selectable = false;
        _timerbox.defaultTextFormat = Resources.makeFormatForCountdown();
        _timerbox.borderColor = Resources.defaultBorderColor;
//        _timerbox.border = true;
        doLayout(_timerbox, Properties.TIMER);
        addChild(_timerbox);
        
        _splash = new Splash();
        addChild(_splash);

        //_stats = new Stats(_gameCtrl);
        //addChild(_stats);
    }

    /** Helper function that copies x, y, width and height properties
        on an object from a given rectangle. */
    private function doLayout (o :DisplayObject, rect :Rectangle) :void
    {
        o.x = rect.x;
        o.y = rect.y;
        o.width = rect.width;
        o.height = rect.height;
    }

    /** Helper function that updates display object position. */
    private function doPosition (o :DisplayObject, p :Point) :void
    {
        o.x = p.x;
        o.y = p.y;
    }

    /** Takes a new letter from the UI, and checks it against game logic. */
    public function tryAddLetter (position :Point) :void
    {
        if (_controller.enabled) {
            // Position of the letter on top of the stack 
            var lastLetterPosition :Point = getLastLetterPosition();
            
            // Did the player click on the first letter? If so, clear out
            // the current word field, and add it.
            var noPreviousLetterFound :Boolean = (lastLetterPosition == null);
            if (noPreviousLetterFound) {
                removeAllSelectedLetters();
                selectLetterAtPosition(position);
                return;
            }
            
            // Did the player click on the last letter they added? If so, remove it.
            if (position.equals(lastLetterPosition)) {
                removeLastSelectedLetter();
                return;
            }
            
            // Did the player click on an empty letter next to the last selected one?
            // If so, add it.
            var isValidNeighbor :Boolean = (areNeighbors(position, lastLetterPosition) &&
                                             ! isLetterSelectedAtPosition(position));
            if (isValidNeighbor) {
                selectLetterAtPosition(position);
                return;
            }
            
            // Player clicked on an invalid position - don't do anything
        }
    }

    /** Determines whether the given /position/ is a neighbor of specified /original/
        position (defined as being one square away from each other). */
    protected function areNeighbors (position :Point, origin :Point) :Boolean
    {
        return (! position.equals(origin) &&
                Math.abs(position.x - origin.x) <= 1 &&
                Math.abs(position.y - origin.y) <= 1);
    }
    


    /** Enables or disables a number of UI elements. */
    protected function setEnableState (value :Boolean) :void
    {
        // Set each letter
        for (var x :int = 0; x < _letters.length; x++) {
            for (var y :int = 0; y < _letters[x].length; y++) {
                _letters[x][y].isLetterEnabled = value;
            }
        }

        // Set other UI elements
        _okbutton.visible = value;
        _wordfield.visible = value;

        _readyButton.visible = ! value;
    }

    /** Are we in the middle of a round? */
    private function getEnableState () :Boolean
    {
        return _okbutton.visible; // this is controlled directly by enabled state
    }
    
    /**
     * Set cursor over a letter at specified board /location/, and removes the cursor
     * from the previous letter. If the location point is null, it just removes
     * the cursor from the previous letter.
     */
    private function setCursor (location :Point) :void
    {
        var l :Letter = null;
        if (location != null && _lastCursor != null && location.equals(_lastCursor)) {
            // Cursor hasn't changed; ignore.
            return;
        }

        // Remove old cursor, if any
        if (_lastCursor != null) {
            l = _letters[_lastCursor.x][_lastCursor.y];
            l.isCursorEnabled = false;
            _lastCursor = null;
        }

        // Set the new cursor
        if (location != null) {
            l = _letters[location.x][location.y];
            l.isCursorEnabled = true;
            _lastCursor = location;
        }
    }

    /** Helper function: converts screen coordinate to a board square position.
        If the screen coordinate falls outside the board, returns /null/. */
    private function screenToBoard (p :Point) :Point
    {
        // remove offset
        var newp :Point = globalToLocal(p).subtract(Properties.BOARDPOS);
//        var newp :Point = new Point(p.x - Properties.BOARD.x, p.y - Properties.BOARD.y);

        // convert to board coordinates
        newp.x = Math.floor(newp.x / Properties.LETTER_SIZE);
        newp.y = Math.floor(newp.y / Properties.LETTER_SIZE);

        // check bounds and return
        return isValidBoardPosition(newp) ? newp : null;
    }

    /** Helper function: converts board square coordinate into the screen coordinates
        of the upper left corner of that square. If the board position falls outside
        the board, returns /null/. */
    private function boardToScreen (p :Point) :Point
    {
        if (! isValidBoardPosition(p)) {
            return null;
        }

        var p :Point = new Point(p.x * Properties.LETTER_SIZE + Properties.BOARD.x,
                                  p.y * Properties.LETTER_SIZE + Properties.BOARD.y);

        return p;
    }

    /** Checks if a given point is inside board dimension bounds */
    private function isValidBoardPosition (p :Point) :Boolean
    {
        return (p.x >= 0 && p.x < Properties.LETTERS &&
                p.y >= 0 && p.y < Properties.LETTERS);
    }

    protected var _readyButton :SimpleTextButton;

    // PRIVATE VARIABLES

    /** Whirled controller */
    private var _gameCtrl :GameControl;

    /** Game logic */
    private var _controller :Controller;

    /** Overall game background */
    private var _background :DisplayObject;

    /** Storage for each letter object */
    private var _letters :Array;

    /** Board position of the currently cursored letter */
    private var _lastCursor :Point;

    /** Text box containing the currently guessed word */
    private var _wordfield :TextField;

    /** The OK button, of course */
    private var _okbutton :Button;

    /** Logger text box */
    private var _logger :Logger;

    /** Timer display */
//    private var _timer :CountdownTimer;
    private var _timerbox :TextField;

    /** Splash screen */
    private var _splash :Splash;

    /** Current word data (as array of board coordinates) */
    private var _word :Array;

    /** Stats screen */
    //private var _stats :Stats;

    protected static const INPUT_HINT :String = "< type here >";
}

} // package
