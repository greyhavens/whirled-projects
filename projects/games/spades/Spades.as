package {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.MovieClip;

import com.threerings.util.Log;

import com.whirled.game.*;

/**
 * The main sprite for the spades game.
 * XXTODO Factor certain things into CardGame and/or TrickTakingCardGame.
 * XXTODO Strip out excessive debug logging.
 * XXTODO Use localized feeedback.
 */
[SWF(width="800", height="800")]
public class Spades extends Sprite
{
    /** Players required for a game of spades */
    public static const NUM_PLAYERS :int = 4;

    /** Number of cards in a player's hand at the start of a round */
    public static const NUM_CARDS_PER_PLAYER :int = 
        CardArray.FULL_DECK.ordinals.length / NUM_PLAYERS;

    /** Number of "hands" played in a round (i.e. tricks to take) */
    public static const NUM_TRICKS_PER_ROUND :int = NUM_CARDS_PER_PLAYER;

    /** Represents an undefined bid (player has not chosen yet) */
    public static const NO_BID :int = -1;

    /** Maximum amount a player can bid */
    public static const MAX_BID :int = NUM_TRICKS_PER_ROUND;

    /** Kludgy constant sized display (TODO: rely on browser area) */
    public static const DISPLAY :Display = new Display(700, 550);

    /** Positions of other players' on the table (relative to the local player). */
    public static const PLAYER_POSITIONS :Array = [
        new Position(50, 40),  // me
        new Position(25, 25),  // my left
        new Position(50, 10),  // opposite
        new Position(75, 25)   // my right
    ];

    /** Position of the center of the local player's hand. */
    public static const HAND_POSITION :Position = new Position(50, 75);

    /** Position of the center of the bid slider */
    public static const SLIDER_POSITION :Position = new Position(50, 60);

    /** Position of the center of the trick pile */
    public static const TRICK_POSITION :Position = new Position(50, 25);

    /** Main entry point. Start a new game of spades. */
    public function Spades ()
    {
        _gameCtrl = new GameControl(this);
        _gameCtrl.game.addEventListener(
            StateChangedEvent.GAME_STARTED, 
            handleGameStarted);
        _gameCtrl.game.addEventListener(
            StateChangedEvent.GAME_ENDED, 
            handleGameEnded);
        _gameCtrl.game.addEventListener(
            StateChangedEvent.ROUND_STARTED, 
            handleRoundStarted);
        _gameCtrl.game.addEventListener(
            StateChangedEvent.ROUND_ENDED, 
            handleRoundEnded);
        _gameCtrl.game.addEventListener(
            StateChangedEvent.TURN_CHANGED, 
            handleTurnChanged);
        _gameCtrl.net.addEventListener(
            ElementChangedEvent.ELEMENT_CHANGED,
            handleElementChanged);
        _gameCtrl.net.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED,
            handlePropertyChanged);
        _gameCtrl.net.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessage);

        // todo: use the config
        var config :Object = _gameCtrl.game.getConfig();

        // todo: clean up scoring paradigm (the idea here is that the score is 
        // shown for each team).
        _gameCtrl.local.setPlayerScores([ 0, "", 0, "" ], [ 1, 1, 0, 0 ]);

        // configure the players
        setUpPlayers();

        // setup the trick pile
        resetTrick();
    }

    / ** For debugging, log a string prefixed with player name and seating position. */
    public function log (str :String) :void
    {
        var myIdx :int = getMySeat();
        var myName :String = _gameCtrl.game.seating.getPlayerNames()[myIdx];
        Log.getLog(this).info("[" + myName + "@seat" + myIdx + "] " + str);
    }

    /** Create and position the player sprites. */
    protected function setUpPlayers () :void
    {
        var names :Array = _gameCtrl.game.seating.getPlayerNames();
        var mySeat :int = getMySeat();

        // For each seat, create a sprite and position relative to local player
        for (var seat :int = 0; seat < NUM_PLAYERS; ++seat) {
            var p :Player = new Player(names[seat] as String);
            var relative :int = (seat - mySeat + NUM_PLAYERS) % NUM_PLAYERS;
            DISPLAY.move(p, PLAYER_POSITIONS[relative] as Position);
            addChild(p);
            _players[seat] = p;
        }
    }

    /** Get the number of bids placed so far */
    protected function countBidsPlaced () :int
    {
        var bids :Array = _gameCtrl.net.get(COMS_BIDS) as Array;
        var count :int = 0;
        if (bids != null) {
            for (var i :int = 0; i < bids.length; ++i) {
                if (bids[i] != NO_BID) {
                    count = count + 1;
                }
            }
        }
        return count;
    }

    /** Boot up the game. */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        _gameCtrl.local.feedback("Spades superchallenge: go!\n");
    }

    /** Start the round. */
    protected function handleRoundStarted (event :StateChangedEvent) :void
    {
        _gameCtrl.local.feedback("Round " + _gameCtrl.game.getRound() + " started\n");

        // let the controlling client kick off the round
        if (_gameCtrl.game.amInControl()) {

            log("Dealing and setting up bids");

            // put all cards into a bag
            var deck :Array = CardArray.FULL_DECK.ordinals;
            _gameCtrl.services.bags.create(COMS_DECK, deck);
            
            // deal to each player
            var playerIds :Array = _gameCtrl.game.seating.getPlayerIds();
            for (var seat :int = 0; seat < NUM_PLAYERS; ++seat) {
                _gameCtrl.services.bags.deal(COMS_DECK, NUM_CARDS_PER_PLAYER, 
                    COMS_HAND, null, playerIds[seat]);
            }

            // set up bids
            _gameCtrl.net.set(COMS_BIDS, filledArray(NUM_PLAYERS, NO_BID));

            // set up the trick (note the arrays are constant size and a separate size
            // property is used. this is much easier for message updates.)
            var zeroes :Array = filledArray(NUM_PLAYERS, 0);
            _gameCtrl.net.set(COMS_TRICK_PLAYERS, zeroes);
            _gameCtrl.net.set(COMS_TRICK_CARDS, zeroes);
            _gameCtrl.net.set(COMS_TRICK_SIZE, 0);

            // advance the current turn holder so that the leader is different 
            // each time
            _gameCtrl.game.startNextTurn();
        }
    }

    /** Entry point for when a round has ended. */
    protected function handleRoundEnded (event :StateChangedEvent) :void
    {
        _gameCtrl.local.feedback("Round " + _gameCtrl.game.getRound() + " ended\n");

    }

    /** Get the id of the player in a particular seat. */
    protected function getPlayerId (seat :int) :int
    {
        var id :int = _gameCtrl.game.seating.getPlayerIds()[seat];
        return id;
    }

    /** Get the id of the player on my left. */
    protected function getNextPlayer () :int
    {
        var mySeat :int = getMySeat();
        return getPlayerId((mySeat + 1) % 4);
    }

    /** Get my seat number. */
    protected function getMySeat () :int
    {
        var mySeat :int = _gameCtrl.game.seating.getMyPosition();
        return mySeat;
    }

    /** Get the seat of a player by id. */
    protected function getPlayerSeat (id :int) :int
    {
        var ids :Array = _gameCtrl.game.seating.getPlayerIds();
        for (var i :int = 0; i < ids.length; ++i) {
            if (id == ids[i]) {
                return i;
            }
        }
        throw Error("Id " + id + " not found");
    }

    /** Get the name of a player by id. */
    protected function getPlayerName (id :int) :String
    {
        var seat :int = getPlayerSeat(id);
        var names :Array = _gameCtrl.game.seating.getPlayerNames();
        return names[seat];
    }

    /** End the game.
     *  XXTODO award points. */
    protected function handleGameEnded (event :StateChangedEvent) :void
    {
        _gameCtrl.local.feedback("Thank you for playing Spades!");
    }

    /** Update the UI after a turn change. */
    protected function handleTurnChanged (event :StateChangedEvent) :void
    {
        // Make sure the current turn holder is "selected"
        var turnHolder :int = _gameCtrl.game.getTurnHolderId();
        var hotSeat :int = _gameCtrl.game.seating.getPlayerPosition(turnHolder);
        log("Turn changed to " + turnHolder + " in seat " + hotSeat);
        for (var i :int = 0; i < NUM_PLAYERS; ++i) {
            var p :Player = _players[i] as Player;
            p.setTurn(i == hotSeat);
        }

        updateBidding();
        updateMoves();

        // This is the beginning of the round, so declare the leader.
        if (turnHolder > 0 && countBidsPlaced() == 0) {
            var leader :String = _gameCtrl.game.seating.getPlayerNames()[hotSeat];
            _gameCtrl.local.feedback("Leader this round is " + leader);
        }
    }

    /** Main entry point for element changes */
    protected function handleElementChanged (event :ElementChangedEvent) :void
    {
        log("Element changed:" + event.name);

        if (event.name == COMS_BIDS) {
            // make sure that a player's bid is reflected in his sprite
            var p :Player = _players[event.index] as Player;
            var bid :int = event.newValue as int;
            if (bid == NO_BID) {
                p.clearBid();
            }
            else {
                p.setBid(bid);
                var name :String = _gameCtrl.game.seating.getPlayerNames()[event.index];
                _gameCtrl.local.feedback(name + " bid " + bid);
            }

            // all bids are complete, start play
            if (countBidsPlaced() == NUM_PLAYERS) {
                _gameCtrl.local.feedback("All bids are in, starting play");
            }
            
            if (_gameCtrl.game.amInControl()) {
                _gameCtrl.game.startNextTurn();
            }
        }
    }
    
    /** Calculate the winner of the trick (so far).
     *  @return id of the player currently winning, or 0 if no one is */
    protected function calculateTrickWinner () :int
    {
        var cards :Array = _gameCtrl.net.get(COMS_TRICK_CARDS) as Array;
        var players :Array = _gameCtrl.net.get(COMS_TRICK_PLAYERS) as Array;
        var size :int = _gameCtrl.net.get(COMS_TRICK_SIZE) as int;

        if (size == 0) {
            return 0;
        }

        var best :Card = Card.createCard(cards[0]);
        var winner :int = players[0];
        for (var i :int = 1; i < size; ++i) {
            // todo: isolate trick logic
            var card :Card = Card.createCard(cards[i]);
            var better :Boolean = false;
            if (card.suit == best.suit) {
                if (card.isBetterRank(best, Card.RANK_ORDER_ACES_HIGH)) {
                    better = true;
                }
            }
            else if (card.suit == Card.SUIT_SPADES) {
                better = true;
            }

            if (better) {
                best = card;
                winner = players[i];
            }
        }

        return winner;
    }

    /** Restart the trick pile. */
    protected function resetTrick () :void
    {
        if (_trick != null) {
            removeChild(_trick.display);
        }
        _trick = new CardArray();
        addChild(_trick.display);
        DISPLAY.move(_trick.display, TRICK_POSITION);
    }

    /** Calculate the winner of the trick, add it to their number of tricks, save to history and 
     *  give them their turn */
    protected function completeTrick () :void
    {
        if (_trick.length != NUM_PLAYERS || 
            _gameCtrl.net.get(COMS_TRICK_SIZE) != NUM_PLAYERS) {
            throw new Error();
        }

        var winner :int = calculateTrickWinner();
        var winnerSeat :int = getPlayerSeat(winner);

        log("Winner is " + winner + " in seat " + winnerSeat + ", name " + getPlayerName(winner));

        _tricksTaken[winnerSeat] += 1;
        _players[winnerSeat].setTricks(_tricksTaken[winnerSeat]);

        _gameCtrl.local.feedback(getPlayerName(winner) + " won the trick");

        // todo: add to score and save to history

        resetTrick();
        
        if (_gameCtrl.game.amInControl()) {
            _gameCtrl.net.set(COMS_TRICK_SIZE, 0);
            _gameCtrl.game.startNextTurn(winner);
        }
    }

    /** Main entry point for property changes. */
    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        log("Property changed:" + event.name);
        if (event.name == COMS_TRICK_SIZE) {

            // someone has played a card, update the local trick stuff
            var value :int = event.newValue as int;

            if (value != 0) {
                var cards :Array = _gameCtrl.net.get(COMS_TRICK_CARDS) as Array;
                _trick.pushOrdinal(cards[value - 1]);
            }

            log("Trick size is now " + value);

            if (value == NUM_PLAYERS) {
                completeTrick();
            }
            else if (_gameCtrl.game.amInControl() && value > 0) {
                _gameCtrl.game.startNextTurn();
            }
        }
    }

    /** Show or hide the bidding interface. */
    protected function updateBidding () :void
    {
        var bids :Array = _gameCtrl.net.get(COMS_BIDS) as Array;
        var showSlider :Boolean = 
            _gameCtrl.game.isMyTurn() && 
            bids != null && 
            bids[getMySeat()] == NO_BID;

        log("Ready to bid: " + showSlider);

        if (showSlider) {
            if (_bidSlider == null) {
                _bidSlider = new BidSlider(NUM_TRICKS_PER_ROUND, onBid);
                DISPLAY.move(_bidSlider, SLIDER_POSITION);
                addChild(_bidSlider);
            }
        }
        else {
            if (_bidSlider != null) {
                removeChild(_bidSlider);
                _bidSlider = null;
            }
        }
    }

    /** Entry point for when the user selects their bid */
    protected function onBid (bid :int) :void
    {
        _gameCtrl.net.setAt(COMS_BIDS, getMySeat(), bid);
    }

    /** Check if spades can be played (part of current game state and/or config).
     *  XXTODO implement. */
    protected function canLeadSpades () :Boolean
    {
        return true;
    }

    /** Check if the local player has a suit in his hand. */
    protected function countSuit (suit :int) :int
    {
        var count :int = 0;
        var cards :Array = _hand.cards;
        for (var i :int = 0; i < cards.length; ++i) {
            if (cards[i].suit == suit) {
                ++count;
            }
        }
        return count;
    }

    /** Get an array of cards from the players hand that either match or do not 
     *  match a given suit. */
    protected function filterCards (suit :int, match :Boolean) :CardArray
    {
        var cards :Array = _hand.cards;
        var result :CardArray = new CardArray();
        for (var i :int = 0; i < cards.length; ++i) {
            if ((match && cards[i].suit == suit) ||
                (!match && cards[i].suit != suit)) {
                result.pushCard(cards[i]);
            }
        }
        return result;
    }

    /** Highlight the cards that may now be played. */
    protected function updateMoves () :void
    {
        if (_hand == null) {
            return;
        }

        var leader :Card = null;

        if (_trick.length > 0) {
            leader = _trick.cards[0];
        }

        if (!_gameCtrl.game.isMyTurn()) {
            // not my turn, disable
            _hand.disable();
        }
        else if (_trick.length == NUM_PLAYERS) {
            // trick full, disable
            _hand.disable();
        }
        else if (countBidsPlaced() < NUM_PLAYERS) {
            // bidding not finished, disable
            _hand.disable();
        }
        else if (leader != null && countSuit(leader.suit) == 0) {
            // out of led suit, allow any
            _hand.enable(onPlay);
        }
        else if (leader != null) {
            // allow only led suit
            _hand.enableSome(filterCards(leader.suit, true), onPlay);
        }
        else if (canLeadSpades()) {
            // leading and spades are available, allow any
            _hand.enable(onPlay);
        }
        else if (countSuit(Card.SUIT_SPADES) == _hand.length) {
            // leading and no other suits available, allow any
            _hand.enable(onPlay);
        }
        else {
            // leading, allow any non-spade suit
            _hand.enableSome(filterCards(leader.suit, false), onPlay);
        }
    }
    /** Entry point for when the user selects a card to play */
    protected function onPlay (card :Card) :void
    {
        _gameCtrl.net.doBatch(batch);
        _hand.remove(card);

        function batch () :void
        {
            var len :int = _trick.length;
            var myId :int = _gameCtrl.game.getMyId();
            _gameCtrl.net.setAt(COMS_TRICK_PLAYERS, len, myId);
            _gameCtrl.net.setAt(COMS_TRICK_CARDS, len, card.ordinal);
            _gameCtrl.net.set(COMS_TRICK_SIZE, len + 1);
        }
    }

    /** Main entry point for messages. */
    protected function handleMessage (event :MessageReceivedEvent) :void
    {
        log("Received message: " + event.name);
        
        if (event.name == COMS_HAND) {
            // we have been given some cards, update our hand, removing first
            if (_hand != null) {
                removeChild(_hand.display);
                _hand = null;
            }
            _hand = new CardArray(event.value as Array);
            log("My hand is " + _hand);
            DISPLAY.move(_hand.display, HAND_POSITION);
            addChild(_hand.display);
        }
    }

    protected static function filledArray(size :int, value :int) :Array
    {
        var array :Array = new Array(size);
        for (var i :int = 0; i < size; ++i) {
            array[i] = value;
        }
        return array;
    }

    /** Our game control object. */
    protected var _gameCtrl :GameControl;

    /** Our hand. */
    protected var _hand :CardArray;

    /** The slider for making a bid (null if not bidding). */
    protected var _bidSlider :BidSlider;

    /** Player instances in the game (indexed by seat). */
    protected var _players :Array = new Array(NUM_PLAYERS);

    /** Tricks taken by each player (indexed by seat). */
    protected var _tricksTaken :Array = filledArray(NUM_PLAYERS, 0);

    /** The trick sprite in the middle of the table */
    protected var _trick :CardArray;

    /** Event message for getting cards. */
    protected static const COMS_HAND :String = "hand";

    /** Name of bag for the deck. */
    protected static const COMS_DECK :String = "deck";

    /** Name of property for bids array. */
    protected static const COMS_BIDS :String = "bids";

    /** Name of property for current trick players. */
    protected static const COMS_TRICK_PLAYERS :String = "trickplayers";

    /** Name of property for current trick cards. */
    protected static const COMS_TRICK_CARDS :String = "trickcards";

    /** Name of property for size of current trick. */
    protected static const COMS_TRICK_SIZE :String = "tricksize";
}
}

