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
        _templateDeck = CardArray.FULL_DECK;

        var config :Object = gameCtrl.game.getConfig();
        if ("minigame" in config) {
            var isHighCard :Function = function (c :Card) :Boolean {
                return Card.compareRanks(c.rank, Card.RANK_QUEEN, 
                    Card.RANK_ORDER_ACES_HIGH) >= 0;
            }
            _templateDeck = _templateDeck.shortFilter(isHighCard);
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

    protected function get bids () :SpadesBids
    {
        return _model.bids as SpadesBids;
    }

    protected function get scores () :Scores
    {
        return _model.scores;
    }

    /** Boot up the game. */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        var deckStr :String = "(" + _templateDeck.length + " card deck)";
        if (_templateDeck.length == 52) {
            deckStr = "";
        }
        gameCtrl.local.feedback(
             "Welcome to Spades, first player to score " + scores.target + 
             " wins" + deckStr  + "\n");

        scores.resetScores();
    }

    /** Start the round. */
    protected function handleRoundStarted (event :StateChangedEvent) :void
    {
        gameCtrl.local.feedback("Round " + gameCtrl.game.getRound() + " started\n");

        // let the controlling client kick off the round
        if (gameCtrl.game.amInControl()) {

            log("Dealing and setting up bids");

            hand.prepare(_templateDeck);
            bids.reset();
            trick.reset();

            // deal cards unless player is eligible for blind nil
            var numCards :int = cardsPerPlayer;
            var wal :WinnersAndLosers = scores.getWinnersAndLosers();
            var blindNil :Team = null;
            if (wal.scoreDifferential >= BLIND_NIL_THRESHOLD) {
                blindNil = wal.losingTeams[0];
            }
            for (var seat :int = 0; seat < NUM_PLAYERS; ++seat) {
                if (blindNil == null || !blindNil.hasSeat(seat)) {
                    hand.dealTo(table.getIdFromAbsolute(seat), numCards);
                }
            }

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

    /** Number of cards dealt per player */
    protected function get cardsPerPlayer () :int
    {
        return _templateDeck.length / NUM_PLAYERS;
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

            if (bids.isBlind(table.getAbsoluteFromId(event.player))) {
                gameCtrl.local.feedback(
                    table.getNameFromId(event.player) + " has bid blind nil!");
            }
            else {
                gameCtrl.local.feedback(name + " bid " + event.value);
            }
            
            if (gameCtrl.game.amInControl()) {
                gameCtrl.game.startNextTurn();
            }
        }
        else if (event.type == SpadesBids.BLIND_NIL_RESPONDED) {

            // player has confirmed or denied the blind nil, deal cards to him and if he accepted,
            // also deal to teammate since he will not be eligible for blind nil
            if (gameCtrl.game.amInControl()) {
                hand.dealTo(event.player, cardsPerPlayer);

                if (Boolean(event.value)) {
                    var teammate :int = table.getTeammateId(event.player);
                    if (!bids.hasBid(table.getAbsoluteFromId(teammate))) {
                        hand.dealTo(teammate, cardsPerPlayer);
                    }
                }
            }

            // if the player has denied blind nil, activate the normal bid ui
            if (!Boolean(event.value) && event.player == table.getLocalId()) {
                bids.request(getLocalPlayerMaximumBid());
            }
        }
        else if (event.type == BidEvent.COMPLETED) {
            gameCtrl.local.feedback("All bids are in, starting play");
        }
        else if (event.type == BidEvent.SELECTED) {
            
            // The first two cases here are special and require a blind nil response 
            // message to be sent to all clients

            if (event.value == SpadesBids.SELECTED_BLIND_NIL) {
                bids.placeBlindNilResponse(true);
            }
            else if (event.value == SpadesBids.SELECTED_SHOW_CARDS) {
                bids.placeBlindNilResponse(false);
            }
            else {
                bids.placeBid(event.value);
            }
        }
    }

    /** Check if the local player meets all criteria for placing a blind nil bid. */
    protected function isLocalPlayerEligibleForBlindNilBid () :Boolean
    {
        var wal :WinnersAndLosers = scores.getWinnersAndLosers();
        if (wal.scoreDifferential < BLIND_NIL_THRESHOLD) {
            return false;
        }
        
        var loser :Team = Team(wal.losingTeams[0]);
        if (!loser.hasSeat(table.getLocalSeat())) {
            return false;
        }
        
        var teammate :int = table.getLocalTeammate();
        if (bids.hasBid(teammate) && bids.isBlind(teammate)) {
            return false;
        }

        return true;
    }

    /** Get the maximum amount a player should be allowed to bid (limited by teammate's bid). */
    protected function getLocalPlayerMaximumBid () :int
    {
        var teamTotal :int = 0;
        if (bids.hasBid(table.getLocalTeammate())) {
            teamTotal = bids.getBid(table.getLocalTeammate());
        }
        return cardsPerPlayer - teamTotal;
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
            else if (isLocalPlayerEligibleForBlindNilBid()) {
                bids.request(SpadesBids.REQUESTED_BLIND_NIL);
            }
            else {
                bids.request(getLocalPlayerMaximumBid()); 
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

    /** True if spades have been shown in the current round. */
    protected var _spadePlayed :Boolean = false;

    /** Deck for use when restarting a round or calculating number of cards. */
    protected var _templateDeck :CardArray;

    /** Name of property indicating the last player to lead the hand. */
    protected static const COMS_LAST_LEADER :String = "lastleader";

    /** Players required for a game of spades */
    protected static const NUM_PLAYERS :int = 4;

    /** Minimum score differential for the losing team to be allowed to bid blind nil. */
    protected static const BLIND_NIL_THRESHOLD :int = 100;

    /** Time between rounds (seconds). */
    protected static const DELAY_TO_NEXT_ROUND :int = 5;
}
}

