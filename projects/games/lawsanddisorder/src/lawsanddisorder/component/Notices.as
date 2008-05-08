package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.events.MouseEvent;

import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.StateChangedEvent;

import lawsanddisorder.Context;

/**
 * Displays in-game messages to the player
 * TODO timestamp notices?
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
    }

    /**
     * Draw the job area
     */
    override protected function initDisplay () :void
    {
        // draw the bg
        graphics.clear();
        graphics.beginFill(0xDD9955);
        graphics.drawRect(0, 0, 700, 30);
        graphics.endFill();

        // main notice area
        currentNotice = new TextField();
        currentNotice.height = 30;
        currentNotice.width = 500;
        currentNotice.x = 100;
        currentNotice.y = 5;
        var format :TextFormat = new TextFormat();
        format.align = "center";
        currentNotice.defaultTextFormat = format;
        addChild(currentNotice);

        // view history button
        viewHistoryButton = new TextField();
        viewHistoryButton.text = "view history";
        viewHistoryButton.x = 570;
        viewHistoryButton.y = 5;
        viewHistoryButton.autoSize = TextFieldAutoSize.CENTER;
        viewHistoryButton.addEventListener(MouseEvent.CLICK, viewHistoryButtonClicked);
        addChild(viewHistoryButton);

        // history area and text
        history = new Sprite();
        history.graphics.beginFill(0xDD9955);
        history.graphics.drawRect(0, 0, 500, 380);
        history.x = 100;
        history.y = -350;
        historyText = new TextField();
        historyText.x = 30;
        historyText.autoSize = TextFieldAutoSize.LEFT;
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
    public function addNotice (notice :String) :void
    {
        /*
        notices.push(notice);
        if (contains(history)) {
            historyText.appendText(notice + "\n");
        }
        if (notices.length > MAX_NOTICES) {
            notices.splice(0, notices.length - MAX_NOTICES);
            // TODO also update history if showing
        }
        updateDisplay();
        */
        _ctx.log(notice);
    }

    /**
     * When a message broadcast to all players is received
     */
    protected function gotBroadcast (event :MessageReceivedEvent) :void
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
}
}