package joingame.net
{
    import joingame.JoingameServer;
    
    public class PlayerReadyMessage extends JoinGameMessage
    {
        public function PlayerReadyMessage(playerId:int = -1)
        {
            super(playerId);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        

        
//        public static const NAME :String = JoingameServer.PLAYER_READY;
        public static const NAME :String = "Server:Player Ready";
        
    }
}