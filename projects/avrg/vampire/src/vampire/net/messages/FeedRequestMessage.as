package vampire.net.messages
{
    import com.threerings.util.ClassUtil;
    
    import flash.utils.ByteArray;
    
    public class FeedRequestMessage extends BaseGameMessage
    {
        public function FeedRequestMessage(playerId :int = 0, targetPlayerId :int = 0, targetPlayerIdVictim :Boolean = false)
        {
            super(playerId);
            _targetPlayerId = targetPlayerId;
            _targetPlayerIsVictim = targetPlayerIdVictim;
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _targetPlayerId = bytes.readInt();
            _targetPlayerIsVictim = bytes.readBoolean();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt( _targetPlayerId );
            bytes.writeBoolean( _targetPlayerIsVictim );
            return bytes;
        }
        
        public function get targetPlayer () :int
        {
           return _targetPlayerId;     
        }
        
        public function get isTargetPlayerTheVictim () :Boolean
        {
           return _targetPlayerIsVictim;     
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function toString() :String
        {
            return ClassUtil.tinyClassName( this ) + ": player=" + _playerId + ", " + (_targetPlayerIsVictim ? " feeds on " : " is eaten by ") + " " + targetPlayer;
        }
        
        
        protected var _targetPlayerId :int;
        protected var _targetPlayerIsVictim :Boolean;
        
        public static const NAME :String = "Message: Request Feed"; 
        
    }
}