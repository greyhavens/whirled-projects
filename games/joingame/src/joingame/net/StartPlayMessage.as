package joingame.net
{
    import com.whirled.game.NetSubControl;
    
    public class StartPlayMessage extends JoinGameMessage
    {
        public function StartPlayMessage()
        {
            super( NetSubControl.TO_SERVER_AGENT);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        
        
        
        public static const NAME :String = "Server:Start Play";        
    }
}