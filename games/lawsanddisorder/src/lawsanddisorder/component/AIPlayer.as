package lawsanddisorder.component {

import flash.events.Event;

import lawsanddisorder.*;

/**
 * Class representing a computer player.  Instanciated by every player and controlled by the
 * player whose turn directly precedes this one.
 */
public class AIPlayer extends Opponent
{
    protected static const TESTING :Boolean = false;
    
    /**
     * Constructor
     * @param id Identifier for this player according to their position on the board
     * @param serverId Identifier from the game server (should be -1)
     */
    public function AIPlayer (ctx :Context, id :int, player :Player = null)
    {
        var aiName :String = aiNames[id];
        super(ctx, id, -1, aiName);
        
        // the smaller the dumbnessFactor, the choosier the ai will be about the decisions
        // they make during their turn.
        this.dumbnessFactor = _ctx.aiDumbnessFactor;
        //dumbnessFactor = (Math.round(Math.random() * 100));
        
        // if player is provided, make this AIPlayer a clone of that player
        if (player != null) {
            this._hand = player.hand;
            this._monies = player.monies;
            this._job = player.job;
            this.job.player = this;
            this.updateDisplay();
        }
    }
    
    public function startTurn() :void
    {
        // for easier testing, all ais play as the DOCTOR
        //_ctx.board.deck.switchJobs(_ctx.board.deck.getJob(Job.DOCTOR), this);

        canPlay = true;
        hand.drawCard(Deck.CARDS_AT_START_OF_TURN);
        
        createdLaw = false;
        usedPower = false;
        changedJobs = false;
        
        // start triggering laws for this player's jobs
        _ctx.board.laws.triggerWhen(Card.START_TURN, job.id);
    }
    
    /**
     * A law is triggering and needs an opponent to be selected.
     */
    public function selectOpponent (law :Law = null) :Player
    {
        // TODO do this based on the content of the law or who is doing well
        var opponent :Player = _ctx.board.players.opponents.getRandomOpponent();
        if (opponent == this) {
            opponent = _ctx.player;
        }
        return opponent;
    }
    
    /**
     * A law is triggering and needs one or more cards to be selected
     * TODO add player to this
     */
    public function selectCards (numCards :int, law :Law = null) :Array
    {
        // TODO pick strategically
        var selectedCards :Array = hand.getRandomCards(numCards);
        return selectedCards;
    }
    
    protected function selectRandomCard (type :int) :Card
    {
        var card :Card = hand.pickRandom(type);
        if (TESTING) {
            _ctx.log("Picked random card of type " + type + " : " + card);
        }
        return card;
    }
    
    /**
     * Select a law to do something with.
     * type can be one of "best", "worst", "random"
     */
    protected function selectLaw (type :String = "random") :Law
    {
        // if ai is 100% dumb, always return a random law.  If ai is 50% dumb, return a random
        // law half the time.  If ai is 5% dumb, pick randomly 5 in 100 times.
        // TODO dumber ais could pick slightly-worse laws instead of random ones 
        if (type == "random" || getRandChance(100, dumbnessFactor)) {
            return _ctx.board.laws.getRandomLaw();
        }
        
        var law :Law = _ctx.board.laws.getLawByValue(this, type);
        if (TESTING) {
            _ctx.log("Selected law using method " + type + " : " + law);
        }
        return law;
    }
    
    /**
     * Called to notify this player that the laws are finished enacting and they once again have
     * focus to play.
     */
    public function doneEnactingLaws () :void
    {
        EventHandler.startTimer(_ctx.aiDelaySeconds * 1000, play);
    }
    
    /**
     * Perform an action on the AIs turn.  First collect a list of available actions and weight
     * them according to benefit to the AI.  Then pick weighted-randomly from them and execute
     * the selected action.  This function will be called again once the action is complete,
     * until no other options are available or the AI decides to end their turn.
     */
    protected function play () :void
    {
        if (!canPlay) {
            if (TESTING) {
                _ctx.log("AIPlayer has been told to halt, stopping.");
            }
            return;
        }
        
        playOptions = new Array();
        playOptionWeights = new Array();
        
        if (!changedJobs) {
            var cardOptions :Array = new Array();
            for each (var card :Card in hand.cards) {
                if (card.group == Card.SUBJECT && card.type != job.id) {
                    cardOptions.push(card);
                }
            }
            if (cardOptions.length != 0) {
                // pick up to 3 options for changing jobs and add them to the options list
                for (var ii :int = 0; ii < 3 && ii < cardOptions.length; ii++) {
                    addChangeJobOption(cardOptions);
                }
            }
        }
        
        if (!createdLaw) {
            for (var jj :int = 0; jj < 3; jj++) {
                addCreateLawOption();
            }
        }

        if (!usedPower) {
            if (job.getUsePowerError()) {
                if (TESTING) {
                    _ctx.log("\ncan't use power because: " + job.getUsePowerError());
                }
            } else {
                for (var kk :int = 0; kk < 3; kk++) {
                    addUsePowerOption();
                }
            }
        }
        
        // if no options (or randomly 1/4 of the time) end turn
        if (playOptions.length == 0 || getRandChance(4)) {
            _ctx.board.endTurnButton.aiTurnEnded();
            return;
        }
        
        var totalWeight :int = dumbnessFactor * playOptionWeights.length;
        for each (var weight :int in playOptionWeights) {
            totalWeight += weight;
        }
        var randomWeightIndex :int = Math.round(Math.random() * (totalWeight-1));
        var runningTotalWeight :int = 0;
        for (var i :int = 0; i < playOptionWeights.length; i++) {
            runningTotalWeight += playOptionWeights[i];
            runningTotalWeight += dumbnessFactor;
            if (runningTotalWeight >= randomWeightIndex) {
                var chosenOption :Function = playOptions[i];
                // when execution or law triggering finishes, play() will be called again.
                chosenOption();
                return;
            } 
        }
        _ctx.error("Finished looking but didn't find randomWeightIndex");
    }
    
    /**
     * Add functions to playOptions for up to three different (?) change job actions.
     */
    protected function addChangeJobOption (cardOptions :Array) :void
    {
        var randomIndex :int = Math.round(Math.random() * (cardOptions.length-1));
        var selectedCard :Card = cardOptions[randomIndex];
        var playerWithJob :Player = _ctx.board.deck.getJob(selectedCard.type).player;
        
        var cardCount :int = 0;
        for each (var cardInHand :Card in hand.cards) {
            if (cardInHand.group == Card.SUBJECT && cardInHand.type == selectedCard.type) {
                cardCount++;
            }
        }
        
        // weight is increased if the player with this job is doing well, or if the ai
        // has other cards of the same SUBJECT.  From 0 to 20+ with avg ~8
        var playerWeight :int = 20;
        if (playerWithJob != null) {
            playerWeight = playerWithJob.getWinningPercentile();
        }
        var weight :int = (playerWeight + (cardCount -1) * 25)/10;
        
        if (TESTING) {
            _ctx.log("\nweight for " + selectedCard + " is " + weight + " #" + cardCount);
            _ctx.log("player with job.getWinningPercentile() is " + playerWithJob.getWinningPercentile());
        }
        
        if (weight > 0) {
            playOptions.push(function (): void { changeJobs(selectedCard); });
            playOptionWeights.push(weight);
        }
    }
    
    /**
     * Add functions to playOptions for up to three different (?) laws.
     */
    protected function addCreateLawOption () :void
    {
        var subject :Card = selectRandomCard(Card.SUBJECT);
        var verb :Card = selectRandomCard(Card.VERB);
        var object :Card = selectRandomCard(Card.OBJECT);
        if (subject == null || verb == null || object == null) {
            return;
        }
        
        // only use a when card (if available) half the time
        var when :Card = selectRandomCard(Card.WHEN);
        if (getRandChance(2)) {
            when = null;
        }
        
        // get an optional TO subject if the verb is GIVES
        var toSubject :Card = null;
        if (verb.type == Card.GIVES) {
            toSubject = selectRandomCard(Card.SUBJECT);
            if (toSubject.type == subject.type || getRandChance(2)) {
                toSubject = null;
            }
        }
        
        var cardList :Array = new Array();
        cardList.push(subject);
        cardList.push(verb);
        if (toSubject != null) {
            cardList.push(toSubject);
        }
        cardList.push(object);
        if (when != null) {
            cardList.push(when);
        }
        
        var weight :int = _ctx.board.laws.calculateLawValue(this, cardList);
        if (weight > 0) {
            playOptions.push(function (): void { createLaw(cardList); });
            playOptionWeights.push(weight);
        }
    }

    /**
     * Add functions to playOptions for up to three different (?) power uses
     */
    protected function addUsePowerOption () :void
    {
        var targetLaw :Law = null;
        var targetCard :Card = null;
        var targetPlayer :Player = null;
        var weight :int = 0;
        
        switch (job.id) {
        case Job.JUDGE:
            targetLaw = selectLaw("best");
            if (TESTING) {
                _ctx.log("Judge is " + dumbnessFactor + " dumb and chose this law to enact: " + targetLaw);
            }
            weight = 50;
            break;

        case Job.THIEF:
            targetPlayer = selectOpponent();
            targetCard = targetPlayer.hand.getRandomCards(1)[0];
            weight = 50;
            break;

        case Job.BANKER:
            targetLaw = selectLaw();
            if (targetLaw.hasGivesTarget()) {
                // can't change DOCTOR gives PRIEST 1 card
                break;
            }
            targetCard = selectRandomCard(Card.VERB);
            var verbInLaw :Card = targetLaw.cards[1];
            if (TESTING) {
                _ctx.log("verbInLaw: " + verbInLaw + ", targetCard: " + targetCard);
            }
            if (verbInLaw.type == targetCard.type) {
                if (TESTING) {
                    _ctx.log("can't swap gets wth gets.");
                }
                // can't swap GETS with GETS
                break;
            }
            weight = 50;
            break;

        case Job.TRADER:
            // base weight on how many cards you already have?
            weight = 90;
            break;

        case Job.PRIEST:
            targetLaw = selectLaw("worst");
            targetCard = selectRandomCard(Card.SUBJECT);
            if (TESTING) {
                _ctx.log("Priest is " + dumbnessFactor + " dumb and chose this law to change:" + targetLaw);
                _ctx.log("PRIEST targetcard: " + targetCard);
            }
            // ai players only ever switch the first SUBJECT in a law
            var subjectInLaw :Card = targetLaw.cards[0];
            if (subjectInLaw.type == targetCard.type) {
                if (TESTING) {
                    _ctx.log("can't swap doctor with doctor.");
                }
                // can't swap DOCTOR with DOCTOR
                break;
            }
            weight = 50;
            break;

        case Job.DOCTOR:
            targetLaw = selectLaw();
            if (targetLaw.when != -1) {
                // law already has a when, so take that.
                weight = 50;
                break;
            }

            // add a when from hand to the end of the law
            targetCard = selectRandomCard(Card.WHEN);
            if (targetCard == null) {
                // ai has no when cards
                break;
            }
            weight = 50;
            break;
        }
    
        if (TESTING) {
            _ctx.log("\nweight for " + job + " ability with " + targetLaw + ", " 
                + targetCard + ", " + targetPlayer + " is " + weight);
        }
        if (weight > 0) {
            if (TESTING) {
                _ctx.log("pushing ability with weight: " + weight);
            }
            
            playOptions.push(function (): void { 
                usePower(targetLaw, targetCard, targetPlayer); });
            playOptionWeights.push(weight);
        }
    }
        
    /**
     * Given a SUBJECT card, remove it from the hand and change jobs to that job.  When done,
     * call play() to continue play.
     */
    protected function changeJobs (card :Card) :void
    {
        changedJobs = true;
        hand.removeCards(new Array(card));
        var newJob :Job = _ctx.board.deck.getJob(card.type);
        _ctx.board.deck.switchJobs(newJob, this);
        EventHandler.startTimer(_ctx.aiDelaySeconds * 1000, play);
    }
    
    /**
     * Given a list of cards, create a new law from those cards.
     */
    protected function createLaw (cardList :Array) :void
    {
        createdLaw = true;
        hand.removeCards(cardList);
        _ctx.board.newLaw.makeLaw(cardList, this);
    }
    
    /**
     * Use your power
     */
    protected function usePower (targetLaw :Law, targetCard :Card, targetPlayer :Player) :void
    {
        usedPower = true;
        job.usePowerAI(targetLaw, targetCard, targetPlayer);
    }
    
    /**
     * Returns true numerator/denominator of the time, and false the rest of the time
     */
    protected function getRandChance (denominator :int, numerator :int = 1) :Boolean
    {
        var result :int = Math.round(Math.random() * (denominator/numerator));
        if (result == 0) {
            return true;
        }
        return false;
    }
    
    /** May be set to false if something disastrous happens like a player leaving */
    public var canPlay :Boolean;
    
    /** Ordered list of play functions that may be called */
    protected var playOptions :Array;
    
    /** Values for play functions based on how good they are for the AI and bad for opponents */
    protected var playOptionWeights :Array;
    
    /** Has the AI created or attempted to create a law this turn */
    protected var createdLaw :Boolean;
    
    /** Has the AI used or attempted to use their power this turn */
    protected var usedPower :Boolean;
    
    /** Has the AI used or attempted to change jobs this turn */
    protected var changedJobs :Boolean;
    
    /** AIs will pick randomly from these names */
    protected var aiNames :Array = 
        new Array("Charles", "Amanda", "Exavier", "Gregory", "Stuart", "Winona");
    
    /** Will be added to weights prior to decision making, the higher, the dumber, from 0 - 100 */
    protected var dumbnessFactor :Number;
}
}
