//
// $Id$

package dictattack {

import flash.utils.getTimer;

import com.threerings.util.Log;
import com.threerings.util.Random;

import com.whirled.game.GameSubControl;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

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

    /** The character used to indicate a wildcard letter. */
    public static const WILDCARD :String = "*";

    /** The character used to indicate a blank or already used space. */
    public static const BLANK :String = " ";

    public function Model (size :int, ctx :Context)
    {
        _size = size;
        _ctx = ctx;
        _ctx.control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        _ctx.control.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);

        // if we're already in play, load up the board immediately
        if (_ctx.control.isConnected() && _ctx.control.game.isInPlay()) {
            gotBoard();
            gameDidStart();
            roundDidStart();
        }
    }

    /**
     * Returns the size of the board along one edge.
     */
    public function getBoardSize () :int
    {
        return _size;
    }

    /**
     * Returns the total number of usable letters that were on the board at the start of the round.
     */
    public function getLetterCount () :int
    {
        return _letterCount;
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
        return isMultiPlayer() ? getConfig("pp_round", 20) : -1;
    }

    /**
     * Returns the number of round wins needed to win the game or -1 if we're in single player
     * mode.
     */
    public function getWinningScore () :int
    {
        return isMultiPlayer() ? getConfig("round_wins", 3) : -1;
    }

    /**
     * Returns the number of word changes allowed for this player in a round.
     */
    public function getChangesAllowed () :int
    {
        return isMultiPlayer() ? 2 : 3;
    }

    /**
     * Returns the name of the player at the specified index, truncated to the supplied max length.
     */
    public function getPlayerName (pidx :int, maxLength :int) :String
    {
        var name :String = _ctx.control.game.seating.getPlayerNames()[pidx];
        if (name.length > maxLength) {
            name = name.substring(0, maxLength);
        }
        return name;
    }

