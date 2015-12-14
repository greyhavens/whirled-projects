package
{

import flash.events.Event;

import com.threerings.util.Assert;
import com.whirled.game.CoinsAwardedEvent;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import com.whirled.contrib.Scoreboard;

import flash.geom.Point;
import flash.utils.Dictionary;

/**
   GameModel is a game-specific interface to the networked data set.
   It contains accessors to get the list of players, scores, etc.
*/

public class Model
{
    //
    //
    // PUBLIC METHODS

    public function Model (gameCtrl :GameControl, observer :Observer = null) :void
    {
        // Squirrel the pointers away
        _gameCtrl = gameCtrl;
        _observer = observer;

        // Register for updates
        _gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        
        // Initialize game data storage
        initializeStorage();
    }

    public function handleUnload (event :Event) :void
    {
        _gameCtrl.net.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
    }        
    
    /** Called at the beginning of a round - push my scoreboard on everyone. */
    public function roundStarted () :void
    {
        // Unused
    }

    /**
     * Ensures that the word is a valid selection and exists on the board.
     * @return Coord array of the letter locations.
     * @throws TangleWordError if the validation failed.
     */
    public function validate (word :String) :Array
    {
        // First, check to make sure it's of the correct length (in characters)
        if (word.length < Properties.MIN_WORD_LENGTH) {
            throw new TangleWordError("Words must be at least " + Properties.MIN_WORD_LENGTH + " letters.");
        }

        // Check if this word exists on the board
        var points :Array = wordExistsOnBoard(word);
        if (points == null) {
            throw new TangleWordError(word + " is not on the board!");
        }

        return points;
    }

    /** Checks if the word exists on the board, by doing an exhaustive
        search of all possible combinations. */
    protected function wordExistsOnBoard (word :String) :Array
    {
        if (word.length == 0) return null;

        for (var x :int = 0; x < Properties.LETTERS; x++) {
            for (var y :int = 0; y < Properties.LETTERS; y++) {
                var points :Array = [];
                if (wordExists (word, 0, x, y, points)) {
                    return points;
                }
            }
        }

        return null;
    }

    protected function wordExists (
        word :String, start :Number, x :Number, y :Number, visited :Array) :Boolean
    {
        // recursion finished successfully.
        if (start >= word.length) return true;

        // if the letter doesn't match, fail.
        var l :String = _board[x][y];
        if (start + l.length > word.length || word.indexOf (l, start) != start) {
            return false;
        }

        // if we've seen it before, fail.
        for each (var p :Point in visited) {
            if (p.x == x && p.y == y) return false;
        }

        // finally, check all neighbors
        visited.push(new Point (x, y));
        for (var dx :int = -1; dx <= 1; dx++) {
            for (var dy :int = -1; dy <= 1; dy++) {
                var xx :int = x + dx;
                var yy :int = y + dy;
                if (xx >= 0 && xx < Properties.LETTERS && yy >= 0 && yy < Properties.LETTERS &&
                        wordExists(word, start + l.length, xx, yy, visited)) {
                    return true;
                }
            }
        }
        visited.pop();

        return false;
    }

    /** Sends out a message to everyone, informing them about a new letter set.
     *  The array contains strings corresponding to the individual letters. */
    public function sendNewLetterSet (a :Array) :void
    {
        _gameCtrl.net.set(LETTER_SET, a);
    }

    /** Called only when joining an existing game, tells the model to update itself
     *  from the dobj, and by requesting whatever transient data is needed from peer in control. */
    public function updateFromExistingGame () :void
    {
        updateLettersOnBoard();
        //_gameCtrl.net.sendMessage (SCOREBOARD_REQUEST_MSG, _scoreboard.internalScoreObject);
    }

    
    //
    //
    // EVENT HANDLERS

    /** From PropertyChangedListener: deal with distributed game data changes */
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == LETTER_SET) {
            updateLettersOnBoard();
        }
    }

    //
    //
    // PRIVATE METHODS

    /** Re-reads letters from the shared object, and displays them on board. */
    private function updateLettersOnBoard () :void
    {
        var letters :Array = _gameCtrl.net.get(LETTER_SET) as Array;
        if (letters != null) {
            setGameBoard(letters);
        }
    }

    /** Initializes letter and word storage */
    private function initializeStorage () :void
    {
        // First, the board
        _board = new Array(Properties.LETTERS);
        for (var x :int = 0; x < _board.length; x++) {
            _board[x] = new Array (Properties.LETTERS);
            for (var y :int = 0; y < _board[x].length; y++) {
                _board[x][y] = "!";
            }
        }
    }

    /** Sets up a new game board, based on a flat array of letters. */
    private function setGameBoard (s :Array) :void
    {
        // Copy them over to the data set
        for (var x :int = 0; x < Properties.LETTERS; x++) {
            for (var y :int = 0; y < Properties.LETTERS; y++) {
                updateBoardLetter(new Point(x, y), s [x * Properties.LETTERS + y]);
            }
        }
    }

    /** Pick all the words that have currently been found. */
    public function getWords () :Array
    {
        var words :Array = new Array();
        var props :Array = _gameCtrl.net.getPropertyNames(WORD_NAMESPACE) || [ ];

        for each (var i :String in props) {
            var word :String = i.substring(WORD_NAMESPACE.length);
            words.push({
                word: word,
                score: getWordScore(word),
                playerIds: _gameCtrl.net.get(i)
            });
        }

        return words;
    }

    public function getWordScore (word :String) :Number
    {
        // return 1 point for 4 letter words, and 1 additional point for each additional letter
        return (word.length - 3);
    }

    /** Updates a single letter at specified /position/ to display a new /text/.  */
    private function updateBoardLetter (position :Point, text :String) :void
    {
        Assert.isNotNull(_board, "Board needs to be initialized first.");
        _board[position.x][position.y] = text;

        if (_observer != null) {
            _observer.letterDidChange(position, text);
        }
    }

    /** Converts player id to name. */
    public function getName (playerId :int, ... ignored) :String
    {
        return _gameCtrl.game.getOccupantName(playerId);
    }

    /**
     * The maximum number first-found words that can count towards your bonus,
     * in relation to the total number of found words.
     */
    protected static const BONUS_CAP_RATIO :Number = 0.5;

    // TODO: Reorder all this, remove useless comments

    //
    //
    // PRIVATE CONSTANTS

    /** Message types */
    private static const LETTER_SET :String = "Letter Set Update";
    private static const ADD_SCORE_MSG :String = "Score Update";
    private static const SCOREBOARD_UPDATE_MSG :String = "Scoreboard Update";
    private static const SCOREBOARD_REQUEST_MSG :String = "Scoreboard Request";

    protected static const WORD_NAMESPACE :String = "word:";

    //
    //
    // PRIVATE VARIABLES

    /**
     * Property for number of first-found words for each player
     * (Dictionary by playerId) for the round-end bonus.
     */
    protected static const FIRST_FINDS :String = "firstFinds";

    /** Main game control structure */
    private var _gameCtrl :GameControl;

    /** Game board data */
    private var _board :Array;

    /** Observer to notify updates to. */
    private var _observer :Observer;
}
}
