package flashmob.server {

import com.threerings.util.Log;

import flashmob.*;
import flashmob.data.*;

public class ServerWaitingMode extends ServerMode
{
    public function ServerWaitingMode (ctx :ServerGameContext)
    {
        _ctx = ctx;
        _availSpectacles = ServerCtx.spectacleDb.getAvailSpectacles(_ctx.players.numPlayers);
        _ctx.props.set(Constants.PROP_AVAIL_SPECTACLES, _availSpectacles.toBytes());
        log.info("Spectacles available=" + _availSpectacles.spectacles.length +
            " numPlayers=" + _ctx.players.numPlayers);

        _dataBindings.bindMessage(Constants.MSG_C_SELECTED_SPEC, onSelectedSpec);
        _dataBindings.bindMessage(Constants.MSG_C_CREATE_SPEC, onCreateSpec);
    }

    protected function onSelectedSpec (id :int) :void
    {
        var selectedSpec :Spectacle = _availSpectacles.getSpectacle(id);
        if (selectedSpec == null) {
            log.warning("Bad spectacle selected", "id", id);
            return;
        }

        _ctx.spectacle = selectedSpec;
        _ctx.game.gameState = Constants.STATE_PLAYER;
    }

    protected function onCreateSpec () :void
    {
        _ctx.game.gameState = Constants.STATE_CREATOR;
    }

    protected var _ctx :ServerGameContext;
    protected var _availSpectacles :SpectacleSet;

    protected var _lastSnapshotTime :Number = 0;

    protected static var log :Log = Log.getLog(ServerWaitingMode);
}

}
