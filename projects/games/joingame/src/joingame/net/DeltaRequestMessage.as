package joingame.net
{
    import flash.utils.ByteArray;
    
    public class DeltaRequestMessage extends JoinGameMessage
    {
        public function DeltaRequestMessage(playerId:int = -1, fromX :int = -1, fromY :int = -1, toX :int = -1, toY :int = -1)
        {
            super(playerId);
            _fromX = fromX;
            _fromY = fromY;
            _toX = toX;
            _toY = toY;
        }
        
        public function get fromX () :int
        {
            return _fromX;
        }
        
        public function get fromY () :int
        {
            return _fromY;
        }
        
        public function get toX () :int
        {
            return _toX;
        }
        
        public function get toY () :int
        {
            return _toY;
        }
        
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _fromX = bytes.readInt();
            _fromY = bytes.readInt();
            _toX = bytes.readInt();
            _toY = bytes.readInt();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt(_fromX);
            bytes.writeInt(_fromY);
            bytes.writeInt(_toX);
            bytes.writeInt(_toY);
            return bytes;
        }
        
  
        
        
        public function toString() :String
        {
            return NAME + "(" + _fromX + ", " + _fromY + ") -> (" + _toX + ", " + _toY + ")";
        }
        
        protected var _fromX :int;
        protected var _fromY :int;
        protected var _toX :int;
        protected var _toY :int;
        
        
        public static const NAME :String = "Server:Board Delta Request";       
        
         
    }
}