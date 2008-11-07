package joingame.net
{
    import com.whirled.game.GameControl;
    
    import joingame.AppContext;
    
    /**
    * Clients only ever send messages to the server, so override the sendMessage method.
    */
    public class JoinMessageManagerClient extends JoinMessageManager
    {
        public function JoinMessageManagerClient( gameControl :GameControl = null )
        {
            super(gameControl);
        }
        
        override public function sendMessage(joingameEvent :JoinGameMessage, toPlayer :int = TO_SERVER_AGENT) :void
        {
            if( !AppContext.useServerAgent ) {
                super.sendMessage(joingameEvent);
            }
            else {
                super.sendMessage( joingameEvent, toPlayer);
//                if( toPlayer == TO_SERVER_AGENT) {
//                    _gameCtrl.net.agent.sendMessage(joingameEvent.type, joingameEvent);
//                }
//                else {
//                    _gameCtrl.net.sendMessage(joingameEvent.type, joingameEvent, toPlayer);
//                }
            }
        }

    }
}