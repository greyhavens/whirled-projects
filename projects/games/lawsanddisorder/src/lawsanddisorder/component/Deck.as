package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import lawsanddisorder.*;

import flash.events.MouseEvent;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.util.HashMap;

/**
 * Content class describing all possible cards
 * TODO look into extending ezgame.CardDeck
 */
public class Deck extends Component 
{
    /** The name of the board data distributed value. */
    public static const DECK_DATA :String = "deckData";
    
    /** The name of the jobs data distributed value. */
    public static const JOBS_DATA :String = "jobsData";
    
    /**
     * Constructor.  Initialize the discard pile and player jobs array, setup event handlers
     * then populate the jobs array and card deck.
     */
    public function Deck (ctx :Context)
    {        
        discardPile = new CardContainer(ctx);
        super(ctx);
        
        _ctx.eventHandler.addPropertyListener(DECK_DATA, deckChanged);
        _ctx.eventHandler.addPropertyListener(JOBS_DATA, jobsChanged);
        
        // TODO get this from somewhere else - board?
        var playerCount :int = _ctx.control.game.seating.getPlayerIds().length;
        playerJobs = new Array(playerCount).map(function (): int { return -1; });
        
        // create the jobs
        createJob(Job.JUDGE);
        createJob(Job.THIEF);
        createJob(Job.BANKER);
        createJob(Job.TRADER);
        createJob(Job.PRIEST);
        createJob(Job.SCIENTIST);
        
        // Change the size of the deck based on the number of players
        // TODO reevaluate these multiplyers - 3p is too small
        /*
        var deckMultiplyer :int;
        if (playerCount < 4) {
        	deckMultiplyer = 1;
        }
        else if (playerCount < 6) {
        	deckMultiplyer = 2;
        }
        else {
        	deckMultiplyer = 3;
        }
        */
        
        // create the deck of cards
        for (var i :int = 0; i < playerCount; i++) {
        	// 12 subjects, 7 verbs, 7 objects, 3 whens = 29
            addNewCards(2, Card.SUBJECT, Job.JUDGE);
            addNewCards(2, Card.SUBJECT, Job.THIEF);
            addNewCards(2, Card.SUBJECT, Job.BANKER);
            addNewCards(2, Card.SUBJECT, Job.TRADER);
            addNewCards(2, Card.SUBJECT, Job.PRIEST);
            addNewCards(2, Card.SUBJECT, Job.SCIENTIST);
            
            // take out gives for 2 player games
            // TODO put this back in, out for testing
            /*
            if (playerCount == 2) {
                addNewCards(4, Card.VERB, Card.LOSES);
                addNewCards(3, Card.VERB, Card.GETS);
            }
            else {
            */
                addNewCards(2, Card.VERB, Card.GIVES);
                addNewCards(3, Card.VERB, Card.LOSES);
                addNewCards(2, Card.VERB, Card.GETS);
            //}
            addNewCards(2, Card.OBJECT, Card.CARD, 1);
            addNewCards(1, Card.OBJECT, Card.CARD, 2);
            addNewCards(1, Card.OBJECT, Card.MONIE, 1);
            addNewCards(1, Card.OBJECT, Card.MONIE, 2);
            addNewCards(1, Card.OBJECT, Card.MONIE, 3);
            addNewCards(1, Card.OBJECT, Card.MONIE, 4);
            addNewCards(1, Card.WHEN, Card.START_TURN);
            addNewCards(1, Card.WHEN, Card.USE_ABILITY);
            addNewCards(1, Card.WHEN, Card.CREATE_LAW);
        	/*
            // 24 subjects 14 verbs 14 objects 6 whens, total = 58
            // 41% subjects, 24% verbs, 24% objects, 10% when
            addNewCards(4, Card.SUBJECT, Job.JUDGE);
            addNewCards(4, Card.SUBJECT, Job.THIEF);
            addNewCards(4, Card.SUBJECT, Job.BANKER);
            addNewCards(4, Card.SUBJECT, Job.TRADER);
            addNewCards(4, Card.SUBJECT, Job.PRIEST);
            addNewCards(4, Card.SUBJECT, Job.SCIENTIST);
            addNewCards(4, Card.VERB, Card.GIVES);
            addNewCards(6, Card.VERB, Card.LOSES);
            addNewCards(4, Card.VERB, Card.GETS);
            addNewCards(4, Card.OBJECT, Card.CARD, 1);
            addNewCards(2, Card.OBJECT, Card.CARD, 2);
            addNewCards(2, Card.OBJECT, Card.MONIE, 1);
            addNewCards(2, Card.OBJECT, Card.MONIE, 2);
            addNewCards(2, Card.OBJECT, Card.MONIE, 3);
            addNewCards(2, Card.OBJECT, Card.MONIE, 4);
            addNewCards(2, Card.WHEN, Card.START_TURN);
            addNewCards(2, Card.WHEN, Card.USE_ABILITY);
            addNewCards(2, Card.WHEN, Card.CREATE_LAW);
            */
        	/*
        	// 18 subjects 9 verbs 11 objects 5 whens = 43
        	// 41% subjects, 20% verbs, 25% objects, 11% when
	        addNewCards(3, Card.SUBJECT, Job.JUDGE);
	        addNewCards(3, Card.SUBJECT, Job.THIEF);
	        addNewCards(3, Card.SUBJECT, Job.BANKER);
	        addNewCards(3, Card.SUBJECT, Job.TRADER);
	        addNewCards(3, Card.SUBJECT, Job.PRIEST);
	        addNewCards(3, Card.SUBJECT, Job.SCIENTIST);
	        addNewCards(3, Card.VERB, Card.GIVES);
	        addNewCards(3, Card.VERB, Card.LOSES);
	        addNewCards(3, Card.VERB, Card.GETS);
	        addNewCards(2, Card.OBJECT, Card.CARD, 1);
	        addNewCards(2, Card.OBJECT, Card.CARD, 2);
	        addNewCards(2, Card.OBJECT, Card.MONIE, 1);
	        addNewCards(2, Card.OBJECT, Card.MONIE, 2);
	        addNewCards(2, Card.OBJECT, Card.MONIE, 3);
	        addNewCards(1, Card.OBJECT, Card.MONIE, 4);
	        addNewCards(2, Card.WHEN, Card.START_TURN);
	        addNewCards(2, Card.WHEN, Card.USE_ABILITY);
            addNewCards(1, Card.WHEN, Card.CREATE_LAW);
            */
        }
    }
    
