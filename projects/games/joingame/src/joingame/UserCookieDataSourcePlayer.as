package joingame
{
    import flash.utils.ByteArray;

    public class UserCookieDataSourcePlayer implements UserCookieDataSource
    {
        public function UserCookieDataSourcePlayer()
        {
            highestRobotLevelDefeated = 1;
        }

        public function writeCookieData(cookie:ByteArray):void
        {
            cookie.writeInt( highestRobotLevelDefeated );
            cookie.writeInt( humansDefeated );
            cookie.writeFloat( bestKillsPerDeltaRatio );
        }
        
        public function readCookieData(version:int, cookie:ByteArray):void
        {
            highestRobotLevelDefeated = Math.max(1, cookie.readInt() );
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
            this.highestRobotLevelDefeated = Math.max(1, newCookie.highestRobotLevelDefeated);
            this.humansDefeated = newCookie.humansDefeated;
            this.bestKillsPerDeltaRatio = newCookie.bestKillsPerDeltaRatio;
        }
        
        public function toString() :String
        {
            return "UserCookieDataSourcePlayer: highestRobotLevelDefeated=" + highestRobotLevelDefeated; 
        }
        
        
        public var highestRobotLevelDefeated :int = 1;
        public var humansDefeated :int = 0;
        public var bestKillsPerDeltaRatio :Number = 0;
        
        public var currentDeltas :int = 0;
        public var currentKills :int = 0;   
        
    }
}