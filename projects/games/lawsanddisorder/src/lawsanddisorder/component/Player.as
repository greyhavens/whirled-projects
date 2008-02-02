package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import com.threerings.ezgame.PropertyChangedEvent;
import lawsanddisorder.*;

/**
 * Area containing details on a single player
 */
public class Player extends Component
{
    /** The current game monies for each player. */
    public static const MONIES_DATA :String = "moniesData";

    /**
     * Constructor
     */
    public function Player (ctx :Context, id :int, serverId :int, name :String)
    {
        this.id = id;
        this.serverId = serverId;
        this._name = name;
        _hand = new Hand(ctx, this);
        ctx.eventHandler.addPropertyListener(Deck.JOBS_DATA, jobsChanged);
        ctx.eventHandler.addPropertyListener(Hand.HAND_DATA, handsChanged);
        ctx.eventHandler.addPropertyListener(MONIES_DATA, moniesChanged);
        
        super(ctx);
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
        _job.player = this;
        _job.x = 20;
        _job.y = 50;
        _job.updateEnabled();
        addChild(_job);
        
        updateDisplay();
    }
    
    /**
     * Called by first user during game start.  Deal the player a hand and give them
     * a random job.
     */
    public function setup () :void
    {
        var job :Job = _ctx.board.deck.drawRandomJob(this);
        _ctx.board.deck.switchJobs(job, this);
        
        hand.setup();
    }
        
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
        _hand.x = 20;
        _hand.y = 415;
        addChild(_hand);
        
        _moniesText = new TextField();
        _moniesText.height = 30;
        _moniesText.mouseEnabled = false;
        _moniesText.x = 20;
        _moniesText.y = 10;
        addChild(_moniesText);
    }

    /**
     * Update the player's changing details
     */
    override protected function updateDisplay () :void
    {
        _moniesText.text = "MONIES: " + monies;
    }
    
    /**
     * Player's job just changed somehow.
     */
    protected function jobsChanged (event :PropertyChangedEvent) :void
    {
        if (event.index == id) {
            var jobId :int = event.newValue as int;

            // fetch the job instance and make it our own
            var tmpJob :Job = _ctx.board.deck.getJob(jobId);
            if (tmpJob == null) {
                _ctx.log("WTF job null in property change. JOB ID is: " + jobId);
                return;
            }
            job = tmpJob;
        }
    }
    
    /**
     * The player's monies has changed; update the value.     */
    protected function moniesChanged (event :PropertyChangedEvent) :void
    {
        if (event.index == id) {
            monies = event.newValue as int;
            updateDisplay();
        }
    }
    
    /**
     * Handles when cards in hands changes (display shows # of cards for opponents)
     */
    protected function handsChanged (event :PropertyChangedEvent) :void
    {
        if (event.index == id) {
            updateDisplay();
        }
    }
    
    /**
     * Display the player as a string for testing.     */
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
    }
    
    /**
     * Remove X monies from this player     */
    public function loseMonies (moniesNum :int) :void
    {
        getMonies(moniesNum * -1);
    }
    
    /**
     * Remove X monies from this player, then give X monies to another player
     * TODO handle asyncronous adjustments ie the thief gives the thief 3 monies     */
    public function giveMoniesTo(moniesNum :int, toPlayer :Player) :void
    {
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
            _ctx.log("WTF no cards to lose!: " + cardsToLose);
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
        loseCards(cardsToGive);
        if (toPlayer != null) {
            toPlayer.hand.addCards(cardsToGive);
           }
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
    
    /** Can the player use their power right now? */
    public function get powerEnabled () :Boolean {
        return _powerEnabled;
    }
    /** Set whether the player can use their power right now */
    public function set powerEnabled (value :Boolean) :void {
        _powerEnabled = value;
        _job.updateEnabled();
    }
    
    /** Public getter for the hand object */
    public function get hand () :Hand {
    	return _hand;
    }
    
    /** Return the player's name 
     * TODO use toString() instead? */
    public function get playerName () :String {
    	return _name;
    }
    
    /** Can the player change jobs right now? */
    protected var _jobEnabled :Boolean;
    
    /** Can the player use their power right now? */
    protected var _powerEnabled :Boolean;
    
    /** Player's id according to their place at the table */
    public var id :int;
    
    /** Id assigned by the server; differs from their place at the table */
    public var serverId :int;
    
    /** Name of this player from the server */
    protected var _name :String;
    
    /** The player's hand */
    protected var _hand :Hand;
    
    /** Number of monies the player has 
     * TODO use public getters */
    public var monies :int = LawsAndDisorder.STARTING_MONIES;
    
    /** The player's current job; may change through the game */
    protected var _job :Job;
    
    /** Textfield for displaying the player's current monies */
    protected var _moniesText :TextField;
}
}