package joingame.net
{
    import flash.utils.ByteArray;
    
    import joingame.UserCookieDataSourcePlayer;
    
    public class StartSinglePlayerWaveMessage extends UserCookieContainingMessage
    {
        public function StartSinglePlayerWaveMessage(playerId:int = -1, client :Boolean = false, cookie :UserCookieDataSourcePlayer = null)
        {
            super(playerId, cookie);
            _client = client;
        }
        
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _client = bytes.readBoolean();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeBoolean(_client);
            return bytes;
        }
        
        
        public function toString() :String
        {
            return NAME + " " + playerId;
        }
        
        public function get client () :Boolean
        {
            return _client;
        }
        
        protected var _client :Boolean;
        public static const NAME :String = "Server:Next Single Player Wave";
        
    }
}