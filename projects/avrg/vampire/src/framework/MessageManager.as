package framework {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.AbstractControl;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import vampire.net.messages.BloodBondRequestMessage;
import vampire.net.messages.FeedRequestMessage;
import vampire.net.messages.RequestActionChangeMessage;


/**
 * 
 * 
 */
public class MessageManager extends EventDispatcher
{
    internal static const log :Log = Log.getLog(MessageManager);
    
    protected var _isUsingServerAgent :Boolean;
    
    public function MessageManager ()
    {
        
        
        
        
    }
    
    public function dispatchXXXEvent() :void
    {
        
    }


    
}

}
