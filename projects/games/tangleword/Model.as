package
{

import flash.events.Event;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;

import com.whirled.FlowAwardedEvent;
import com.whirled.WhirledGameControl;

import flash.geom.Point;

/**
   GameModel is a game-specific interface to the networked data set.
   It contains accessors to get the list of players, scores, etc.
*/

public class Model
    implements MessageReceivedListener, PropertyChangedListener
{
    //
    //
    // PUBLIC METHODS

    public function Model (gameCtrl :WhirledGameControl, display :Display) :void
    {
        // Squirrel the pointers away
        _gameCtrl = gameCtrl;
        _display = display;
        _playerName = _gameCtrl.getOccupantName(_gameCtrl.getMyId());

        // Register for updates
        _gameCtrl.registerListener (this);
        _gameCtrl.addEventListener(FlowAwardedEvent.FLOW_AWARDED, flowAwarded);

        // Initialize game data storage
        initializeStorage ();
    }

    public function get scoreboard () :Scoreboard
    {
        return _scoreboard;
    }

    /** Called at the beginning of a round - push my scoreboard on everyone. */
    public function roundStarted () :void
    {
        if (_gameCtrl.amInControl ())
        {
            // Share the scoreboard
            _gameCtrl.sendMessage (SCOREBOARD_UPDATE_MSG, _scoreboard.internalScoreObject);
        }
    }

    public function endRound () :void
    {
        if (!_gameCtrl.amInControl()) {
            return;
        }

        var playerIds :Array = [];
        var scores :Array = [];
        for each (var playerId :int in _gameCtrl.getOccupantIds()) {
            var score :int = _scoreboard.getRoundScore(_gameCtrl.getOccupantName(playerId));
            if (score > 0) {
                playerIds.push(playerId);
                scores.push(score);
            }
        }
        _gameCtrl.endGameWithScores(playerIds, scores, WhirledGameControl.TO_EACH_THEIR_OWN);
    }

    /** Called when the round ends - cleans up data, and awards flow! */
    public function roundEnded () :void
    {
        removeAllSelectedLetters ();
        _scoreboard.resetWordClaims();
    }

    //
    //
    // LETTER ACCESSORS

    /** If this board letter is already selected as part of the word, returns true.  */
    public function isLetterSelectedAtPosition (position :Point) :Boolean
    {
        var pointMatches :Function =
            function (item :Point, index :int, array :Array) :Boolean
            {
                return (item.equals (position));
            };

        return _word.some (pointMatches);
    }

    /** Returns coordinates of the most recently added word, or null. */
    public function getLastLetterPosition () :Point
    {
        if (_word.length > 0)
        {
            return _word[_word.length - 1] as Point;
        }

        return null;
    }

    /** Adds a new letter to the word (by adding a pair of coordinates) */
    public function selectLetterAtPosition (position :Point) :void
    {
        _word.push (position);
        _display.updateLetterSelection (_word);
    }

    /** Removes last selected letter from the word (if applicable) */
    public function removeLastSelectedLetter () :void
    {
        if (_word.length > 0)
        {
            _word.pop ();
            _display.updateLetterSelection (_word);
        }
    }

    /** Removes all selected letters, resetting the word. */
    public function removeAllSelectedLetters () :void
    {
        _word = new Array ();
        _display.updateLetterSelection (_word);
    }

    /** Checks if the word exists on the board, by doing an exhaustive
        search of all possible combinations. */
    public function wordExistsOnBoard (word :String) :Boolean
    {
        // TODO
        // return true;

        if (word.length == 0) return false;

        for (var x :int = 0; x < Properties.LETTERS; x++) {
            for (var y :int = 0; y < Properties.LETTERS; y++) {
                if (wordExists (word, 0, x, y, new Array ()))
                    return true;
            }
        }

        return false;
    }

    protected function wordExists (
        word :String, start :Number, x :Number, y :Number, visited :Array) :Boolean
    {
        // recursion finished successfully.
        if (start >= word.length) return true;

        // if the letter doesn't match, fail.
        var l :String = _board[x][y];
        if (start + l.length > word.length || word.indexOf (l, start) != start)
            return false;

        // if we've seen it before, fail.
        for each (var p :Point in visited) {
            if (p.x == x && p.y == y) return false;
        }

        // finally, check all neighbors
        visited.push (new Point (x, y));
        for (var dx :int = -1; dx <= 1; dx++) {
            for (var dy :int = -1; dy <= 1; dy++) {
                var xx :int = x + dx;
                var yy :int = y + dy;
                if (xx >= 0 && xx < Properties.LETTERS &&
                    yy >= 0 && yy < Properties.LETTERS)
                {
                    if (wordExists (word, start + l.length, xx, yy, visited))
                        return true;
                }
            }
        }
        visited.pop();

        return false;
    }

    //
    //
    // SHARED DATA ACCESSORS

    /** Sends out a message to everyone, informing them about adding
        the new word to their lists. */
    public function addScore (word :String, score :Number, isvalid :Boolean) :void
    {
        var obj :Object = new Object ();
        obj.player = _playerName;
        obj.word = word;
        obj.score = score;
        obj.isvalid = isvalid;

        _gameCtrl.sendMessage (ADD_SCORE_MSG, obj);

        // reset selection
        removeAllSelectedLetters ();
    }

    /** Sends out a message to everyone, informing them about a new letter set.
        The array contains strings corresponding to the individual letters. */
    public function sendNewLetterSet (a :Array) :void
    {
        _gameCtrl.set (LETTER_SET, a);
    }

    /** Called only when joining an existing game, tells the model to update itself
     *  from the dobj, and by requesting whatever transient data is needed from peer in control. */
    public function updateFromExistingGame () :void
    {
        updateLettersOnBoard();
        _gameCtrl.sendMessage (SCOREBOARD_REQUEST_MSG, _scoreboard.internalScoreObject);
    }

    
    //
    //
    // EVENT HANDLERS

    /** From MessageReceivedListener: checks for special messages signaling
        game data updates. */
    public function messageReceived (event :MessageReceivedEvent) :void
    {
//        _gameCtrl.localChat (_gameCtrl.amInControl () ?
//                           "Model: I AM THE HOST! :)" :
//                           "Model: I'm not the host. :(");

        switch (event.name)
        {
        case ADD_SCORE_MSG:
            // Store the score in a local data structure
            addWordToScoreboard (
                event.value.player, event.value.word, event.value.score, event.value.isvalid);
            updateScoreDisplay ();
            break;

        case SCOREBOARD_UPDATE_MSG:
            // Take the scoreboard we've received, and use it instead of
            // our previous one.
            Assert.Fail ("Clobbering existing scoreboard...");
            _scoreboard.internalScoreObject = event.value;
            updateScoreDisplay ();
            break;

        case SCOREBOARD_REQUEST_MSG:
            // Someone requested my current scoreboard - if i'm in control, i should send it
            if (_gameCtrl.amInControl ())
            {
                var playerId :int = int(event.value);
                _gameCtrl.sendMessage (
                    SCOREBOARD_UPDATE_MSG, _scoreboard.internalScoreObject, playerId);
            }
            break;

        default:
            // Ignore any other messages; they're not for us.

        }

    }

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
        var letters :Array = _gameCtrl.get(LETTER_SET) as Array;
        if (letters != null) {
            setGameBoard(letters);
        }
    }

    /** Called when flow is awarded at the end of the round. */
    protected function flowAwarded (event :FlowAwardedEvent) :void
    {
        var roundScore :int = _scoreboard.getRoundScore(_playerName);
        if (roundScore > 0) {
            _display.logRoundEnded(roundScore, event.amount);
        }
    }

    /** Resets the currently guessed word */
    private function resetWord () :void
    {
        _word = new Array ();
    }

    /** Initializes letter and word storage */
    private function initializeStorage () :void
    {
        // First, the board
        _board = new Array (Properties.LETTERS);
        for (var x :int = 0; x < _board.length; x++) {
            _board[x] = new Array (Properties.LETTERS);
            for (var y :int = 0; y < _board[x].length; y++) {
                _board[x][y] = "!";
            }
        }

        // Second, the currently assembled word
        resetWord ();

        // Third, make a new scoreboard
        _scoreboard = new Scoreboard ();
    }

    /** Sets up a new game board, based on a flat array of letters. */
    private function setGameBoard (s :Array) :void
    {
        // Copy them over to the data set
        for (var x :int = 0; x < Properties.LETTERS; x++) {
            for (var y :int = 0; y < Properties.LETTERS; y++) {
                updateBoardLetter (new Point (x, y), s [x * Properties.LETTERS + y]);
            }
        }
    }

    /**
       Checks if the word is not in the scoreboard already, and if it isn't, adds it.
       If the word is not valid, prints out a message.
     */
    private function addWordToScoreboard (
        player :String, word :String, score :Number, isvalid :Boolean) :void
    {
        // if this message came in after the end of the round, just ignore it
        if (!_gameCtrl.isInPlay()) {
            return;
        }

        // if the word is invalid, display who tried to claim it
        if (! isvalid) {
            _display.logInvalidWord (player, word);
            return;
        }

        // if the word is valid and not claimed, score!
        if (! _scoreboard.isWordClaimed (word)) {
            _scoreboard.addWord (player, word, score);
            _display.logSuccess (player, word, score);
            return;
        }

        // by this point, the word is valid and already claimed.
        // if this was my word, let me know.
        if (_playerName == player) {
            _display.logAlreadyClaimed (player, word);
            return;
        }

        // the word was valid and already claimed, when another player tried to claim it.
        // just ignore.
    }

    /** Updates a single letter at specified /position/ to display a new /text/.  */
    private function updateBoardLetter (position :Point, text :String) :void
    {
        Assert.NotNull (_board, "Board needs to be initialized first.");
        _board[position.x][position.y] = text;
        _display.setLetter (position, text);
    }

    /** Updates the total scores displayed on the board */
    private function updateScoreDisplay () :void
    {
        _display.updateScores (_scoreboard);
    }

    //
    //
    // PRIVATE CONSTANTS

    /** Message types */
    private static const LETTER_SET :String = "Letter Set Update";
    private static const ADD_SCORE_MSG :String = "Score Update";
    private static const SCOREBOARD_UPDATE_MSG :String = "Scoreboard Update";
    private static const SCOREBOARD_REQUEST_MSG :String = "Scoreboard Request";

    //
    //
    // PRIVATE VARIABLES

    /** Main game control structure */
    private var _gameCtrl :WhirledGameControl;

    /** Cache the player's name */
    private var _playerName :String;

    /** Game board data */
    private var _board :Array;

    /** Current word data (as array of board coordinates) */
    private var _word :Array;

    /** Game board view */
    private var _display :Display;

    /** List of players and their scores */
    private var _scoreboard :Scoreboard;
}
}



