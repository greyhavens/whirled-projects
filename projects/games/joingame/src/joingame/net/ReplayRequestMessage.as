package joingame.net
{
    import flash.utils.ByteArray;
    
    import joingame.UserCookieDataSourcePlayer;
    
    public class ReplayRequestMessage extends UserCookieContainingMessage
    {
        public function ReplayRequestMessage(playerId:int = -1, usercookieData :UserCookieDataSourcePlayer = null, requestedLevel :int = -1)
        {
            super( playerId, usercookieData);
            _requestedLevel = requestedLevel;
        }
        
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _requestedLevel = bytes.readInt();
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt( _requestedLevel);
            return bytes;
        }
        
        public function get requestedLevel () :int
        {
           return _requestedLevel;     
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        protected var _requestedLevel :int;
        public static const NAME :String = "Server:Request Replay";        
    }
}