    /**
     * Called by first player during game start.
     * First player fills the deck; other players get it from property change event.
     */
    public function setup () :void
    {
        shuffle();
        _ctx.eventHandler.setData(DECK_DATA, cards);
    }
    
    /** 
     * Remove the top card from the deck and return it
     */
    public function drawCard () :Card
    {
        var cardIndex :int = cards.pop();
        updateDisplay();
        _ctx.eventHandler.setData(DECK_DATA, cards);
        if (cards.length == 5) {
        	_ctx.broadcast("Only 5 cards left in the deck!");
        }
        
        return cardObjects[cardIndex];
    }
    
    /**
     * Draw the deck
     */
    override protected function initDisplay () :void
    {
        graphics.clear();
        graphics.beginFill(0xFF55EE);
        graphics.drawRect(0, 0, 40, 60);
        graphics.endFill();
    }
    
    /**
     * Update variable graphics
     */
    override protected function updateDisplay () :void
    {
    	title.text = "Deck[" + cards.length + "]";
    }
    
    /**
     * Display contents of cards array for debugging purposes
     */
    override public function toString() :String
    {
        return cards.toString();
    }

    /**
     * Called when the deck contents change on the server.
     * TODO can one assume, after the first turn, that a card was drawn?
     */
    protected function deckChanged (event :PropertyChangedEvent) :void
    {
        cards = _ctx.eventHandler.getData(DECK_DATA) as Array;
        updateDisplay();
    }
    
