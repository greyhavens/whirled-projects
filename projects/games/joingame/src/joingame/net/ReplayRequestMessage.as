package joingame.net
{
    import joingame.UserCookieDataSourcePlayer;
    
    public class ReplayRequestMessage extends UserCookieContainingMessage
    {
        public function ReplayRequestMessage(playerId:int = -1, usercookieData :UserCookieDataSourcePlayer = null)
        {
            super( playerId, usercookieData);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }

        public static const NAME :String = "Server:Request Replay";        
    }
}