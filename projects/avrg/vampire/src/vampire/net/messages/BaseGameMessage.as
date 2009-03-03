package vampire.net.messages
{
    import com.threerings.util.ClassUtil;
    
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
//            trace("fromBytes, bytes==null " + (bytes==null));
//            trace("fromBytes, bytes.length=" + bytes.length);
            bytes.position = 0;
            _playerId = bytes.readInt();
        }
        
        public function toBytes (bytes :ByteArray = null) :ByteArray
        {
//            trace("toBytes, _playerId=" + _playerId);
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
        
//        public function set playerId( id :int) :void 
//        {
//            _playerId = id;
//        }
        
        public function toString() :String
        {
            return ClassUtil.tinyClassName( this ) + ": From player " + _playerId + " ";
        }
        
        protected var _playerId :int;  
    }
}