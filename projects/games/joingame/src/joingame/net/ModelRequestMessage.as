package joingame.net
{
    public class ModelRequestMessage extends JoinGameMessage
    {
        public function ModelRequestMessage(playerId:int = -1)
        {
            super( playerId);
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        

        
        public static const NAME :String = "Server:Model Request"; 
        
    }
}