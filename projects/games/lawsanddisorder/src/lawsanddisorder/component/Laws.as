package lawsanddisorder.component {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.Dictionary;

import lawsanddisorder.*;

/**
 * Area filled with laws
 */
public class Laws extends Component
{
    /** The name of the hand data distributed value. */
    public static const LAWS_DATA :String = "lawsData";
    public static const ENACT_LAW :String = "enactLaw";
    public static const ENACT_LAW_DONE :String = "enactLawDone";

    /** Message sent when new law added, value is list of cards */
    public static const NEW_LAW :String = "newLaw";

    /**
     * Constructor
     */
    public function Laws (ctx :Context)
    {
        super(ctx);

        ctx.eventHandler.addDataListener(LAWS_DATA, lawsChanged);
        ctx.eventHandler.addMessageListener(ENACT_LAW, enactLaw);
        ctx.eventHandler.addMessageListener(ENACT_LAW_DONE, enactLawDone);
        ctx.eventHandler.addMessageListener(Job.SOME_POWER_USED, somePowerUsed);

        ctx.eventHandler.addEventListener(EventHandler.MY_TURN_STARTED, turnStarted);
        ctx.eventHandler.addEventListener(Job.MY_POWER_USED, powerUsed);
    }
    
    /**
     * Play a sound when any player uses their power
     */
    protected function somePowerUsed (...ignored) :void
    {
        Content.playSound(Content.SFX_POWER_USED);
    }
    
    /**
     * For watchers who join partway through the game, fetch the existing law data
     */
    public function refreshData () :void
    {
        var lawsData :Dictionary = _ctx.eventHandler.getData(Laws.LAWS_DATA) as Dictionary;
        if (lawsData != null) {
            var i :int = 0;
            while (true) {
                var lawData :Array = lawsData[i];
                if (lawData == null) {
                    break;
                }
                var law :Law = new Law(_ctx, i);
                law.setSerializedCards(lawData);
                addLaw(law);
                i++;
            }
        }
    }

    /**
     * Clear the laws in preparation for a new game.  This is called only by the controller.
     */
    public function setup () :void
    {
        _ctx.eventHandler.setData(LAWS_DATA, null);
    }

    /**
     * A player just finished using their ability, or created a law, or it's the start
     * of their turn.  Trigger any laws with the appropriate WHEN card and their job as the
     * subject type.
     * @param whenType Type of when card to execute, eg Card.START_TURN
     * @job Optional (as for Card.CREATE_LAW) subject type eg Job.BANKER or _ctx.player.job.id
     */
    public function triggerWhen (whenType :int, job :int = -1) :void
    {
        // tell the state that we're enacting laws; player can't do anything else.
        if (!(_ctx.board.players.turnHolder as AIPlayer)) {
            _ctx.state.startEnactingLaws();
        }

        triggerWhenType = whenType;
        triggerSubjectType = job;
        _ctx.eventHandler.addMessageListener(ENACT_LAW_DONE, triggeringWhen);

        // kick off the loop through laws with a dummy event (oldestLawId-1 is the last law enacted).
        var dummyEvent :MessageEvent = new MessageEvent(ENACT_LAW_DONE, oldestLawId-1);
        triggeringWhen(dummyEvent);
    }
    
    /**
     * Called if something disastrous happens, such as a player leaving the game.  If we
     * were in the middle of triggering an effects chain, remove listeners for it now.
     */
    public function cancelTriggering () :void
    {
        _ctx.eventHandler.removeMessageListener(ENACT_LAW_DONE, triggeringWhen);

        // action complete; return focus to the player or to the ai player
        if (_ctx.board.players.turnHolder as AIPlayer) {
            AIPlayer(_ctx.board.players.turnHolder).doneEnactingLaws();
        } else {
            _ctx.state.doneEnactingLaws();
        }
    }

    /**
     * Choose and return a random law.
     */
    public function getRandomLaw () :Law
    {
        if (laws.length == 0) {
            return null;
        }
        var numLaws :int = Math.min(laws.length,MAX_LAWS);
        var randomIndex :int = Math.round(Math.random() * (numLaws - 1)) + oldestLawId;
        return laws[randomIndex];
    }
    
    /**
     * Return the (type=) "best" or "worst" law for a given player.
     */
    public function getLawByValue (player :Player, type :String) :Law
    {
        var chosenLaw :Law = null;
        var chosenLawValue :int = 0;
        for (var ii :int = oldestLawId; ii < laws.length; ii++) {
            var lawValue :int = calculateLawValue(player, laws[ii].cards);
            if (chosenLaw == null || (type == "best" && lawValue > chosenLawValue)
                || (type == "worst" && lawValue < chosenLawValue)) {
                chosenLaw = laws[ii];
                chosenLawValue = lawValue;
            }
        }
        
        if (chosenLaw == null) {
            _ctx.error("chosenLaw null in Laws.getRandomLaw for type " + type);
            return null;
        }
        return chosenLaw;
    }
    
    /**
     * Return a value from 0 to 262 with avg ~80 that determines how good this law is for a given 
     * player.  Return 0 (worst possible) if the law hurts that player.
     */
    public function calculateLawValue (player :Player, cardList :Array) :int
    {
        var gainingPlayer :Player = _ctx.board.newLaw.isGoodFor(cardList);
        var losingPlayer :Player = _ctx.board.newLaw.isBadFor(cardList);
        
        // laws that hurt yourself are automatically the worst ever (value 0)
        if (losingPlayer == player) {
            return 0;
        }
        
        var weight :int = 25;
        if (gainingPlayer == player && losingPlayer != null) {
            weight = 175;
        } else if (gainingPlayer == player) {
            weight = 140;
        } else if (gainingPlayer != null && losingPlayer != null) {
            weight = ((100 - gainingPlayer.getWinningPercentile()) + (losingPlayer.getWinningPercentile())) / 2;
        } else if (gainingPlayer != null) {
            // sometimes make laws that help players who are in the bottom 20%
            weight = Math.max(0, 20 - gainingPlayer.getWinningPercentile());
        } else if (losingPlayer != null) {
            weight = losingPlayer.getWinningPercentile();
        }
        
        // adjust the weight: 2 cards at the start of your turn is better than 1 monie now
        var object :Card = _ctx.board.newLaw.getObject(cardList);
        var when :Card = _ctx.board.newLaw.getWhen(cardList);
        var powerMultiplier :int = object.value;
        if (object.type == Card.CARD) {
            powerMultiplier *= 2;
        }
        if (when != null) {
            powerMultiplier += 2;
        }
        
        // after multiplier, weight range is 0 - 262 with avg ~80
        weight *= (powerMultiplier + 9)/10;
        
        /* _ctx.log("\nweight for " + cardList + " is " + weight + " with mult " + ((powerMultiplier + 9)/10));
        if (gainingPlayer != null) {
            if (gainingPlayer == this) {
                _ctx.log("gaining player is me.");
            } else {
                _ctx.log("gaining player.winning: " + gainingPlayer.getWinningPercentile());
            }
        } 
        if (losingPlayer != null) {
            _ctx.log("losingPlayer.winning: " + losingPlayer.getWinningPercentile());
        }  */
        
        return weight;
    }
    
    /**
     * Called when a law is triggered.  Event value is the index of the triggered law.
     */
    protected function enactLaw (event :MessageEvent) :void
    {
        var lawId :int = event.value as int;
        var law :Law = laws[lawId];
        if (law == null) {
            _ctx.error("law is null when enacting: " + lawId);
            return;
        }
        law.setHighlighted(true);
        law.enactLaw();
    }
    
    /**
     * Handles when laws data changes
     */
    protected function lawsChanged (event :DataChangedEvent) :void
    {
        // a single law changed; update it
        if (event.index != -1) {
            updateLawData(event.index, event.newValue);
        }

        // got a law resetting event; clear the laws
        else if (event.newValue == null) {
            while (laws.length > 0) {
                var law :Law = laws.pop();
                if (contains(law)) {
                   removeChild(law);
                }
            }
            oldestLawId = 0;
        }
    }
    
    /**
     * Fetch the data for a single law.
     */
    protected function updateLawData (lawId :int, cards :Object) :void
    {
        if (cards == null) {
            _ctx.error("null cards in Laws.updateLawData");
            cards = _ctx.eventHandler.getData(LAWS_DATA, lawId);
        }
        // add a new law
        if (laws.length == lawId) {
            // create and add law for enacting but do not add as child until animation done
            var law :Law = new Law(_ctx, laws.length);
            laws.push(law);
            law.setSerializedCards(cards);
                        
            // animate the current player adding the new law to the board
            var fromPoint :Point;
            if (_ctx.board.players.turnHolder == _ctx.player) {
                fromPoint = _ctx.board.newLaw.localToGlobal(new Point(0, 0));
            } else {
                fromPoint = (_ctx.board.players.turnHolder as Opponent).localToGlobal(
                    new Point(0, 0));
            }
            var toPoint :Point;
            if (laws.length > MAX_LAWS) {
                toPoint = localToGlobal(new Point(0, (MAX_LAWS - 1) * LAW_SPACING_Y));
            }
            else {
                toPoint = localToGlobal(new Point(0, (laws.length-1) * LAW_SPACING_Y));
            }
            Content.playSound(Content.SFX_LAW_CREATED);
            // when animation completes, add the new law sprite and trigger it
            law.animateMove(fromPoint, toPoint, 
                function () :void { 
                    addLaw(law); 
                    triggerNewLaw(law); 
                });

        // update an existing law
        } else if (laws.length > lawId) {
            var existingLaw :Law = laws[lawId];
            if (existingLaw == null) {
                _ctx.error("existing law " + lawId + " null when updating data. laws.length:" 
                    + laws.length);
                return;
            }
            existingLaw.setSerializedCards(cards);
        }
        else {
            _ctx.error("it's a TOO new law. laws.length:" + laws.length + " , lawId:" + lawId);
        }
    }

    /**
     * Add a law to the array of law objects and as a child sprite, then position sprites.
     */
    protected function addLaw (law :Law) :void
    {
        if (!contains(law)) {
            addChild(law);
        }
        if (laws.indexOf(law) < 0) {
             laws.push(law);
        }
        law.x = 0;
        if (laws.length > MAX_LAWS) {
            var oldestLaw :Law = laws[oldestLawId];
            _ctx.notice("There are too many laws - removing the oldest one.");
            removeChild(oldestLaw);
            oldestLawId++;
            arrangeLaws();
        }
        else {
            law.y = (laws.length - 1) * LAW_SPACING_Y;
        }
    }

    /**
     * Rearrange the laws vertically
     */
    protected function arrangeLaws () :void
    {
        // position the laws vertically
        for (var i :int = oldestLawId; i < laws.length; i++) {
            var law :Law = laws[i];
            law.y = (i - oldestLawId) * LAW_SPACING_Y;
        }
    }
    
    /**
     * A new law was just created; the player whose turn it is starts the law triggering
     */
    protected function triggerNewLaw (law :Law) :void
    {
        //if (_ctx.board.players.isMyTurn() || _ctx.board.players.amControllingAI() ) {
        if (_ctx.board.players.isMyTurn() || 
            (_ctx.board.players.turnHolder as AIPlayer && _ctx.player.isController)) {
            if (law.when == -1) {
                // to avoid multiple laws enacting at once, wait until this one is done before
                // searching for laws that trigger on CREATE_LAW.
                _ctx.eventHandler.addMessageListener(ENACT_LAW_DONE, newLawEnacted);
                _ctx.sendMessage(ENACT_LAW, law.id);
            }
            else {
                triggerWhen(Card.CREATE_LAW);
            }
        }
    }

    /**
     * Called when a new law is successfully enacted.  Now scroll through all the laws and
     * enact any that trigger on CREATE_LAW.
     */
    protected function newLawEnacted (event :MessageEvent) :void
    {
        _ctx.eventHandler.removeMessageListener(ENACT_LAW_DONE, newLawEnacted);
        triggerWhen(Card.CREATE_LAW);
    }

    /**
     * Handler for start turn event.  Enact any laws that trigger when this
     * player's turn starts.
     */
    protected function turnStarted (event :Event) :void
    {
        triggerWhen(Card.START_TURN, _ctx.player.job.id);
    }

    /**
     * Called when in the process of triggering laws.  To avoid enacting multiple laws at once,
     * this will only be called to continue once a law is finished enacting.
     */
    protected function triggeringWhen (event :MessageEvent) :void
    {
        // may be -1 the first time through
        var lastLawEnacted :int = event.value as int;
        _ctx.eventHandler.removeMessageListener(ENACT_LAW_DONE, triggeringWhen);

        for (var i :int = lastLawEnacted + 1; i < laws.length; i++) {
            var law :Law = laws[i];
            if (law.when == triggerWhenType) {
                if (triggerSubjectType == -1 || law.subject == triggerSubjectType) {
                    _ctx.eventHandler.addMessageListener(ENACT_LAW_DONE, triggeringWhen);
                    _ctx.sendMessage(ENACT_LAW, law.id);
                    return;
                }
            }
        }

        // action complete; return focus to the player or to the ai player
        if (_ctx.board.players.turnHolder as AIPlayer) {
            AIPlayer(_ctx.board.players.turnHolder).doneEnactingLaws();
        } else {
            _ctx.state.doneEnactingLaws();
        }
    }

    /**
     * Called when a law is finished being enacted; de-highlight it.
     */
    protected function enactLawDone (event :MessageEvent) :void
    {
        var lastLawEnacted :int = event.value as int;
        if (lastLawEnacted > -1) {
            Law(laws[lastLawEnacted]).setHighlighted(false, true);
        }
    }
    
    /**
     * Player has finished using their ability, trigger any laws with "WHEN USES THEIR ABILITY"
     */
    protected function powerUsed (event :Event) :void
    {
        _ctx.board.laws.triggerWhen(Card.USE_ABILITY, _ctx.board.players.turnHolder.job.id);
    }
    
    /**
     * Return the number of laws
     */
    public function get numLaws () :int
    {
        return laws.length;
    }
    
    /** The position of the oldest still-visible law */
    protected var oldestLawId :int = 0;

    /** If in the middle of triggering laws, this is the when type */
    protected var triggerWhenType :int;

    /** If in the middle of triggering laws, this is the subject type */
    protected var triggerSubjectType :int;

    /** Array of laws */
    protected var laws :Array = new Array();

    /** Maximum number of laws; if another is added the first one will disappear */
    protected var MAX_LAWS :int = 8;

    /** Number of pixels between laws */
    protected var LAW_SPACING_Y :int = 40;
}
}