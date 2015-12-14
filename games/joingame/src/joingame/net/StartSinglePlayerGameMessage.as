package joingame.net
{
    import flash.utils.ByteArray;
    
    import joingame.UserCookieDataSourcePlayer;
    
    public class StartSinglePlayerGameMessage extends UserCookieContainingMessage
    {
        public function StartSinglePlayerGameMessage(playerId:int = -1, gameType :String = "", usercookieData :UserCookieDataSourcePlayer = null, requestedLevel :int = -1)
        {
            super(playerId, usercookieData);
            _gameType = gameType;
            _requestedLevel = requestedLevel;
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _gameType = bytes.readUTF();
            _requestedLevel = bytes.readInt();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeUTF( _gameType);
            bytes.writeInt( _requestedLevel);
            return bytes;
        }
        
        public function get gameType () :String
        {
           return _gameType;     
        }
        
        public function get requestedLevel () :int
        {
           return _requestedLevel;     
        }
        
        public function toString() :String
        {
            return NAME + ", gametype=" + _gameType ;
        }
        
        protected var _gameType :String;
        protected var _requestedLevel :int;
        public static const NAME :String = "Server:Start Single Player Game";
        
    }
}