package joingame.net
{
    import flash.utils.ByteArray;
    
    public class AddPlayerMessage extends JoinGameMessage
    {
        public function AddPlayerMessage(playerId:int = -1, fromServer :Boolean = false, addToLeft :Boolean = false, board :Array = null)
        {
            super(playerId);
            _fromServer = fromServer;
            _board = board;
            _addToLeft = addToLeft;
        }
        
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _fromServer = bytes.readBoolean();
            _addToLeft = bytes.readBoolean();
            _board = bytes.readObject() as Array;
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeBoolean( _fromServer);
            bytes.writeBoolean( _addToLeft);
            bytes.writeObject( _board);
            return bytes;
        }
        
        
        public function get fromServer () :Boolean
        {
            return _fromServer;
        }
        
        public function get board () :Array
        {
            return _board;
        }
        
        public function get addToLeft () :Boolean
        {
            return _addToLeft;
        }
        
        protected var _fromServer :Boolean;
        protected var _board :Array;
        protected var _addToLeft :Boolean;
        
        
        public static const NAME :String = "Server:Add player";        
    }
}