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
import spades.card.Trick;
import spades.card.TrickEvent;
import spades.card.Bids;
import spades.card.BidEvent;
import spades.card.Table;

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
        _trick = new Trick(_gameCtrl, trumps);
        _bids = new Bids(_gameCtrl);
        _seating = new Table(
            _gameCtrl.game.seating.getPlayerNames(),
            _gameCtrl.game.seating.getPlayerIds(), 
            _gameCtrl.game.seating.getMyPosition());

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
            MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessage);

        _trick.addEventListener(TrickEvent.CARD_PLAYED, trickListener);
        _trick.addEventListener(TrickEvent.COMPLETED, trickListener);

        _bids.addEventListener(BidEvent.PLACED, bidListener);
        _bids.addEventListener(BidEvent.COMPLETED, bidListener);

        var config :Object = _gameCtrl.game.getConfig();

        if ("playto" in config) {
            _targetScore = parseInt(config["playto"] as String);
        }
        if ("minigame" in config) {
            _miniGame = config["minigame"] as Boolean;
        }

        // configure the players
        _table = new TableSprite(
            _seating,
            _targetScore,
            _bids,
            _trick,
            _hand);

        setupHeadShots();

        addChild(_table);
    }

    / ** For debugging, log a string prefixed with player name and seating position. */
    public function log (str :String) :void
    {
        Debug.debug(str);
    }

    protected function setupHeadShots () :void
    {
        var players :Array = _gameCtrl.game.seating.getPlayerIds();
        for (var i :int = 0; i < players.length; ++i) {
            var callback :Function = _table.getHeadShotCallback(i);
            log("Getting headshot for " + players[i]);
            _gameCtrl.local.getHeadShot(players[i], callback);
        }
    }

    /** Boot up the game. */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        var mini :String = _miniGame ? " (mini game selected)" : "";
        _gameCtrl.local.feedback(
             "Welcome to Spades, first player to score " + _targetScore + 
             " wins" + mini  + "\n");
        _scores = filledArray(NUM_PLAYERS / 2, 0);
        _table.setTeamScores(_scores);
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

            _bids.reset();

            _trick.reset();

            // on the first round, set a random first player as leader. Otherwise, advance the 
            // previous leader by one
            if (_gameCtrl.game.getRound() == 1) {
                _gameCtrl.game.startNextTurn();
            }
            else {
                var lastId :int = _gameCtrl.net.get(COMS_LAST_LEADER) as int;
                _gameCtrl.game.startNextTurn(_seating.getIdToLeft(lastId));
            }
        }

        _tricksTaken = filledArray(NUM_PLAYERS, 0);
    }
    
    /** Get the index of the team for the given seat. */
    protected function getTeam (seat :int) :int
    {
        if (seat == 0 || seat == 2) {
            return 0;
        }
        return 1;
    }

    /** Process the total tricks taken for this set of hands played, add into the local scores
     *  and display */
    protected function updateScores () :void
    {
        var teamBids :Array = filledArray(NUM_PLAYERS / 2, 0);
        var teamTricks :Array = filledArray(NUM_PLAYERS / 2, 0);
        var team :int;

        for (var seat :int = 0; seat < NUM_PLAYERS; ++seat) {
            team = getTeam(seat);
            teamBids[team] += _bids.getBid(seat);
            teamTricks[team] += _tricksTaken[seat];
        }

        for (team = 0; team < teamBids.length; ++team) {
            var over :int = teamTricks[team] - teamBids[team];
            var base :int = teamBids[team] * 10;
            var score :int = over >= 0 ? (base + over) : (-base);
            _scores[team] += score;
        }

        _table.setTeamScores(_scores);
    }

    /** Entry point for when a round has ended. */
    protected function handleRoundEnded (event :StateChangedEvent) :void
    {
        var round :int = -_gameCtrl.game.getRound();
        _gameCtrl.local.feedback("Round " + round + " ended\n");
        _table.setPlayerTurn(-1);
    }

    /** End the game.
     *  TODO: award points + flow? */
    protected function handleGameEnded (event :StateChangedEvent) :void
    {
        _gameCtrl.local.feedback("Thank you for playing Spades!");
    }

    protected function bidListener (event :BidEvent) :void
    {
        log("Received " + event);
        if (event.type == BidEvent.PLACED) {

            var name :String = _seating.getNameFromId(event.player);
            _gameCtrl.local.feedback(name + " bid " + event.value);
            
            if (_gameCtrl.game.amInControl()) {
                _gameCtrl.game.startNextTurn();
            }
        }
        else if (event.type == BidEvent.COMPLETED) {
            _gameCtrl.local.feedback("All bids are in, starting play");
        }
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
            if (_bids.length == 0) {
                var leader :String = _seating.getNameFromAbsolute(hotSeat);
                _gameCtrl.local.feedback("Leader this round is " + leader);

                if (_gameCtrl.game.amInControl()) {
                    _gameCtrl.net.set(COMS_LAST_LEADER, turnHolder);
                }
            }
        }
    }

    /** Calculate the winner of the trick, add it to their number of tricks, save to history and 
     *  give them their turn */
    protected function completeTrick () :void
    {
        if (_trick.length != NUM_PLAYERS) {
            throw new Error();
        }

        var winner :int = _trick.winner;
        var winnerSeat :int = _seating.getAbsoluteFromId(winner);

        log("Trick winner is " + winner + " in seat " + winnerSeat + ", name " + 
            _seating.getNameFromId(winner));

        _tricksTaken[winnerSeat] += 1;
        _table.setPlayerTricks(winnerSeat, _tricksTaken[winnerSeat]);

        _gameCtrl.local.feedback(_seating.getNameFromId(winner) + " won the trick");

        if (_gameCtrl.game.amInControl()) {
            _trick.reset();

            if (_hand.length > 0) {
                _gameCtrl.game.startNextTurn(winner);
            }
        }

        if (_hand.length == 0) {
            completeRound();
        }
    }

    protected function getTeamName (team :int) :String
    {
        var names :Array = _gameCtrl.game.seating.getPlayerNames();
        return names[team] + " and " + names[team + 2];
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
        var winner :int = -1;
        for (var team :int = 0; team <= NUM_PLAYERS / 2; ++team) {
            if (_scores[team] >= _targetScore) {
                if (_scores[team] > highest) {
                    highest = _scores[team];
                    count = 1;
                    winner = team;
                }
                else if (_scores[team] == highest) {
                    count++;
                }
            }
        }

        // feedback
        if (count == 1) {
            _gameCtrl.local.feedback(getTeamName(winner) + " win the game!");
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
                var winners :Array = playerIds.filter(isWinner);
                var losers :Array = playerIds.filter(isntWinner);
                _gameCtrl.game.endGameWithWinners(
                    winners, losers, GameSubControl.CASCADING_PAYOUT);
            }
        }

        function isWinner (id :int, i :int, a :Array) :Boolean
        {
            return getTeam(_seating.getAbsoluteFromId(id)) == winner;
        }

        function isntWinner (id :int, i :int, a :Array) :Boolean
        {
            return getTeam(_seating.getAbsoluteFromId(id)) != winner;
        }
    }

    protected function trickListener (event :TrickEvent) :void
    {
        log("Received " + event);
        if (event.type == TrickEvent.COMPLETED) {
            completeTrick();
        }
        else if (event.type == TrickEvent.CARD_PLAYED) {
            if (!_trick.complete && _gameCtrl.game.amInControl()) {
                _gameCtrl.game.startNextTurn();
            }
        }
    }

    /** Show or hide the bidding interface. */
    protected function updateBidding () :void
    {
        var showSlider :Boolean = 
            _gameCtrl.game.isMyTurn() && 
            !_bids.hasBid(_seating.getLocalSeat());

        log("Ready to bid: " + showSlider);
        
        // TODO: subtract my partner's bid from the maximum bid 
        _table.showBidControl(showSlider, _hand.length, onBid);
    }

    /** Entry point for when the user selects their bid */
    protected function onBid (bid :int) :void
    {
        _bids.placeBid(bid);
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
        var leader :Card = _trick.ledCard;

        if (!_gameCtrl.game.isMyTurn()) {
            // not my turn, disable
            _table.disableHand();
        }
        else if (_trick.complete) {
            // trick full, disable
            _table.disableHand();
        }
        else if (!_bids.complete) {
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
        _trick.playCard(card);
        _hand.remove(card);
        _table.disableHand();
    }

    /** Main entry point for messages. */
    protected function handleMessage (event :MessageReceivedEvent) :void
    {
        log("Received message: " + event.name);
        
        if (event.name == COMS_HAND) {
            // we have been given some cards, repopulate our hand
            var hand :CardArray = new CardArray(event.value as Array);
            hand.standardSort(SUITS, Card.RANK_ORDER_ACES_HIGH);
            _hand.reset(hand.ordinals);
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

    protected static function trumps (candidate :Card, winnerSoFar :Card) :Boolean
    {
        if (candidate.suit == winnerSoFar.suit) {
            return candidate.isBetterRank(winnerSoFar, Card.RANK_ORDER_ACES_HIGH);
        }
        else if (candidate.suit == Card.SUIT_SPADES) {
            return true;
        }
        return false;
    }

    /** Our game control object. */
    protected var _gameCtrl :GameControl;

    /** Our seating object. */
    protected var _seating :Table;

    /** Our hand. */
    protected var _hand :CardArray = new CardArray();

    /** The table. */
    protected var _table :TableSprite;

    /** Tricks taken by each player (indexed by seat). */
    protected var _tricksTaken :Array = filledArray(NUM_PLAYERS, 0);

    /** The trick in the middle of the table */
    protected var _trick :Trick;

    /** The bids */
    protected var _bids :Bids;

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

    /** Name of property indicating the last player to lead the hand. */
    protected static const COMS_LAST_LEADER :String = "lastleader";

    protected static const SUITS :Array = [
        Card.SUIT_SPADES,
        Card.SUIT_HEARTS,
        Card.SUIT_CLUBS,
        Card.SUIT_DIAMONDS];
}
}

