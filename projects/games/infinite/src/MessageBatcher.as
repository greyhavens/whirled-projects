package
{
    import arithmetic.VoidBoardRectangle;
    
    import com.whirled.game.NetSubControl;
    
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    public class MessageBatcher
    {
        public function MessageBatcher (control:NetSubControl)
        {
            _control = control;
            _timer = new Timer(DELAY);
            _timer.addEventListener(TimerEvent.TIMER, handleTimer);
        }
        
        public function start () :void
        {
            _timer.start();
        }        
        
        public function stop () :void
        {
            _timer.stop();
        }
        
        protected function handleTimer (event:TimerEvent) :void
        {
            sendAsBatch();
        }
        
        public function sendMessage (messageName:String, value:Object, playerId:int) :void
        {
            enQueue(messageName, value, playerId);
        }

        protected function enQueue (messageName:String, value:Object, playerId:int) :void
        {
            if (_queue == null) {
                _queue = new Array();
            }
            
            _queue.push({
               messageName: messageName,
               value: value,
               playerId: playerId 
            });
        }
    
        protected function sendAsBatch () :void
        {
            _control.doBatch(function () :void {
               sendQueued(); 
            });
        }
    
        protected function sendQueued () :void
        {
            if (_queue != null) {
                Log.debug("sending batch of "+_queue.length+" messages");
                for each (var message:Object in _queue) {
                    _control.sendMessage(message.name, message.value, message.playerId);
                }
            }
            _queue = null;
        }

        protected var _timer:Timer;
        protected var _queue:Array;
        protected var _control:NetSubControl;
        
        protected static const DELAY:int = 100;
    }
}