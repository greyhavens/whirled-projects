//
// $Id$

package dictattack {

import flash.utils.getTimer;

import com.threerings.util.Random;

import com.threerings.ezgame.MessageReceivedEvent;

import com.whirled.WhirledGameControl;

/**
 * Models and manages the (distributed) state of the board. We model the state of the board as a
 * one dimensional array of letters in row major order.
 */
public class Model
{
    /** The name of the board data distributed value. */
    public static const BOARD_DATA :String = "boardData";

    /** The scores for each player. */
    public static const SCORES :String = "scores";

    /** The current round points for each player. */
    public static const POINTS :String = "points";

    /** An event sent when a word is played. */
    public static const WORD_PLAY :String = "wordPlay";

    /** An event sent when a player requests a letter change. */
    public static const LETTER_CHANGE :String = "letterChange";

    public function Model (size :int, control :WhirledGameControl)
    {
        _size = size;
        _control = control;
        _control.addEventListener(MessageReceivedEvent.TYPE, messageReceived);
    }

    /**
     * Returns the size of the board along one edge.
     */
    public function getBoardSize () :int
    {
        return _size;
    }

    /**
     * Returns the minimum world length.
     */
    public function getMinWordLength () :int
    {
        return getConfig("min_word_len", 4);
    }

    /**
     * Returns the points needed to win the round or -1 if we're in single player mode.
     */
    public function getWinningPoints () :int
    {
        return isMultiPlayer() ? getConfig("pp_round", 15) : -1;
    }

    /**
     * Returns the number of round wins needed to win the game or -1 if we're in single player
     * mode.
     */
    public function getWinningScore () :int
    {
        return isMultiPlayer() ? getConfig("round_wins", 1) : -1;
    }

    /**
     * Returns the number of word changes allowed for this player in a round.
     */
    public function getChangesAllowed () :int
    {
        return isMultiPlayer() ? 2 : 3;
    }

//     /**
//      * Returns the penalty for changing a letter.
//      */
//     public function getChangePenalty () :int
//     {
//         return isMultiPlayer() ? 2 : 3;
//     }

    /**
     * Returns the bonus for perfectly clearing the board.
     */
    public function getPerfectClearBonus () :int
    {
        return 10;
    }

    /**
     * Returns true if this is a multiplayer game.
     */
    public function isMultiPlayer () :Boolean
    {
        return (_control.seating.getPlayerNames().length > 1);
    }

    /**
     * Returns the type of tile at the specified coordinate.
     */
    public function getType (xx :int, yy :int) :int
    {
        var half :int = int(_size/2), quarter :int = int(_size/4);
        if (xx == half && yy == half) {
            return TYPE_TRIPLE;
        } else if ((xx == quarter || xx == (_size-quarter-1)) &&
                   (yy == quarter || yy == (_size-quarter-1))) {
            return TYPE_DOUBLE;
        } else {
            return TYPE_NORMAL;
        }
    }

    /**
     * Called when a round starts.
     */
    public function roundDidStart () :void
    {
        // if we are in control, zero out the points, create a board and publish it
        if (_control.amInControl()) {
            var pcount :int = _control.seating.getPlayerIds().length;
            _control.set(POINTS, new Array(pcount).map(function (): int { return 0; }));
            _control.getDictionaryLetterSet(
                Content.LOCALE, _size*_size, function (letters :Array) :void {
                _control.set(BOARD_DATA, letters);
            });
        }
    }

    /**
     * Called when a round ends. Returns the names of the players that scored points.
     */
    public function roundDidEnd () :String
    {
        var scorer :String = "";
        var points :Array = (_control.get(POINTS) as Array);
        for (var ii :int = 0; ii < points.length; ii++) {
            if (points[ii] >= getWinningPoints()) {
                if (scorer.length > 0) {
                    scorer += ", ";
                }
                scorer += _control.seating.getPlayerNames()[ii];
            }
        }
        return scorer;
    }

    public function highlightWord (board :Board, word :String) :void
    {
        // first reset any existing highlight
        for (var xx :int = 0; xx < _size; xx++) {
            // scan from the bottom upwards looking for the first letter
            for (var yy :int = _size-1; yy >= 0; yy--) {
                var pos :int = yy * _size + xx;
                var l :Letter = board.getLetter(pos);
                if (l != null) {
                    l.setHighlighted(false);
                    break;
                }
            }
        }

        // now highlight the word in question
        var used :Array = new Array();
        for (var ii :int = 0; ii < word.length; ii++) {
            var c :String = word.charAt(ii);
            var idx :int = locateLetter(c, used);
            if (idx == -1) {
                return;
            }
            used.push(idx);
            board.getLetter(idx).setHighlighted(true);
        }
    }

    /**
     * Called by the display when the player submits a word.
     */
    public function submitWord (board :Board, word :String, callback :Function) :void
    {
        if (word.length < getMinWordLength()) {
            callback(word + " is less than " + getMinWordLength() + " letters long.");
            return;
        }

        // make sure this word is on the board and determine the columns used by this word in the
        // process
        var used :Array = new Array();
        for (var ii :int = 0; ii < word.length; ii++) {
            var c :String = word.charAt(ii);
            var idx :int = locateLetter(c, used);
            if (idx == -1) {
                // TODO: play a sound indicating the mismatch
                board.resetLetters(used);
                callback(word + " is not on the board.");
                return;
            }
            used.push(idx);
            board.getLetter(idx).setHighlighted(true);
        }

        // submit the word to the server to see if it is valid
        _control.checkDictionaryWord(
            Content.LOCALE, word, function (word :String, isValid :Boolean) : void {
            if (!isValid) {
                // TODO: play a sound indicating the mismatch
                board.resetLetters(used);
                callback(word + " is not in the dictionary.");
                return;
            }

            // remove our tiles from the distributed state (we do this in individual events so that
            // watchers coming into a game half way through will see valid state), while we're at
            // it, compute our points
            var wpoints :int = used.length - getMinWordLength() + 1;
            var wpos :Array = new Array();
            var ii :int, mult :int = 1;
            for (ii = 0; ii < used.length; ii++) {
                // map our local coordinates back to a global position coordinates
                var xx :int = int(used[ii] % _size);
                var yy :int = int(used[ii] / _size);
                mult = Math.max(TYPE_MULTIPLIER[getType(xx, yy)], mult);
                var pos :int = getPosition(xx, yy);
                _control.setImmediate(BOARD_DATA, null, pos);
                wpos.push(pos);
            }
            wpoints *= mult;

            // broadcast our our played word as a message
            var myidx :int = _control.seating.getMyPosition();
            _control.sendMessage(WORD_PLAY, [ myidx, word, wpoints, mult, wpos ]);

            // update our points
            var points :Array = (_control.get(POINTS) as Array);
            var newpoints :int = points[myidx] + wpoints;
            if (wpoints > 0) {
                _control.set(POINTS, newpoints, myidx);
            }

            // if this is a single player game, they go until the board is clear
            if (!isMultiPlayer()) {
                if (nonEmptyColumns() < getMinWordLength()) {
                    _control.endGame(new Array().concat(myidx));
                }

            // if it's a multiplayer game, see if we have exceeded the winning points
            } else if (newpoints >= getWinningPoints()) {
                // if so, score a point and end the round 
                var newscore :int = (_control.get(SCORES) as Array)[myidx] + 1;
                _control.set(SCORES, newscore, myidx);
                if (newscore >= getWinningScore()) {
                    _control.endGame(new Array().concat(myidx));
                } else {
                    _control.endRound(INTER_ROUND_DELAY);
                }
            }
        });
    }

    /**
     * Returns the number of columns that have letters in them.
     */
    public function nonEmptyColumns () :int
    {
        var columns :int = 0;
        for (var xx: int = 0; xx < _size; xx++) {
            // scan from the bottom upwards looking for the first letter
            for (var yy :int = _size-1; yy >= 0; yy--) {
                var letter :String = getLetter(xx, yy);
                if (letter != null) {
                    columns++;
                    break;
                }
            }
        }
        return columns;
    }

    /**
     * Called when the player requests a change to some of their letters due to a lack of vowels.
     */
    public function requestChange () :void
    {
        if (_changePending) {
            Log.getLog(this).info("Rejecting change request. Have one in progress.");
            return;
        }
        _changePending = true;

        var vowels :Array = [], consonants :Array = [];
        for (var xx :int = 0; xx < _size; xx++) {
            // scan from the bottom upwards looking for the first letter
            for (var yy :int = _size-1; yy >= 0; yy--) {
                var letter :String = getLetter(xx, yy);
                var pos :int = getPosition(xx, yy);
                if (letter == null) {
                    continue;
                }
                if (VOWELS.indexOf(letter) != -1) {
                    vowels.push(pos);
                } else if (CONSONANTS.indexOf(letter) != -1) {
                    consonants.push(pos);
                }
                break;
            }
        }

        var set :Array;
        var chars :String;
        if (vowels.length > consonants.length) {
            set = vowels;
            chars = CONSONANTS;
        } else {
            set = consonants;
            chars = VOWELS;
        }

        // sanity check
        if (set.length == 0) {
            trace("No non-wildcard letters to change. Sorry.");
            return;
        }

        // select the letter to change and issue the change notification
        var rpos :int = int(set[_rando.nextInt(set.length)]);
//         var nlet :String = chars.substr(_rando.nextInt(chars.length), 1);
        var nlet :String = "*";
        _control.set(BOARD_DATA, nlet, rpos);

//         // penalize our score
//         var points :Array = (_control.get(POINTS) as Array);
//         var myidx : int = _control.seating.getMyPosition();
//         _control.set(POINTS, points[myidx] - getChangePenalty(), myidx);

        // finally send a message indicating what we've done so that the UI can react
        _control.sendMessage(LETTER_CHANGE, [ _control.getMyId(), rpos ]);
    }

    public function updatePlayable (board :Board) :void
    {
        for (var xx :int = 0; xx < _size; xx++) {
            updateColumnPlayable(board, xx);
        }
    }

    public function updateColumnPlayable (board :Board, xx :int) :void
    {
        if (!_control.isInPlay()) {
            return;
        }

        // scan from the bottom upwards looking for the first letter
        for (var yy :int = _size-1; yy >= 0; yy--) {
            var l :String = getLetter(xx, yy);
            if (l != null) {
                board.getLetter(yy * _size + xx).setPlayable(true, _size-1-yy);
                break;
            }
        }
    }

    public function getPosition (xx :int, yy :int) :int
    {
        switch (_control.seating.getMyPosition()) {
        default:
        case 0: return yy * _size + xx;
        case 1: return (_size-1 - yy) * _size + (_size-1 - xx);
        case 2: return xx * _size + (_size-1 - yy); 
        case 3: return (_size-1 - xx) * _size + yy; 
        }
    }

    public function getReverseX (pos :int) :int
    {
        switch (_control.seating.getMyPosition()) {
        default:
        case 0: return pos % _size;
        case 1: return _size-1 - pos % _size;
        case 2: return int(pos / _size);
        case 3: return _size-1 - int(pos / _size);
        }
    }

    public function getReverseY (pos :int) :int
    {
        switch (_control.seating.getMyPosition()) {
        default:
        case 0: return int(pos / _size);
        case 1: return _size-1 - int(pos / _size);
        case 2: return _size-1 - pos % _size;
        case 3: return pos % _size;
        }
    }

    public function getLetter (xx :int, yy :int) :String
    {
        var data :Array = (_control.get(BOARD_DATA) as Array);
        return data[getPosition(xx, yy)];
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == Model.LETTER_CHANGE) {
            var data :Array = (event.value as Array);
            if (int(data[0]) == _control.getMyId()) {
                _changePending = false;
            }
        }
    }

    /**
     * Locates the column that contains the supplied letter, ignoring columns in the supplied
     * "used" columns array. The columns are searched from the center outwards. Returns the
     * position in the letters array of the matched letter or -1 if the letter could not be found.
     */
    protected function locateLetter (c :String, used :Array) :int
    {
        var pos :int = locateLetterWild(c, used, false);
        return (pos == -1) ? locateLetterWild(c, used, true) : pos;
    }

    protected function locateLetterWild (c :String, used :Array, wildCard :Boolean) :int
    {
        for (var ii :int = 0; ii < _size; ii++) {
            // this searches like so: 14 12 10 8 6 4 2 0 1 3 5 7 9 11 13
            var xx :int = int(_size/2) + ((ii%2 == 0) ? int(-ii/2) : (int(ii/2)+1));
            if (used.indexOf(xx) != -1) {
                continue; // skip already used columns
            }
            // scan from the bottom upwards looking for the first letter
            for (var yy :int = _size-1; yy >= 0; yy--) {
                var l :String = getLetter(xx, yy);
                var pos :int = yy * _size + xx;
                if (l == null) {
                    continue;
                } else if (used.indexOf(pos) != -1) {
                    break; // try the next column
                } else if (wildCard ? l == "*" : l == c) {
                    return pos;
                } else {
                    break; // try the next column
                }
            }
        }
        return -1;
    }

    protected function getConfig (key :String, defval :int) :int
    {
        return (key in _control.getConfig()) ? int(_control.getConfig()[key]) : defval;
    }

    protected var _size :int;
    protected var _control :WhirledGameControl;
    protected var _rando :Random = new Random(getTimer());
    protected var _changePending :Boolean;

    // yay english!
    protected static const VOWELS :String = "aeiou";
    protected static const CONSONANTS :String = "bcdfghjklmnpqrstvwxyz";

    protected static const INTER_ROUND_DELAY :int = 7;

    protected static const TYPE_NORMAL :int = 0;
    protected static const TYPE_DOUBLE :int = 1;
    protected static const TYPE_TRIPLE :int = 2;

    protected static const TYPE_MULTIPLIER :Array = [ 1, 2, 3 ];
}

}
