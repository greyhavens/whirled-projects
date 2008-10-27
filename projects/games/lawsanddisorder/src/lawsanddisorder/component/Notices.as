package lawsanddisorder.component {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import lawsanddisorder.*;

/**
 * Displays in-game messages to the player
 */
public class Notices extends Component
{
    /** Message sent when broadcasting in-game to all players in the chat */
    public static const BROADCAST :String = "broadcast";
    
    /** Message sent when sending in-game to all players that will appear in their notice area */
    public static const BROADCAST_NOTICE :String = "broadcastNotice";

    /**
     * Constructor
     */
    public function Notices (ctx :Context)
    {
        //notices = new Array();
        super(ctx);
        ctx.eventHandler.addMessageListener(BROADCAST, gotBroadcast);
        ctx.eventHandler.addMessageListener(BROADCAST_NOTICE, gotBroadcast);
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
        currentNotice.height = 35;
        currentNotice.width = 300;
        currentNotice.x = 40;
        currentNotice.y = 10;
        addChild(currentNotice);
        
        // history area and text
        history = new Sprite();
        history.graphics.beginFill(0xB9B9B9);
        history.graphics.drawRect(0, 0, 355, 380);
        history.x = 15;
        //var pt :Point = this.globalToLocal(new Point(0,0));
        //_ctx.log("zero locally is :" + pt.y);
        //history.y = globalToLocal(new Point(0,0)).y;
        history.y = -380;
        historyText = Content.defaultTextField(1.0, "left");
        //historyText.border = true;
        historyText.width = 320;
        historyText.x = 20;
        //historyText.border = true;
        
        history.addChild(historyText);
        addEventListener(MouseEvent.ROLL_OUT, historyRollOut);
        history.addEventListener(MouseEvent.ROLL_OUT, historyRollOut);
    }

    /**
     * Update the job name
     */
    override protected function updateDisplay () :void
    {
        //if (notices != null && notices.length > 0) {
        /*
            var noticeText :String = notices[notices.length-1];
            if (noticeText == null) {
                _ctx.log("WTF tried to display null notice text.");
                return;
            }
            currentNotice.text = noticeText;
            */

            // position text at the bottom of the history area
            //_ctx.log("historyText textheight: " + historyText.textHeight);
            //historyText.height = Math.min(historyText.textHeight + 20, 360);
            historyText.height = historyText.textHeight + 10;
            historyText.y = 375 - historyText.height;//historyText.textHeight;
         //}
    }

    /**
     * When a new game notice comes in, add it to the list of notices and display it.
     */
    public function addNotice (notice :String, alsoLog :Boolean = true) :void
    {
        // if blank, just clear the current notice but do not log to history
        if (notice == null || notice.length == 0) {
            if (_ctx.board.players.isMyTurn()) {
                currentNotice.text = "It's your turn."
            } else {
                currentNotice.text = "It's " + _ctx.board.players.turnHolder.name + "'s turn."
            }
            return;
        }
    
        if (alsoLog) {
            _ctx.log(notice);
        }
        
        notice = notice.replace("\n", "");
        currentNotice.text = notice;
        //notices.push(notice);
        historyText.appendText(notice + "\n");
        //if (notices.length > MAX_NOTICES) {
        //    notices.splice(0, notices.length - MAX_NOTICES);
        //}
        
        updateDisplay();
    }

    /**
     * When a message broadcast to all players is received
     */
    protected function gotBroadcast (event :MessageEvent) :void
    {
        //_ctx.log("[broadcast]: " + event.value);
        if (event.name == Notices.BROADCAST_NOTICE) {
            _ctx.notice(event.value as String);
        } else {
            _ctx.log(event.value as String);
        }
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
            addChildAt(history, 0);
            updateDisplay();
        }
        else if (!value && contains(history)) {
            removeChild(history);
        }
        //_ctx.log("\nHISTORY text is now =====\n" + historyText.text + "\n=====\n");
        //_ctx.log("height: " + historyText.height + ", textheight: " + historyText.textHeight);
    }

    ///** Array of messages in chronolocial order */
    //protected var notices :Array;

    /** Displays text of the most recent notice. */
    protected var currentNotice :TextField;

    /** Full display of notices history. */
    protected var history :Sprite;

    /** Full display of notices history text. */
    protected var historyText :TextField;

    /** Press this button to view the history */
    protected var viewHistoryButton :TextField;

    ///** Maximum number of notices to record in history */
    //protected var MAX_NOTICES :int = 30;

    /** Background image for the notices */
    [Embed(source="../../../rsrc/components.swf#notices")]
    protected static const NOTICES_BACKGROUND :Class;
}
}