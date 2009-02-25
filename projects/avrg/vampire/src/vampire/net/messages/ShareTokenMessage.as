package vampire.net.messages
{
    import com.threerings.util.ClassUtil;
    
    import flash.utils.ByteArray;
    
    public class ShareTokenMessage extends BaseGameMessage
    {
        public function ShareTokenMessage(playerId:int = 0, inviterId :int = 0, token :String = "")
        {
            super(playerId);
            _inviterId = inviterId;
            _shareToken = (token != null ? token : "");
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _inviterId = bytes.readInt();
            _shareToken = bytes.readUTF();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt( _inviterId );
            bytes.writeUTF( _shareToken );
            return bytes;
        }
        
        public function get shareToken () :String
        {
           return _shareToken;     
        }
        public function get inviterId () :int
        {
           return _inviterId;     
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function toString() :String
        {
            return ClassUtil.tinyClassName( this ) + ": player=" + _playerId + ", inviterId=" + _inviterId + ", shareToken=" + _shareToken;
        }
        
        protected var _shareToken :String;
        protected var _inviterId :int;
        
        public static const NAME :String = "Message: Share Token";
        
    }
}