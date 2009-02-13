package vampire.feeding.client.view {

import vampire.feeding.client.*;
import vampire.feeding.net.CurrentScoreMsg;

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.net.MessageReceivedEvent;

import flash.display.DisplayObject;
import flash.text.TextField;

public class RemotePlayerScoreView extends SceneObject
{
    public function RemotePlayerScoreView (playerId :int)
    {
        _playerId = playerId;

        _tf = UIBits.createText("");

        updateScore(0);
        registerListener(
            ClientCtx.msgDispatcher,
            MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);
    }

    override public function get displayObject () :DisplayObject
    {
        return _tf;
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        var msg :CurrentScoreMsg = ClientCtx.getMessage(e.name, e.value) as CurrentScoreMsg;
        if (msg != null && msg.playerId == _playerId) {
            updateScore(msg.score);
        }
    }

    protected function updateScore (score :int) :void
    {
        var text :String = ClientCtx.getPlayerName(_playerId) + ": " + score;
        UIBits.initTextField(_tf, text, 1.5, 0, 0x0000ff);
    }

    protected var _playerId :int;

    protected var _tf :TextField;
}

}
