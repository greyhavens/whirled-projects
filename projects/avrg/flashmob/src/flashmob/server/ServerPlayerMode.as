package flashmob.server {

import com.threerings.util.Log;

import flashmob.*;
import flashmob.data.*;

public class ServerPlayerMode extends ServerMode
{
    public function ServerPlayerMode (ctx :ServerGameContext)
    {
        _ctx = ctx;

        _dataBindings.bindMessage(Constants.MSG_C_STARTPLAYING, handleStartPlaying);
        _dataBindings.bindMessage(Constants.MSG_C_PATTERNCOMPLETE, handlePatternComplete);
        _dataBindings.bindMessage(Constants.MSG_C_OUTOFTIME, handleOutOfTime);
        _dataBindings.bindMessage(Constants.MSG_C_PLAYAGAIN, handlePlayAgain);
        _dataBindings.bindMessage(Constants.MSG_C_RESETGAME, handleResetGame);
        _dataBindings.bindMessage(Constants.MSG_CS_SET_SPECTACLE_OFFSET, handleNewSpectacleOffset,
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
        _ctx.outMsg.sendMessage(Constants.MSG_S_PLAYNEXTPATTERN);
    }

    protected function handlePatternComplete () :void
    {
        if (!_started || _completed) {
            log.warning("Received bad PATTERN COMPLETE message");
            return;
        }

        ++_patternIndex;
        if (_patternIndex < _ctx.spectacle.numPatterns) {
            _ctx.outMsg.sendMessage(Constants.MSG_S_PLAYNEXTPATTERN);

        } else {
            _ctx.outMsg.sendMessage(Constants.MSG_S_PLAYSUCCESS);
            _completed = true;
        }
    }

    protected function handleOutOfTime () :void
    {
        if (!_started || _completed) {
            log.warning("Received bad OUT OF TIME message");
            return;
        }

        _completed = true;
        _ctx.outMsg.sendMessage(Constants.MSG_S_PLAYFAIL);
    }

    protected function handlePlayAgain () :void
    {
        _ctx.outMsg.sendMessage(Constants.MSG_S_PLAYAGAIN);
        _started = false;
        _completed = false;
        _patternIndex = 0;
    }

    protected function handleResetGame () :void
    {
        _ctx.game.gameState = Constants.STATE_CHOOSER;
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
