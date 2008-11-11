package joingame.net
{
    import flash.utils.ByteArray;
    
    import joingame.UserCookieDataSourcePlayer;
    
    public class StartSinglePlayerGameMessage extends UserCookieContainingMessage
    {
        public function StartSinglePlayerGameMessage(playerId:int = -1, gameType :String = "", usercookieData :UserCookieDataSourcePlayer = null)
        {
            super(playerId, usercookieData);
            _gameType = gameType;
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _gameType = bytes.readUTF();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeUTF( _gameType);
            return bytes;
        }
        
        public function get gameType () :String
        {
           return _gameType;     
        }
        
        public function toString() :String
        {
            return NAME + ", gametype=" + _gameType ;
        }
        
        protected var _gameType :String;
        public static const NAME :String = "Server:Start Single Player Game";
        
    }
}