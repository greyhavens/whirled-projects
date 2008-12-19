package flashmob.server {

import com.threerings.util.Log;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.ByteArray;

import flashmob.*;
import flashmob.data.*;

public class ServerSpectaclePlayerMode extends ServerMode
{
    public function ServerSpectaclePlayerMode (ctx :ServerGameContext)
    {
        _ctx = ctx;

        _dataBindings.bindMessage(Constants.MSG_STARTPLAYING, handleStartPlaying);
        _dataBindings.bindMessage(Constants.MSG_SET_SPECTACLE_OFFSET, handleNewSpectacleOffset,
            PatternLoc.fromBytes);
    }

    override public function setup () :void
    {
        updateSpectacleOffset(new PatternLoc());
    }

    protected function handleStartPlaying () :void
    {
        if (_started) {
            log.warning("Received multiple START PLAYING messages");
            return;
        }

        // tell the clients to start playing
        _started = true;
        _ctx.outMsg.sendMessage(Constants.MSG_PLAYNEXTPATTERN);
    }

    protected function handleNewSpectacleOffset (newOffset :PatternLoc) :void
    {
        if (_started) {
            log.warning("Can't set the spectacle offset after the spectacle has started");
            return;
        }

        updateSpectacleOffset(newOffset);
    }

    protected function updateSpectacleOffset (newOffset :PatternLoc) :void
    {
        if (_spectacleOffset == null || !newOffset.isEqual(_spectacleOffset)) {
            _spectacleOffset = newOffset;
            _ctx.props.set(Constants.PROP_SPECTACLE_OFFSET, newOffset.toBytes(), true);
        }
    }

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _ctx :ServerGameContext;
    protected var _started :Boolean;
    protected var _spectacleOffset :PatternLoc;
}

}
