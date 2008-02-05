package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import lawsanddisorder.Context;
import com.threerings.ezgame.MessageReceivedEvent;

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
     * Draw the job area
     */
    override protected function initDisplay () :void
    {
        // draw the job bg
        graphics.clear();
        graphics.beginFill(0xEE5599);
        graphics.drawRect(0, 0, 120, 150);
        graphics.endFill();
        
        // use power button
        usePowerButton = new TextField();
        usePowerButton.text = "use power";
        usePowerButton.x = 20;
        usePowerButton.y = 100;
        usePowerButton.height = 30;
        addChild(usePowerButton);
        
        // cancel use power button
        cancelButton = new TextField();
        cancelButton.text = "cancel";
        cancelButton.x = 20;
        cancelButton.y = 130;
        cancelButton.height = 30;
        cancelButton.addEventListener(MouseEvent.CLICK, cancelButtonClicked);
        
        title.height = 150;
    }
    
    /**
     * Called when use ability or change job is enabled/disabled.  Display the changes.
     */
    public function updateEnabled () :void
    {
        updateDisplay();
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
        
        // display title with/without instructions for changing jobs
        if (player.jobEnabled) {
            title.text = name + "\n" + description + "\n (drag a subject here to change jobs)";
        }
        else {
            title.text = name + "\n" + description;
        }
        
        // enable/disable use power button
        if (player.powerEnabled) {
            usePowerButton.addEventListener(MouseEvent.CLICK, usePowerButtonClicked);
            usePowerButton.textColor = 0x000000;
        }
        else {
            usePowerButton.removeEventListener(MouseEvent.CLICK, usePowerButtonClicked);
            usePowerButton.textColor = 0x999999;
        }
    }
    
    /**
     * Handler for user power button
     */
    protected function usePowerButtonClicked (event :MouseEvent) :void
    {
        // TODO includes isMyTurn so remove check above
        if (!_ctx.state.interactMode) {
            _ctx.notice("You can't use your power right now.");
            return;
        }
        
        //if (!player.powerEnabled) {
        //    _ctx.log("WTF clicked use power button when disabled.");
        //    return;
        //}
        
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
                    _ctx.notice("There are no laws to modify.");
                    return;
                }            
                if (_ctx.board.player.monies < 2) {
		            _ctx.notice("Your ability costs 2 monies to use.");
		            return;
		        }
		        startUsingAbility();
                _ctx.state.selectLaw(judgeLawSelected);
                return;
                
            case THIEF:
                if (_ctx.board.player.monies < 2) {
                    _ctx.notice("Your ability costs 2 monies to use.");
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
                startUsingAbility();
                removeChild(cancelButton);
                _ctx.board.player.loseMonies(2);
                _ctx.board.player.hand.drawCard(2);
                _ctx.state.selectCards(1, traderCardSelected);
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
     * that we're performing an action.     */
    protected function startUsingAbility () :void
    {
    	addChild(cancelButton);
        _ctx.board.player.powerEnabled = false;
        _ctx.state.performingAction = true;
    }
    
    /**
     * Called when using judge power and a law was just selected.
     */
    protected function judgeLawSelected () :void
    {
        removeChild(cancelButton);
    	_ctx.board.player.loseMonies(2);
        var law :Law = _ctx.state.selectedLaw;
        _ctx.broadcast("Judge ("+ _ctx.board.player.playerName + ") enacting law: " + law.id);
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
        removeChild(cancelButton);
        _ctx.board.player.loseMonies(2);
        var opponent :Opponent = _ctx.state.selectedOpponent;
        _ctx.broadcast("Thief (" + _ctx.board.player.playerName + ") stealing from " + opponent.playerName);
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
        opponent.showHand = false;
        opponent.giveCardsTo(selectedCards, _ctx.board.player);
        _ctx.state.deselectOpponent();
        _ctx.state.deselectCards();
        doneUsingAbility();
    }
    
    /**
     * Called when using banker power and a verb card from hand was just exchanged with one
     * in a law.
     * TODO broadcast which verb is being exchanged
     * TODO move exchange to here?
     * TODO move deselect to here so we can broadcast what was effected?
     */
    protected function bankerVerbExchanged () :void
    {
        doneUsingAbility();
    }
    
    /**
     * Called after trader draws two cards and selects one to discard.  Discard the card.
     */
    protected function traderCardSelected () :void
    {
        var selectedCards :Array = _ctx.state.selectedCards;
        _ctx.broadcast("Trader (" + _ctx.board.player.playerName + ") drew two cards and discarded one");
        _ctx.state.deselectCards();
        _ctx.board.player.loseCards(selectedCards);
        doneUsingAbility();
    }
    
    /**
     * Called when using priest power and a subject card from hand was just exchanged with one
     * in a law.
     * TODO broadcast which subject exchanged
     */
    protected function priestSubjectExchanged () :void
    {
        doneUsingAbility();
    }
    
    /**
     * Called when a scientist finishes adding or removing a when card
     * TODO broadcast which card added/removed
     */
    protected function scientistWhenMoved () :void
    {
        doneUsingAbility();
    }
    
    /**
     * Called when the player finishes succesfully using their ability.
     * Hide the cancel button again and trigger any laws that go when using ability.
     */
    protected function doneUsingAbility () :void
    {
        if (contains(cancelButton)) {
            removeChild(cancelButton);
        }
        _ctx.board.laws.triggerWhen(Card.USE_ABILITY, _ctx.board.player.job.id);
        _ctx.notice("Done using ability.");
    }
    
    /**
     * Cancel button was clicked while using an ability:
     * Return monies paid to use ability.
     * Reset mode to a neutral state and allow the player to use their power again.
     * TODO deselect?
     */
    protected function cancelButtonClicked (event :MouseEvent) :void
    {
        if (contains(cancelButton)) {
            removeChild(cancelButton);
        }
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
                return "The Scientist";
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
                return "pay $2: trigger a law immediately, ignoring any WHEN cards";
            case Job.THIEF:
                return "pay $2: look at a players hand and steal one card";
            case Job.BANKER:
                return "exchange a VERB card in a law with one from your hand";
            case Job.TRADER:
                return "pay 2$: draw two cards then discard one";
            case Job.PRIEST:
                return "exchange a SUBJECT card in a law with one from your hand";
            case Job.SCIENTIST:
                return "add one WHEN card to a law or take one WHEN card from a law";
        }
        _ctx.log("WTF Unknown job in job get description.");
        return "UNKNOWN";
    }

    ///**
    // * Retrieve the player that currently has this job
    // */
    //public function get player () :Player
    //{
    //    return _player;
    //}
    //
    ///**
    // * Set the player that currently has this job
    // */
    //public function set player (player :Player) :void
    //{
    //    _player = player;
    //}

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
    protected var usePowerButton :TextField;
    
    /** Button for cancelling using power 
     * TODO make usePowerButton become cancel button?
     */
    protected var cancelButton :TextField;
    
    ///** Player who currently has this job, or null */
    //protected var _player :Player;
}
}