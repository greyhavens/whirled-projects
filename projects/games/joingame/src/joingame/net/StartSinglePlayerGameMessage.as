package joingame.net
{
    import flash.utils.ByteArray;
    
    public class StartSinglePlayerGameMessage extends JoinGameMessage
    {
        public function StartSinglePlayerGameMessage(playerId:int = -1, gameType :String = "", level :int = 0)
        {
            super(playerId);
            _gameType = gameType;
            _level = level;
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _level = bytes.readInt();
            _gameType = bytes.readUTF();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt( _level);
            bytes.writeUTF( _gameType);
            return bytes;
        }
        
        public function get gameType () :String
        {
           return _gameType;     
        }
        
        public function get level () :int
        {
           return _level;     
        }

        public function toString() :String
        {
            return NAME + ", gametype=" + _gameType + ", level=" + _level; 
        }
        protected var _level :int;
        protected var _gameType :String;
        public static const NAME :String = "Server:Start Single Player Game";
        
    }
}