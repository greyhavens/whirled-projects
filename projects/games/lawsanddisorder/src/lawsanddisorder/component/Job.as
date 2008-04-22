package lawsanddisorder.component {

import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.events.MouseEvent;

import com.whirled.game.MessageReceivedEvent;

import lawsanddisorder.Context;
import lawsanddisorder.Content;

/**
 * A single job.  Will move from player to player during play.
 * TODO animate moving between players
 */
public class Job extends Component
{
    /**
     * Constructor
     */
    public function Job (ctx :Context, id :int)
    {
        _id = id;
        super(ctx);
    }
    
    /**
     * Called when use ability or change job is enabled/disabled.  Display the changes.
     * TODO trigger with an event
     */
    public function updateEnabled () :void
    {
        updateDisplay();
    }
    
    /**
     * Draw the job area
     */
    override protected function initDisplay () :void
    {  
        var bground :Sprite = new JOB_BACKGROUND();
        addChild(bground);
		
		var symbol :Sprite = getSymbol();
        symbol.width = symbol.width / 1.6;
        symbol.height = symbol.height / 1.6;
        symbol.x = 63;
        symbol.y = 80;
        var colorTransform :ColorTransform = new ColorTransform();
        colorTransform.color = 0x660033;
        symbol.transform.colorTransform = colorTransform;
        symbol.alpha = 0.15;
        addChild(symbol);
        
        // Job name text
        jobTitle = Content.defaultTextField(1.5);
        jobTitle.text = name;
        jobTitle.width = bground.width;
        jobTitle.height = 50;
        jobTitle.y = 15;
        addChild(jobTitle);
    
        // Text of abilities
        jobDescription = Content.defaultTextField();
        jobDescription.text = description;
        jobDescription.width = 105;
        jobDescription.height = 150;
        jobDescription.y = 40;
        jobDescription.x = 10;
        addChild(jobDescription);
    }
    
    /**
     * Update the job name and enable/disable the use power button
     */
    override protected function updateDisplay () :void
    {
    	// during setup, not attached to a player yet anyway
    	if (_ctx.board == null || _ctx.board.deck == null) {
    		return;
    	}
    	var player :Player = _ctx.board.deck.getPlayerByJob(this);
    	
        // don't display unless on the active player
        if (player == null || player != _ctx.board.player) {
            return;
        }
        
        // display description with/without instructions for changing jobs
        if (player.jobEnabled) {
            jobDescription.text = description + "\n\n (Drag a blue card here to change jobs)";
        }
        else {
            jobDescription.text = description;
        }
    }
    
    /**
     * Called when the player starts using their job's power.  The state
     * has already been set and the use power button disabled, so cancelUsePower()
     * must be called if for some reason they can't finish performing their power.
     */
    public function usePower () :void
    {
        switch (id) {
            case JUDGE:
                if (_ctx.board.laws.numLaws == 0) {
                    _ctx.notice("There are no laws to enact.");
                    cancelUsePower();
                    return;
                }            
                if (_ctx.board.player.monies < 2) {
		            _ctx.notice("You need at least 2 monies to use The Judge's ability.");
		            cancelUsePower();
		            return;
		        }
                _ctx.state.selectLaw(judgeLawSelected);
                return;
                
            case THIEF:
                if (_ctx.board.player.monies < 2) {
                    _ctx.notice("Your need at least 2 monies to use The Thief's ability.");
                    cancelUsePower();
                    return;
                }
                _ctx.state.selectOpponent(thiefOpponentSelected);
                return;
                
            case BANKER:
                if (_ctx.board.laws.numLaws == 0) {
                    _ctx.notice("There are no laws to modify.");
                    cancelUsePower();
                    return;
                }
                if (!_ctx.board.player.hand.containsVerb()) {
                    _ctx.notice("You don't have any verbs.");
                    cancelUsePower();
                    return;
                }
                _ctx.state.exchangeVerb(bankerVerbExchanged);
                return;
                
            case TRADER:
                if (_ctx.board.player.monies < 2) {
                    _ctx.notice("Your ability costs 2 monies to use.");
                    cancelUsePower();
                    return;
                }
                if (_ctx.board.deck.numCards == 0) {
                	_ctx.notice("There are no cards left to draw.");
                	cancelUsePower();
                	return;
                }
                // the trader's ability happens immediately
                reachedPointOfNoReturn();
                _ctx.board.player.loseMonies(2);
                _ctx.board.player.hand.drawCard(2);
                _ctx.broadcast(_ctx.board.player.playerName + " (The Trader) used their ability to draw two cards");
                doneUsingPower();
                return;
                
            case PRIEST:
                if (_ctx.board.laws.numLaws == 0) {
                    _ctx.notice("There are no laws to modify.");
                    cancelUsePower();
                    return;
                }
                if (!_ctx.board.player.hand.containsSubject()) {
                    _ctx.notice("You don't have any subject cards.");
                    cancelUsePower();
                    return;
                }
                _ctx.state.exchangeSubject(priestSubjectExchanged);
                return;
                
            case DOCTOR:
                if (_ctx.board.laws.numLaws == 0) {
                    _ctx.notice("There are no laws to modify.");
                    cancelUsePower();
                    return;
                }
                _ctx.state.moveWhen(doctorWhenMoved);
                return;
        }
    }
    
    /**
     * Once this is called, power can't be cancelled because player has seen or done something
     * that can't be undone.  May be called a second time for some powers.     */
    protected function reachedPointOfNoReturn () :void
    {
        _ctx.board.usePowerButton.enabled = false;
    }
    
    /**
     * Called when using judge power and a law was just selected.
     */
    protected function judgeLawSelected () :void
    {
        reachedPointOfNoReturn();
    	_ctx.board.player.loseMonies(2);
        var law :Law = _ctx.state.selectedLaw;
        _ctx.broadcast(_ctx.board.player.playerName + "(The Judge) is enacting law " + law.displayId);
        _ctx.state.deselectLaw();
        _ctx.eventHandler.addMessageListener(Laws.ENACT_LAW_DONE, judgeLawEnacted);
        _ctx.sendMessage(Laws.ENACT_LAW, law.id);
    }
    
    /**
     * Called when judge is done enacting a law.
     */
    protected function judgeLawEnacted (event :MessageReceivedEvent) :void
    {
        _ctx.eventHandler.removeMessageListener(Laws.ENACT_LAW_DONE, judgeLawEnacted);
        doneUsingPower();
    }
    
    /**
     * Called when using thief power and an opponent was just selected
     */
    protected function thiefOpponentSelected () :void
    {
        reachedPointOfNoReturn();
        _ctx.board.player.loseMonies(2);
        var opponent :Opponent = _ctx.state.selectedOpponent;
        // display opponent's hand then select a card from it
        opponent.showHand = true;
        _ctx.state.selectCards(1, thiefCardSelected, opponent);
    }
    
    /**
     * Called when using thief power and a card was just selected
     */
    protected function thiefCardSelected () :void
    {
        var opponent :Opponent = _ctx.state.selectedOpponent;
        if (opponent == null) {
           _ctx.log("WTF opponent null when theif card selected.");
           return;
        }
        var selectedCards :Array = _ctx.state.selectedCards;
        var card :Card = selectedCards[0];
        opponent.showHand = false;
        opponent.giveCardsTo(selectedCards, _ctx.board.player);
        _ctx.state.deselectOpponent();
        _ctx.state.deselectCards();
        // TODO broadcast this only to players not involved
        _ctx.broadcast(_ctx.board.player.playerName + " (The Thief) stole a card from " + opponent.playerName);
        _ctx.broadcast(_ctx.board.player.playerName + " (The Thief) stole '" + card.text + "' card from you", opponent);
        _ctx.notice("You stole '" + card.text + "' card from " + opponent.playerName);
        doneUsingPower();
    }
    
    /**
     * Called when using banker power and a verb card from hand was just exchanged with one
     * in a law.
     */
    protected function bankerVerbExchanged () :void
    {
    	var card :Card = _ctx.state.activeCard;
    	var targetCard :Card = _ctx.state.selectedCards[0];
    	var law :Law = _ctx.state.selectedLaw;    	
    	_ctx.broadcast(_ctx.board.player.playerName + " (The Banker) swapped '" + 
    	   targetCard.text + "' with '" + card.text + "' in Law " + law.displayId);
        _ctx.state.deselectLaw();
        _ctx.state.deselectCards();    	
        doneUsingPower();
    }
    
    /**
     * Called when using priest power and a subject card from hand was just exchanged with one
     * in a law.
     */
    protected function priestSubjectExchanged () :void
    {
        var card :Card = _ctx.state.activeCard;
        var targetCard :Card = _ctx.state.selectedCards[0];
        var law :Law = _ctx.state.selectedLaw;
        _ctx.broadcast(_ctx.board.player.playerName + " (The Priest) swapped '" + 
           targetCard.text + "' with '" + card.text + "' in Law " + law.displayId);
        _ctx.state.deselectLaw();
        _ctx.state.deselectCards();    	
        doneUsingPower();
    }
    
    /**
     * Called when a doctor finishes adding or removing a when card
     */
    protected function doctorWhenMoved () :void
    {
        var law :Law = _ctx.state.selectedLaw;
		var card :Card = _ctx.state.activeCard;
        // if the when card is in the law, it was just added to it
        if (card.cardContainer == law) {
        	_ctx.broadcast(_ctx.board.player.playerName + " (The Doctor) added '" + 
        	   card.text + "' to Law " + law.displayId);
        }
        else {
        	var targetCard :Card = _ctx.state.selectedCards[0];
        	_ctx.broadcast(_ctx.board.player.playerName + " (The Doctor) removed '" + 
        	   targetCard.text + "' from Law " + law.displayId);
        }
        _ctx.state.deselectLaw();
        _ctx.state.deselectCards();
        doneUsingPower();
    }
    
    /**
     * Called when the player finishes succesfully using their ability.
     * Hide the cancel button again and trigger any laws that go when using ability.
     */
    protected function doneUsingPower () :void
    {
        // this may have already been called for some powers    	
        reachedPointOfNoReturn();
    	_ctx.board.usePowerButton.doneUsingPower();
    	
    	// enact laws that trigger when this player uses their ability
        _ctx.board.laws.triggerWhen(Card.USE_ABILITY, _ctx.board.player.job.id);
    }
    
    /**
     * Cancel button was clicked while using an ability:
     * Return monies paid to use ability.  Reset mode to a neutral state and allow the player 
     * to use their power again.
     */
    public function cancelUsePower () :void
    {
        _ctx.state.cancelMode();
        _ctx.board.usePowerButton.cancelUsingPower();
        _ctx.notice("Power cancelled.");
    }
    
    /**
     * Return the text for the job area.  Must be unique for all jobs.
     */
    override public function get name () :String
    {
        switch (id) {
        	case WATCHER:
        	    return "Watching";
            case JUDGE:
                return "The Judge";
            case Job.THIEF:
                return "The Thief";
            case Job.BANKER:
                return "The Banker";
            case Job.TRADER:
                return "The Trader";
            case Job.PRIEST:
                return "The Priest";
            case Job.DOCTOR:
                return "The Doctor";
        }
        _ctx.log("WTF Unknown job in job get name.");
        return "UNKNOWN";
    }
    
    /**
     * Returns a text description of the job's abilities.
     */
    protected function get description () :String
    {
        switch (id) {
        	case WATCHER:
        	    return "You are not a player";
            case JUDGE:
                return "Pay $2 to trigger a law, ignoring any purple cards";
            case Job.THIEF:
                return "Pay $2 to steal a card from another player";
            case Job.BANKER:
                return "Switch a red card in your hand with one in a law";
            case Job.TRADER:
                return "Pay $2 to draw two cards";
            case Job.PRIEST:
                return "Switch a blue card in your hand with one in a law";
            case Job.DOCTOR:
                return "Add a purple card to a law or take one from a law";
        }
        _ctx.log("WTF Unknown job in job get description.");
        return "UNKNOWN";
    }
    
    /**
     * Generate and return a new sprite containing the symbol for this job, or null
     * if there is no symbol for this job.
     */
    public function getSymbol () :Sprite
    {
        switch (id) {
        	case WATCHER:
        	    return new Sprite();
            case JUDGE:
                return new SYMBOL_JUDGE();
            case THIEF:
                return new SYMBOL_THIEF();
            case BANKER:
                return new SYMBOL_BANKER();
            case TRADER:
                return new SYMBOL_TRADER();
            case PRIEST:
                return new SYMBOL_PRIEST();
            case DOCTOR:
                return new SYMBOL_DOCTOR();
        }
        _ctx.log("WTF Unknown job in job get symbol.");
        return new Sprite();
    }
    
    /**
     * Retrieve the id for this job (eg JUDGE).
     */
    public function get id () :int
    {
        return _id;
    }
    
    /**
     * Display this job as a string for testing
     */
    override public function toString () :String
    {
        return name;
    }

    /** Enumeration of job types (and a special non-job for people just watching) */
    public static const WATCHER :int = -1;
    public static const JUDGE :int = 0;
    public static const THIEF :int = 1;
    public static const BANKER :int = 2;
    public static const TRADER :int = 3;
    public static const PRIEST :int = 4;
    public static const DOCTOR :int = 5;
    
    /** JUDGE/THIEF/BANKER etc */
    protected var _id :int;
    
    /** Job name text */
    protected var jobTitle :TextField;
    
    /** Text of abilities */
    protected var jobDescription :TextField;
    
    [Embed(source="../../../rsrc/symbols.swf#judge")]
    public static const SYMBOL_JUDGE :Class;
    
    [Embed(source="../../../rsrc/symbols.swf#thief")]
    public static const SYMBOL_THIEF :Class;
    
    [Embed(source="../../../rsrc/symbols.swf#banker")]
    public static const SYMBOL_BANKER :Class;
    
    [Embed(source="../../../rsrc/symbols.swf#trader")]
    public static const SYMBOL_TRADER :Class;
    
    [Embed(source="../../../rsrc/symbols.swf#priest")]
    public static const SYMBOL_PRIEST :Class;
    
    [Embed(source="../../../rsrc/symbols.swf#scientist")]
    public static const SYMBOL_DOCTOR :Class;
    
    /** Background image for a player job */
    [Embed(source="../../../rsrc/components.swf#job")]
    protected static const JOB_BACKGROUND :Class;
}
}