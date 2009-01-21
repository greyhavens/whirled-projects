package vampire.net.messages
{
    import flash.utils.ByteArray;
    
    public class BloodBondRequestMessage extends BaseGameMessage
    {
        public function BloodBondRequestMessage(playerId:int = 0, targetPlayerId :int = 0, add :Boolean = true)
        {
            super(playerId);
            _targetPlayerId = targetPlayerId;
            _add = add;
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _targetPlayerId = bytes.readInt();
            _add = bytes.readBoolean();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt( _targetPlayerId );
            bytes.writeBoolean( _add );
            return bytes;
        }
        
        public function get targetPlayer () :int
        {
           return _targetPlayerId;     
        }
        
        public function get add () :Boolean
        {
           return _add;     
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        protected var _targetPlayerId :int;
        protected var _add :Boolean;
        
        public static const NAME :String = "Message: Request Bloodbond Change";
        
    }
}