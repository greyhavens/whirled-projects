package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import com.whirled.game.MessageReceivedEvent;

import lawsanddisorder.*;

/**
 * Area filled with laws
 * TODO rename to LawsArea?
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
        ctx.eventHandler.addDataListener(LAWS_DATA, lawsChanged);
        ctx.eventHandler.addMessageListener(ENACT_LAW, enactLaw);
        ctx.eventHandler.addMessageListener(NEW_LAW, addNewLaw);
        super(ctx);
    }
    
    /**
     * Some player just created a new law.  Create a new law component with the event value
     * as its cards, and add it to our array.  Next enact the law if applicable, then begin
     * triggering laws that have "when a new law is created".     */
    public function addNewLaw (event :MessageReceivedEvent) :void
    {
    	var law :Law = new Law(_ctx, numLaws);
    	//_ctx.log("NEW law got serialized: " + event.value);
    	law.setSerializedCards(event.value);
    	addLaw(law);
    	law.setDistributedLawData();
    	
    	// player whose turn it is starts law triggering
        if (_ctx.board.isMyTurn()) {
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
    
    /*
     * Player just created this law; distribute it to everyone.  Connect a temporary listener
     * so we will know when the data has been recieved by the server and we can send the 
     * command to enact the new law.
     *
    public function addNewLaw (law :Law) :void
    {
        if (law.id != laws.length) {
            _ctx.log("WTF new law id: " + law.id + " is not equals to laws.length.");
        }
        _ctx.eventHandler.addDataListener(LAWS_DATA, newLawAdded, law.id);
        
        // TODO this is the second time we set the law data - what to do..
        // TODO is this law thrown out here?
        law.setDistributedLawData();
    }
    */

    /*
     * Called when the data for a new law we created comes back.  Now that the server has the
     * card data for it, send a message to every player to enact the law.
     *
     *
    protected function newLawAdded (event :DataChangedEvent) :void
    {
        _ctx.eventHandler.removeDataListener(LAWS_DATA, newLawAdded, event.index);
        
        // TODO this is also called by the law when it catches this event - fix?
        updateLawData(event.index, event.newValue);
        
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
    */
    
    /**
     * Called when a new law is successfully enacted.  Now scroll through all the laws and
     * enact any that trigger on CREATE_LAW.
     */
    protected function newLawEnacted (event :MessageReceivedEvent) :void
    {
        _ctx.eventHandler.removeMessageListener(ENACT_LAW_DONE, newLawEnacted);
        triggerWhen(Card.CREATE_LAW);
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
        if (laws.length > MAX_LAWS) {
        	//var oldestLawId :int = laws.length - MAX_LAWS - 1;
        	var oldestLaw :Law = laws[oldestLawId];
        	_ctx.notice("There are too many laws - removing the oldest: " + oldestLaw.text);
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
    protected function enactLaw (event :MessageReceivedEvent) :void
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
            cards = _ctx.eventHandler.getData(LAWS_DATA, lawId);
        }
        // add a new law
        if (laws.length == lawId) {
            var law :Law = new Law(_ctx, laws.length);
            law.setSerializedCards(cards);
            addLaw(law);
        }
        // update an existing law
        else if (laws.length > lawId) {
            var existingLaw :Law = laws[lawId];
            if (existingLaw == null) {
                _ctx.log("WTF existing law " + lawId + " null when updating data. laws.length:" + laws.length);
                return;
            }
            existingLaw.setSerializedCards(cards);
        }
        else {
            _ctx.log("WTF it's a TOO new law. laws.length:" + laws.length + " , lawId:" + lawId);
        }
    }
    
    /**
     * Handles when laws data changes
     */
    protected function lawsChanged (event :DataChangedEvent) :void
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
        
        // kick off the loop through laws with a dummy event (oldestLawId-1 is the last law enacted).
        var dummyEvent :MessageReceivedEvent = new MessageReceivedEvent(ENACT_LAW_DONE, oldestLawId-1);
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
        
        // action complete; return focus to the player if it is their turn
        _ctx.state.performingAction = false;
    }
    
    /** The position of the oldest still-visible law */
    protected var oldestLawId :int = 0;
    
    /** If in the middle of triggering laws, this is the when type */
    protected var triggerWhenType :int;
    
    /** If in the middle of triggering laws, this is the subject type */
    protected var triggerSubjectType :int;
    
    /** Array of laws */
    protected var laws :Array = new Array();
    //protected var laws :Dictionary = new Dictionary();
    
    /** Maximum number of laws; if another is added the first one will disappear */
    protected var MAX_LAWS :int = 10;
    
    /** Number of pixels between laws */
    protected var LAW_SPACING_Y :int = 32;
}
}