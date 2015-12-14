package joingame.net
{
    import joingame.UserCookieDataSourcePlayer;

    public class WaveDefeatedMessage extends UserCookieContainingMessage
    {
        public function WaveDefeatedMessage( usercookieData:UserCookieDataSourcePlayer=null)
        {
            super(-1, usercookieData);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        public static const NAME :String = "Server:Wave Defeated";
    }
}