package redrover.game.view {

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.audio.*;

import redrover.*;
import redrover.game.*;

public class MusicPlayer extends GameObject
{
    public function MusicPlayer ()
    {
        // start our music in the paused state
        _myTeamControls = new AudioControls(GameCtx.musicControls).pause(true);
        _otherTeamControls = new AudioControls(GameCtx.musicControls).pause(true);

        _myTeamControls.retain();
        _otherTeamControls.retain();

        ClientCtx.audio.playSoundNamed("mus_pepperland", _myTeamControls,
            AudioManager.LOOP_FOREVER);
        ClientCtx.audio..playSoundNamed("mus_motm", _otherTeamControls,
            AudioManager.LOOP_FOREVER);
    }

    override protected function destroyed () :void
    {
        _myTeamControls.stop(true);
        _otherTeamControls.stop(true);

        _myTeamControls.release();
        _otherTeamControls.release();
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var newControls :AudioControls = (GameCtx.localPlayer.isOnOwnBoard ?
            _myTeamControls : _otherTeamControls);

        if (newControls != _curControls) {
            if (_curControls != null) {
                _curControls.fadeOut(1).pauseAfter(1);
                newControls.pause(false).volume(0).fadeIn(1);
            } else {
                newControls.pause(false).volume(1);
            }

            _curControls = newControls;
        }
    }

    protected var _curMusicName :String;
    protected var _musicChannel :AudioChannel;

    protected var _myTeamControls :AudioControls;
    protected var _otherTeamControls :AudioControls;
    protected var _curControls :AudioControls;
}

}
