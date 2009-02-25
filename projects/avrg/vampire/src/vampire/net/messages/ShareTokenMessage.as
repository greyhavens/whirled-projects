package vampire.net.messages
{
    import com.threerings.util.ClassUtil;
    
    import flash.utils.ByteArray;
    
    public class ShareTokenMessage extends BaseGameMessage
    {
        public function ShareTokenMessage(playerId:int = 0, token :String = "")
        {
            super(playerId);
            _shareToken = token;
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _shareToken = bytes.readUTF();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeUTF( _shareToken );
            return bytes;
        }
        
        public function get shareToken () :String
        {
           return _shareToken;     
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function toString() :String
        {
            return ClassUtil.tinyClassName( this ) + ": player=" + _playerId + ", shareToken=" + _shareToken;
        }
        
        protected var _shareToken :String;
        
        public static const NAME :String = "Message: Share Token";
        
    }
}