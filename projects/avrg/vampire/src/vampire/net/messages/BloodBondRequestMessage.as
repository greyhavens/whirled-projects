package vampire.net.messages
{
    import com.threerings.util.ClassUtil;
    
    import flash.utils.ByteArray;
    
    public class BloodBondRequestMessage extends BaseGameMessage
    {
        public function BloodBondRequestMessage(playerId:int = 0, targetPlayerId :int = 0, targetPlayerName :String = null, add :Boolean = true)
        {
            super(playerId);
            _targetPlayerId = targetPlayerId;
            _targetPlayerName = targetPlayerName;
            _add = add;
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _targetPlayerId = bytes.readInt();
            _targetPlayerName = bytes.readUTF();
            _add = bytes.readBoolean();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt( _targetPlayerId );
            bytes.writeUTF( _targetPlayerName );
            bytes.writeBoolean( _add );
            return bytes;
        }
        
        public function get targetPlayer () :int
        {
           return _targetPlayerId;     
        }
        
        public function get targetPlayerName () :String
        {
           return _targetPlayerName;     
        }
        
        public function get add () :Boolean
        {
           return _add;     
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function toString() :String
        {
            return ClassUtil.tinyClassName( this ) + ": player=" + _playerId + ", " + (_add ? "+" : "-") + " " + targetPlayer;
        }
        
        
        protected var _targetPlayerId :int;
        protected var _targetPlayerName :String;
        protected var _add :Boolean;
        
        public static const NAME :String = "Message: Request Bloodbond Change";
        
    }
}