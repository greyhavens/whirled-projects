package joingame.net
{
    import flash.utils.ByteArray;
    
    public class GameOverMessage extends JoinGameMessage
    {
        public function GameOverMessage()//toObserverState :Boolean = true)
        {
            super(-1);
//            _gotoObserverState = toObserverState;
        }
        
        
//        override public function fromBytes (bytes :ByteArray) :void
//        {
//            super.fromBytes(bytes);
//            _gotoObserverState = bytes.readBoolean();
//        }
//        
//        override public function toBytes (bytes :ByteArray = null) :ByteArray
//        {
//            var bytes :ByteArray = super.toBytes(bytes);
//            bytes.writeBoolean( _gotoObserverState);
//            return bytes;
//        }
        
//        public function get toObserverState () :Boolean
//        {
//           return _gotoObserverState;     
//        }
//        
//        public function get level () :int
//        {
//           return _level;     
//        }


        override public function get name () :String
        {
           return NAME;// + " toObserver=" + _gotoObserverState;     
        }
        
        
//        protected var _gotoObserverState :Boolean;

        public static const NAME :String = "Server:Game Over";   
    }
}