package
{

import flash.display.Sprite;
import flash.display.Stage;
import flash.display.SimpleButton;
import flash.display.DisplayObject;
import flash.display.Graphics;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import com.threerings.util.Assert;
import com.threerings.util.StringUtil;

import com.whirled.game.GameControl;

/**
 * The Display class represents the game visualization, including UI
 * and game state display.
 */
public class Display extends Sprite
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
        addEventListener(KeyboardEvent.KEY_UP, typingHandler);

        _logger.Log(version);
    }

    /** Shutdown handler */
    public function handleUnload (event :Event) :void
    {
        removeEventListener(MouseEvent.CLICK, clickHandler);
        removeEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
        removeEventListener(KeyboardEvent.KEY_UP, typingHandler);
    }

    /** Called when the round starts - enables display. */
    public function roundStarted (duration :int) :void
    {
        logRoundStarted();
        setEnableState(true);
    }

    /** Called when the round ends - disables display. */
    public function roundEnded (board :Scoreboard) :void
    {
        setEnableState(false);

        _stats.show(board);
    }

    /** Called from the model, this accessor modifies the display /text/
        for one letter at specified board /position/. */
    public function setLetter (position :Point, text :String) :void
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
        for (var x :int = 0; x < _letters.length; x++)
        {
            for (var y :int = 0; y < _letters[x].length; y++)
            {
                _letters[x][y].setSelection(false);
            }
        }

        // Now select just the word - and, at the same time,
        // assemble the word string.
        var word :String = "";
        for each (var p :Point in points)
        {
            var l :Letter = _letters[p.x][p.y];
            l.setSelection(true);
            word += l.getText();
        }

        // Finally, update the word
        _wordfield.text = word;
    }

    /** Updates the log with a success message */
    public function logSuccess (player :String, word :String, score :Number) :void
    {
        _logger.Log(StringUtil.truncate(player, 18, "...") + ": +" + score + " (" + word + ")");
    }

    /** Updates the log with a failure message */
    public function logAlreadyClaimed (player :String, word :String) :void
    {
        _logger.Log(StringUtil.truncate(player, 18, "...") + ":");
        _logger.Log("  " + word + " already claimed.");
    }

    /** Updates the log with an invalid word message */
    public function logInvalidWord (player :String, word :String) :void
    {
        _logger.Log(StringUtil.truncate(player, 18, "...") + ":");
        _logger.Log("  " + word + " is not valid.");
    }

    /** Adds a "please wait" message */
    public function logPleaseWait () :void
    {
        _logger.Log("Please wait for");
        _logger.Log("   the next round.");
    }

    /** Adds a "round started" message */
    public function logRoundStarted () :void
    {
        _logger.Log("New round started!");
    }

    /** Adds a round summary message */
    public function logRoundEnded (points :Number, flow :Number) :void
    {
        _logger.Log("Round ended: " + points + " points");
        _logger.Log("You received " + flow + " flow!");
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

        // check if we need to start hiding the inter-round display
        if (! getEnableState() && int(remainingsecs) == Stats.HIDE_DELAY) {
            _stats.hide();
        }
    }
    
    // PRIVATE EVENT HANDLERS

    private function clickHandler (event :MouseEvent) :void
    {
        var p :Point = new Point(event.stageX, event.stageY);
        var i :Point = screenToBoard(p);
        if (i != null)
        {
            _controller.tryAddLetter(i);
        }
    }

    private function mouseHandler (event :MouseEvent) :void
    {
        var p :Point = new Point(event.stageX, event.stageY);
        var i :Point = screenToBoard(p);
        setCursor(i);
    }

    protected function submitWord () :void
    {
        _controller.tryScoreWord(_wordfield.text);
        _wordfield.text = "";
    }

    /** Called when the user types a letter inside the word field. */
    public function typingHandler (event :KeyboardEvent) :void
    {
        switch (event.keyCode)
        {
        case 13:
            // If it's an ENTER, try scoring.
            if (_wordfield.text != "") {
                submitWord();
            }
            break;

        default:
            // It's just a regular keystroke. Let the controller know.
            _controller.processKeystroke(event);
        }
    }



    // PRIVATE HELPER FUNCTIONS

    /** Initializes storage, and creates letters at specified positions on the board */
    private function initializeLetters () :void
    {
        // Create the 2D array
        var count :int = Properties.LETTERS;
        _letters = new Array(count);
        for (var x :int = 0; x < count; x++)
        {
            _letters[x] = new Array(count);
            for (var y :int = 0; y < count; y++)
            {
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

        _wordfield = new TextField();
        _wordfield.defaultTextFormat = Resources.makeFormatForUI();
        _wordfield.borderColor = Resources.defaultBorderColor;
//        _wordfield.border = true;
        _wordfield.type = TextFieldType.INPUT;
        _wordfield.text = "< type here >";
        doLayout(_wordfield, Properties.WORDFIELD);
        addChild(_wordfield);

        _logger = new Logger ();
        doLayout(_logger, Properties.LOGFIELD);
        addChild(_logger);

//        _logger.scrollRect = new Rectangle(0, 0, 50, 50);
//        var box :ScrollContainer = new ScrollContainer(_logger, 100, 200);
//        this.addChild(box);

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

        _stats = new Stats();
        addChild(_stats);
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
    
    /** Enables or disables a number of UI elements. */
    private function setEnableState (value :Boolean) :void
    {
        // Set each letter
        for (var x :int = 0; x < _letters.length; x++)
        {
            for (var y :int = 0; y < _letters[x].length; y++)
            {
                _letters[x][y].isLetterEnabled = value;
            }
        }

        // Set other UI elements
        _okbutton.visible = value;
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

        if (location != null &&
            _lastCursor != null &&
            location.equals(_lastCursor))
        {
            // Cursor hasn't changed; ignore.
            return;
        }

        // Remove old cursor, if any
        if (_lastCursor != null)
        {
            l = _letters[_lastCursor.x][_lastCursor.y];
            l.isCursorEnabled = false;
            _lastCursor = null;
        }

        // Set the new cursor
        if (location != null)
        {
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
        if (! isValidBoardPosition(newp))
        {
            return null;
        }

        return newp;
    }

    /** Helper function: converts board square coordinate into the screen coordinates
        of the upper left corner of that square. If the board position falls outside
        the board, returns /null/. */
    private function boardToScreen (p :Point) :Point
    {
        if (! isValidBoardPosition(p))
        {
            return null;
        }

        var p :Point = new Point(p.x * Properties.LETTER_SIZE + Properties.BOARD.x,
                                  p.y * Properties.LETTER_SIZE + Properties.BOARD.y);

        return p;
    }

    /** Checks if a given point is inside board dimension bounds */
    private function isValidBoardPosition (p :Point) :Boolean
    {
        return(p.x >= 0 && p.x < Properties.LETTERS &&
                p.y >= 0 && p.y < Properties.LETTERS);
    }



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

    /** Stats screen */
    private var _stats :Stats;
}

} // package
