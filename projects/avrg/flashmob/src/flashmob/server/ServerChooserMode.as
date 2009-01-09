package flashmob.server {

import com.threerings.util.Log;

import flashmob.*;
import flashmob.data.*;

public class ServerChooserMode extends ServerMode
{
    public function ServerChooserMode (ctx :ServerGameContext)
    {
        _ctx = ctx;
        _availSpectacles = ServerContext.spectacleDb.getAvailSpectacles(_ctx.numPlayers);

        _ctx.props.set(Constants.PROP_AVAIL_SPECTACLES, _availSpectacles.toBytes());

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

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _ctx :ServerGameContext;
    protected var _availSpectacles :SpectacleSet;

    protected var _lastSnapshotTime :Number = 0;
}

}
