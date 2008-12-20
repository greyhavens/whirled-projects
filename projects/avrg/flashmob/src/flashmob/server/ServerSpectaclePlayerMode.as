package flashmob.server {

import com.threerings.util.Log;

import flashmob.*;
import flashmob.data.*;

public class ServerSpectaclePlayerMode extends ServerMode
{
    public function ServerSpectaclePlayerMode (ctx :ServerGameContext)
    {
        _ctx = ctx;

        _dataBindings.bindMessage(Constants.MSG_STARTPLAYING, handleStartPlaying);
        _dataBindings.bindMessage(Constants.MSG_PATTERNCOMPLETE, handlePatternComplete);
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

        // echo the message back to everyone
        _started = true;
        _patternIndex = 0;
        _ctx.outMsg.sendMessage(Constants.MSG_PLAYNEXTPATTERN);
    }

    protected function handlePatternComplete () :void
    {
        if (!_started || _completed) {
            log.warning("Received bad PATTERN COMPLETE message");
            return;
        }

        ++_patternIndex;
        if (_patternIndex < _ctx.spectacle.numPatterns) {
            _ctx.outMsg.sendMessage(Constants.MSG_PLAYNEXTPATTERN);

        } else {
            _ctx.outMsg.sendMessage(Constants.MSG_PLAYSUCCESS);
            _completed = true;
        }
    }

    protected function handleNewSpectacleOffset (newOffset :PatternLoc) :void
    {
        if (_started) {
            log.warning("Received SPECTACLE OFFSET message after START PLAYING");
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
    protected var _completed :Boolean;
    protected var _spectacleOffset :PatternLoc;
    protected var _patternIndex :int;
}

}
