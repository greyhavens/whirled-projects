package vampire.net {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.AbstractControl;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import vampire.net.messages.BloodBondRequestMessage;
import vampire.net.messages.FeedRequestMessage;
import vampire.net.messages.RequestActionChangeMessage;


public class MessageManager extends EventDispatcher
{
    internal static const log :Log = Log.getLog(MessageManager);
    
    protected var _isUsingServerAgent :Boolean;
    
    public function MessageManager (gameCtrl :AbstractControl = null, isUsingServerAgent :Boolean = true)
    {
        _msgTypes = new HashMap();
        _isUsingServerAgent = isUsingServerAgent;
        
        _gameCtrl = gameCtrl;
        if( _gameCtrl != null && _gameCtrl.isConnected() && _isUsingServerAgent) {
            
            if( _gameCtrl is GameControl) {
                log.info("MessageManager listening to GameControl.");
                (_gameCtrl as GameControl).net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMessageReceived);
            }
            else if(_gameCtrl is AVRServerGameControl){
                log.info("MessageManager listening to AVRServerGameControl.game.");
                (_gameCtrl as AVRServerGameControl).game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMessageReceived);
            }
            else if(_gameCtrl is AVRGameControl){
                log.info("MessageManager listening to AVRGameControl.game.");
                (_gameCtrl as AVRGameControl).game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMessageReceived);
            }
            
            else {
                log.error("MessageManager, _gameCtrl neither GameControl, AVRGameControl, nor AVRServerGameControl.  No listeners.");
            }
        }
        else {
            log.warning("MessageManager is not using any GameControl (or AVRG) type messaging.  Local messages only.");
        }
        
        //Move this out of here!  But to where???
        addMessageType( RequestActionChangeMessage );
        addMessageType( BloodBondRequestMessage );
        addMessageType( FeedRequestMessage );
        
        
    }

    public function addMessageType (messageClass :Class) :void
    {
        if (_msgTypes.put(messageClass.NAME, messageClass) !== undefined) {
            throw new Error("can't add duplicate '" + messageClass.NAME + "' message type");
        }
    }

    public function sendMessage( gameEvent :IGameMessage, toPlayer :int = TO_ALL) :void
    {
        
        log.debug("attempting to send message " + gameEvent);
        
        if (_msgTypes.get(gameEvent.name) == null) {
            log.error("sendMessage(), unknown message type: " + gameEvent);
        }
        
        if( !_isUsingServerAgent ) {//GameControl-less local testing.  Faster for development
            log.debug("     sending locally ");
            var msgClass :Class = _msgTypes.get(gameEvent.name);
            var messageToSend :IGameMessage = new msgClass();
//            trace("creating new message type: " + messageToSend.name);
            var bytes :ByteArray = gameEvent.toBytes();
            bytes.position = 0;
            messageToSend.fromBytes( bytes );
//            trace("Message sent=" + messageToSend);
            dispatchEvent(new MessageReceivedEvent(messageToSend.name, messageToSend, 0));
//            dispatchEvent(new MessageReceivedEvent(messageToSend.name, messageToSend, 0));
        }
        else {
            if( _gameCtrl is GameControl) {
                log.debug("     sending via GameControl, toPlayer=" + toPlayer);
                (_gameCtrl as GameControl).net.sendMessage(gameEvent.name, gameEvent.toBytes());
            }
            else if(_gameCtrl is AVRServerGameControl){
                log.debug("     sending via AVRServerGameControl (to clients)");
                (_gameCtrl as AVRServerGameControl).game.sendMessage(gameEvent.name, gameEvent.toBytes());
            }
            else if(_gameCtrl is AVRGameControl){
                log.debug("     sending via AVRGameControl (to agent)");
                (_gameCtrl as AVRGameControl).agent.sendMessage(gameEvent.name, gameEvent.toBytes());
            }
            else {
                log.error("sendMessage(), _gameCtrl neither GameControl, AVRGameControl, nor AVRServerGameControl.  Message not sent.");
            }
        }
    }

    /**
    * If we are communicating with a server agent over the internet, messages are 
    * converted to ByteArrays to save bandwidth.  If the server is local, we
    * just leave the messages as they are.
    * 
    */
    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        trace("onMessageReceived(): " + e);
        var msgClass :Class = _msgTypes.get(e.name);
        if (msgClass != null) {
            
            var msg :IGameMessage = new msgClass();
            msg.fromBytes( e.value as ByteArray );
            if(msg == null) {
                throw Error("Message Error");
            }
            log.debug("onMessageReceived(): dispatching message to listeners=" + e.name);
            dispatchEvent(new MessageReceivedEvent(msg.name, msg, e.senderId));            
        }
        else {
            log.error("onMessageReceived(): unknown message type=" + e.name);
            dispatchEvent(new MessageReceivedEvent(e.name, e.value, e.senderId));
        }
        
    }

    protected var _gameCtrl :AbstractControl ;
    protected var _msgTypes :HashMap;
    
    public static const TO_ALL :int = 0;//NetSubControl.TO_ALL;
    public static const TO_SERVER_AGENT :int = int.MIN_VALUE;;//NetSubControl.TO_SERVER_AGENT;
}

}