//     /**
//      * Returns the penalty for changing a letter.
//      */
//     public function getChangePenalty () :int
//     {
//         return isMultiPlayer() ? 2 : 3;
//     }

    /**
     * Returns true if this is a multiplayer game.
     */
    public function isMultiPlayer () :Boolean
    {
        return (_ctx.control.game.seating.getPlayerNames().length > 1);
    }

    /**
     * Returns the delay between rounds, in seconds.
     */
    public function getInterRoundDelay () :int
    {
        var pcount :int = _ctx.control.game.seating.getPlayerIds().length;
        return INTER_ROUND_DELAY * pcount;
    }

    /**
     * Returns the number of words played that were not on the board.
     */
    public function getNotOnBoardPlays () :int
    {
        return _notOnBoard;
    }

    /**
     * Returns the number of words played that were not in the dictionary.
     */
    public function getNotInDictPlays () :int
    {
        return _notInDict;
    }

    /**
     * Returns the duration of the most recently completed round in milliseconds.
     */
    public function getRoundDuration () :int
    {
        return _roundDuration;
    }

    /**
     * Returns the duration of the most recently completed game in milliseconds.
     */
    public function getGameDuration () :int
    {
        return _gameDuration;
    }

    /**
     * Return true if the player ended the game early, false if they played until there were no
     * more plays possible.
     */
    public function getEndedEarly () :Boolean
    {
        return _endedEarly;
    }

    /**
     * Returns true if we've scored at least the specified number of points in the last specified
     * number of games.
     */
    public function checkConsecutivePoints (games :int, points :int) :Boolean
    {
        if (_recentPoints.length < games) {
            return false;
        }
        for (var ii :int = 0; ii < games; ii++) {
            if (int(_recentPoints[_recentPoints.length-ii-1]) < points) {
                return false;
            }
        }
        return true;
    }

    /**
     * Returns the longest word played in this round, if multiple words of the same length are the
     * longest the first is returned.
     */
    public function getLongestWord (pidx :int = -1) :WordPlay
    {
        var word :WordPlay = new WordPlay();
        for (var pp :int = 0; pp < _plays.length; pp++) {
            for (var ii :int = 0; ii < _plays[pp].length; ii++) {
                var play :WordPlay = (_plays[pp][ii] as WordPlay);
                if ((pidx == -1 || pidx == play.pidx) &&
                    (play.word.length > word.word.length || play.when < word.when)) {
                    word = play;
                }
            }
        }
        return word;
    }

    /**
     * Returns the highest scoring word played in this round, if multiple words of the same length
     * are the highest the first is returned.
     */
    public function getHighestScoringWord (pidx :int = -1) :WordPlay
    {
        var word :WordPlay = new WordPlay();
        for (var pp :int = 0; pp < _plays.length; pp++) {
            for (var ii :int = 0; ii < _plays[pp].length; ii++) {
                var play :WordPlay = (_plays[pp][ii] as WordPlay);
                if ((pidx == -1 || pidx == play.pidx) &&
                    (play.getPoints(this) > word.getPoints(this) || play.when < word.when)) {
                    word = play;
                }
            }
        }
        return word;
    }

    /**
     * Returns true if we played the specified word.
     */
    public function playedWord (word :String) :Boolean
    {
        var myidx : int = _ctx.control.game.seating.getMyPosition();
        for (var pp :int = 0; pp < _plays[myidx].length; pp++) {
            if (_plays[myidx][pp].word == word) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns the number of words played by length, starting from zero (lengths below the minimum
     * allowed word length will simply be zero).
     */
    public function getWordCountsByLength () :Array
    {
        var counts :Array = [];
        for (var ll :int = getMinWordLength(); ll <= Content.BOARD_SIZE; ll++) {
            counts[ll] = 0;
        }
        for (var pp :int = 0; pp < _plays.length; pp++) {
            for (var ii :int = 0; ii < _plays[pp].length; ii++) {
                var play :WordPlay = (_plays[pp][ii] as WordPlay);
                counts[play.word.length]++;
            }
        }
        return counts;
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
     * Called when the game starts.
     */
    public function gameDidStart () :void
    {
        _gameDuration = 0;
        _endedEarly = false;
    }

    /**
     * Called when a round starts.
     */
    public function roundDidStart () :void
    {
        var pcount :int = _ctx.control.game.seating.getPlayerIds().length;

        // if we are in control, zero out the points, create a board and publish it
        if (_ctx.control.game.amInControl()) {
            _ctx.control.net.set(POINTS, new Array(pcount).map(function (): int { return 0; }));
            _ctx.control.services.getDictionaryLetterSet(
                Content.LOCALE, null, _size*_size, gotLetterSet);
        }

        // create our play history (TODO: we should probably store this in the game object)
        for (var ii :int = 0; ii < pcount; ii++) {
            _plays[ii] = [];
        }

        // clear out our non-on-board and not-in-dictionary counters
        _notOnBoard = 0;
        _notInDict = 0;

        // note our round start time
        _roundStart = getTimer();
    }

    /**
     * Called when a round ends.
     */
    public function roundDidEnd () :void
    {
        // note our round duration and accumulate to game duration
        _roundDuration = getTimer() - _roundStart;
        _gameDuration += _roundDuration;
    }

    /**
     * Called when the game ends.
     */
    public function gameDidEnd () :void
    {
        // if this is a single player game, append our points to the recent points list
        var myidx :int = _ctx.control.game.seating.getMyPosition();
        if (!isMultiPlayer() && myidx >= 0) {
            var points :Array = (_ctx.control.net.get(POINTS) as Array);
            _recentPoints.push(int(points[myidx]));
        }
    }

    public function highlightWord (board :Board, word :String) :void
    {
        // first reset any existing highlight
        for (var xx :int = 0; xx < _size; xx++) {
            // scan from the bottom upwards looking for the first letter
            for (var yy :int = _size-1; yy >= 0; yy--) {
                var pos :int = yy * _size + xx;
                var letter :Letter = board.getLetter(pos);
                if (letter != null) {
                    letter.setHighlighted(false);
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
                _notOnBoard++;
                return;
            }
            used.push(idx);
            board.getLetter(idx).setHighlighted(true);
        }

        // submit the word to the server to see if it is valid
        _ctx.control.services.checkDictionaryWord(
            Content.LOCALE, null, word, function (word :String, isValid :Boolean) : void {
            if (!isValid) {
                // TODO: play a sound indicating the mismatch
                board.resetLetters(used);
                callback(word + " is not in the dictionary.");
                _notInDict++;
                return;
            }

            // remove our tiles from the distributed state (we do this in individual events so that
            // watchers coming into a game half way through will see valid state), while we're at
            // it, compute our points
            var play :WordPlay = new WordPlay();
            play.pidx = _ctx.control.game.seating.getMyPosition();
            play.word = word;
            for (var ii :int = 0; ii < used.length; ii++) {
                // map our local coordinates back to a global position coordinates
                var xx :int = int(used[ii] % _size);
                var yy :int = int(used[ii] / _size);
                play.mults[ii] = TYPE_MULTIPLIER[getType(xx, yy)];
                var pos :int = getPosition(xx, yy);
                _ctx.control.net.setAt(BOARD_DATA, pos, BLANK, true);
                play.positions[ii] = pos;
                // if this was a wildcard, it scores no point
                if (board.getLetter(used[ii]).getText() == WILDCARD) {
                    play.wilds[ii] = true;
                }
            }

            // broadcast our our played word as a message
            _ctx.control.net.sendMessage(WORD_PLAY, play.flatten());

            // update our points
            var points :Array = (_ctx.control.net.get(POINTS) as Array);
            var ppoints :int = play.getPoints(_ctx.model);
            var newpoints :int = points[play.pidx] + ppoints;
            if (ppoints > 0) {
                _ctx.control.net.setAt(POINTS, play.pidx, newpoints);
            }

            // if they earned a trophy due to the length of this word, award it
            if (used.length >= 8 && !play.usedWild()) {
                if (!_ctx.control.player.holdsTrophy("word_length_" + used.length)) {
                    _ctx.control.player.awardTrophy("word_length_" + used.length);
                }
            }

            // if this is a single player game, they go until the board is clear
            if (!isMultiPlayer()) {
                if (nonEmptyColumns() < getMinWordLength()) {
                    _ctx.control.game.endGameWithScore(newpoints);
                }

            // if it's a multiplayer game, see if we have exceeded the winning points
            } else if (newpoints >= getWinningPoints()) {
                // if so, score a point and end the round 
                var scores :Array = (_ctx.control.net.get(SCORES) as Array);
                scores[play.pidx] = scores[play.pidx] + 1;
                _ctx.control.net.setAt(SCORES, play.pidx, scores[play.pidx]);
                if (scores[play.pidx] >= getWinningScore()) {
                    var winners :Array = [ _ctx.control.game.getMyId() ];
                    var losers :Array = _ctx.control.game.seating.getPlayerIds().filter(
                        function (o :*, i :int, a :Array) :Boolean {
                            return (int(o) != _ctx.control.game.getMyId());
                        });
                    _ctx.control.game.endGameWithWinners(
                        winners, losers, GameSubControl.CASCADING_PAYOUT);
                } else {
                    _ctx.control.game.endRound(getInterRoundDelay());
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
                if (letter != BLANK) {
                    columns++;
                    break;
                }
            }
        }
        return columns;
    }

    /**
     * Returns the total number of unused letters on the board.
     */
    public function unusedLetters () :int
    {
        var letters :int = 0;
        for (var xx: int = 0; xx < _size; xx++) {
            // scan from the bottom upwards looking for non-blank letters
            for (var yy :int = _size-1; yy >= 0; yy--) {
                var letter :String = getLetter(xx, yy);
                if (letter != BLANK) {
                    letters++;
                }
            }
        }
        return letters;
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
                if (letter == BLANK) {
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

        // we select a wildcard from among either the consonants or vowels, whichever are more
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
            Log.getLog(this).info("No non-wildcard letters to change. Sorry.");
            return;
        }

        // select the letter to change and issue the change notification
        var rpos :int = int(set[_rando.nextInt(set.length)]);
//         var nlet :String = chars.substr(_rando.nextInt(chars.length), 1);
        _ctx.control.net.setAt(BOARD_DATA, rpos, WILDCARD);

//         // penalize our score
//         var points :Array = (_ctx.control.net.get(POINTS) as Array);
//         var myidx : int = _ctx.control.game.seating.getMyPosition();
//         _ctx.control.net.setAt(POINTS, myidx, points[myidx] - getChangePenalty());

        // finally send a message indicating what we've done so that the UI can react
        _ctx.control.net.sendMessage(LETTER_CHANGE, [ _ctx.control.game.getMyId(), rpos ]);
    }

    public function endGameEarly () :void
    {
        var myidx :int = _ctx.control.game.seating.getMyPosition();
        _ctx.control.game.endGameWithScore((_ctx.control.net.get(POINTS) as Array)[myidx]);
        _endedEarly = true;
    }

    public function updatePlayable (board :Board) :void
    {
        for (var xx :int = 0; xx < _size; xx++) {
            updateColumnPlayable(board, xx);
        }
    }

    public function updateColumnPlayable (board :Board, xx :int) :void
    {
        if (!_ctx.control.isConnected() || !_ctx.control.game.isInPlay()) {
            return;
        }

        // scan from the bottom upwards looking for the first letter
        for (var yy :int = _size-1; yy >= 0; yy--) {
            var l :String = getLetter(xx, yy);
            if (l != BLANK) {
                board.getLetter(yy * _size + xx).setPlayable(true, _size-1-yy, !isMultiPlayer());
                break;
            }
        }
    }

    public function getPosition (xx :int, yy :int) :int
    {
        switch (_ctx.control.game.seating.getMyPosition()) {
        default:
        case 0: return yy * _size + xx;
        case 1: return (_size-1 - yy) * _size + (_size-1 - xx);
        case 2: return xx * _size + (_size-1 - yy); 
        case 3: return (_size-1 - xx) * _size + yy; 
        }
    }

    public function getReverseX (pos :int) :int
    {
        switch (_ctx.control.game.seating.getMyPosition()) {
        default:
        case 0: return pos % _size;
        case 1: return _size-1 - pos % _size;
        case 2: return int(pos / _size);
        case 3: return _size-1 - int(pos / _size);
        }
    }

    public function getReverseY (pos :int) :int
    {
        switch (_ctx.control.game.seating.getMyPosition()) {
        default:
        case 0: return int(pos / _size);
        case 1: return _size-1 - int(pos / _size);
        case 2: return _size-1 - pos % _size;
        case 3: return pos % _size;
        }
    }

    public function getLetter (xx :int, yy :int) :String
    {
        var data :Array = (_ctx.control.net.get(BOARD_DATA) as Array);
        return data[getPosition(xx, yy)];
    }

    public function dumpCurrentBoard () :void
    {
        dumpBoard(_ctx.control.net.get(BOARD_DATA) as Array);
    }

    public function dumpBoard (data :Array) :void
    {
        for (var yy :int = 0; yy < _size; yy++) {
            var row :String = "";
            for (var xx :int = 0; xx < _size; xx++) {
                var letter :String = (data[yy * _size + xx] as String);
                row += letter;
            }
            trace("Board: " + row);
        }
    }

    protected function gotLetterSet (letters :Array) :void
    {
        var patterns :Array = isMultiPlayer() ? Content.BOARDS_MULTI : Content.BOARDS_SINGLE;
        var pattern :String = patterns[_rando.nextInt(patterns.length)] as String;
        for (var ii :int = 0; ii < pattern.length; ii++) {
            if (pattern.charAt(ii) == ".") {
                letters[ii] = " ";
            }
        }
        _ctx.control.net.set(BOARD_DATA, letters);
    }

    /**
     * Called when a message comes in.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == Model.LETTER_CHANGE) {
            var data :Array = (event.value as Array);
            if (int(data[0]) == _ctx.control.game.getMyId()) {
                _changePending = false;
            }

        } else if (event.name == Model.WORD_PLAY) {
            var play :WordPlay = WordPlay.unflatten(event.value as Array);
            play.when = getTimer();
            _plays[play.pidx].push(play);
        }
    }

    /**
     * Called when our distributed game state changes.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == Model.BOARD_DATA) {
            gotBoard();
        }
    }

    protected function gotBoard () :void
    {
        var data :Array = (_ctx.control.net.get(BOARD_DATA) as Array);
        _letterCount = 0;
        for each (var letter :String in data) {
            if (letter != BLANK) {
                _letterCount++;
            }
        }
        Log.getLog(this).info("Board has " + _letterCount + " letters.");
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
                if (l == BLANK) {
                    continue;
                } else if (used.indexOf(pos) != -1) {
                    break; // try the next column
                } else if (wildCard ? l == WILDCARD : l == c) {
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
        return (key in _ctx.control.game.getConfig()) ?
            int(_ctx.control.game.getConfig()[key]) : defval;
    }

    protected var _size :int;
    protected var _ctx :Context;

    protected var _letterCount :int;
    protected var _rando :Random = new Random(getTimer());
    protected var _changePending :Boolean;
    protected var _endedEarly :Boolean;

    protected var _plays :Array = [];

    protected var _roundStart :int, _roundDuration :int, _gameDuration :int
    protected var _notOnBoard :int, _notInDict :int;

    /** Contains our point totals for all single player games played during this session. */
    protected var _recentPoints :Array = [];

    // yay english!
    protected static const VOWELS :String = "aeiou";
    protected static const CONSONANTS :String = "bcdfghjklmnpqrstvwxyz";

    protected static const INTER_ROUND_DELAY :int = 10;

    protected static const TYPE_NORMAL :int = 0;
    protected static const TYPE_DOUBLE :int = 1;
    protected static const TYPE_TRIPLE :int = 2;

    protected static const TYPE_MULTIPLIER :Array = [ 1, 2, 3 ];
}

}
