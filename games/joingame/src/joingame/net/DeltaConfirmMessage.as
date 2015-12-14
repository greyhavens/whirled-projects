package joingame.net
{
    import flash.utils.ByteArray;
    
    public class DeltaConfirmMessage extends JoinGameMessage
    {
        public function DeltaConfirmMessage(playerId:int = -1, fromIndex :int = -1, toIndex :int = -1)
        {
            super(playerId);
            _fromIndex = fromIndex;
            _toIndex = toIndex;
        }
        
        public function get fromIndex () :int
        {
            return _fromIndex;
        }
        
        public function get toIndex () :int
        {
            return _toIndex;
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _fromIndex = bytes.readInt();
            _toIndex = bytes.readInt();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt(_fromIndex);
            bytes.writeInt(_toIndex);
            return bytes;
        }
        
        public function toString() :String
        {
            return NAME + " " + _fromIndex + " -> " + _toIndex ;
        }
        
        
        protected var _fromIndex :int;
        protected var _toIndex :int;
        
        public static const NAME :String = "Server:Board Delta Confirm"; 
        
    }
}