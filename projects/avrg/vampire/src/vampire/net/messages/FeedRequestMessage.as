package vampire.net.messages
{
    import com.threerings.util.ClassUtil;
    
    import flash.utils.ByteArray;
    
    public class FeedRequestMessage extends BaseGameMessage
    {
        public function FeedRequestMessage(playerId :int = 0, targetPlayerId :int = 0, allowMultiplePredators :Boolean = false)
        {
            super(playerId);
            _targetPlayerId = targetPlayerId;
            _allowMultiplePredators = allowMultiplePredators;
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _targetPlayerId = bytes.readInt();
            _allowMultiplePredators = bytes.readBoolean();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt( _targetPlayerId );
            bytes.writeBoolean( _allowMultiplePredators );
            return bytes;
        }
        
        public function get targetPlayer () :int
        {
           return _targetPlayerId;     
        }
        
        public function get isAllowingMultiplePredators () :Boolean
        {
           return _allowMultiplePredators;     
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function toString() :String
        {
            return ClassUtil.tinyClassName( this ) + ": player=" + _playerId + ", " + (_allowMultiplePredators ? " Allows multiple predators " : " eating alone ") + ", eating " + targetPlayer;
        }
        
        
        protected var _targetPlayerId :int;
        protected var _allowMultiplePredators :Boolean;
        
        public static const NAME :String = "Message: Request Feed"; 
        
    }
}