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
 * TODO different class for each job?
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
        
        // use power / cancel button
        useAbilityButton = new Button(_ctx);
        useAbilityButton.text = "use power";
        useAbilityButton.x = 0;
        useAbilityButton.y = 160;
        useAbilityButton.addEventListener(MouseEvent.CLICK, useAbilityButtonClicked);
        useAbilityButton.enabled = false;
        addChild(useAbilityButton);
        
        /** Job name text */
        jobTitle = Content.defaultTextField(1.5);
        jobTitle.text = name;
        jobTitle.width = bground.width;
        jobTitle.height = 50;
        jobTitle.y = 15;
        addChild(jobTitle);
    
        /** Text of abilities */
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
            jobDescription.text = description + "\n\n (Drag a subject here to change jobs)";
        }
        else {
            jobDescription.text = description;
        }
        
        // enable/disable use power button
        if (player.powerEnabled) {
        	useAbilityButton.enabled = true;
        }
        else {
        	useAbilityButton.enabled = false;
        }
    }
    
    /**
     * Handler for user power button
     */
    protected function useAbilityButtonClicked (event :MouseEvent) :void
    {
        if (!_ctx.state.interactMode) {
            _ctx.notice("You can't use your power right now.");
            return;
        }
        usePower();
    }
    
    /**
     * TODO judge and thief have select handled in state, logic handled here, but banker has
     *      exchange logic handled in state - inconsistant?
     */
    protected function usePower () :void
    {
        switch (id) {
            case JUDGE:
                if (_ctx.board.laws.numLaws == 0) {
                    _ctx.notice("There are no laws to enact.");
                    return;
                }            
                if (_ctx.board.player.monies < 2) {
		            _ctx.notice("You need at least 2 monies to use The Judge's ability.");
		            return;
		        }
		        startUsingAbility();
                _ctx.state.selectLaw(judgeLawSelected);
                return;
                
            case THIEF:
                if (_ctx.board.player.monies < 2) {
                    _ctx.notice("Your need at least 2 monies to use The Thief's ability.");
                    return;
                }
                startUsingAbility();
                _ctx.state.selectOpponent(thiefOpponentSelected);
                return;
                
            case BANKER:
                if (_ctx.board.laws.numLaws == 0) {
                    _ctx.notice("There are no laws to modify.");
                    return;
                }
                if (!_ctx.board.player.hand.containsVerb()) {
                    _ctx.notice("You don't have any verbs.");
                    return;
                }
                startUsingAbility();
                _ctx.state.exchangeVerb(bankerVerbExchanged);
                return;
                
            case TRADER:
                if (_ctx.board.player.monies < 2) {
                    _ctx.notice("Your ability costs 2 monies to use.");
                    return;
                }
                // the trader's ability happens immediately
                startUsingAbility();
                useAbilityButton.enabled = false;
                //removeChild(cancelButton);
                _ctx.board.player.loseMonies(2);
                _ctx.board.player.hand.drawCard(2);
                _ctx.broadcast(_ctx.board.player.playerName + " (The Trader) used their ability to draw two cards");
                doneUsingAbility();
                return;
                
            case PRIEST:
                if (_ctx.board.laws.numLaws == 0) {
                    _ctx.notice("There are no laws to modify.");
                    return;
                }
                if (!_ctx.board.player.hand.containsSubject()) {
                    _ctx.notice("You don't have any subject cards.");
                    return;
                }
                startUsingAbility();
                _ctx.state.exchangeSubject(priestSubjectExchanged);
                return;
                
            case SCIENTIST:
                if (_ctx.board.laws.numLaws == 0) {
                    _ctx.notice("There are no laws to modify.");
                    return;
                }
                startUsingAbility();
                _ctx.state.moveWhen(scientistWhenMoved);
                return;
        }
    }
    
    /**
     * Player has begun using their ability.  Add a cancel button and tell the state
     * that we're performing an action.
     */
    protected function startUsingAbility () :void
    {
    	//addChild(cancelButton);
    	// switch useAbilityButton to cancel button
    	useAbilityButton.removeEventListener(MouseEvent.CLICK, useAbilityButtonClicked);
    	useAbilityButton.addEventListener(MouseEvent.CLICK, cancelButtonClicked);
    	useAbilityButton.text = "cancel";
    	
        _ctx.board.player.powerEnabled = false;
        _ctx.state.performingAction = true;
    }
    
    /**
     * Called when using judge power and a law was just selected.
     */
    protected function judgeLawSelected () :void
    {
        //removeChild(cancelButton);
        useAbilityButton.enabled = false;
    	_ctx.board.player.loseMonies(2);
        var law :Law = _ctx.state.selectedLaw;
        _ctx.broadcast(_ctx.board.player.playerName + "(The Judge) is enacting law " + law.id);
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
        doneUsingAbility();
    }
    
    /**
     * Called when using thief power and an opponent was just selected
     */
    protected function thiefOpponentSelected () :void
    {
        //removeChild(cancelButton);
        useAbilityButton.enabled = false;
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
        _ctx.broadcast(_ctx.board.player.playerName + " (The Thief) stole '" + card.text + "' from you", opponent);
        _ctx.notice("You stole '" + card.text + "' from " + opponent.playerName);
        doneUsingAbility();
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
    	   targetCard.text + "' with '" + card.text + "' in Law " + law.id);
        _ctx.state.deselectLaw();
        _ctx.state.deselectCards();    	
        doneUsingAbility();
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
           targetCard.text + "' with '" + card.text + "' in Law " + law.id);
        _ctx.state.deselectLaw();
        _ctx.state.deselectCards();    	
        doneUsingAbility();
    }
    
    /**
     * Called when a scientist finishes adding or removing a when card
     */
    protected function scientistWhenMoved () :void
    {
        var law :Law = _ctx.state.selectedLaw;
		var card :Card = _ctx.state.activeCard;
        // if the when card is in the law, it was just added to it
        if (card.cardContainer == law) {
        	_ctx.broadcast(_ctx.board.player.playerName + " (The Scientist) added '" + 
        	   card.text + "' to Law " + law.id);
        }
        else {
        	var targetCard :Card = _ctx.state.selectedCards[0];
        	_ctx.broadcast(_ctx.board.player.playerName + " (The Scientist) removed '" + 
        	   targetCard.text + "' from Law " + law.id);
        }
        _ctx.state.deselectLaw();
        _ctx.state.deselectCards();
        doneUsingAbility();
    }
    
    /**
     * Called when the player finishes succesfully using their ability.
     * Hide the cancel button again and trigger any laws that go when using ability.
     */
    protected function doneUsingAbility () :void
    {
        // switch useAbilityButton to use power
        useAbilityButton.addEventListener(MouseEvent.CLICK, useAbilityButtonClicked);
        useAbilityButton.removeEventListener(MouseEvent.CLICK, cancelButtonClicked);
        useAbilityButton.text = "use power";
        
        _ctx.board.laws.triggerWhen(Card.USE_ABILITY, _ctx.board.player.job.id);
    }
    
    /**
     * Cancel button was clicked while using an ability:
     * Return monies paid to use ability.  Reset mode to a neutral state and allow the player 
     * to use their power again.
     */
    protected function cancelButtonClicked (event :MouseEvent) :void
    {
        // switch useAbilityButton to use power
        useAbilityButton.addEventListener(MouseEvent.CLICK, useAbilityButtonClicked);
        useAbilityButton.removeEventListener(MouseEvent.CLICK, cancelButtonClicked);
        useAbilityButton.text = "use power";
        
        _ctx.state.cancelMode();
        _ctx.state.performingAction = false;
        _ctx.board.player.powerEnabled = true;
        _ctx.notice("Ability cancelled.");
    }
    
    /**
     * Return the text for the job area.  Must be unique for all jobs.
     */
    override public function get name () :String
    {
        switch (id) {
            case JUDGE:
                return "The Judge"
            case Job.THIEF:
                return "The Thief";
            case Job.BANKER:
                return "The Banker";
            case Job.TRADER:
                return "The Trader";
            case Job.PRIEST:
                return "The Priest";
            case Job.SCIENTIST:
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
            case JUDGE:
                return "Pay $2 to trigger a law, ignoring any when cards";
            case Job.THIEF:
                return "Pay $2 to steal a card from another player";
            case Job.BANKER:
                return "Switch a verb card in your hand with one in a law";
            case Job.TRADER:
                return "Pay $2 to draw two cards";
            case Job.PRIEST:
                return "Switch a subject card in your hand with one in a law";
            case Job.SCIENTIST:
                return "Add a when card to a law or take one from a law";
        }
        _ctx.log("WTF Unknown job in job get description.");
        return "UNKNOWN";
    }
    
    /**
     * Generate and return a new sprite containing the symbol for this job, or null
     * if there is no symbol for this job.
     * TODO make these MovieClips instead?
     * TODO combine with Card.getSymbol()
     */
    public function getSymbol () :Sprite
    {
        switch (id) {
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
            case SCIENTIST:
                return new SYMBOL_SCIENTIST();
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

    /** Enumeration of job types */    
    public static const JUDGE :int = 0;
    public static const THIEF :int = 1;
    public static const BANKER :int = 2;
    public static const TRADER :int = 3;
    public static const PRIEST :int = 4;
    public static const SCIENTIST :int = 5;
    
    /** JUDGE/THIEF/BANKER etc */
    protected var _id :int;
    
    /** Button for using power */
    protected var useAbilityButton :Button;
    
    /** Job name text */
    protected var jobTitle :TextField;
    
    /** Text of abilities */
    protected var jobDescription :TextField;
    
    // TODO move to content class (?)
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
    public static const SYMBOL_SCIENTIST :Class;
    
    /** Background image for a player job */
    [Embed(source="../../../rsrc/components.swf#job")]
    protected static const JOB_BACKGROUND :Class;
}
}