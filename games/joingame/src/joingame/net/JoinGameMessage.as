package joingame.net
{
    import flash.utils.ByteArray;

    public class JoinGameMessage implements IJoinGameMessage //extends Event
    {
        public function JoinGameMessage(playerId :int = -1)//type:String, 
        {
//            super(type, false, false);
            _playerId = playerId;
        }
        
        public function get name () :String
        {
           throw Error("Abstract");     
        }
        
        public function fromBytes (bytes :ByteArray) :void
        {
            _playerId = bytes.readInt();
        }
        
        public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            if( bytes == null) {
                bytes = new ByteArray();
            }
            bytes.writeInt( _playerId);
            return bytes;
        }
        
        public function get playerId() :int 
        {
            return _playerId;
        }
        
        protected var _playerId :int;
        
    }
}