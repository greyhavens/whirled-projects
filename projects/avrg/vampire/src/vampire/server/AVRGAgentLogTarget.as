package vampire.server
{
    import com.threerings.util.LogTarget;
    import com.threerings.util.StringBuilder;
    import com.whirled.avrg.AVRServerGameControl;
    
    import flash.utils.getTimer;

    /**
    * Caches messages and then regularly broadcasts them once per minute.
    */
    public class AVRGAgentLogTarget implements LogTarget
    {
        
        public function AVRGAgentLogTarget( ctrl :AVRServerGameControl )
        {
            _ctrl = ctrl;
            _lastTimeMessageSent = getTimer();
            _messageCache = new StringBuilder("\n>>>>Server Begin>>>>");
        }
        
        public function log(msg:String):void
        {
//            _ctrl.game.sendMessage( SERVER_LOG, msg );
            
            _messageCache.append("\n\t\t" + msg);
            var now :int = getTimer();
            if( now - _lastTimeMessageSent >= 1000) {
                _lastTimeMessageSent = now;
                _messageCache.append("\n<<<<Server End<<<<\n");
                _ctrl.game.sendMessage( SERVER_LOG, _messageCache.toString() );
                _messageCache = new StringBuilder("\n>>>>Server Begin>>>>");
            }
                
        }
        
        protected var _ctrl :AVRServerGameControl;
        protected var _messageCache :StringBuilder;
        protected var _lastTimeMessageSent :int;
        
        public static const SERVER_LOG :String = "Server log broadcast";
    }
}