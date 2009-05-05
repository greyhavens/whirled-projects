package vampire.feeding.server {

import com.whirled.contrib.simplegame.net.Message;

import vampire.feeding.*;
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
            if (senderId != _ctx.lobbyLeader) {
                _ctx.logBadMessage(log, senderId, msg.name, "player is not the lobby leader");
            } else if (!_ctx.preyIsAi && _ctx.preyId == Constants.NULL_PLAYER) {
                _ctx.logBadMessage(log, senderId, msg.name,
                    "The prey has left; the game can't start.");
            } else {
                _ctx.server.setMode(Constants.MODE_PLAYING);
            }

            return true;
        }

        return false;
    }

    override public function get modeName () :String
    {
        return Constants.MODE_LOBBY;
    }
}

}
