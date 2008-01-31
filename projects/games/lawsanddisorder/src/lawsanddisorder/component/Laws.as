﻿package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import lawsanddisorder.Context;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.MessageReceivedEvent;

/**
 * Area filled with laws
 * TODO rename to LawsArea?
 */
public class Laws extends Component
{
    /** The name of the hand data distributed value. */
    // TODO use more unique names incl class name?
    public static const LAWS_DATA :String = "lawsData";
    public static const ENACT_LAW :String = "enactLaw";
    public static const ENACT_LAW_DONE :String = "enactLawDone";
    
    /**
     * Constructor
     */
    public function Laws (ctx :Context)
    {
        ctx.eventHandler.addPropertyListener(LAWS_DATA, lawsChanged);
        ctx.eventHandler.addMessageListener(ENACT_LAW, lawEnacted);
        super(ctx);
    }
    
    /**
     * Player just created this law; distribute it to everyone.  Connect a temporary listener
     * so we will know when the data has been recieved by the server and we can send the 
     * command to enact the new law.
     */
    public function addNewLaw (law :Law) :void
    {
        if (law.id != laws.length) {
            _ctx.log("WTF new law id: " + law.id + " is not equals to laws.length.");
        }
        _ctx.eventHandler.addPropertyListener(LAWS_DATA, newLawAdded);
        _ctx.set(Laws.LAWS_DATA, law.getSerializedCards(), law.id);
    }

    /**
     * Called when the data for a new law we created comes back.  Now that the server has the
     * card data for it, send a message to every player to enact the law.
     * 
     * TODO what about the case of create a law then modify a law; if modify message gets there
     * first we're going to disconnect the handler prematurely??
     * 
     * TODO cards are being set twice - prevent this?
     */
    protected function newLawAdded (event :PropertyChangedEvent) :void
    {
        _ctx.eventHandler.removePropertyListener(LAWS_DATA, newLawAdded);
        
        // enact the new law only if it contains no WHEN card
        // law already exists because we know this is the player who created it
        var law :Law = laws[event.index];
        if (law == null) {
            _ctx.log("WTF law " + event.index + " is null when newLawAdded message recieved.");
            return;
        }
        if (law.when == -1) {
            // to avoid multiple laws enacting at once, wait until this one is done before
            // searching for laws that trigger on CREATE_LAW.
            _ctx.eventHandler.addMessageListener(ENACT_LAW_DONE, newLawEnacted);
           _ctx.sendMessage(ENACT_LAW, event.index);
        }
        else {
            _ctx.board.laws.triggerWhen(Card.CREATE_LAW);
        }
    }
    
    /**
     * Called when a new law is successfully enacted.  Now scroll through all the laws and
     * enact any that trigger on CREATE_LAW.
     */
    protected function newLawEnacted (event :MessageReceivedEvent) :void
    {
        _ctx.eventHandler.removeMessageListener(ENACT_LAW_DONE, newLawEnacted);
        _ctx.board.laws.triggerWhen(Card.CREATE_LAW);
    }
    
    /**
     * Add a law to the hand and rearrange cards
     */
    public function addLaw (law :Law) :void
    {
        if (!contains(law)) {
            addChild(law);
        }
        if (laws.indexOf(law) < 0) {
             laws.push(law);
        }
        law.x = 0;
        law.y = (laws.length - 1) * 35;
    }
    
    /** 
     * Return the number of laws
     */
    public function get numLaws () :int
    {
        return laws.length;
    }
    
    /**
     * Called when a law is triggered.  Event value is the index of the triggered law.
     * Get the law card set from the server to make sure we have the newest version first.
     */
    protected function lawEnacted (event :MessageReceivedEvent) :void
    {
        var lawId :int = event.value as int;
        updateLawData(lawId);
        var law :Law = laws[lawId];
        if (law == null) {
            _ctx.log("WTF law is null when enacting: " + lawId);
            return;
        }
        law.enactLaw();
    }
    
    /**
     * Fetch the data for a single law.  If serializedCards is supplied use that, otherwise 
     * fetch from the server.
     */
    protected function updateLawData (lawId :int, cards :Object = null) :void
    {
        if (cards == null) {
            cards = _ctx.get(LAWS_DATA, lawId);
        }
        
        if (laws.length == lawId) {
            var law :Law = new Law(_ctx, laws.length);
            law.setSerializedCards(cards);
            addLaw(law);
        }
        else if (laws.length > lawId) {
            var existingLaw :Law = laws[lawId];
            if (existingLaw == null) {
                _ctx.log("WTF existing law " + lawId + " null when updating data. laws.length:" + laws.length);
                return;
            }
            existingLaw.setSerializedCards(cards);
        }
        else {
            // TODO make sure this can never happen or we can deal with it
            _ctx.log("WTF it's a TOO new law. laws.length:" + laws.length + " , lawId:" + lawId);
        }
    }
    
    /**
     * Handles when laws data changes
     */
    protected function lawsChanged (event :PropertyChangedEvent) :void
    {
        if (event.index != -1) {
            updateLawData(event.index, event.newValue);
        }
    }
    
    /**
     * A player just finished using their ability, or created a law, or it's the start
     * of their turn.  Trigger any laws with the appropriate WHEN card and their job as the 
     * subject type.
     */
    public function triggerWhen (whenType :int, subjectType :int = -1) :void
    {
        triggerWhenType = whenType;
        triggerSubjectType = subjectType;
        _ctx.eventHandler.addMessageListener(ENACT_LAW_DONE, triggeringWhen);
        
        // kick off the loop through laws with a dummy event (-1 is the last law enacted).
        var dummyEvent :MessageReceivedEvent = new MessageReceivedEvent(null, ENACT_LAW_DONE, -1);
        triggeringWhen(dummyEvent);
    }
    
    /**
     * Called when in the process of triggering laws.  To avoid enacting multiple laws at once,
     * this will only be called to continue once a law is finished enacting.
     */
    protected function triggeringWhen (event :MessageReceivedEvent) :void
    {
        // may be -1 the first time through
        var lastLawEnacted :int = event.value as int;
        _ctx.eventHandler.removeMessageListener(ENACT_LAW_DONE, triggeringWhen);

        for (var i :int = lastLawEnacted + 1; i < laws.length; i++) {
            var law :Law = laws[i];
            if (law.when == triggerWhenType) {
                if (triggerSubjectType == -1 || law.subject == triggerSubjectType) {
                    _ctx.eventHandler.addMessageListener(ENACT_LAW_DONE, triggeringWhen);
                    _ctx.sendMessage(Laws.ENACT_LAW, law.id);
                    return;
                }
            }
        }
        
        // TOOD is there a reason to clear these?
        triggerWhenType = -1;
        triggerSubjectType = -1;
        
        // action complete; return focus to the player if it is their turn
        _ctx.state.performingAction = false;
    }
    
    /** If in the middle of triggering laws, this is the when type */
    protected var triggerWhenType :int;
    
    /** If in the middle of triggering laws, this is the subject type */
    protected var triggerSubjectType :int;
    
    /** Array of laws */
    protected var laws :Array = new Array();
}
}