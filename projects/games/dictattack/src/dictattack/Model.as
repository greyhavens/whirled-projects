//
// $Id$

package dictattack {

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

    public function Model (size :int, control :WhirledGameControl)
    {
        _size = size;
        _control = control;
    }

    /**
     * Returns the minimum world length.
     */
    public function getMinWordLength () :int
    {
        return int(_control.getConfig()["Minimum word length"]);
    }

    /**
     * Returns the points needed to win the round.
     */
    public function getWinningPoints () :int
    {
        return int(_control.getConfig()["Points per round"]);
    }

    /**
     * Returns the number of round wins needed to win the game.
     */
    public function getWinningScore () :int
    {
        return int(_control.getConfig()["Round wins"]);
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

    /**
     * Called by the display when the player submits a word.
     */
    public function submitWord (board :Board, word :String) :Boolean
    {
        if (word.length < getMinWordLength()) {
            return false;
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
                return false;
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
                return;
            }

            // remove our tiles from the distributed state (we do this in individual events so that
            // watchers coming into a game half way through will see valid state), while we're at
            // it, compute our points
            var wpoints :int = used.length - getMinWordLength() + 1;
            var ii :int, mult :int = 1;
            for (ii = 0; ii < used.length; ii++) {
                // map our local coordinates back to a global position coordinates
                var xx :int = int(used[ii] % _size);
                var yy :int = int(used[ii] / _size);
                mult = Math.max(TYPE_MULTIPLIER[getType(xx, yy)], mult);
                _control.set(BOARD_DATA, null, getPosition(xx, yy));
            }
            wpoints *= mult;

            // broadcast our our played word as a message
            var myidx :int = _control.seating.getMyPosition();
            _control.sendMessage(WORD_PLAY, [ myidx, word, wpoints, mult ]);

            // update our points
            var points :Array = (_control.get(POINTS) as Array);
            var newpoints :int = points[myidx] + wpoints;
            if (wpoints > 0) {
                _control.set(POINTS, newpoints, myidx);
            }

            // if we have exceeded the winning points, score a point and end the round 
            if (newpoints >= getWinningPoints()) {
                var newscore :int = (_control.get(SCORES) as Array)[myidx] + 1;
                _control.set(SCORES, newscore, myidx);
                if (newscore >= getWinningScore()) {
                    _control.endGame(new Array().concat(myidx));
                } else {
                    _control.endRound(INTER_ROUND_DELAY);
                }
            }
        });

        // the word is on the board at least, so tell the caller to clear the input field
        return true;
    }

    public function updatePlayable (board :Board) :void
    {
        for (var xx :int = 0; xx < _size; xx++) {
            // scan from the bottom upwards looking for the first letter
            for (var yy :int = _size-1; yy >= 0; yy--) {
                var l :String = getLetter(xx, yy);
                if (l != null) {
                    board.getLetter(yy * _size + xx).setPlayable(true, _size-1-yy);
                    break;
                }
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

    /**
     * Locates the column that contains the supplied letter, ignoring columns in the supplied
     * "used" columns array. The columns are searched from the center outwards. Returns the
     * position in the letters array of the matched letter or -1 if the letter could not be found.
     */
    protected function locateLetter (c :String, used :Array) :int
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
                } else if (l == c) {
                    return pos;
                } else {
                    break; // try the next column
                }
            }
        }
        return -1;
    }

    protected var _size :int;
    protected var _control :WhirledGameControl;

    protected static const INTER_ROUND_DELAY :int = 5;

    protected static const TYPE_NORMAL :int = 0;
    protected static const TYPE_DOUBLE :int = 1;
    protected static const TYPE_TRIPLE :int = 2;

    protected static const TYPE_MULTIPLIER :Array = [ 1, 2, 3 ];
}

}
