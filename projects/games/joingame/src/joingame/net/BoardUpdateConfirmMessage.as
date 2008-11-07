package joingame.net
{
    import flash.utils.ByteArray;
    
    public class BoardUpdateConfirmMessage extends JoinGameMessage
    {
        public function BoardUpdateConfirmMessage(playerId:int = 1, boardId :int = -1, board :Array = null)
        {
            super(playerId);
            _boardId = boardId;
            _board = board;
        }
        
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _boardId = bytes.readInt();
            _board = bytes.readObject() as Array;
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt(_boardId);
            bytes.writeObject( _board);
            return bytes;
        }
        
        
        public function get boardId () :int
        { 
            return _boardId; 
        }
        
        public function get board () :Array
        { 
            return _board; 
        }
        
        protected var _boardId :int;
        protected var _board :Array;
        
        public static const NAME :String = "Server:Board Update Confirm"; 
    }
}