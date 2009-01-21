package vampire.net.messages
{
    import flash.utils.ByteArray;
    
    import vampire.net.IGameMessage;
    
    public class BaseGameMessage 
        implements IGameMessage
    {
        public function BaseGameMessage(playerId :int = -1)
        {
            _playerId = playerId;
        }
        
        public function get name () :String
        {
           throw Error("Abstract class.");     
        }
        
        public function fromBytes (bytes :ByteArray) :void
        {
            bytes.position = 0;
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
        
        public function set playerId( id :int) :void 
        {
            _playerId = id;
        }
        
        public function toString() :String
        {
            return " From player " + _playerId + " ";
        }
        
        public var _playerId :int;  
    }
}