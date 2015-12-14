package joingame.net {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import joingame.AppContext;


/**
 * All internal and external messages are funneled through this class.  This allows us to have a 
 * local server class that does not use the GameControl stuff, allowing faster testing.
 * 
 * Also, in game communication is cleaner as message events are now named appropriately.
 */
public class JoinMessageManager extends EventDispatcher
{
    internal static const log :Log = Log.getLog(JoinMessageManager);
    
    public function JoinMessageManager (gameCtrl :GameControl = null)
    {
        _msgTypes = new HashMap();
        
        _gameCtrl = gameCtrl;
        if( _gameCtrl != null && _gameCtrl.isConnected() && AppContext.useServerAgent) {
            _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMessageReceived);
        }
        
        //Move this out of here!
        addMessageType( AddPlayerMessage );
        addMessageType( AllPlayersReadyMessage );
        addMessageType( BoardRowRemoveConfirmtoServer );
        addMessageType( BoardUpdateConfirmMessage );
        addMessageType( BoardUpdateRequestMessage );
        addMessageType( BottomRowRemovalConfirmMessage );
        addMessageType( BottomRowRemovalRequestMessage );
        addMessageType( DeltaConfirmMessage );
        addMessageType( DeltaRequestMessage );
        addMessageType( GameOverMessage );
        addMessageType( GoToObserverModeMessage );
        addMessageType( ModelConfirmMessage );
        addMessageType( ModelRequestMessage );
        addMessageType( PlayerDestroyedMessage );
        addMessageType( PlayerReadyMessage );
        addMessageType( PlayerReceivedGameStateMessage );
        addMessageType( PlayerRemovedMessage );
        addMessageType( RegisterPlayerMessage );
        addMessageType( ReplayConfirmMessage );
        addMessageType( ReplayRequestMessage );
        addMessageType( ResetViewToModelMessage );
        addMessageType( StartPlayMessage );
        addMessageType( StartSinglePlayerGameMessage );
        addMessageType( StartSinglePlayerWaveMessage );
        addMessageType( WaveDefeatedMessage );
        
    }

    public function addMessageType (messageClass :Class) :void
    {
        if (_msgTypes.put(messageClass.NAME, messageClass) !== undefined) {
            throw new Error("can't add duplicate '" + messageClass.NAME + "' message type");
        }
    }

    public function sendMessage(joingameEvent :JoinGameMessage, toPlayer :int = TO_ALL) :void
    {
        log.debug("attempting to send message " + joingameEvent.name);
        if( !AppContext.useServerAgent ) {//GameControl-less local testing.  Faster for development
            dispatchEvent(new MessageReceivedEvent(joingameEvent.name, joingameEvent, 0));
        }
        else {
            _gameCtrl.net.sendMessage(joingameEvent.name, joingameEvent.toBytes(), toPlayer);
        }
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        var msgClass :Class = _msgTypes.get(e.name);
        if (msgClass != null) {
            
            var msg :IJoinGameMessage = new msgClass();
            msg.fromBytes( e.value as ByteArray );
            if(msg == null) {
                throw Error("Message Error");
            }
            dispatchEvent(new MessageReceivedEvent(MessageReceivedEvent.MESSAGE_RECEIVED, msg, e.senderId));            
        }
        else {
            log.error("onMessageReceived(): unknown message type=" + e.name);
        }
    }

    protected var _gameCtrl :GameControl;
    protected var _msgTypes :HashMap;
    
    protected static const TO_ALL :int = 0;//NetSubControl.TO_ALL;
    protected static const TO_SERVER_AGENT :int = int.MIN_VALUE;;//NetSubControl.TO_SERVER_AGENT;
    
    
}

}
