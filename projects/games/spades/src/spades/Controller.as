package spades {

import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.OccupantChangedEvent;
import com.threerings.util.Assert;

import com.whirled.contrib.card.Card;
import com.whirled.contrib.card.CardArray;
import com.whirled.contrib.card.trick.Trick;
import com.whirled.contrib.card.trick.TrickEvent;
import com.whirled.contrib.card.trick.Bids;
import spades.card.SpadesBids;
import com.whirled.contrib.card.trick.BidEvent;
import com.whirled.contrib.card.Table;
import com.whirled.contrib.card.Hand;
import com.whirled.contrib.card.HandEvent;
import com.whirled.contrib.card.Sorter;
import com.whirled.contrib.card.trick.Scores;
import com.whirled.contrib.card.trick.ScoresEvent;
import spades.card.SpadesScores;
import com.whirled.contrib.card.trick.ScoreBreakdown;
import com.whirled.contrib.card.Team;
import com.whirled.contrib.card.trick.WinnersAndLosers;
import com.whirled.contrib.card.trick.TrickTurnTimer;
import com.whirled.contrib.card.TurnTimerEvent;

/**
 * The controller for spades.
 * TODO Strip out excessive debug logging.
 * TODO Use localized feeedback.
 */
public class Controller
{
    /** Create a new controller. Constructs Model and connects all listeners. */
    public function Controller (gameCtrl :GameControl, createViews :Function)
    {
        _templateDeck = CardArray.makeDeck();
        _server = gameCtrl.game.amServerAgent();

        Debug.debug("amServerAgent: " + _server);

        var config :Object = gameCtrl.game.getConfig();
        if ("minigame" in config && config.minigame) {
            var isHighCard :Function = function (c :Card) :Boolean {
                return Card.compareRanks(c.rank, Card.RANK_JACK, 
                    Card.RANK_ORDER_ACES_HIGH) >= 0;
            }
            _templateDeck = _templateDeck.shortFilter(isHighCard);
        }

        if (!_server && 
            gameCtrl.game.seating.getMyPosition() == -1) {
            attachToModel(createModel(gameCtrl));
            createViews(_model);
        }
        else {
            // Listen for game start and round start events, on the first one that occurs,
            // construct the model and views and call the appropriate listener method. This
            // is necessary because 1) whirled starts the round before the game, but there
            // is a load of stuff that spades needs to do specifically to restart a round
            // and 2) the model needs all the players to be at the table before construction
            gameCtrl.game.addEventListener(
                StateChangedEvent.GAME_STARTED, 
                startGame);
            gameCtrl.game.addEventListener(
                StateChangedEvent.ROUND_STARTED, 
                startRound);
        }


        function bootstrap (fn :Function, evt :StateChangedEvent) :void {
            if (_model == null) {
                attachToModel(createModel(gameCtrl));
                if (createViews != null) {
                    createViews(_model);
                }
            }
            fn(evt);
        }

        function startGame (event :StateChangedEvent) :void {
            Debug.debug("Bootstrapping game start");
            bootstrap(handleGameStarted, event);
            gameCtrl.game.removeEventListener(
                StateChangedEvent.GAME_STARTED, 
                startGame);
        }

        function startRound (event :StateChangedEvent) :void {
            Debug.debug("Bootstrapping round start");
            bootstrap(handleRoundStarted, event);
            gameCtrl.game.removeEventListener(
                StateChangedEvent.ROUND_STARTED, 
                startRound);
        }
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

    protected function get scores () :SpadesScores
    {
        return _model.scores as SpadesScores;
    }

    protected static function createModel (gameCtrl :GameControl) :Model
    {
        var config :Object = gameCtrl.game.getConfig();

        var sorter :Sorter = new Sorter(
            Card.RANK_ORDER_ACES_HIGH, [
                Card.SUIT_SPADES,
                Card.SUIT_HEARTS,
                Card.SUIT_CLUBS,
                Card.SUIT_DIAMONDS]);

        var targetScore :int = 300;

        if ("playTo" in config) {
            targetScore = parseInt(config.playTo as String);
        }

        var table :Table = new Table(
            gameCtrl.game.seating.getPlayerNames(),
            gameCtrl.game.seating.getPlayerIds(), 
            gameCtrl.game.seating.getMyPosition(),
            [new Team(0, [0, 2]), new Team(1, [1, 3])]);
        var hand :Hand = table.isWatcher() ? null : new Hand(gameCtrl, sorter);
        var trick :Trick = new Trick(gameCtrl, trumps);
        var bids :SpadesBids = new SpadesBids(gameCtrl, 52 / table.numPlayers);
        var scores :Scores = new SpadesScores(gameCtrl, table, bids, targetScore);
        var timer :TrickTurnTimer = new TrickTurnTimer(
            gameCtrl, table, bids, trick, true);
        timer.debug = Debug.debug;

        if ("timer" in config && !config.timer) {
            timer.disable();
        }

        if ("playTime" in config) {
            timer.playTime = parseInt(config.playTime);
        }

        if ("bidTime" in config) {
            timer.bidTime = parseInt(config.bidTime);
        }

        if ("leadTime" in config) {
            timer.leadTime = parseInt(config.leadTime);
        }

        return new Model(gameCtrl, table, hand, trick, bids, scores, timer);
    }

    protected function attachToModel (model :Model) :void
    {
        _model = model;

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
        gameCtrl.game.addEventListener(
            OccupantChangedEvent.OCCUPANT_LEFT,
            handleOccupantChanged);

        trick.addEventListener(TrickEvent.CARD_PLAYED, trickListener);
        trick.addEventListener(TrickEvent.COMPLETED, trickListener);

        bids.addEventListener(BidEvent.PLACED, bidListener);
        bids.addEventListener(BidEvent.COMPLETED, bidListener);
        bids.addEventListener(BidEvent.SELECTED, bidListener);
        bids.addEventListener(SpadesBids.BLIND_NIL_RESPONDED, bidListener);

        if (hand != null) {
            hand.addEventListener(HandEvent.CARDS_PLAYED, handListener);
            hand.addEventListener(HandEvent.PASS_REQUESTED, handListener);
            hand.addEventListener(HandEvent.PASSED, handListener);
        }

        model.timer.addEventListener(TurnTimerEvent.EXPIRED, turnTimerListener);

        model.scores.addEventListener(ScoresEvent.TRICKS_CHANGED, scoresListener);
        model.scores.addEventListener(ScoresEvent.SCORES_CHANGED, scoresListener);
    }

    /** Boot up the game. */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        if (!_gameStarted) {
            Debug.debug("Game started " + event);

            _gameStarted = true;

            var deckStr :String = "(" + _templateDeck.length + " card deck)";
            if (_templateDeck.length == 52) {
                deckStr = "";
            }
            gameCtrl.local.feedback(
                "Welcome to Spades, first player to score " + scores.target + 
                " wins" + deckStr  + "\n");

            if (_server) {
                scores.resetScores();
            }
        }
    }

    /** Start the round. */
    protected function handleRoundStarted (event :StateChangedEvent) :void
    {
        if (!_gameStarted) {
            handleGameStarted(null);
        }

        Debug.debug("Round started " + event);

        gameCtrl.local.feedback("Round " + gameCtrl.game.getRound() + " started\n");

        // let the server kick off the round
        if (_server) {

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
                if (blindNil != null && blindNil.hasSeat(seat)) {
                    hand.dealFaceDownTo(table.getIdFromAbsolute(seat), numCards);
                }
                else {
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
            
            scores.resetTricks();
        }

        _spadePlayed = false;
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
            var breakdown :ScoreBreakdown = new ScoreBreakdown(table, team);

            var over :int = scores.getTricks(team) - scores.getBid(team);
            var base :int = scores.getBid(team) * 10;

            // base score
            breakdown.addTeamAchievement(over >= 0 ? base : -base, 
                "making their team bid");

            // overtricks
            if (over > 0) {
                breakdown.addTeamAchievement(over, "exceeding their team bid");
            }

            // sandbags
            var bags :int = scores.getAllTricks(team) - scores.getBid(team);
            var newBags :int = scores.getSandbags(team) + bags;
            while (newBags >= 10) {
                breakdown.addTeamFailure(-100, "sandbagging");
                newBags -= 10;
            }

            // nil bids
            var players :Array = table.getTeam(team).players;
            for (var i :int = 0; i < players.length; ++i) {
                var player :int = players[i];
                if (bids.getBid(player) > 0) {
                    continue;
                }
                
                var score :int = 1;
                score *= scores.getPlayerTricks(player) > 0 ? -1 : 1;

                // (Rules on WWW say 100, but yohoho uses 50)
                score *= 50;
                
                var achievement :String = "making a nil bid";
                if (bids.isBlind(player)) {
                    score *= 2;
                    achievement = "making a blind nil bid";
                }
                breakdown.addPlayerAchievement(score, i, achievement);
            }

            breakdown.describe().forEach(function (d :String, ...x) :void {
                gameCtrl.local.feedback(d);
            });

            if (_server) {
                scores.addScore(team, breakdown.total);
                scores.setSandbags(team, newBags);
            }
        }
    }

    /** Entry point for when a round has ended. */
    protected function handleRoundEnded (event :StateChangedEvent) :void
    {
        var round :int = -gameCtrl.game.getRound();
        gameCtrl.local.feedback("Round " + round + " ended\n");
    }

    /** End the game. */
    protected function handleGameEnded (event :StateChangedEvent) :void
    {
        if (_gameStarted) {
            _gameStarted = false;
            gameCtrl.local.feedback("Thank you for playing Spades!");
        }
    }

    protected function handleOccupantChanged (event :OccupantChangedEvent) :void
    {
        if (event.type == OccupantChangedEvent.OCCUPANT_LEFT) {
            if (event.player && _gameStarted && _server) {
                var team :Team = table.getTeamFromId(event.occupantId);
                var otherTeam :Team = table.getTeam((team.index + 1) % 2);
                gameCtrl.local.feedback(
                    getTeamName(team) + " are disqualified, " + 
                    getTeamName(otherTeam) + " win!");
                gameCtrl.game.startNextTurn(-1);
                gameCtrl.game.endGameWithWinners(
                    table.getIdsNotOnTeam(team), table.getIdsOnTeam(team), 
                    GameSubControl.CASCADING_PAYOUT);
            }
        }
    }

    protected function bidListener (event :BidEvent) :void
    {
        log("Received " + event);

        var teammate :int;

        if (event.type == BidEvent.PLACED) {

            var name :String = table.getNameFromId(event.player);

            if (bids.isBlind(table.getAbsoluteFromId(event.player))) {
                gameCtrl.local.feedback(
                    table.getNameFromId(event.player) + " has bid blind nil!");
            }
            else {
                gameCtrl.local.feedback(name + " bid " + event.value);
            }
            
            if (_server && !bids.complete) {
                gameCtrl.game.startNextTurn();
            }
        }
        else if (event.type == SpadesBids.BLIND_NIL_RESPONDED) {

            // player has confirmed or denied the blind nil, deal cards to him and if he accepted,
            // also deal to teammate since he will not be eligible for blind nil
            if (_server) {
                hand.dealTo(event.player, cardsPerPlayer);
                _model.timer.restart();

                if (Boolean(event.value)) {
                    teammate = table.getTeammateId(event.player);
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

            // check if any card passing is needed
            var blindBidder :int = bids.blindBidder;
            if (blindBidder >= 0) {
                teammate = table.getTeammateAbsolute(blindBidder);
                var names :String = 
                    table.getNameFromAbsolute(blindBidder) + " and " +
                    table.getNameFromAbsolute(teammate);
                gameCtrl.local.feedback("All bids are in, " + names + " must exchange cards");
                if (_server) {
                    // by convention, the blind bidder first gives 2 cards to teammate
                    hand.requestPass(
                        table.getIdFromAbsolute(blindBidder), 
                        table.getIdFromAbsolute(teammate), 
                        BLIND_NIL_EXCHANGE);
                    gameCtrl.game.startNextTurn(
                        table.getIdFromAbsolute(blindBidder));
                }
            }
            else {
                gameCtrl.local.feedback("All bids are in, starting play");
                if (_server) {
                    gameCtrl.game.startNextTurn();
                }
            }

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
        Assert.isFalse(table.isWatcher());

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
        Assert.isFalse(table.isWatcher());

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
        var seat :int = table.getAbsoluteFromId(turnHolder);
        log("Turn changed to " + turnHolder + " in seat " + seat);

        if (gameCtrl.game.isMyTurn()) {
            if (bids.complete) {
                if (hand.isPassing) {
                    hand.allowPlay(hand.cards, BLIND_NIL_EXCHANGE);
                }
                else {
                    hand.allowPlay(getLegalMoves());
                }
            }
            else if (isLocalPlayerEligibleForBlindNilBid()) {
                bids.request(SpadesBids.REQUESTED_BLIND_NIL);
            }
            else {
                bids.request(getLocalPlayerMaximumBid()); 
            }
        }
        else if (!_server && !table.isWatcher()) {
            if (bids.complete) {
                if (trick.hasPlayed(table.getLocalId())) {
                    hand.disallowSelection();
                }
                else if (trick.ledCard != null) {
                    hand.allowSelection(getLegalMoves());
                }
            }
        }

        if (turnHolder > 0) {
            // This is the beginning of the round, so declare the leader.
            if (bids.length == 0) {
                var leader :String = table.getNameFromAbsolute(seat);
                gameCtrl.local.feedback("Leader this round is " + leader);

                if (_server) {
                    gameCtrl.net.set(COMS_LAST_LEADER, turnHolder);
                }
            }
        }
    }

    /** Calculate the winner of the trick, add it to their number of tricks, save to history and 
     *  give them their turn */
    protected function completeTrick () :void
    {
        Assert.isTrue(trick.length == NUM_PLAYERS);

        var winner :int = trick.winner;
        var winnerSeat :int = table.getAbsoluteFromId(winner);

        log("Trick winner is " + winner + " in seat " + winnerSeat + ", name " + 
            table.getNameFromId(winner));

        gameCtrl.local.feedback(
            table.getNameFromId(winner) + " won the trick");

        if (_server) {
            scores.addTrick(winnerSeat);

            trick.reset();

            if (scores.totalTricks + 1 < cardsPerPlayer) {
                Debug.debug("Tricks taken: " + scores.totalTricks + ", advancing turn");
                gameCtrl.game.startNextTurn(winner);
            } else {
                Debug.debug("Tricks taken: " + scores.totalTricks + ", clearing turn holder");
                //gameCtrl.game.startNextTurn(-1);
            }
        }
    }

    protected function getTeamName (team :Team) :String
    {
        var names :Array = gameCtrl.game.seating.getPlayerNames();
        return names[team.index] + " and " + names[team.index + 2];
    }

    protected function completeRound () :void
    {
        var wal :WinnersAndLosers = scores.getWinnersAndLosers();
        var winners :Array = wal.winningTeams;
        var highScore :int = wal.highestScore;
        var skunk :Boolean = false;

        if (highScore < scores.target && wal.losingTeams.length == 1) {
            highScore = wal.scoreDifferential;
            skunk = true;
        }
        // feedback
        if (highScore >= scores.target) {
            if (winners.length == 1) {
                if (skunk) {
                    gameCtrl.local.feedback(
                        getTeamName(Team(winners[0])) + " are more than " + 
                        scores.target + " points ahead, so win the game!");
                }
                else {
                    gameCtrl.local.feedback(
                        getTeamName(Team(winners[0])) + " win the game!");
                }
            }
            else if (winners.length > 1) {
                gameCtrl.local.feedback("Tie game! Continuing...");
            }
        }
        
        // control
        if (_server) {
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

            if (!trick.complete && _server) {
                gameCtrl.game.startNextTurn();
            }
        }
    }

    protected function scoresListener (event :ScoresEvent) :void
    {
        if (event.type == ScoresEvent.TRICKS_CHANGED) {
            if (scores.totalTricks == cardsPerPlayer) {
                updateScores();
            }
        }
        else if (event.type == ScoresEvent.SCORES_CHANGED) {
            if (event.team.index == 1) {
                completeRound();
            }
        }
    }

    /** Check if spades can be played (part of current game state and/or config). */
    protected function canLeadSpades () :Boolean
    {
        return _spadePlayed;
    }

    /** Check how many cards of a suit the local player has in his hand. */
    protected function countSuit (suit :int) :int
    {
        Assert.isFalse(table.isWatcher());

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
        Assert.isFalse(table.isWatcher());

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
        Assert.isFalse(table.isWatcher());

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

    /** Entry point for when the user selects a card or cards to play */
    protected function handListener (event :HandEvent) :void
    {
        Assert.isFalse(table.isWatcher());

        Debug.debug("Received " + event);
        if (event.type == HandEvent.CARDS_PLAYED) {
            if (hand.isPassing) {
                hand.passCards(event.cards);
                hand.removeCards(event.cards);
                hand.disallowSelection();
            }
            else {
                var card :Card = event.cards.cards[0];
                trick.playCard(card);
                hand.removeCard(card);
                hand.disallowSelection();
            }
        }
        else if (event.type == HandEvent.PASSED) {

            // by convention, the blind bidder passes first, so we can tell if the exchange is 
            // complete by checking if the passing player bid blind
            if (bids.isBlind(table.getAbsoluteFromId(event.player))) {
                if (_server) {
                    var teammate :int = table.getTeammateId(event.player);
                    hand.requestPass(teammate, event.player, BLIND_NIL_EXCHANGE);
                    gameCtrl.game.startNextTurn(teammate);
                }
            }
            else {
                gameCtrl.local.feedback("Exchange complete, starting play");
                if (_server) {
                    var lastId :int = gameCtrl.net.get(COMS_LAST_LEADER) as int;
                    gameCtrl.game.startNextTurn(lastId);
                }
            }
        }
    }

    protected function turnTimerListener (event :TurnTimerEvent) :void
    {
        if (event.type == TurnTimerEvent.EXPIRED) {
            if (gameCtrl.game.getTurnHolderId() == event.player) {
                if (gameCtrl.game.isMyTurn()) {
                    autoPlay();
                }
            }
        }
    }

    protected function autoPlay () :void
    {
        Assert.isFalse(table.isWatcher());

        if (bids.complete) {
            var moves :CardArray;
            var count :int;
            if (hand.isPassing) {
                // TODO: figure out if the user has already selected ONE card and select 
                // only one other one randomly
                moves = hand.cards;
                count = BLIND_NIL_EXCHANGE;
            }
            else {
                moves = getLegalMoves();
                count = 1;
            }
            // this check is to prevent the edge case where the player selects a card while the 
            // expiry message (caller of this function) is in transit
            if (!hand.hasPlayed) {
                var random :CardArray = getRandomSubset(moves, count);
                Debug.debug("Random cards for autoPlay are " + random);
                hand.playCards(random);
            }
        }
        else if (isLocalPlayerEligibleForBlindNilBid() && 
            !bids.hasResponded(table.getLocalSeat())) {
            // edge case prevention (see above)
            if (!bids.hasSelected) {
                bids.select(SpadesBids.SELECTED_SHOW_CARDS);
            }
        }
        else {
            var maxbid :int = getLocalPlayerMaximumBid();
            var bid :int = AUTOPLAY_DEFAULT_BID;
            if (bid > maxbid) {
                bid = maxbid;
            }
            // edge case prevention (see above)
            if (!bids.hasSelected) {
                bids.select(bid);
            }
        }
    }

    protected static function getRandomSubset (
        moves :CardArray, 
        count :int) :CardArray
    {
        if (moves.length < count) {
            throw new Error("Not enough cards in " + moves + 
                " to select " + count + " random ones");
        }

        var selected :CardArray = new CardArray();
        for (var i :int = 0; i < count; ++i) {
            var random :int = Math.random() * moves.length;
            var card :Card = moves.cards[random];
            if (selected.has(card)) {
                --i;
                continue;
            }
            selected.push(card);
        }

        return selected;
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

    /** Set if the game is started */
    protected var _gameStarted :Boolean;

    /** Set if we are the server. */
    protected var _server :Boolean;

    /** Name of property indicating the last player to lead the hand. */
    protected static const COMS_LAST_LEADER :String = "lastleader";

    /** Players required for a game of spades */
    protected static const NUM_PLAYERS :int = 4;

    /** Minimum score differential for the losing team to be allowed to bid blind nil. */
    protected static const BLIND_NIL_THRESHOLD :int = 100;

    /** Number of cards for teammates to exchange on blind nil bids. */
    protected static const BLIND_NIL_EXCHANGE :int = 2;

    /** When making a bid for an absent player, this is the bid. */
    protected static const AUTOPLAY_DEFAULT_BID :int = 6;

    /** Time between rounds (seconds). */
    protected static const DELAY_TO_NEXT_ROUND :int = 5;
}
}

