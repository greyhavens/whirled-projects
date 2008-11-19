package redrover.game.view {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.audio.*;

import redrover.game.*;

public class MusicPlayer extends SimObject
{
    public function MusicPlayer ()
    {
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var musicName :String =
            (GameContext.localPlayer.isOnOwnBoard ? "mus_lsd" : "mus_breakonthrough");

        if (_curMusicName != musicName) {
            // fade the old music out
            if (_musicChannel != null) {
                _musicChannel.audioControls.fadeOut(1).stopAfter(1);
                _musicChannel = null;
            }

            // and the new music in
            _musicChannel = GameContext.playGameMusic(musicName);
            _musicChannel.audioControls.volume(0).fadeIn(0.5);

            _curMusicName = musicName;
        }

    }

    protected var _curMusicName :String;
    protected var _musicChannel :AudioChannel;

}

}
