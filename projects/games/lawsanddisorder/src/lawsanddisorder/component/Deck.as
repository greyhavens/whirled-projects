package lawsanddisorder.component {

import com.threerings.util.ArrayUtil;

import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;

import lawsanddisorder.*;

/**
 * Content class describing all possible cards
 */
public class Deck extends Component
{
    /** The name of the board data distributed value. */
    public static const DECK_DATA :String = "deckData";

    /** The name of the jobs data distributed value. */
    public static const JOBS_DATA :String = "jobsData";

    /** Event indicating some card was moved. value[0] is card.id, value[1] is from player.id or 
     * DECK_ID, value[2] is destination player.id or DECK_ID */
    public static const CARD_MOVED :String = "cardMoved";
    
    /** Indicator that the person/thing giving or receiving a card is the deck not a player */
    public static const DECK_ID :int = -5;
    
    /** The number of cards players draw at the start of their turn */
    public static const CARDS_AT_START_OF_TURN :int = 2;

    /**
     * Constructor.  Initialize the discard pile and player jobs array, setup event handlers
     * then populate the jobs array and card deck.
     */
    public function Deck (ctx :Context)
    {
        super(ctx);

        _ctx.eventHandler.addDataListener(DECK_DATA, deckChanged);
        _ctx.eventHandler.addDataListener(JOBS_DATA, jobsChanged);
        _ctx.eventHandler.addMessageListener(CARD_MOVED, cardMoved);

        // create the job objects
        createJob(Job.JUDGE);
        createJob(Job.THIEF);
        createJob(Job.BANKER);
        createJob(Job.TRADER);
        createJob(Job.PRIEST);
        createJob(Job.DOCTOR);

        playerJobs = new Array(_ctx.numPlayers).map(function (): int { return -1; });

        var numDecks :int;
        // 2 players 2 decks 10 laws 5 laws each
        if (_ctx.numPlayers == 2) {
            numDecks = 2;
        }
        // 3 players 3 decks 15 laws 5 laws each
        // 4 players 3 decks 15 laws 4 laws each
        else if (_ctx.numPlayers < 5) {
            numDecks = 3;
        }
        // 5 players 4 decks 20 laws 4 laws each
        // 6 players 4 decks 20 laws 3 laws each
        else {
            numDecks = 4;
        }
        
        // set to false for a test deck
        if (true) { 
    
            // Change the size of the deck based on the number of players
            for (var i :int = 0; i < numDecks; i++) {
                // 12 subjects, 7 verbs, 7 objects, 3 whens = 29
                addNewCards(2, Card.SUBJECT, Job.JUDGE);
                addNewCards(2, Card.SUBJECT, Job.THIEF);
                addNewCards(2, Card.SUBJECT, Job.BANKER);
                addNewCards(2, Card.SUBJECT, Job.TRADER);
                addNewCards(2, Card.SUBJECT, Job.PRIEST);
                addNewCards(2, Card.SUBJECT, Job.DOCTOR);
                // take out gives for 2 player games
                if (_ctx.numPlayers == 2) {
                    addNewCards(4, Card.VERB, Card.LOSES);
                    addNewCards(3, Card.VERB, Card.GETS);
                }
                else {
                    addNewCards(2, Card.VERB, Card.GIVES);
                    addNewCards(3, Card.VERB, Card.LOSES);
                    addNewCards(2, Card.VERB, Card.GETS);
                }
    
                addNewCards(2, Card.OBJECT, Card.CARD, 1);
                addNewCards(1, Card.OBJECT, Card.CARD, 2);
                addNewCards(1, Card.OBJECT, Card.MONIE, 1);
                addNewCards(1, Card.OBJECT, Card.MONIE, 2);
                addNewCards(1, Card.OBJECT, Card.MONIE, 3);
                addNewCards(1, Card.OBJECT, Card.MONIE, 4);
                addNewCards(1, Card.WHEN, Card.START_TURN);
                addNewCards(1, Card.WHEN, Card.USE_ABILITY);
                addNewCards(1, Card.WHEN, Card.CREATE_LAW);
            }
        
        } else {
            
            // Change the size of the deck based on the number of players
            for (var i :int = 0; i < 2; i++) {
                // 12 subjects, 7 verbs, 7 objects, 3 whens = 29
                addNewCards(2, Card.SUBJECT, Job.JUDGE);
                addNewCards(2, Card.SUBJECT, Job.THIEF);
                addNewCards(2, Card.SUBJECT, Job.BANKER);
                addNewCards(2, Card.SUBJECT, Job.TRADER);
                addNewCards(2, Card.SUBJECT, Job.PRIEST);
                addNewCards(2, Card.SUBJECT, Job.DOCTOR);
                // take out gives for 2 player games
                if (_ctx.numPlayers == 2) {
                    addNewCards(4, Card.VERB, Card.LOSES);
                    addNewCards(3, Card.VERB, Card.GETS);
                }
                else {
                    addNewCards(2, Card.VERB, Card.GIVES);
                    addNewCards(3, Card.VERB, Card.LOSES);
                    addNewCards(2, Card.VERB, Card.GETS);
                }
    
                addNewCards(2, Card.OBJECT, Card.CARD, 1);
                addNewCards(1, Card.OBJECT, Card.CARD, 2);
                addNewCards(1, Card.OBJECT, Card.MONIE, 1);
                addNewCards(1, Card.OBJECT, Card.MONIE, 2);
                addNewCards(1, Card.OBJECT, Card.MONIE, 3);
                addNewCards(1, Card.OBJECT, Card.MONIE, 4);
                addNewCards(1, Card.WHEN, Card.START_TURN);
                addNewCards(1, Card.WHEN, Card.USE_ABILITY);
                addNewCards(1, Card.WHEN, Card.CREATE_LAW);
            }
        /*
    
            // custom deck for testing
            for (var j :int = 0; j < 1; j++) {
                // 12 subjects, 7 verbs, 7 objects, 3 whens = 29
                //addNewCards(24, Card.SUBJECT, Job.JUDGE);
                //addNewCards(6, Card.SUBJECT, Job.THIEF);
                //addNewCards(6, Card.SUBJECT, Job.BANKER);
               /// addNewCards(6, Card.SUBJECT, Job.TRADER);
               // addNewCards(6, Card.SUBJECT, Job.PRIEST);
                addNewCards(20, Card.SUBJECT, Job.DOCTOR);
                // take out gives for 2 player games
    //            if (playerCount == 2) {
      //              addNewCards(4, Card.VERB, Card.LOSES);
        //            addNewCards(3, Card.VERB, Card.GETS);
          //      }
            //    else {
                    addNewCards(10, Card.VERB, Card.GIVES);
        //            addNewCards(3, Card.VERB, Card.LOSES);
          //          addNewCards(2, Card.VERB, Card.GETS);
              //  }
    
                //addNewCards(4, Card.OBJECT, Card.CARD, 1);
         //       addNewCards(4, Card.OBJECT, Card.CARD, 2);
    //            addNewCards(1, Card.OBJECT, Card.MONIE, 1);
      //          addNewCards(1, Card.OBJECT, Card.MONIE, 2);
        //        addNewCards(1, Card.OBJECT, Card.MONIE, 3);
                addNewCards(10, Card.OBJECT, Card.MONIE, 4);
                //addNewCards(6, Card.WHEN, Card.START_TURN);
                addNewCards(10, Card.WHEN, Card.USE_ABILITY);
                //addNewCards(3, Card.WHEN, Card.CREATE_LAW);
            }
        */
        }
    }
    
    /**
     * Create numCards new cards, add them to the array of card objects.  Does not fill the
     * deck with cards - that is done by the control player in setup().
     */
    protected function addNewCards (
        numCards :int, cardGroup :int, cardType :int, cardValue :int = 0) :void
    {
        for (var i :int = 1; i <= numCards; i++) {
            var cardId :int = cardObjects.length;
            var card :Card = new Card(_ctx, cardId, cardGroup, cardType, cardValue);
            cardObjects.push(card);
        }
    }

    /**
     * Called by control player during game start.  Control player resets the job array and
     * populates the deck; other players get these values from data change events.
     */
    public function setup () :void
    {
        // populate the deck
        cards = new Array();
        for each (var card :Card in cardObjects) {
            cards.push(card.id);
        }
        ArrayUtil.shuffle(cards);
        _ctx.eventHandler.setData(DECK_DATA, cards);
    }

    /**
     * Remove the top card from the deck and return it.  Animate a card moving from the deck
     * to the player's hand.
     */
    public function drawCard (player :Player) :Card
    {
        // no cards in deck to draw
        if (numCards == 0) {
            return null;
        }
        var cardIndex :int = cards.pop();
        updateDisplay();
        _ctx.eventHandler.setData(DECK_DATA, cards);

        // warn that the game will be ending soon
        if (cards.length == 5) {
            _ctx.broadcast("Only 5 cards left in the deck, the game will end soon!", null, true);
        }

        // if the deck is ever empty after drawing from it, game ends
        if (numCards == 0) {
            _ctx.board.endTurnButton.lastTurn();
        }
        
        var card :Card = cardObjects[cardIndex];
        
        // tell all players to animate the card drawing
        _ctx.sendMessage(CARD_MOVED, new Array(card.id, DECK_ID, player.id));
        
        return card;
    }

    /**
     * A card was moved from someone/somewhere to someone/somewhere, animate it.
     * @param event event.value[0] is card.id, event.value[1] is source id, [2] destination id
     */
    protected function cardMoved (event :MessageEvent) :void
    {
        var card :Card = getCard((event.value as Array)[0] as int);
        var fromId :int = (event.value as Array)[1] as int;
        var toId :int = (event.value as Array)[2] as int;
        
        var fromPoint :Point;
        if (fromId == DECK_ID) {
            fromPoint = localToGlobal(new Point(0,0));
        } else {
            var fromPlayer :Player = _ctx.board.players.getPlayer(fromId);
            if (fromPlayer as Opponent) {
                fromPoint = Opponent(fromPlayer).getGlobalHandLocation();
            } else {
                fromPoint = fromPlayer.hand.localToGlobal(new Point(300,0));
            }
        }
        
        var toPoint :Point;
        if (toId == DECK_ID) {
            toPoint = localToGlobal(new Point(0,0));
        } else {
            var toPlayer :Player = _ctx.board.players.getPlayer(toId);
            if (toPlayer as Opponent) {
                toPoint = Opponent(toPlayer).getGlobalHandLocation();
            } else {
                toPoint = toPlayer.hand.localToGlobal(new Point(300,0));
            }
        }
        
        //_ctx.board.animateMove(new Content.CARD_BACK(), fromPoint, toPoint);
        var cardBack :Component = new Component(_ctx);
        cardBack.addChild(new Content.CARD_BACK());
        cardBack.animateMove(fromPoint, toPoint);
    }
    
    /**
     * Fetch an array of numCards cards for a starting hand.  Massage it so that it contains
     * at least two subjects, one object and one verb.
     */
    public function drawStartingHand (numCards :int) :Array
    {
        var numSubjects :int = 0;
        var numObjects :int = 0;
        var numVerbs :int = 0;

        var cardArray :Array = new Array();
        for (var cardPos :int = 0; cardPos < cards.length; cardPos++) {
            var cardId :int = cards[cardPos];
            var card :Card = cardObjects[cardId];
            switch (card.group) {
                case Card.SUBJECT:
                    if (numSubjects < 2 || (numObjects >= 1 && numVerbs >= 1)) {
                        cards.splice(cardPos, 1);
                        cardArray.push(card);
                        numSubjects++;
                    }
                    break;
                case Card.OBJECT:
                    if (numObjects < 1 || (numSubjects >= 2 && numVerbs >= 1)) {
                        cards.splice(cardPos, 1);
                        cardArray.push(card);
                        numObjects++;
                    }
                    break;
                case Card.VERB:
                    if (numVerbs < 1 || (numSubjects >= 2 && numObjects >= 1)) {
                        cards.splice(cardPos, 1);
                        cardArray.push(card);
                        numVerbs++;
                    }
                    break;
                default:
                    if (numSubjects >= 2 && numObjects >= 1 && numVerbs >= 1) {
                        cards.splice(cardPos, 1);
                        cardArray.push(card);
                    }
                    break;
            }
            if (cardArray.length == numCards) {
                break;
            }
        }

        // tough luck, there weren't enough subjects/objects/verbs left in the deck
        var missingCardsNum :int = numCards - cardArray.length;
        if (missingCardsNum > 0) {
            for (var i :int = 0; i < missingCardsNum; i++) {
                var missingCard :Card = Card(cardObjects[cards.pop() as int]);
                if (missingCard != null) {
                    cardArray.push(missingCard);
                }
            }
        }

        // shuffle the hand and deck again afterwards
        ArrayUtil.shuffle(cardArray);
        ArrayUtil.shuffle(cards);
        updateDisplay();
        _ctx.eventHandler.setData(DECK_DATA, cards);

        return cardArray;
    }

    /**
     * Draw the deck
     */
    override protected function initDisplay () :void
    {
        var bground :Sprite = new Content.CARD_BACK();
        addChild(bground);

        numCardText = Content.defaultTextField(1.5);
        numCardText.width = 60;
        numCardText.height = 30;
        numCardText.x = 8;
        numCardText.y = 3;
        var format :TextFormat = numCardText.defaultTextFormat;
        format.color = 0xFFFFFF;
        numCardText.defaultTextFormat = format;
        addChild(numCardText);
    }

    /**
     * Update variable graphics
     */
    override protected function updateDisplay () :void
    {
        numCardText.text = cards.length + "";
    }

    /**
     * For watchers who join partway through the game, fetch the existing deck data
     */
    public function refreshData () :void
    {
        cards = _ctx.eventHandler.getData(DECK_DATA) as Array;
        updateDisplay();
    }

    /**
     * Called when the deck contents change on the server.
     */
    protected function deckChanged (event :DataChangedEvent) :void
    {
        cards = _ctx.eventHandler.getData(DECK_DATA) as Array;
        updateDisplay();
    }

    /**
     * Called when the player jobs array changes on the server.  Also set the player for every
     * job at this time.
     * @event event.index is the player.id and event.newValue is the job.id
     */
    protected function jobsChanged (event :DataChangedEvent) :void
    {
        if (event.index > -1) {
            playerJobs[event.index] = event.newValue;
            var player :Player = _ctx.board.players.getPlayer(event.index);
            var job :Job = getJob(event.newValue);
            
            if (job == null) {
                _ctx.error("null job in Deck.jobsChanged for id " + event.newValue);
                return;
            }
            job.player = player;
            player.job = job;
        
            // highlight all cards with the player's new job
            if (player == _ctx.player) {
                for each (var card :Card in cardObjects) {
                    card.highlightJob();
                }
            }
        }
        else {
            // this will be blank setup data
            playerJobs = _ctx.eventHandler.getData(JOBS_DATA) as Array;
        }
    }

    /**
     * Create a job and add it to the global list and available jobs list
     */
    protected function createJob (jobId :int) :void
    {
        var job :Job = new Job(_ctx, jobId);
        jobObjects[jobId] = job;
    }

    /**
     * Remove a random job from the pool of available jobs and return it
     */
    public function drawRandomJob (player :Player) :Job
    {
        // select all the available jobs
        var availableJobs :Array = new Array();
        for (var i :int = 0; i < jobObjects.length; i++) {
            var tempJob :Job = jobObjects[i];
            if (playerJobs.indexOf(tempJob.id) == -1) {
                availableJobs.push(tempJob);
            }
        }

        // pick a random available job (from zero to length-1)
        var randomIndex :int = Math.round(Math.random() * (availableJobs.length-1));
        var job :Job = availableJobs[randomIndex];

        //updateDisplay();
        return job;
    }

    /**
     * Retrieve a single job by id
     */
    public function getJob (jobId :int) :Job
    {
        return jobObjects[jobId];
    }

    /**
     * Retrieve a single card by id
     */
    public function getCard (cardId :int) :Card
    {
        return cardObjects[cardId];
    }

    /**
     * Assign the job to the player, swapping with another player if applicable
     */
    public function switchJobs (job :Job, player :Player, duringSetup :Boolean = false) :void
    {
        if (job == null || player == null) {
            _ctx.error("null job or player? " + job + ", " + player);
            return;
        }

        // grab player's old job, and job's old player
        var oldJob :Job = player.job;
        var oldPlayer :Player = getPlayerByJob(job);

        if (oldJob == null && oldPlayer != null) {
            _ctx.error("Trying to steal a player's job with no existing job!");
            return;
        }

        // assign new job to player
        playerJobs = _ctx.eventHandler.getData(JOBS_DATA) as Array;
        if (playerJobs == null) {
            _ctx.error("playerjobs is null when swapping jobs?");
            return;
        }
        playerJobs[player.id] = job.id;
        player.job = job;
        job.player = player;
        _ctx.eventHandler.setData(JOBS_DATA, job.id, player.id);

        // job was on another player; assign old job to other player
        if (oldJob != null && oldPlayer != null) {
            playerJobs[oldPlayer.id] = oldJob.id;
            oldPlayer.job = oldJob;
            oldJob.player = oldPlayer;
            _ctx.eventHandler.setData(JOBS_DATA, oldJob.id, oldPlayer.id);
            if (player == _ctx.player) {
                _ctx.notice("You swapped jobs with " + oldPlayer.playerName + 
                    " - you're the " + job + " now!");
                _ctx.broadcastOthers(player.name + " swapped jobs with " + oldPlayer.name);
            } else {
                _ctx.broadcast(player.name + " swapped jobs with " + oldPlayer.name);
            }
            // also notify the other player whose job was changed
            if (!(oldPlayer as AIPlayer)) {
                _ctx.broadcast(player.playerName + " swapped jobs with you " + 
                    " - you're the " + oldJob + " now!", oldPlayer, true);
            }
        }
        else if (oldPlayer == null) {
            if (!duringSetup) {
                if (player == _ctx.player) {
                    _ctx.notice("You became the " + job);
                    _ctx.broadcastOthers(player.playerName + " became the " + job);
                } else {
                    _ctx.broadcast(player.playerName + " became the " + job);
                }
            }
        }
    }

    /**
     * Return the player who has the given job, or null if it is not assigned
     */
    public function getPlayerByJobId (jobId :int) :Player
    {
        for (var playerId :int = 0; playerId < playerJobs.length; playerId++) {
            if (playerJobs[playerId] == jobId) {
                return _ctx.board.players.getPlayer(playerId);
            }
        }
        return null;

    }

    /** Return the number of cards in the deck */
    public function get numCards () :int
    {
        return cards.length;
    }

    /**
     * Given a job, return the player who has that job, or null if nobody does
     */
    public function getPlayerByJob (job :Job) :Player
    {
        if (job == null) {
            _ctx.error("null job in getPlayerByJob");
            return null;
        }
        var playerId :int = playerJobs.indexOf(job.id);
        if (playerId == -1) {
            return null;
        }
        return _ctx.board.players.getPlayer(playerId);
    }

    /** Displays the number of cards in the deck */
    protected var numCardText :TextField;

    /** Array of card indexes still in the deck */
    protected var cards :Array = new Array();

    /** Ordered array of all card objects in the game */
    protected var cardObjects :Array = new Array();

    /** All the jobs in the game */
    protected var jobObjects :Array = new Array();

    /** Job-Player map.  Index = seating position; value = job id */
    protected var playerJobs :Array;
}
}