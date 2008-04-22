package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;

import lawsanddisorder.*;

/**
 * Area containing details on a single player
 */
public class Player extends Component
{
    /** How much money does every player start with? */
    public static const STARTING_MONIES :int = 5;
    
    /** The current game monies for each player. */
    public static const MONIES_DATA :String = "moniesData";

    /**
     * Constructor
     * @param id Identifier for this player according to their position on the board
     * @param serverId Identifier for this player according to the game server
     */
    public function Player (ctx :Context, id :int, serverId :int, name :String)
    {
        this.id = id;
        if (id == -1) {
        	isWatcher = true;
        }
        this.serverId = serverId;
        
        // truncate player names for display on the opponent area, 10 chars maximum
        if (name.length > 10) {
        	name = name.substr(0, 10);
        }
        this._name = name;
        
        _hand = new Hand(ctx, this);
        
        // connect handlers for job, hand or monies changing.
        if (!isWatcher) {
            ctx.eventHandler.addDataListener(Deck.JOBS_DATA, jobChanged, id);
            ctx.eventHandler.addDataListener(Hand.HAND_DATA, handChanged, id);
            ctx.eventHandler.addDataListener(MONIES_DATA, moniesChanged, id);
        }
        
        super(ctx);
    }
     
    /**
     * Called by first user during game start.  Deal the player a hand and give them
     * a random job.
     */
    public function setup () :void
    {
        var newJob :Job = _ctx.board.deck.drawRandomJob(this);
        _ctx.board.deck.switchJobs(newJob, this, true);
        hand.setup();
        _ctx.eventHandler.setData(MONIES_DATA, STARTING_MONIES, id);
    }
    
    /**
     * For watchers who join partway through the game, fetch the existing player data
     */
    public function refreshData () :void
    {
    	// watching players have no monies, job or hand to fetch
    	if (isWatcher) {
    		return;
    	}
        _monies = _ctx.eventHandler.getData(MONIES_DATA, id);
        var jobId :int = _ctx.eventHandler.getData(Deck.JOBS_DATA, id);
        job = _ctx.board.deck.getJob(jobId);
        hand.refreshData();
        updateDisplay();
    }
    
    /**
     * Retrieve the player's current job
     */
    public function get job () :Job
    {
        return _job;
    }
    
    /**
     * Change the player's job.  Remove the existng one then position and add the new one.
     * Update the job's display to enable/disable buttons.
     */
    public function set job (job :Job) :void
    {
        if (job == null) {
            _ctx.log("WTF null job in player.set job?");
            return;
        }
        // remove existing job
        if (_job != null && contains(_job)) {
           removeChild(_job);
        }
        
        _job = job;
        _job.x = 12;
        _job.y = 50;
        _job.updateEnabled();
        addChild(_job);
        
        updateDisplay();
    }
    
	/**
	 * Display the player's / opponent's hand
	 * TODO only used in opponent - move there?
	 */
    public function set showHand (value :Boolean) :void
    {
        if (value && !contains(hand)) {
            addChild(hand);
        }
        else if (!value && contains(hand)) {
            removeChild(hand);
        }
    }
    
    /**
     * Draw the area containing a player
     */
    override protected function initDisplay () :void
    {
        // hand will be created, maybe not populated
        _hand.x = 30;
        _hand.y = 407;
        addChild(_hand);
		
		var moniesBg :Sprite = new MONIES_BG();
		moniesBg.x = 10;
		moniesBg.y = 5;
		addChild(moniesBg);
        
		var monieIcon :Sprite = new Content.MONIE_BACK();
        monieIcon.width = monieIcon.width / 2;
        monieIcon.height = monieIcon.height / 2;
        monieIcon.x = 97;
        monieIcon.y = 10;
        addChild(monieIcon);
        
		// TODO align right my ass - what is this doing?
        _moniesText = Content.defaultTextField(1.2, "right");
        _moniesText.height = 30;
		_moniesText.width = 80;
        _moniesText.x = 10;
        _moniesText.y = 15;
        addChild(_moniesText);
        
        // give watchers an empty job to fill the space
        if (isWatcher) {
            job = new Job(_ctx, -1);
        }
    }

    /**
     * Update the player's changing details
     */
    override protected function updateDisplay () :void
    {
        _moniesText.text = "Monies: " + monies;
    }
    
