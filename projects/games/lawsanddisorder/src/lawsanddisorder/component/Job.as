package lawsanddisorder.component {

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import lawsanddisorder.*;

/**
 * A single job.  Will move from player to player during play.
 */
public class Job extends Component
{
    /** Event fired when this player is finished using their power. */
    public static const MY_POWER_USED :String = "myPowerUsed";
    
    /** Event fired when any player is finished using their power. */
    public static const SOME_POWER_USED :String = "somePowerUsed";
    
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

        // don't display unless on the active player
        if (player == null || player != _ctx.player) {
            return;
        }

        // display description with/without instructions for changing jobs
        if (player.jobEnabled) {
            jobDescription.text = description + "\n\n (Drop a blue card to change)";
        }
        else {
            jobDescription.text = description;
        }
    }
    
    /**
     * If this job's power is able to be used right now, return null, otherwise return an error
     * explaining why the power cannot be used.
     * TODO add checks for DOCTOR whenless law or when in hand, and BANKER gives subjectless law 
     */
    public function getUsePowerError () :String
    {
        switch (id) {
            case JUDGE:
                if (_ctx.board.laws.numLaws == 0) {
                    return("There are no laws to enact.");
                }
                if (player.monies < 2) {
                    return("You need at least 2 monies to use The Judge's ability.");
                }
                return null;

            case THIEF:
                if (player.monies < 2) {
                    return("Your need at least 2 monies to use The Thief's ability.");
                }
                return null;

            case BANKER:
                if (_ctx.board.laws.numLaws == 0) {
                    return("There are no laws to modify.");
                }
                if (!player.hand.containsVerb()) {
                    return("You don't have any verbs.");
                }
                return null;

            case TRADER:
                if (player.monies < 2) {
                    return("Your ability costs 2 monies to use.");
                }
                if (_ctx.board.deck.numCards == 0) {
                    return("There are no cards left to draw.");
                }
                return null;

            case PRIEST:
                if (_ctx.board.laws.numLaws == 0) {
                    return("There are no laws to modify.");
                }
                if (!player.hand.containsSubject()) {
                    return("You don't have any subject cards.");
                }
                return null;

            case DOCTOR:
                if (_ctx.board.laws.numLaws == 0) {
                    return("There are no laws to modify.");
                }
                return null;
        }
        return null;
    }

    /**
     * Called when the player starts using their job's power.  The state
     * has already been set and the use power button disabled, so cancelUsePower()
     * must be called if for some reason they can't finish performing their power.
     */
    public function usePower () :void
    {
        var errorMessage :String = getUsePowerError();
        if (errorMessage) {
            _ctx.notice(errorMessage);
            cancelUsePower();
            return;
        }
        
        switch (id) {
            case JUDGE:
                _ctx.state.selectLaw(judgeLawSelected);
                return;

            case THIEF:
                _ctx.state.selectOpponent(thiefOpponentSelected);
                return;

            case BANKER:
                _ctx.state.exchangeVerb(bankerVerbExchanged);
                return;

            case TRADER:
                // the trader's ability happens immediately
                reachedPointOfNoReturn();
                player.loseMonies(2);
                player.hand.drawCard(2);
                announcePowerUsed("used Trader's power to draw two cards");
                doneUsingPower();
                return;

            case PRIEST:
                _ctx.state.exchangeSubject(priestSubjectExchanged);
                return;

            case DOCTOR:
                _ctx.state.moveWhen(doctorWhenMoved);
                return;
        }
    }

    /**
     * Called when an AI player decides to use their power.
     * Hijacks the state selectedLaw, etc to more easily integrate with human player actions. 
     */
    public function usePowerAI (targetLaw :Law, targetCard :Card, targetPlayer :Player) :void
    {
        var aiPlayer :AIPlayer = player as AIPlayer;
        if (aiPlayer == null) {
            _ctx.error("aiplayer is null in Job.usePowerAI");
            return;
        }
        
        switch (id) {
            case JUDGE:
                _ctx.state.selectedLaw = targetLaw;
                judgeLawSelected();
                return;

            case THIEF:
                _ctx.state.selectedPlayer = targetPlayer;
                // perform card select here instead of in theifOpponentSelected
                reachedPointOfNoReturn();
                player.loseMonies(2);
                _ctx.state.selectedCards = new Array(targetCard);
                thiefCardSelected();
                return;

            case BANKER:
                // select a verb to exchange and a law to exchange it with
                _ctx.state.selectedLaw = targetLaw;
                _ctx.state.selectedCard = targetCard;
                _ctx.state.activeCard = _ctx.state.selectedLaw.cards[1];
                
                _ctx.log("banker card in law: " + _ctx.state.activeCard + ", card in hand: " + _ctx.state.selectedCard);
                
                // perform the actual swap here - propagate data change info only when adding
                player.hand.removeCards(_ctx.state.selectedCards, false);
                _ctx.state.selectedLaw.removeCards(new Array(_ctx.state.activeCard), false);
                _ctx.state.selectedLaw.addCards(_ctx.state.selectedCards, true, 1);
                player.hand.addCards(new Array(_ctx.state.activeCard), true);
            
                // continue and notify other players
                bankerVerbExchanged();
                return;

            case TRADER:
                // the trader's ability happens immediately
                player.loseMonies(2);
                player.hand.drawCard(2);
                announcePowerUsed("used Trader's power to draw two cards");
                doneUsingPower();
                return;

            case PRIEST:
                // select a subject to exchange and a law to exchange it with
                _ctx.state.selectedLaw = targetLaw;
                _ctx.state.selectedCard = targetCard;
                // ai players only ever switch the first SUBJECT in a law
                _ctx.state.activeCard = _ctx.state.selectedLaw.cards[0];
                
                // perform the actual swap here - propagate data change info only when adding
                player.hand.removeCards(_ctx.state.selectedCards, false);
                _ctx.state.selectedLaw.removeCards(new Array(_ctx.state.activeCard), false);
                _ctx.state.selectedLaw.addCards(_ctx.state.selectedCards, true, 0);
                player.hand.addCards(new Array(_ctx.state.activeCard), true);
            
                // continue and notify other players
                priestSubjectExchanged();
                return;

            case DOCTOR:
                // select a when to add and a law to add it to
                _ctx.state.selectedLaw = targetLaw;
                if (_ctx.state.selectedLaw.when != -1) {
                    // if the law already has a when, take it
                    _ctx.state.activeCard = 
                        _ctx.state.selectedLaw.cards[_ctx.state.selectedLaw.cards.length - 1];
                    _ctx.state.selectedCard = _ctx.state.activeCard;
                    _ctx.state.selectedLaw.removeCards(new Array(_ctx.state.activeCard), true);
                    player.hand.addCards(new Array(_ctx.state.activeCard), true);
                    
                } else {
                    // add a when from hand to the end of the law
                    _ctx.state.selectedCard = targetCard;
                    _ctx.state.activeCard = _ctx.state.selectedCard;
                    player.hand.removeCards(_ctx.state.selectedCards, true);
                    _ctx.state.selectedLaw.addCards(_ctx.state.selectedCards, true, 
                        _ctx.state.selectedLaw.cards.length);
                }
                
                // continue and notify other players
                doctorWhenMoved();
                return;
        }
    }
    
    /*
     * Called when an AI player decides to use their power.  Assume it's already valid to do so.
     * Hijacks the state selectedLaw, etc to more easily integrate with human player actions. 
     * TODO make AI smarter by deciding which law or card to affect before deciding to use power.
     * TODO ai should not reach this point if they cannot take an action, and should take an
     * action if they reach this point.  See BANKER swapping GETS with GETS, etc.
     *
    public function usePowerAI () :void
    {
        var aiPlayer :AIPlayer = player as AIPlayer;
        if (aiPlayer == null) {
            _ctx.error("aiplayer is null in Job.usePowerAI");
            return;
        }
        
        switch (id) {
            case JUDGE:
                _ctx.state.selectedLaw = aiPlayer.selectLaw();
                judgeLawSelected();
                return;

            case THIEF:
                _ctx.state.selectedPlayer = aiPlayer.selectOpponent();
                thiefOpponentSelected();
                return;

            case BANKER:
                // select a verb to exchange and a law to exchange it with
                _ctx.state.selectedLaw = aiPlayer.selectLaw();
                if (_ctx.state.selectedLaw.hasGivesTarget()) {
                    // error if law has a gives target, abort by giving focus back to ai
                    _ctx.state.selectedCards = null;
                    aiPlayer.doneEnactingLaws();
                    return;
                }
                
                _ctx.state.selectedCard = player.hand.pickRandom(Card.VERB);
                _ctx.state.activeCard = _ctx.state.selectedLaw.cards[1];
                
                if (_ctx.state.activeCard.type == _ctx.state.selectedCard.type) {
                    // if ai would switch GETS with GETS
                    _ctx.state.selectedCards = null;
                    _ctx.state.selectedLaw = null;
                    _ctx.state.activeCard = null;
                    aiPlayer.doneEnactingLaws();
                    return;
                }
                
                // perform the actual swap here - propagate data change info only when adding
                player.hand.removeCards(_ctx.state.selectedCards, false);
                _ctx.state.selectedLaw.removeCards(new Array(_ctx.state.activeCard), false);
                _ctx.state.selectedLaw.addCards(_ctx.state.selectedCards, true, 1);
                player.hand.addCards(new Array(_ctx.state.activeCard), true);
            
                // continue and notify other players
                bankerVerbExchanged();
                return;

            case TRADER:
                // the trader's ability happens immediately
                player.loseMonies(2);
                player.hand.drawCard(2);
                announcePowerUsed("used Trader's power to draw two cards");
                doneUsingPower();
                return;

            case PRIEST:
                // select a subject to exchange and a law to exchange it with
                _ctx.state.selectedCard = player.hand.pickRandom(Card.SUBJECT);
                _ctx.state.selectedLaw = aiPlayer.selectLaw();
                // ai players only ever switch the first SUBJECT in a law
                _ctx.state.activeCard = _ctx.state.selectedLaw.cards[0];
                
                if (_ctx.state.activeCard.type == _ctx.state.selectedCard.type) {
                    // if ai would switch DOCTOR with DOCTOR
                    _ctx.state.selectedCards = null;
                    _ctx.state.selectedLaw = null;
                    _ctx.state.activeCard = null;
                    aiPlayer.doneEnactingLaws();
                    return;
                }
                
                // perform the actual swap here - propagate data change info only when adding
                player.hand.removeCards(_ctx.state.selectedCards, false);
                _ctx.state.selectedLaw.removeCards(new Array(_ctx.state.activeCard), false);
                _ctx.state.selectedLaw.addCards(_ctx.state.selectedCards, true, 0);
                player.hand.addCards(new Array(_ctx.state.activeCard), true);
            
                // continue and notify other players
                priestSubjectExchanged();
                return;

            case DOCTOR:
                // select a when to add and a law to add it to
                _ctx.state.selectedLaw = aiPlayer.selectLaw();
                if (_ctx.state.selectedLaw.when != -1) {
                    // if the law already has a when, take it
                    _ctx.state.activeCard = 
                        _ctx.state.selectedLaw.cards[_ctx.state.selectedLaw.cards.length - 1];
                    _ctx.state.selectedCard = _ctx.state.activeCard;
                    _ctx.state.selectedLaw.removeCards(new Array(_ctx.state.activeCard), true);
                    player.hand.addCards(new Array(_ctx.state.activeCard), true);
                    
                } else {
                    // add a when from hand to the end of the law
                    _ctx.state.selectedCard = player.hand.pickRandom(Card.WHEN);
                    if (_ctx.state.selectedCards[0] == null) {
                        // if ai has no when cards
                        _ctx.state.selectedCards = null;
                        aiPlayer.doneEnactingLaws();
                        return;
                    }
                    _ctx.state.activeCard = _ctx.state.selectedCard;
                    player.hand.removeCards(_ctx.state.selectedCards, true);
                    _ctx.state.selectedLaw.addCards(_ctx.state.selectedCards, true, 
                        _ctx.state.selectedLaw.cards.length);
                }
                
                // continue and notify other players
                doctorWhenMoved();
                return;
        }
    }
    */

    /**
     * Once this is called, power can't be cancelled because player has seen or done something
     * that can't be undone.  May be called a second time for some powers.
     */
    public function reachedPointOfNoReturn () :void
    {
        _ctx.board.usePowerButton.enabled = false;
    }

    /**
     * Called when using judge power and a law was just selected.
     */
    protected function judgeLawSelected () :void
    {
        reachedPointOfNoReturn();
        player.loseMonies(2);
        var law :Law = _ctx.state.selectedLaw;
        announcePowerUsed("is enacting a law: '" + law + "'");
        _ctx.state.deselectLaw();
        _ctx.eventHandler.addMessageListener(Laws.ENACT_LAW_DONE, judgeLawEnacted);
        _ctx.sendMessage(Laws.ENACT_LAW, law.id);
    }

    /**
     * Called when judge is done enacting a law.
     */
    protected function judgeLawEnacted (event :MessageEvent) :void
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
        player.loseMonies(2);
        var opponent :Player = _ctx.state.selectedPlayer;
        
        // display opponent's hand then select a card from it
        Opponent(opponent).showHand = true;
        _ctx.state.selectCards(1, thiefCardSelected, opponent);
    }

    /**
     * Called when using thief power and a card was just selected
     */
    protected function thiefCardSelected () :void
    {
        var opponent :Player = _ctx.state.selectedPlayer;
        if (opponent == null) {
           _ctx.error("opponent null when theif card selected.");
           return;
        }
        opponent.giveCardsTo(_ctx.state.selectedCards, player);
        var stolenCard :Card = _ctx.state.selectedCard;
        _ctx.state.deselectOpponent();
        _ctx.state.deselectCards();

        // give different players different information
        announcePowerUsed("stole a card from " + opponent.name);
        if (!(opponent as AIPlayer)) {
            _ctx.broadcast(player.name + " stole a '" + stolenCard.text + 
                "' card from you", opponent);
        }
        if (!(player as AIPlayer)) {
            Opponent(opponent).showHand = false;
            _ctx.notice("You stole a '" + stolenCard.text + "' card from " + opponent.name);
        }
        doneUsingPower();
    }

    /**
     * Called when using banker power and a verb card from hand was just exchanged with one
     * in a law.
     */
    protected function bankerVerbExchanged () :void
    {
        var card :Card = _ctx.state.activeCard;
        var targetCard :Card = _ctx.state.selectedCard;
        var law :Law = _ctx.state.selectedLaw;
        announcePowerUsed("swapped '" + targetCard.text + "' with '" + card.text + 
            "' to make '" + law + "'");
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
        var targetCard :Card = _ctx.state.selectedCard;
        var law :Law = _ctx.state.selectedLaw;
        announcePowerUsed("swapped '" + targetCard.text + "' with '" + card.text + 
            "' to make '" + law + "'");
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
            announcePowerUsed("added '" + card.text + "' to make '" + law + "'");
        }
        else {
            var targetCard :Card = _ctx.state.selectedCard;
           announcePowerUsed("removed '" + targetCard.text + "' to make '" + law + "'");
        }
        _ctx.state.deselectLaw();
        _ctx.state.deselectCards();
        doneUsingPower();
    }
    
    /**
     * Tell players that a power was just used.  Display "You ..." or "Bob The Banker ...".
     */
    protected function announcePowerUsed (message :String) :void
    {
        if (_ctx.board.players.isMyTurn()) {
            _ctx.notice("You " + message);
            _ctx.broadcastOthers(player.name + " " + message);
        } else {
            _ctx.broadcast(player.name + " " + message);
        }
    }

    /**
     * Called when the player finishes succesfully using their ability.
     * Hide the cancel button again and trigger any laws that go when using ability.
     */
    protected function doneUsingPower () :void
    {
        // this may have already been called for some powers
        reachedPointOfNoReturn();
        _ctx.eventHandler.dispatchEvent(new Event(MY_POWER_USED));
        _ctx.sendMessage(SOME_POWER_USED);
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
    }

    /**
     * Return the text for the job area.  Must be unique for all jobs.
     */
    override public function get name () :String
    {
        switch (id) {
            case WATCHER:
                return "Watcher";
            case JUDGE:
                return "Judge";
            case Job.THIEF:
                return "Thief";
            case Job.BANKER:
                return "Banker";
            case Job.TRADER:
                return "Trader";
            case Job.PRIEST:
                return "Priest";
            case Job.DOCTOR:
                return "Doctor";
        }
        _ctx.error("Unknown job in job get name.");
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
                return "Swap a red card in your hand with one in a law";
            case Job.TRADER:
                return "Pay $2 to draw two cards";
            case Job.PRIEST:
                return "Swap a blue card in your hand with one in a law";
            case Job.DOCTOR:
                return "Add a 'when' card to a law or take one from a law";
        }
        _ctx.error("Unknown job in job get description.");
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
        _ctx.error("Unknown job in job get symbol.");
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
    
    /** The player who currently holds this job, or null */
    public var player :Player;

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