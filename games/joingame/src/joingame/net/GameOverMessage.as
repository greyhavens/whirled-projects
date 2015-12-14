package joingame.net
{
    import flash.utils.ByteArray;
    
    import joingame.UserCookieDataSourcePlayer;
    
    public class GameOverMessage extends JoinGameMessage
    {
        public function GameOverMessage( usercookieData :UserCookieDataSourcePlayer = null)//toObserverState :Boolean = true)
        {
            super(-1);
            if( usercookieData == null) {
                _userCookieData = new UserCookieDataSourcePlayer();
            }   
            else {
                _userCookieData = usercookieData;
            }   
        }
        
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _userCookieData = new UserCookieDataSourcePlayer();
            _userCookieData.readCookieData(1, bytes);
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            _userCookieData.writeCookieData(bytes);
            return bytes;
        }
        public function get userCookieData () :UserCookieDataSourcePlayer
        {
           return _userCookieData;     
        }


        override public function get name () :String
        {
           return NAME;     
        }
        
        
        protected var _userCookieData :UserCookieDataSourcePlayer;

        public static const NAME :String = "Server:Game Over";   
    }
}