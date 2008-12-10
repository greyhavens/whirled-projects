package redrover.game.view {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.audio.*;

import redrover.game.*;

public class MusicPlayer extends SimObject
{
    public function MusicPlayer ()
    {
        // start our music in the paused state
        _myTeamControls = new AudioControls(GameContext.musicControls).pause(true);
        _otherTeamControls = new AudioControls(GameContext.musicControls).pause(true);

        _myTeamControls.retain();
        _otherTeamControls.retain();

        AudioManager.instance.playSoundNamed("mus_lsd", _myTeamControls, AudioManager.LOOP_FOREVER);
        AudioManager.instance.playSoundNamed("mus_breakonthrough", _otherTeamControls,
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

        var newControls :AudioControls = (GameContext.localPlayer.isOnOwnBoard ?
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
