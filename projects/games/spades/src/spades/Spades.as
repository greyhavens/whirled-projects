package spades {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.MovieClip;

import com.threerings.flash.Vector2;

import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.MessageReceivedEvent;

import spades.card.Card;
import spades.card.CardArray;

import spades.graphics.TableSprite;


/**
 * The main sprite for the spades game.
 * TODO Factor certain things into CardGame and/or TrickTakingCardGame.
 * TODO Strip out excessive debug logging.
 * TODO Use localized feeedback.
 */
[SWF(width="800", height="800")]
public class Spades extends Sprite
{
    /** Players required for a game of spades */
    public static const NUM_PLAYERS :int = 4;

    /** Represents an undefined bid (player has not chosen yet) */
    public static const NO_BID :int = TableSprite.NO_BID;

    /** Time between rounds (seconds). */
    public static const DELAY_TO_NEXT_ROUND :int = 5;

    /** Main entry point. Start a new game of spades. */
    public function Spades (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
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

        var config :Object = _gameCtrl.game.getConfig();

        if ("playto" in config) {
            _targetScore = parseInt(config["playto"] as String);
        }
        if ("minigame" in config) {
            _miniGame = config["minigame"] as Boolean;
        }

        // configure the players
        _table = new TableSprite(
            new Vector2(700, 550),
            _gameCtrl.game.seating.getPlayerNames(), 
            getMySeat(),
            _trick,
            _hand);

        addChild(_table);
    }

    / ** For debugging, log a string prefixed with player name and seating position. */
    public function log (str :String) :void
    {
        Debug.debug(str);
    }

    /** Get the number of bids placed so far */
    protected function countBidsPlaced () :int
    {
        var bids :Array = _gameCtrl.net.get(COMS_BIDS) as Array;
        var count :int = 0;
        if (bids != null) {
            bids.forEach(countIfValid);
        }

        return count;

        function countIfValid (bid :int, i :int, a :Array) :void
        {
            if (bid != NO_BID) {
                count++;
            }
        }
    }

    /** Boot up the game. */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        var mini :String = _miniGame ? " (mini game selected)" : "";
        _gameCtrl.local.feedback(
             "Welcome to Spades, first player to score " + _targetScore + 
             " wins" + mini  + "\n");
        _scores = filledArray(NUM_PLAYERS, 0);
        _gameCtrl.local.setPlayerScores(_scores);
    }

    /** Start the round. */
    protected function handleRoundStarted (event :StateChangedEvent) :void
    {
        _gameCtrl.local.feedback("Round " + _gameCtrl.game.getRound() + " started\n");

        // let the controlling client kick off the round
        if (_gameCtrl.game.amInControl()) {

            log("Dealing and setting up bids");

            // put all cards into a bag
            var deck :CardArray = CardArray.FULL_DECK;

            if (_miniGame) {
                var isHighCard :Function = function (c :Card) :Boolean {
                    return Card.compareRanks(c.rank, Card.RANK_QUEEN, 
                        Card.RANK_ORDER_ACES_HIGH) >= 0;
                }
                deck = deck.shortFilter(isHighCard);
            }

            _gameCtrl.services.bags.create(COMS_DECK, deck.ordinals);
            
            // deal to each player
            var playerIds :Array = _gameCtrl.game.seating.getPlayerIds();
            for (var seat :int = 0; seat < NUM_PLAYERS; ++seat) {
                _gameCtrl.services.bags.deal(COMS_DECK, deck.length / NUM_PLAYERS, 
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

            // on the first round, set a random first player as leader. Otherwise, advance the 
            // previous leader by one
            if (_gameCtrl.game.getRound() == 1) {
                _gameCtrl.game.startNextTurn();
            }
            else {
                var lastId :int = _gameCtrl.net.get(COMS_LAST_LEADER) as int;
                var nextIdx :int = (getPlayerSeat(lastId) + 1) % NUM_PLAYERS;
                _gameCtrl.game.startNextTurn(getPlayerId(nextIdx));
            }
        }

        _tricksTaken = filledArray(NUM_PLAYERS, 0);
    }

    /** Process the total tricks taken for this set of hands played, add into the local scores
     *  and display */
    protected function updateScores () :void
    {
        var bids :Array = _gameCtrl.net.get(COMS_BIDS) as Array;

        for (var seat :int = 0; seat < NUM_PLAYERS; ++seat) {
            var over :int = _tricksTaken[seat] - bids[seat];
            var base :int = bids[seat] * 10;
            var score :int = over >= 0 ? (base + over) : (-base);
            _scores[seat] += score;
        }

        _gameCtrl.local.setPlayerScores(_scores);
    }

    /** Entry point for when a round has ended. */
    protected function handleRoundEnded (event :StateChangedEvent) :void
    {
        var round :int = -_gameCtrl.game.getRound();
        _gameCtrl.local.feedback("Round " + round + " ended\n");
        _table.setPlayerTurn(-1);
    }

    /** Get the id of the player in a particular seat. */
    protected function getPlayerId (seat :int) :int
    {
        var id :int = _gameCtrl.game.seating.getPlayerIds()[seat];
        return id;
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
        var seat :int = ids.indexOf(id);
        if (seat == -1) {
            throw Error("Id " + id + " not found");
        }
        return seat;
    }

    /** Get the name of a player by id. */
    protected function getPlayerName (id :int) :String
    {
        var seat :int = getPlayerSeat(id);
        var names :Array = _gameCtrl.game.seating.getPlayerNames();
        return names[seat];
    }

    /** End the game.
     *  TODO: award points + flow? */
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
        _table.setPlayerTurn(hotSeat);

        updateBidding();
        updateMoves();

        if (turnHolder > 0) {
            // This is the beginning of the round, so declare the leader.
            if (countBidsPlaced() == 0) {
                var leader :String = _gameCtrl.game.seating.getPlayerNames()[hotSeat];
                _gameCtrl.local.feedback("Leader this round is " + leader);
                _table.setTrickLeader(hotSeat);

                if (_gameCtrl.game.amInControl()) {
                    _gameCtrl.net.set(COMS_LAST_LEADER, turnHolder);
                }
            }
            else if (_gameCtrl.net.get(COMS_TRICK_SIZE) == 0) {
                _table.setTrickLeader(hotSeat);
            }
        }
    }

    /** Main entry point for element changes */
    protected function handleElementChanged (event :ElementChangedEvent) :void
    {
        log("Element changed:" + event.name);

        if (event.name == COMS_BIDS) {
            // make sure that a player's bid is reflected in the view
            var bid :int = event.newValue as int;
            _table.setPlayerBid(event.index, bid);

            if (bid != NO_BID) {
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

        log("Trick winner is " + winner + " in seat " + winnerSeat + ", name " + 
            getPlayerName(winner));

        _tricksTaken[winnerSeat] += 1;
        _table.setPlayerTricks(winnerSeat, _tricksTaken[winnerSeat]);

        _gameCtrl.local.feedback(getPlayerName(winner) + " won the trick");

        if (_gameCtrl.game.amInControl()) {
            _gameCtrl.net.set(COMS_TRICK_SIZE, 0);

            if (_hand.length > 0) {
                _gameCtrl.game.startNextTurn(winner);
            }
        }

        if (_hand.length == 0) {
            completeRound();
        }
    }

    protected function completeRound () :void
    {
        updateScores();

        var playerIds :Array = _gameCtrl.game.seating.getPlayerIds();

        // calculate the highest score that is at least target,
        // as well as the number of players with that score and the
        // player that achieved it
        var highest :int = 0;
        var count :int = 0;
        var winnerId :int = 0;
        for (var seat :int = 0; seat <= NUM_PLAYERS; ++seat) {
            if (_scores[seat] >= _targetScore) {
                if (_scores[seat] > highest) {
                    highest = _scores[seat];
                    count = 1;
                    winnerId = playerIds[seat];
                }
                else if (_scores[seat] == highest) {
                    count++;
                }
            }
        }

        // feedback
        if (count == 1) {
            _gameCtrl.local.feedback(getPlayerName(winnerId) + " wins the game!");
        }
        else if (count > 1) {
            _gameCtrl.local.feedback("Tie game! Continuing...");
        }
        
        // control
        if (_gameCtrl.game.amInControl()) {
            if (count != 1) {
                _gameCtrl.game.endRound(DELAY_TO_NEXT_ROUND);
            }
            else {
                var winners :Array = [winnerId];
                var losers :Array = playerIds.filter(notWinner);
                _gameCtrl.game.endGameWithWinners(
                    winners, losers, GameSubControl.CASCADING_PAYOUT);
            }
        }

        function notWinner (id :int, i :int, a :Array) :Boolean
        {
            return id != winnerId;
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

            if (value > 0) {
                _table.setTrickWinner(getPlayerSeat(calculateTrickWinner()));
            }

            if (value == 0) {
                _trick.reset();
            }
            else if (value == NUM_PLAYERS) {
                completeTrick();
            }
            else if (_gameCtrl.game.amInControl()) {
                _gameCtrl.game.startNextTurn();
            }
        }
        else if (event.name == COMS_BIDS) {
            // make sure that a player's bid is reflected in the view
            var bids :Array = event.newValue as Array;
            for (var i :int = 0; i < NUM_PLAYERS; ++i) {
                _table.setPlayerBid(i, bids[i]);
                _table.setPlayerTricks(i, 0);
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

        _table.showBidControl(showSlider, _hand.length, onBid);
    }

    /** Entry point for when the user selects their bid */
    protected function onBid (bid :int) :void
    {
        _gameCtrl.net.setAt(COMS_BIDS, getMySeat(), bid);
    }

    /** Check if spades can be played (part of current game state and/or config).
     *  TODO: implement. */
    protected function canLeadSpades () :Boolean
    {
        return true;
    }

    /** Check how many cards of a suit the local player has in his hand. */
    protected function countSuit (suit :int) :int
    {
        var count :int = 0;
        _hand.cards.forEach(countIfSameSuit);
        return count;

        function countIfSameSuit (c :Card, i :int, a :Array) :void
        {
            if (c.suit == suit) {
                ++count;
            }
        }
    }

    /** Get an array of cards from the players hand that either match or do not 
     *  match a given suit. */
    protected function filterCards (suit :int, match :Boolean) :CardArray
    {
        return _hand.shortFilter(compare);

        function compare (c :Card) :Boolean
        {
            if (match) {
                return c.suit == suit;
            }
            else {
                return c.suit != suit;
            }
        }
    }

    /** Highlight the cards that may now be played. */
    protected function updateMoves () :void
    {
        var leader :Card = null;

        if (_trick.length > 0) {
            leader = _trick.cards[0];
        }

        if (!_gameCtrl.game.isMyTurn()) {
            // not my turn, disable
            _table.disableHand();
        }
        else if (_trick.length == NUM_PLAYERS) {
            // trick full, disable
            _table.disableHand();
        }
        else if (countBidsPlaced() < NUM_PLAYERS) {
            // bidding not finished, disable
            _table.disableHand();
        }
        else if (leader != null && countSuit(leader.suit) == 0) {
            // out of led suit, allow any
            _table.enableHand(onPlay);
        }
        else if (leader != null) {
            // allow only led suit
            _table.enableHand(onPlay, filterCards(leader.suit, true));
        }
        else if (canLeadSpades()) {
            // leading and spades are available, allow any
            _table.enableHand(onPlay);
        }
        else if (countSuit(Card.SUIT_SPADES) == _hand.length) {
            // leading and no other suits available, allow any
            _table.enableHand(onPlay);
        }
        else {
            // leading, allow any non-spade suit
            _table.enableHand(onPlay, filterCards(leader.suit, false));
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
            // we have been given some cards, repopulate our hand
            _hand.reset(event.value as Array);
            log("My hand is " + _hand);
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
    protected var _hand :CardArray = new CardArray();

    /** The table. */
    protected var _table :TableSprite;

    /** Tricks taken by each player (indexed by seat). */
    protected var _tricksTaken :Array = filledArray(NUM_PLAYERS, 0);

    /** The trick sprite in the middle of the table */
    protected var _trick :CardArray = new CardArray();

    /** The scores so far. */
    protected var _scores :Array;

    /** Target score for declaring the winner. */
    protected var _targetScore :int = 300;

    /** If we are running a "development minigame". */
    protected var _miniGame :Boolean = false;

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

    /** Name of property indicating the last player to lead the hand. */
    protected static const COMS_LAST_LEADER :String = "lastleader";

}
}

