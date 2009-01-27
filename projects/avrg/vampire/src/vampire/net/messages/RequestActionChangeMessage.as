package vampire.net.messages
{
    import com.threerings.util.ClassUtil;
    
    import flash.utils.ByteArray;
    
    public class RequestActionChangeMessage extends BaseGameMessage
    {
        public function RequestActionChangeMessage(playerId:int = 0, action :String = null)
        {
            super(playerId);
            _action = action == null ? "" : action;
        }
        
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _action = bytes.readUTF();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeUTF( _action );
            return bytes;
        }
        
        public function get action () :String
        {
           return _action;     
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function toString() :String
        {
            return ClassUtil.tinyClassName( this ) + ": player=" + _playerId + ", action=" + _action;
        }
        
        protected var _action :String;
        
        public static const NAME :String = "Message: Request Action Change";
        
    }
}