    /**
     * Called when the player jobs array changes on the server.
     */
    protected function jobsChanged (event :PropertyChangedEvent) :void
    {
        if (event.index != -1) {
            playerJobs[event.index] = event.newValue;
        }
        else {
            playerJobs = _ctx.eventHandler.getData(JOBS_DATA) as Array;
        }
    }
    
    /**
     * Create numCards new cards, add them to the global deck (cardObjects), then to the deck in 
     * use (cards).  Does not trigger a deck changed event.
     */
    protected function addNewCards (numCards :int, cardGroup :int, cardType :int, cardValue :int = 0) :void
    {
        for (var i :int = 1; i <= numCards; i++) {
            var cardId :int = cardObjects.length;
            var card :Card = new Card(_ctx, cardId, cardGroup, cardType, cardValue);
            cardObjects.push(card);
            cards.push(cardId);
        }
    }
    
    /**
     * Randomize the order of the cards in deck
     */
    protected function shuffle () :void
    {
        for (var i :int = 0; i < cards.length; i++) {
            var cardId :int = cards[i];
            var randomNum :int = Math.round(Math.random() * (cards.length-1));
            cards[i] = cards[randomNum];
            cards[randomNum] = cardId;
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
     * TODO inefficient even for setup, should setup all jobs and send data
     */
    public function drawRandomJob (player :Player) :Job
    {
        // select all the available jobs
        var availableJobs :Array = new Array();
        for (var i :int = 0; i < jobObjects.length; i++) {
            var tempJob :Job = jobObjects[i];
            if (playerJobs.indexOf(tempJob.id) == -1) {
            //if (tempJob.player == null) {
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
            _ctx.log("WTF null job or player? " + job + ", " + player);
            return;
        } 
        
        // grab player's old job, and job's old player
        var oldJob :Job = player.job;
        var oldPlayer :Player = getPlayerByJob(job);
        
        if (oldJob == null && oldPlayer != null) {
            _ctx.log("WTF Trying to steal a player's job with no existing job!");
            return;
        }

        // assign new job to player
        playerJobs = _ctx.eventHandler.getData(JOBS_DATA) as Array;
        if (playerJobs == null) {
            _ctx.log("WTF playerjobs is null when swapping jobs?");
            return;
        }
        playerJobs[player.id] = job.id;
        //job.player = player;
        player.job = job;
        _ctx.eventHandler.setData(JOBS_DATA, job.id, player.id);
        
        // job was on another player; assign old job to other player
        if (oldJob != null && oldPlayer != null) {
            playerJobs[oldPlayer.id] = oldJob.id;
            //oldJob.player = oldPlayer;
            oldPlayer.job = oldJob;
            _ctx.eventHandler.setData(JOBS_DATA, oldJob.id, oldPlayer.id);
            _ctx.broadcast(player.playerName + " swapped jobs with " + oldPlayer.playerName);
        }
        else if (oldPlayer == null) {
        	if (duringSetup) {
        		_ctx.broadcast(player.playerName + " drew " + player.job);
        	}
        	else {
        	   _ctx.broadcast(player.playerName + " became " + player.job);
        	}
        }
        
        // nobody to give the old job; clear this player from it
        //if (oldJob != null && oldPlayer == null) {
//_ctx.log("clearing player from old job");
        //    oldJob.player = null;
        //}
    }
    
    /**
     * Return the player who has the given job, or null if it is not assigned
     */
    public function getPlayerByJobId (jobId :int) :Player
    {
        for (var playerId :int = 0; playerId < playerJobs.length; playerId++) {
            if (playerJobs[playerId] == jobId) {
                return _ctx.board.getPlayer(playerId);
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
     * Given a job, return the player who has that job, or null if nobody does     */
    public function getPlayerByJob (job :Job) :Player
    {
    	if (job == null) {
    		_ctx.log("WTF null job in getPlayerByJob");
    		return null;
    	}
    	var playerId :int = playerJobs.indexOf(job.id);
    	if (playerId == -1) {
    		return null;
    	}
    	return _ctx.board.getPlayer(playerId);
    }
    
    /** Cards are added to here when they leave the board. 
     * TODO synchronize this or remove it - do we need to track this?
     */
    public var discardPile :CardContainer;
    
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