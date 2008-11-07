package joingame.net
{
    import flash.utils.ByteArray;
    
    public class BoardUpdateRequestMessage extends JoinGameMessage
    {
        public function BoardUpdateRequestMessage(playerId:int = -1, boardId :int = -1)
        {
            super(playerId);
            _boardId = boardId;
        }
        
        public function get boardId () :int
        { 
            return _boardId; 
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _boardId = bytes.readInt();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt(_boardId);
            return bytes;
        }
        
        protected var _boardId :int;
        
        public static const NAME :String = "Server:Board Update Request";        
    }
}