    /**
     * Player's job just changed somehow.
     */
    protected function jobChanged (event :DataChangedEvent) :void
    {
        var jobId :int = event.newValue as int;

        // fetch the job instance and make it our own
        var tmpJob :Job = _ctx.board.deck.getJob(jobId);
        if (tmpJob == null) {
            _ctx.log("WTF job null in property change. JOB ID is: " + jobId);
            return;
        }
        job = tmpJob;
    }
    
    /**
     * The player's monies has changed; update the value.
     */
    protected function moniesChanged (event :DataChangedEvent) :void
    {
        _monies = event.newValue as int;
        updateDisplay();
    }
    
    /**
     * Handles when cards in hands changes (display shows # of cards for opponents)
     */
    protected function handChanged (event :DataChangedEvent) :void
    {
        updateDisplay();
    }
    
    /**
     * Display the player as a string for testing.
     */
    override public function toString () :String
    {
        return "Player " + id + ": " + _name;
    }
    
    /**
     * Give X monies to this player.
     */
    public function getMonies (moniesNum :int) :void
    {
    	if (monies + moniesNum < 0) {
    		_ctx.log("WTF Player " + this + " would end up with negative monies!");
    		moniesNum = 0;
    	}
    	_ctx.eventHandler.setData(MONIES_DATA, monies + moniesNum, id);
    	_monies = monies + moniesNum;
    }
    
    /**
     * Remove X monies from this player
     */
    public function loseMonies (moniesNum :int) :void
    {
        getMonies(moniesNum * -1);
    }
    
    /**
     * Remove X monies from this player, then give X monies to another player
     */
    public function giveMoniesTo(moniesNum :int, toPlayer :Player) :void
    {
    	// giving money to oneself, no net change
    	if (toPlayer == this) {
    		return;
    	}
        loseMonies(moniesNum);
        if (toPlayer != null) {
            toPlayer.getMonies(moniesNum);
        }
    }
    
    /**
     * Draw X cards from the deck and add them to the player's hand
     * TODO pick a better name like getsCards or giveCards or recieveCards and rename getMonies too
     */
    public function getCards (cardsNum :int) :void
    {
        hand.drawCard(cardsNum);
    }
    
    /**
     * Remove X cards from the player's hand
     */
    public function loseCards (cardsToLose :Array) :void
    {
        if (cardsToLose == null || cardsToLose.length == 0) {
            return;
        }
        // will set display and distributed data
        hand.removeCards(cardsToLose);
    }
    
    /**
     * Remove cards from this player and give them to another
     */
    public function giveCardsTo (cardsToGive :Array, toPlayer :Player) :void
    {
    	// giving cards to self, no net change
    	if (toPlayer == this) {
    		return;
    	}
        loseCards(cardsToGive);
        if (toPlayer != null) {
            toPlayer.hand.addCards(cardsToGive);
        }
    }
    
    /**
     * Called when this player has left the game; do unload cleanup.
     */
    public function unload () :void
    {
        _ctx.eventHandler.removeDataListener(Deck.JOBS_DATA, jobChanged, id);
        _ctx.eventHandler.removeDataListener(Hand.HAND_DATA, handChanged, id);
        _ctx.eventHandler.removeDataListener(MONIES_DATA, moniesChanged, id);
        hand.unload();
    }
    
    /** Can the player change jobs right now? */
    public function get jobEnabled () :Boolean {
        return _jobEnabled;
    }
    /** Set whether the player can change jobs right now */
    public function set jobEnabled (value :Boolean) :void {
        _jobEnabled = value;
        _job.updateEnabled();
    }
    
    /** Public getter for the hand object */
    public function get hand () :Hand {
    	return _hand;
    }
    
    /** Return the player's name */
    public function get playerName () :String {
    	return _name;
    }
    
    /**
     * Return the player's current monies
     */
    public function get monies () :int {
    	return _monies;
    }
    
    /** Can the player change jobs right now? */
    protected var _jobEnabled :Boolean;
    
    /** Is the player a real player or are they just watching? */
    public var isWatcher :Boolean = false;
    
    /** Player's id according to their place at the table */
    public var id :int;
    
    /** Id assigned by the server; differs from their place at the table */
    public var serverId :int;
    
    /** Name of this player from the server */
    protected var _name :String;
    
    /** The player's hand */
    protected var _hand :Hand;
    
    /** Number of monies the player has  */
    protected var _monies :int;
    
    /** The player's current job; may change through the game */
    protected var _job :Job;
    
    /** Textfield for displaying the player's current monies */
    protected var _moniesText :TextField;
    
    [Embed(source="../../../rsrc/components.swf#monies")]
    protected static const MONIES_BG :Class;
}
}