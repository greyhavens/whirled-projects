package joingame.net
{
    public class GoToObserverModeMessage extends JoinGameMessage
    {
        public function GoToObserverModeMessage(playerId:int = -1)
        {
            super(playerId);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        public static const NAME :String = "Server:Go To Observer Mode";
        
    }
}