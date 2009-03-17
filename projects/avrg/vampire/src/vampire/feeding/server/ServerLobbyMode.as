package vampire.feeding.server {

import com.whirled.contrib.simplegame.net.Message;

import vampire.feeding.net.*;

public class ServerLobbyMode extends ServerMode
{
    public function ServerLobbyMode (ctx :ServerCtx)
    {
        super(ctx);
    }

    override public function onMsgReceived (senderId :int, msg :Message) :Boolean
    {
        if (msg is CloseLobbyMsg) {
            if (senderId != _ctx.getPrimaryPredatorId()) {
                _ctx.logBadMessage(senderId, msg.name, "player is not the lobby leader");
            } else {
                _ctx.server.closeLobby();
            }

            return true;
        }

        return false;
    }

}

}
