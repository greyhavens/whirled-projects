package spades {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.MovieClip;

import com.threerings.flash.Vector2;

import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.StateChangedEvent;

import spades.card.Card;
import spades.card.CardArray;
import spades.card.Trick;
import spades.card.TrickEvent;
import spades.card.Bids;
import spades.card.BidEvent;
import spades.card.Table;
import spades.card.Hand;
import spades.card.HandEvent;
import spades.card.Sorter;
import spades.card.Scores;
import spades.card.Team;
import spades.card.WinnersAndLosers;

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

    /** Time between rounds (seconds). */
    public static const DELAY_TO_NEXT_ROUND :int = 5;

    /** Main entry point. Start a new game of spades. */
    public function Spades (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;

        var config :Object = _gameCtrl.game.getConfig();
        var targetScore :int = 300;

        if ("playto" in config) {
            targetScore = parseInt(config["playto"] as String);
        }
        if ("minigame" in config) {
            _miniGame = config["minigame"] as Boolean;
        }


        _seating = new Table(
            _gameCtrl.game.seating.getPlayerNames(),
            _gameCtrl.game.seating.getPlayerIds(), 
            _gameCtrl.game.seating.getMyPosition(),
            [new Team(0, [0, 2]), new Team(1, [1, 3])]);
        _trick = new Trick(_gameCtrl, trumps);
        _bids = new Bids(_gameCtrl, CardArray.FULL_DECK.length / NUM_PLAYERS);
        _hand = new Hand(_gameCtrl, new Sorter(
            Card.RANK_ORDER_ACES_HIGH, [
                Card.SUIT_SPADES,
                Card.SUIT_HEARTS,
                Card.SUIT_CLUBS,
                Card.SUIT_DIAMONDS]));
        _scores = new Scores(_seating, _bids, targetScore);

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

        _trick.addEventListener(TrickEvent.CARD_PLAYED, trickListener);
        _trick.addEventListener(TrickEvent.COMPLETED, trickListener);

        _bids.addEventListener(BidEvent.PLACED, bidListener);
        _bids.addEventListener(BidEvent.COMPLETED, bidListener);
        _bids.addEventListener(BidEvent.SELECTED, bidListener);

        _hand.addEventListener(HandEvent.CARDS_SELECTED, handListener);

        // configure the players
        _table = new TableSprite(
            _scores,
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
             "Welcome to Spades, first player to score " + _scores.target + 
             " wins" + mini  + "\n");

        _scores.resetScores();
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

            _hand.deal(deck);
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

        _scores.resetTricks();
    }
    
    /** Process the total tricks taken for this set of hands played, add into the local scores
     *  and display */
    protected function updateScores () :void
    {
        for (var team :int = 0; team < _seating.numTeams; ++team) {
            var over :int = _scores.getTricks(team) - _scores.getBid(team);
            var base :int = _scores.getBid(team) * 10;
            var score :int = over >= 0 ? (base + over) : (-base);
            _scores.addScore(team, score);
        }
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
        else if (event.type == BidEvent.SELECTED) {
            _bids.placeBid(event.value);
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

        if (_gameCtrl.game.isMyTurn()) {
            if (_bids.complete) {
                _hand.beginTurn(getLegalMoves());
            }
            else {
                _bids.request(_hand.length);
            }
        }

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

        _scores.addTrick(winnerSeat);

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

    protected function getTeamName (team :Team) :String
    {
        
        var names :Array = _gameCtrl.game.seating.getPlayerNames();
        return names[team.index] + " and " + names[team.index + 2];
    }

    protected function completeRound () :void
    {
        updateScores();

        var wal :WinnersAndLosers = _scores.getWinnersAndLosers();
        var winners :Array = wal.winningTeams;

        var highScore :int = _scores.getScore(Team(winners[0]).index);

        if (highScore < _scores.target && wal.losingTeams.length == 1) {
            highScore = 
                _scores.getScore(Team(winners[0]).index) -
                _scores.getScore(Team(wal.losingTeams[0]).index);
        }

        // feedback
        if (highScore >= _scores.target) {
            if (winners.length == 1) {
                _gameCtrl.local.feedback(
                    getTeamName(Team(winners[0])) + " win the game!");
            }
            else if (winners.length > 1) {
                _gameCtrl.local.feedback("Tie game! Continuing...");
            }
        }
        
        // control
        if (_gameCtrl.game.amInControl()) {
            if (winners.length == 1 && highScore >= _scores.target) {
                _gameCtrl.game.endGameWithWinners(
                    wal.winningPlayers, wal.losingPlayers, 
                    GameSubControl.CASCADING_PAYOUT);
            }
            else {
                _gameCtrl.game.endRound(DELAY_TO_NEXT_ROUND);
            }
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
        _hand.cards.cards.forEach(countIfSameSuit);
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
        return _hand.cards.shortFilter(compare);

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

    /** Get the cards that may now be played. */
    protected function getLegalMoves () :CardArray
    {
        var leader :Card = _trick.ledCard;

        if (leader != null && countSuit(leader.suit) == 0) {
            // out of led suit, allow any
            return _hand.cards;
        }
        else if (leader != null) {
            // allow only led suit
            return filterCards(leader.suit, true);
        }
        else if (canLeadSpades()) {
            // leading and spades are available, allow any
            return _hand.cards;
        }
        else if (countSuit(Card.SUIT_SPADES) == _hand.length) {
            // leading and no other suits available, allow any
            return _hand.cards;
        }
        else {
            // leading, allow any non-spade suit
            return filterCards(Card.SUIT_SPADES, false);
        }
    }

    /** Entry point for when the user selects a card to play */
    protected function handListener (event :HandEvent) :void
    {
        if (event.type == HandEvent.CARDS_SELECTED) {
            var card :Card = event.cards.cards[0];
            _trick.playCard(card);
            _hand.endTurn();
        }
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
    protected var _hand :Hand;

    /** The table. */
    protected var _table :TableSprite;

    /** The trick in the middle of the table */
    protected var _trick :Trick;

    /** The bids */
    protected var _bids :Bids;
    
    /** The scores */
    protected var _scores :Scores;

    /** If we are running a "development minigame". */
    protected var _miniGame :Boolean = false;

    /** Name of property indicating the last player to lead the hand. */
    protected static const COMS_LAST_LEADER :String = "lastleader";
}
}

