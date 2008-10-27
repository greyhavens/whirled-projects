package lawsanddisorder.component {

import flash.events.Event;

import lawsanddisorder.*;

/**
 * Class representing a computer player.  Instanciated by every player and controlled by the
 * player whose turn directly precedes this one.
 */
public class AIPlayer extends Opponent
{
    /**
     * Constructor
     * @param id Identifier for this player according to their position on the board
     * @param serverId Identifier from the game server (should be -1)
     */
    public function AIPlayer (ctx :Context, id :int)
    {
        var aiName :String = aiNames[id];
        super(ctx, id, -1, aiName);
        
        // the smaller the dumbnessFactor, the choosier the ai will be about the decisions
        // they make during their turn.
        this.dumbnessFactor = _ctx.aiDumbnessFactor;
        //dumbnessFactor = (Math.round(Math.random() * 100));
    }
    
    public function startTurn() :void
    {
        //_ctx.notice("\nI, " + name + " am starting my turn!");
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
        //_ctx.log(name + " selected opponent " + opponent.name);
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
        //_ctx.log(name + " selected cards " + selectedCards);
        return selectedCards;
    }
    
    /**
     * Select a law to do something with.
     * TODO need strategy, must switch on what we are doing (or move to job).
     */
    public function selectLaw () :Law
    {
        return _ctx.board.laws.getRandomLaw();
    }
    
    /**
     * Called to notify this player that the laws are finished enacting and they once again have
     * focus to play.
     */
    public function doneEnactingLaws () :void
    {
        //_ctx.log(name + " has focus again, returning to play");
        EventHandler.invokeLater(_ctx.aiDelaySeconds, play);
    }
    
    /**
     * Perform an action on the AIs turn.  First collect a list of available actions and weight
     * them according to benefit to the AI.  Then pick weighted-randomly from them and execute
     * the selected action.  This function will be called again once the action is complete,
     * until no other options are available or the AI decides to end their turn.
     */
    protected function play (timerEvent :Object = null) :void
    {
        playOptions = new Array();
        playOptionWeights = new Array();
        
        if (!changedJobs) {
            addChangeJobOptions();
        }
        
        if (!createdLaw) {
            addCreateLawOptions();
        }

        if (!usedPower) {
            addUsePowerOptions();
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
        _ctx.log("WTF finished looking but didn't find randomWeightIndex");
    }
    
    /**
     * Add functions to playOptions for up to three different (?) change job actions.
     */
    protected function addChangeJobOptions () :void
    {
        var cardOptions :Array = new Array();
        for each (var card :Card in hand.cards) {
            if (card.group == Card.SUBJECT && card.type != job.id) {
                cardOptions.push(card);
            }
        }
        if (cardOptions.length == 0) {
            return;
        }

        // pick 3 options for changing jobs and add them to the options list
        for (var i :int = 0; i < 3 && i < cardOptions.length; i++) {
            var randomIndex :int = Math.round(Math.random() * (cardOptions.length-1));
            var selectedCard :Card = cardOptions[randomIndex];
            var playerWithJob :Player = _ctx.board.deck.getJob(selectedCard.type).player;
            
            var cardCount :int = 0;
            for each (var cardInHand :Card in hand.cards) {
                if (cardInHand.group == Card.SUBJECT && cardInHand.type == selectedCard.type) {
                    cardCount++;
                }
            }
            
            playOptions.push(function (): void { changeJobs(selectedCard); });
            // weight is increased if the player with this job is doing well, or if the ai
            // has other cards of the same SUBJECT.  From 0 to 75+, avg ~30
            var playerWeight :int = 20;
            if (playerWithJob != null) {
                playerWeight = playerWithJob.getWinningPercentile();
            }
            var weight :int = (playerWeight/2 + (cardCount -1) * 25)/2;
            playOptionWeights.push(weight);
            //_ctx.log("weight for job " + selectedCard + " is " + weight);
            //_ctx.log("cardCount is " + cardCount);
            //_ctx.log("player with job.getWinningPercentile() is " + playerWithJob.getWinningPercentile());
        }
    }
    
    /**
     * Add functions to playOptions for up to three different (?) laws.
     */
    protected function addCreateLawOptions () :void
    {
        for (var i :int = 0; i < 3; i++) {
            var subject :Card = hand.pickRandom(Card.SUBJECT);
            var verb :Card = hand.pickRandom(Card.VERB);
            var object :Card = hand.pickRandom(Card.OBJECT);
            if (subject == null || verb == null || object == null) {
                return;
            }
            
            // only use a when card (if available) half the time
            var when :Card = hand.pickRandom(Card.WHEN);
            if (getRandChance(2)) {
                when = null;
            }
            
            // get an optional TO subject if the verb is GIVES
            var toSubject :Card = null;
            if (verb.type == Card.GIVES) {
                toSubject = hand.pickRandom(Card.SUBJECT);
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
            
            if (!_ctx.board.newLaw.isValidLaw(cardList)) {
                _ctx.log("WTF AIplayer tried to make an invalid law: " + cardList);
                return;
            }
            
            var gainingPlayer :Player = _ctx.board.newLaw.isGoodFor(cardList);
            var losingPlayer :Player = _ctx.board.newLaw.isBadFor(cardList);
            
            // don't ever play a law that hurts yourself
            if (losingPlayer == this) {
                continue;
            }
            
            var weight :int = 25;
            if (gainingPlayer == this && losingPlayer != null) {
                weight = 150;
            } else if (gainingPlayer == this) {
                weight = 125;
            } else if (gainingPlayer != null && losingPlayer != null) {
                weight = ((100 - gainingPlayer.getWinningPercentile()) + (losingPlayer.getWinningPercentile())) / 2;
            } else if (gainingPlayer != null) {
                weight = Math.max(0, 50 - gainingPlayer.getWinningPercentile());
            } else if (losingPlayer != null) {
                weight = losingPlayer.getWinningPercentile();
            }
            
            // adjust the weight: 2 cards at the start of your turn is better than 1 monie now
            var powerMultiplier :int = object.value;
            if (object.type == Card.CARD) {
                powerMultiplier *= 2;
            }
            if (when != null) {
                powerMultiplier += 3;
            }
            weight *= powerMultiplier/4 + 10;

/*
            _ctx.log("weight for " + cardList + " is " + weight);
            _ctx.log("power multiplier is " + powerMultiplier);
            
            if (gainingPlayer != null) {
                _ctx.log("gaining player.winning: " + gainingPlayer.getWinningPercentile());
            } 
            if (losingPlayer != null) {
                _ctx.log("losingPlayer.winning: " + losingPlayer.getWinningPercentile());
            } 
            */
            playOptions.push(function (): void { createLaw(cardList); });
            playOptionWeights.push(weight);
        }
    }
    
    /**
     * Add functions to playOptions for up to three different (?) power uses
     */
    protected function addUsePowerOptions () :void
    {
        if (job.getUsePowerError()) {
            //_ctx.log("can't use power because: " + job.getUsePowerError()); 
            return;
        }
        
        // TODO queue up decisions (which law, which card) here and check weird conditions
        // eg there is only one law and it already has a when for DOCTOR.
        playOptions.push(function (): void { usePower(); });
        playOptionWeights.push(50);
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
        EventHandler.invokeLater(_ctx.aiDelaySeconds, play);
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
    protected function usePower () :void
    {
        usedPower = true;
        job.usePowerAI();
    }
    
    /**
     * Returns true 1/denominator of the time, and false the rest of the time
     */
    protected function getRandChance (denominator :int) :Boolean
    {
        var result :int = Math.round(Math.random() * denominator);
        if (result == 0) {
            return true;
        }
        return false;
    }
    
    /** True if this is the instance that controls this AI's behavior.  Control instance will
     * be on the human player whose turn precedes this AI's turn. */
    public var isController :Boolean = false;
    
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
