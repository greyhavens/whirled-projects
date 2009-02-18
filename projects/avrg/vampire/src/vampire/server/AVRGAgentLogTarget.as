package vampire.server
{
    import com.threerings.util.LogTarget;
    import com.threerings.util.StringBuilder;
    import com.whirled.avrg.AVRServerGameControl;
    
    import flash.utils.setInterval;

    /**
    * Caches messages and then regularly broadcasts them once per minute.
    */
    public class AVRGAgentLogTarget implements LogTarget
    {
        
        public function AVRGAgentLogTarget( ctrl :AVRServerGameControl )
        {
            _ctrl = ctrl;
            _messageCache = new StringBuilder();
            setInterval(sendLogs, MESSAGE_BROADCAST_INTERVAL_MS);
        }
        
        public function sendLogs(...ignored) :void
        {
            if( _isLogs ) {
                _ctrl.game.sendMessage( SERVER_LOG, _messageCache.toString() );
                _messageCache = new StringBuilder();
                _isLogs = false;
            }
        }
        
        public function log(msg:String):void
        {
            _messageCache.append("\n\t\t>>>>>SERVER " + msg);
            _isLogs = true;
        }
        
        protected var _isLogs :Boolean = false;
        protected var _ctrl :AVRServerGameControl;
        protected var _messageCache :StringBuilder;
        
        protected static const MESSAGE_BROADCAST_INTERVAL_MS :int = 1000;
        
        public static const SERVER_LOG :String = "Server log broadcast";
    }
}