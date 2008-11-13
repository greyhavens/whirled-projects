package joingame
{
    import flash.utils.ByteArray;

    public class UserCookieDataSourcePlayer implements UserCookieDataSource
    {
        public function UserCookieDataSourcePlayer()
        {
        }

        public function writeCookieData(cookie:ByteArray):void
        {
            cookie.writeInt( highestRobotLevelDefeated );
            cookie.writeInt( humansDefeated );
            cookie.writeFloat( bestKillsPerDeltaRatio );
        }
        
        public function readCookieData(version:int, cookie:ByteArray):void
        {
            highestRobotLevelDefeated = cookie.readInt();
            humansDefeated = cookie.readInt();
            bestKillsPerDeltaRatio = cookie.readFloat();
        }
        
        public function get minCookieVersion():int
        {
            return 1;
        }
        
        public function cookieReadFailed():Boolean
        {
            return false;
        }
        
        public function clone() : UserCookieDataSourcePlayer
        {
            var cloned :UserCookieDataSourcePlayer = new UserCookieDataSourcePlayer();
            cloned.highestRobotLevelDefeated = this.highestRobotLevelDefeated;
            cloned.humansDefeated = this.humansDefeated;
            cloned.bestKillsPerDeltaRatio = this.bestKillsPerDeltaRatio;
            return cloned;
        }
        
        public function setFrom( newCookie :UserCookieDataSourcePlayer ) :void
        {
            this.highestRobotLevelDefeated = newCookie.highestRobotLevelDefeated;
            this.humansDefeated = newCookie.humansDefeated;
            this.bestKillsPerDeltaRatio = newCookie.bestKillsPerDeltaRatio;
        }
        
        
        public var highestRobotLevelDefeated :int;
        public var humansDefeated :int;
        public var bestKillsPerDeltaRatio :Number;   
        
    }
}