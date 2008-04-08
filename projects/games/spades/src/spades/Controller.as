package spades {

import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.StateChangedEvent;

import spades.card.Card;
import spades.card.CardArray;
import spades.card.Trick;
import spades.card.TrickEvent;
import spades.card.Bids;
import spades.card.SpadesBids;
import spades.card.BidEvent;
import spades.card.Table;
import spades.card.Hand;
import spades.card.HandEvent;
import spades.card.Sorter;
import spades.card.Scores;
import spades.card.Team;
import spades.card.WinnersAndLosers;

/**
 * The controller for spades.
 * TODO Strip out excessive debug logging.
 * TODO Use localized feeedback.
 */
public class Controller
{
    /** Create a new controller. Constructs Model and connects all listeners. */
    public function Controller (gameCtrl :GameControl)
    {
        var config :Object = gameCtrl.game.getConfig();
        if ("minigame" in config) {
            _miniGame = config["minigame"] as Boolean;
        }

        var sorter :Sorter = new Sorter(
            Card.RANK_ORDER_ACES_HIGH, [
                Card.SUIT_SPADES,
                Card.SUIT_HEARTS,
                Card.SUIT_CLUBS,
                Card.SUIT_DIAMONDS]);

        var targetScore :int = 300;

        if ("playto" in config) {
            targetScore = parseInt(config["playto"] as String);
        }

        var table :Table = new Table(
            gameCtrl.game.seating.getPlayerNames(),
            gameCtrl.game.seating.getPlayerIds(), 
            gameCtrl.game.seating.getMyPosition(),
            [new Team(0, [0, 2]), new Team(1, [1, 3])]);
        var hand :Hand = new Hand(gameCtrl, sorter);
        var trick :Trick = new Trick(gameCtrl, trumps);
        var bids :SpadesBids = new SpadesBids(gameCtrl, 
            CardArray.FULL_DECK.length / table.numPlayers);
        var scores :Scores = new Scores(table, bids, targetScore);

        _model = new Model(gameCtrl, table, hand, trick, bids, scores);

        gameCtrl.game.addEventListener(
            StateChangedEvent.GAME_STARTED, 
            handleGameStarted);
        gameCtrl.game.addEventListener(
            StateChangedEvent.GAME_ENDED, 
            handleGameEnded);
        gameCtrl.game.addEventListener(
            StateChangedEvent.ROUND_STARTED, 
            handleRoundStarted);
        gameCtrl.game.addEventListener(
            StateChangedEvent.ROUND_ENDED, 
            handleRoundEnded);
        gameCtrl.game.addEventListener(
            StateChangedEvent.TURN_CHANGED, 
            handleTurnChanged);

        trick.addEventListener(TrickEvent.CARD_PLAYED, trickListener);
        trick.addEventListener(TrickEvent.COMPLETED, trickListener);

        bids.addEventListener(BidEvent.PLACED, bidListener);
        bids.addEventListener(BidEvent.COMPLETED, bidListener);
        bids.addEventListener(BidEvent.SELECTED, bidListener);
        bids.addEventListener(SpadesBids.BLIND_NIL_RESPONDED, bidListener);

        hand.addEventListener(HandEvent.CARDS_SELECTED, handListener);
    }

    public function get model () :Model
    {
        return _model;
    }

    / ** For debugging, log a string prefixed with player name and seating position. */
    public function log (str :String) :void
    {
        Debug.debug(str);
    }

    protected function get gameCtrl () :GameControl
    {
        return _model.gameCtrl;
    }

    protected function get table () :Table
    {
        return _model.table;
    }

    protected function get hand () :Hand
    {
        return _model.hand;
    }

    protected function get trick () :Trick
    {
        return _model.trick;
    }

    protected function get bids () :Bids
    {
        return _model.bids;
    }

    protected function get scores () :Scores
    {
        return _model.scores;
    }

    /** Boot up the game. */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        var mini :String = _miniGame ? " (mini game selected)" : "";
        gameCtrl.local.feedback(
             "Welcome to Spades, first player to score " + scores.target + 
             " wins" + mini  + "\n");

        scores.resetScores();
    }

    /** Start the round. */
    protected function handleRoundStarted (event :StateChangedEvent) :void
    {
        gameCtrl.local.feedback("Round " + gameCtrl.game.getRound() + " started\n");

        // let the controlling client kick off the round
        if (gameCtrl.game.amInControl()) {

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

            hand.deal(deck);
            bids.reset();
            trick.reset();

            // on the first round, set a random first player as leader. Otherwise, advance the 
            // previous leader by one
            if (gameCtrl.game.getRound() == 1) {
                gameCtrl.game.startNextTurn();
            }
            else {
                var lastId :int = gameCtrl.net.get(COMS_LAST_LEADER) as int;
                gameCtrl.game.startNextTurn(table.getIdToLeft(lastId));
            }
        }

        _spadePlayed = false;
        scores.resetTricks();
    }
    
    /** Process the total tricks taken for this set of hands played, add into the local scores
     *  and display */
    protected function updateScores () :void
    {
        for (var team :int = 0; team < table.numTeams; ++team) {
            var over :int = scores.getTricks(team) - scores.getBid(team);
            var base :int = scores.getBid(team) * 10;
            var score :int = over >= 0 ? (base + over) : (-base);
            scores.addScore(team, score);
        }
    }

    /** Entry point for when a round has ended. */
    protected function handleRoundEnded (event :StateChangedEvent) :void
    {
        var round :int = -gameCtrl.game.getRound();
        gameCtrl.local.feedback("Round " + round + " ended\n");
    }

    /** End the game.
     *  TODO: award points + flow? */
    protected function handleGameEnded (event :StateChangedEvent) :void
    {
        gameCtrl.local.feedback("Thank you for playing Spades!");
    }

    protected function bidListener (event :BidEvent) :void
    {
        log("Received " + event);
        if (event.type == BidEvent.PLACED) {

            var name :String = table.getNameFromId(event.player);
            gameCtrl.local.feedback(name + " bid " + event.value);
            
            if (gameCtrl.game.amInControl()) {
                gameCtrl.game.startNextTurn();
            }
        }
        else if (event.type == BidEvent.COMPLETED) {
            gameCtrl.local.feedback("All bids are in, starting play");
        }
        else if (event.type == BidEvent.SELECTED) {
            bids.placeBid(event.value);
        }
    }

    /** Update the UI after a turn change. */
    protected function handleTurnChanged (event :StateChangedEvent) :void
    {
        // Make sure the current turn holder is "selected"
        var turnHolder :int = gameCtrl.game.getTurnHolderId();
        var hotSeat :int = gameCtrl.game.seating.getPlayerPosition(turnHolder);
        log("Turn changed to " + turnHolder + " in seat " + hotSeat);

        if (gameCtrl.game.isMyTurn()) {
            if (bids.complete) {
                hand.beginTurn(getLegalMoves());
            }
            else if (bids.hasBid(table.getLocalTeammate())) {
                var teamBid :int = bids.getBid(table.getLocalTeammate());
                bids.request(hand.length - teamBid);
            }
            else {
                bids.request(hand.length);
            }
        }

        if (turnHolder > 0) {
            // This is the beginning of the round, so declare the leader.
            if (bids.length == 0) {
                var leader :String = table.getNameFromAbsolute(hotSeat);
                gameCtrl.local.feedback("Leader this round is " + leader);

                if (gameCtrl.game.amInControl()) {
                    gameCtrl.net.set(COMS_LAST_LEADER, turnHolder);
                }
            }
        }
    }

    /** Calculate the winner of the trick, add it to their number of tricks, save to history and 
     *  give them their turn */
    protected function completeTrick () :void
    {
        if (trick.length != NUM_PLAYERS) {
            throw new Error();
        }

        var winner :int = trick.winner;
        var winnerSeat :int = table.getAbsoluteFromId(winner);

        log("Trick winner is " + winner + " in seat " + winnerSeat + ", name " + 
            table.getNameFromId(winner));

        scores.addTrick(winnerSeat);

        gameCtrl.local.feedback(
            table.getNameFromId(winner) + " won the trick");

        if (gameCtrl.game.amInControl()) {
            trick.reset();

            if (hand.length > 0) {
                gameCtrl.game.startNextTurn(winner);
            }
        }

        if (hand.length == 0) {
            completeRound();
        }
    }

    protected function getTeamName (team :Team) :String
    {
        
        var names :Array = gameCtrl.game.seating.getPlayerNames();
        return names[team.index] + " and " + names[team.index + 2];
    }

    protected function completeRound () :void
    {
        updateScores();

        var wal :WinnersAndLosers = scores.getWinnersAndLosers();
        var winners :Array = wal.winningTeams;
        var highScore :int = wal.highestScore;

        if (highScore < scores.target && wal.losingTeams.length == 1) {
            highScore = wal.scoreDifferential;
        }

        // feedback
        if (highScore >= scores.target) {
            if (winners.length == 1) {
                gameCtrl.local.feedback(
                    getTeamName(Team(winners[0])) + " win the game!");
            }
            else if (winners.length > 1) {
                gameCtrl.local.feedback("Tie game! Continuing...");
            }
        }
        
        // control
        if (gameCtrl.game.amInControl()) {
            if (winners.length == 1 && highScore >= scores.target) {
                gameCtrl.game.endGameWithWinners(
                    wal.winningPlayers, wal.losingPlayers, 
                    GameSubControl.CASCADING_PAYOUT);
            }
            else {
                gameCtrl.game.endRound(DELAY_TO_NEXT_ROUND);
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
            if (event.card.suit == Card.SUIT_SPADES) {
                _spadePlayed = true;
            }

            if (!trick.complete && gameCtrl.game.amInControl()) {
                gameCtrl.game.startNextTurn();
            }
        }
    }

    /** Entry point for when the user selects their bid */
    protected function onBid (bid :int) :void
    {
        bids.placeBid(bid);
    }

    /** Check if spades can be played (part of current game state and/or config).
     *  TODO: implement. */
    protected function canLeadSpades () :Boolean
    {
        return _spadePlayed;
    }

    /** Check how many cards of a suit the local player has in his hand. */
    protected function countSuit (suit :int) :int
    {
        var count :int = 0;
        hand.cards.cards.forEach(countIfSameSuit);
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
        return hand.cards.shortFilter(compare);

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
        var leader :Card = trick.ledCard;

        if (leader != null && countSuit(leader.suit) == 0) {
            // out of led suit, allow any
            return hand.cards;
        }
        else if (leader != null) {
            // allow only led suit
            return filterCards(leader.suit, true);
        }
        else if (canLeadSpades()) {
            // leading and spades are available, allow any
            return hand.cards;
        }
        else if (countSuit(Card.SUIT_SPADES) == hand.length) {
            // leading and no other suits available, allow any
            return hand.cards;
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
            trick.playCard(card);
            hand.endTurn();
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

    /** Our model object. */
    protected var _model :Model;

    /** If we are running a "development minigame". */
    protected var _miniGame :Boolean = false;

    /** True if spades have been shown in the current round. */
    protected var _spadePlayed :Boolean = false;

    /** Name of property indicating the last player to lead the hand. */
    protected static const COMS_LAST_LEADER :String = "lastleader";

    /** Players required for a game of spades */
    protected static const NUM_PLAYERS :int = 4;

    /** Time between rounds (seconds). */
    protected static const DELAY_TO_NEXT_ROUND :int = 5;
}
}

