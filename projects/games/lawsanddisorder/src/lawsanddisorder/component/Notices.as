package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import lawsanddisorder.Context;
import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.StateChangedEvent;

/**
 * Displays in-game messages to the player
 * TODO on mouseover, display old notices
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
        
        // TODO center the message text
        title.height = 30;
        title.width = 500;
        title.x = 100;
        title.y = 5;
    }
    
    /**
     * Update the job name
     */
    override protected function updateDisplay () :void
    {
    	if (notices != null && notices.length > 0) {
        	title.text = notices[notices.length-1];
     	}
    }
    
    /**
     * When a new game notice comes in, add it to the list of notices and display it.
     * TODO crop message list if it is too long?  add to front of list instead?
     */
    public function addNotice (notice :String) :void
    {
        notices.push(notice);
        updateDisplay();
    }
    
    /**
     * When a message broadcast to all players is received
     */ 
    protected function gotBroadcast (event :MessageReceivedEvent) :void
    {
    	_ctx.log("[broadcast]: " + event.value);
    	addNotice(event.value as String);
    }
    
    /** Array of messages in chronolocial order 
    * TODO better name? */
    protected var notices :Array;
}
}