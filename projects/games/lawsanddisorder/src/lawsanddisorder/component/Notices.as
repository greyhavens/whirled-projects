package lawsanddisorder.component {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import lawsanddisorder.*;

/**
 * Displays in-game messages to the player
 */
public class Notices extends Component
{
    /** Name of the message sent when broadcasting in-game to all players */
    public static const BROADCAST :String = "broadcast";

    /**
     * Constructor
     */
    public function Notices (ctx :Context)
    {
        notices = new Array();
        super(ctx);
        ctx.eventHandler.addMessageListener(BROADCAST, gotBroadcast);
        addEventListener(MouseEvent.CLICK, viewHistoryButtonClicked);
    }

    /**
     * Draw the job area
     */
    override protected function initDisplay () :void
    {
        var background :Sprite = new NOTICES_BACKGROUND();
        addChild(background);

        // main notice area
        currentNotice = Content.defaultTextField();
        currentNotice.height = 30;
        currentNotice.width = 300;
        currentNotice.x = 40;
        currentNotice.y = 6;
        currentNotice.wordWrap = false;
        addChild(currentNotice);

        // view history button
        /*
        viewHistoryButton = Content.defaultTextField(0.9);
        viewHistoryButton.text = "more";
        viewHistoryButton.x = 300;
        viewHistoryButton.y = 7;
        viewHistoryButton.addEventListener(MouseEvent.CLICK, viewHistoryButtonClicked);
        addChild(viewHistoryButton);
        */

        // history area and text
        history = new Sprite();
        history.graphics.beginFill(0xB9B9B9);
        history.graphics.drawRect(0, 0, 355, 380);
        history.x = 15;
        history.y = -380;
        historyText = Content.defaultTextField(1.0, "left");
        historyText.width = 320;
        historyText.x = 30;
        history.addChild(historyText);
        addEventListener(MouseEvent.ROLL_OUT, historyRollOut);
        history.addEventListener(MouseEvent.ROLL_OUT, historyRollOut);
    }

    /**
     * Update the job name
     */
    override protected function updateDisplay () :void
    {
        if (notices != null && notices.length > 0) {
            var noticeText :String = notices[notices.length-1];
            if (noticeText == null) {
                _ctx.log("WTF tried to display null notice text.");
                return;
            }
            noticeText = noticeText.replace("\n", "");
            currentNotice.text = noticeText;

            // position text at the bottom of the history area
            if (contains(history)) {
                historyText.y = 365 - historyText.textHeight;
            }
         }
    }

    /**
     * When a new game notice comes in, add it to the list of notices and display it.
     */
    public function addNotice (notice :String, alsoLog :Boolean = true) :void
    {
        notices.push(notice);
        if (contains(history)) {
            historyText.appendText(notice + "\n");
        }
        if (notices.length > MAX_NOTICES) {
            notices.splice(0, notices.length - MAX_NOTICES);
            // TODO also update history if showing
        }
        updateDisplay();
        
        if (alsoLog) {
            _ctx.log(notice);
        }
    }

    /**
     * When a message broadcast to all players is received
     */
    protected function gotBroadcast (event :MessageEvent) :void
    {
        //_ctx.log("[broadcast]: " + event.value);
        _ctx.log(event.value as String);
        //addNotice(event.value as String);
    }

    /**
     * History button was clicked; toggle history display
     */
    protected function viewHistoryButtonClicked (event :MouseEvent) :void
    {
        _ctx.log("view history button clicked");
        if (contains(history)) {
            showHistory = false;
        }
        else {
            showHistory = true;
        }
    }

    /**
     * Triggered by the mouse exiting the notices history area.  Hide the notices history area.
     */
    protected function historyRollOut (event :MouseEvent) :void
    {
        if (contains(history)) {
            showHistory = false;
        }
    }

    /**
     * Display or hide the history area.  If displaying, update the history text first.
     */
    protected function set showHistory (value :Boolean) :void
    {
        if (value && !contains(history)) {
            // reset the history contents
            historyText.text = "";
            for each (var notice :String in notices) {
                historyText.appendText(notice + "\n");
            }
            _ctx.log("adding history");
            addChild(history);
            updateDisplay();
        }
        else if (!value && contains(history)) {
            removeChild(history);
        }
    }

    /** Array of messages in chronolocial order */
    protected var notices :Array;

    /** Displays text of the most recent notice. */
    protected var currentNotice :TextField;

    /** Full display of notices history. */
    protected var history :Sprite;

    /** Full display of notices history text. */
    protected var historyText :TextField;

    /** Press this button to view the history */
    protected var viewHistoryButton :TextField;

    /** Maximum number of notices to record in history */
    protected var MAX_NOTICES :int = 30;

    /** Background image for the notices */
    [Embed(source="../../../rsrc/components.swf#notices")]
    protected static const NOTICES_BACKGROUND :Class;
}
}