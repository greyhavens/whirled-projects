package
{
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
        
        public function sendMessage (messageName:String, value:Object, playerId:int = NetSubControl.TO_ALL) :void
        {
            enQueue(messageName, value, playerId);
        }

        protected function enQueue (messageName:String, value:Object, playerId:int) :void
        {
            if (_queue == null) {
                _queue = new Array();
            }
            
            _queue.push(new QueueEntry(messageName, value, playerId));
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
                for each (var message:QueueEntry in _queue) {
                    _control.sendMessage(message.messageName, message.value, message.playerId);
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

class QueueEntry {
    public var messageName:String;
    public var value:Object;
    public var playerId:int;
    
    public function QueueEntry (messageName:String, value:Object, playerId:int) :void
    {
        this.messageName = messageName;
        this.value = value;
        this.playerId = playerId;
    }   
    
    public function toString () :String
    {
        return "messageName: "+messageName+" value: "+value+" playerId: "+playerId;
    }
}