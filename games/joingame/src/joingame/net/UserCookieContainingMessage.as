package joingame.net
{
    import flash.utils.ByteArray;
    
    import joingame.UserCookieDataSourcePlayer;
    
    public class UserCookieContainingMessage extends JoinGameMessage
    {
        public function UserCookieContainingMessage(playerId:int, usercookieData :UserCookieDataSourcePlayer = null)
        {
            super(playerId);
            if( usercookieData == null) {
                _userCookieData = new UserCookieDataSourcePlayer();
                JoinMessageManager.log.warning("UserCookieContainingMessage(), usercookieData is null");
            }   
            else {
                _userCookieData = usercookieData;
            }
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
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
        
        protected var _userCookieData :UserCookieDataSourcePlayer;
        
    }
}