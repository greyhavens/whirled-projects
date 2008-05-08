package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.Event;
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
        super(ctx);

        ctx.eventHandler.addDataListener(LAWS_DATA, lawsChanged);
        ctx.eventHandler.addMessageListener(ENACT_LAW, enactLaw);
        ctx.eventHandler.addMessageListener(NEW_LAW, addNewLaw);

        ctx.eventHandler.addEventListener(EventHandler.PLAYER_TURN_STARTED, turnStarted);
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
     * Some player just created a new law.  Create a new law component with the event value
     * as its cards, and add it to our array.  Next enact the law if applicable, then begin
     * triggering laws that have "when a new law is created".
     */
    public function addNewLaw (event :MessageReceivedEvent) :void
    {
        var law :Law = new Law(_ctx, numLaws);
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
     * Handler for start turn event.  Enact any laws that trigger when this
     * player's turn starts.
     */
    protected function turnStarted (event :Event) :void
    {
        _ctx.board.laws.triggerWhen(Card.START_TURN, _ctx.board.player.job.id);
    }

    /**
     * A player just finished using their ability, or created a law, or it's the start
     * of their turn.  Trigger any laws with the appropriate WHEN card and their job as the
     * subject type.
     */
    public function triggerWhen (whenType :int, subjectType :int = -1) :void
    {
        // tell the state that we're enacting laws; player can't do anything else.
        _ctx.state.startEnactingLaws();

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
        _ctx.state.doneEnactingLaws();
    }

    /**
     * Called if something disastrous happens, such as a player leaving the game.  If we
     * were in the middle of triggering an effects chain, remove listeners for it now.
     */
    public function cancelTriggering () :void
    {
        _ctx.eventHandler.removeMessageListener(ENACT_LAW_DONE, triggeringWhen);
        _ctx.state.doneEnactingLaws();
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
    protected var MAX_LAWS :int = 10;

    /** Number of pixels between laws */
    protected var LAW_SPACING_Y :int = 34;
}
}