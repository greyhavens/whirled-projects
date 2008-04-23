package spades.card {

import com.whirled.game.GameControl;
import com.whirled.game.PropertyChangedEvent;
import flash.events.EventDispatcher;

/** Represents the trick in a trick-taking card game such as spades. Manages communication with 
 *  the server. Generally when a change is requested to the trick via methods (e.g. playCard),
 *  the notification is sent to the server the change is only made after the reply is received,
 *  at which time one or more TrickEvent objects are dispatched. Also manages the detection of the 
 *  trick winner.*/
public class Trick extends EventDispatcher
{
    /** Create a new trick object.
     *  @param gameCtrl the game control used to listen and send network events that update the 
     *  trick
     *  @param beats function to compare two cards. The signature should be:
     * 
     *     function beats (candidate :Card, winnerSoFar :Card) :Boolean
     *
     *  and should return true if the candidate card beats the winner so far and false if it 
     *  doesn't. Note that the winnerSoFar argument converys information about the led suit.
     *  @param prefix the prefix to use for server-side variables in case the client needs to 
     *  instantiate more than one trick */
    public function Trick (
        gameCtrl :GameControl, 
        beats: Function,
        prefix :String=null)
    {
        _gameCtrl = gameCtrl;
        _prefix = prefix;
        _beats = beats;
        _numPlayers = _gameCtrl.game.seating.getPlayerIds().length;

        updateFromServer();

        _gameCtrl.net.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED,
            handlePropertyChanged);
    }

    /** Send a message to the server to clear all cards out of the trick. When the reply is 
     *  received, a TrickEvent.RESET event will be dispatched. */
    public function reset () :void
    {
        var zeroes :Array = new Array(_numPlayers);
        for (var i :int = 0; i < _numPlayers; ++i) {
            zeroes[i] = 0;
        }

        _gameCtrl.doBatch(batch);

        function batch () :void {
            _gameCtrl.net.set(varName(PLAYERS), zeroes);
            _gameCtrl.net.set(varName(CARDS), zeroes);
            _gameCtrl.net.set(varName(SIZE), 0);
        }
    }

    /** Send a message to the server that the local player has played a card into the trick.
     *  When the reply is received, a TrickEvent.CARD_PLAYED event will be dispatched. Then,
     *  if the card changes the winner of the trick, a FORERUNNER_CHANGED event is dispatched.
     *  Finally, if the card is the final card in the trick, a COMPLETED event is dispatched. 
     *  @throws CardException if the trick is already full */
    public function playCard (card :Card) :void
    {
        if (_players.length == _numPlayers) {
            throw new CardException("Trick size cannot exceed " + _numPlayers);
        }
        
        var player :int = _gameCtrl.game.getMyId();
        var len :int = _cards.length;

        _gameCtrl.doBatch(batch);
        
        function batch () :void
        {
            _gameCtrl.net.setAt(varName(PLAYERS), len, player);
            _gameCtrl.net.setAt(varName(CARDS), len, card.ordinal);
            _gameCtrl.net.set(varName(SIZE), len + 1);
        }
    }

    /** Tests whether the player with the id has already put a card into the trick. */
    public function hasPlayed (playerId :int) :Boolean
    {
        return _players.indexOf(playerId) >= 0;
    }

    /** Access the id of the player that led the trick. Ths value is 0 if no cards have been played 
     *  since the trick was reset. */
    public function get leader () :int
    {
        if (_players.length == 0) {
            return 0;
        }

        return _players[0];
    }

    /** Access the first card played in the trick. The value is 0 if no cards have been played since
     *  the trick was reset. */
    public function get ledCard () :Card
    {
        if (_cards.length == 0) {
            return null;
        }
        return _cards.cards[0];
    }

    /** Access the number of players. This determines the maximum size of the trick and also the 
     *  number of cards that complete the trick. */
    public function get numPlayers () :int
    {
        return _numPlayers;
    }

    /** Access the underlying array of cards that make up the trick. The 0th card is always the led 
     *  card. DO NOT modify the array. */
    public function get cards () :CardArray
    {
        return _cards;
    }

    /** Access the underyling array of players that have participated in the trick. The 0th entry is
     *  the player that led the trick. DO NOT modify the array. */
    public function get players () :Array
    {
        return _players;
    }

    /** Access the number of cards played so far. */
    public function get length () :int
    {
        return _players.length;
    }
    
    /** Access the winner of the trick. Even if the trick is not complete, the winner is set to the
     *  player that would currently win. */
    public function get winner () :int
    {
        return _winner;
    }

    /** Call a function for each card, player pair. The signature should be:
     *  
     *  function fn (card :Card, player :int) 
     * 
     **/
    public function forEach (fn :Function) :void
    {
        for (var i :int = 0; i < length; ++i) {
            fn(_cards.cards[i], players[i]);
        }
    }

    /** Access the flag indicating whether or not the trick is complete. The trick is only complete 
     *  if all players have played a card. */
    public function get complete () :Boolean
    {
        return _cards.length == _numPlayers;
    }

    /** Prefix the name for our instance. */
    protected function varName (name :String) :String
    {
        if (_prefix == null) {
            return name;
        }
        return _prefix + "." + name;
    }

    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == varName(SIZE)) {

            // value is the new size of the trick
            var value :int = event.newValue as int;

            if (value > 0) {

                // someone has played a card...

                // add the player who played
                var players :Array = _gameCtrl.net.get(varName(PLAYERS)) as Array;
                _players.push(players[value - 1]);
                if (_players.length != value) {
                    throw new Error("Out of sync! Number of players do not match trick size.");
                }

                // add the card
                var cards :Array = _gameCtrl.net.get(varName(CARDS)) as Array;
                _cards.pushOrdinal(cards[value - 1]);
                if (_cards.length != value) {
                    throw new Error("Out of sync! Number of cards do not match trick size.");
                }

                // send an event
                dispatchEvent(new TrickEvent(TrickEvent.CARD_PLAYED, 
                    _cards.cards[value - 1], _players[value - 1]));

                // calculate the winner and send an event if changed
                var winner :int = calculateWinner();
                if (winner != _winner) {
                    _winner = winner;
                    dispatchEvent(new TrickEvent(TrickEvent.FRONTRUNNER_CHANGED,
                        _cards.cards[value - 1], _winner));
                }
            }

            if (value == 0) {
                // reset the values and send an event
                _players.splice(0, _players.length);
                _cards.reset();
                _winner = 0;

                dispatchEvent(new TrickEvent(TrickEvent.RESET));
            }
            else if (value == _numPlayers) {
                var winnerCard :Card = _cards.cards[
                    _players.indexOf(_winner)] as Card;
                dispatchEvent(new TrickEvent(TrickEvent.COMPLETED, 
                    winnerCard, _winner));
            }
        }
    }

    protected function calculateWinner () :int
    {
        if (_cards.length == 0) {
            return 0;
        }

        if (_cards.length != _players.length) {
            throw new Error("Cards and players in trick out of sync");
        }

        var best :Card = _cards.cards[0];
        var winner :int = _players[0];

        for (var i :int = 1; i < _cards.length; ++i) {
            var candidate :Card = _cards.cards[i];
            if (_beats(candidate, best) as Boolean) {
                best = candidate;
                winner = _players[i];
            }
        }

        return winner;
    }

    protected function updateFromServer () :void
    {
        var players :Array = _gameCtrl.net.get(varName(PLAYERS)) as Array;
        var cards :Array = _gameCtrl.net.get(varName(CARDS)) as Array;
        var len :int = _gameCtrl.net.get(varName(SIZE)) as int;

        _players = new Array();
        _cards = new CardArray();

        if (players == null) {
            return;
        }

        for (var i :int = 0; i < len; ++i) {
            _players.push(players[i]);
            _cards.pushOrdinal(cards[i]);
        }
    }

    protected var _gameCtrl :GameControl;
    protected var _prefix :String;
    protected var _numPlayers :int;
    protected var _cards :CardArray;
    protected var _players :Array;
    protected var _winner :int;
    protected var _beats :Function;

    protected static const PLAYERS :String = "trick.players";
    protected static const CARDS :String = "trick.cards";
    protected static const SIZE :String = "trick.size";
}

}
