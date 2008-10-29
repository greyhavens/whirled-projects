package {

import flash.media.Sound;
import flash.media.SoundChannel;

public class Audio
{

    [Embed(source="rsrc/sound/Tangleword_1.mp3")]
    protected static const MUSIC :Class;
    [Embed(source="rsrc/sound/click_letter.mp3")]
    protected static const CLICK_LETTER :Class;
    [Embed(source="rsrc/sound/not_on_board_2.mp3")]
    protected static const NOT_ON_BOARD :Class;
    [Embed(source="rsrc/sound/word_on_board.mp3")]
    protected static const WORD_ON_BOARD :Class;

    public static const click :Sound = new CLICK_LETTER() as Sound;
    public static const error :Sound = new NOT_ON_BOARD() as Sound;
    public static const success :Sound = new WORD_ON_BOARD() as Sound;
    public static const theme :Sound = new MUSIC() as Sound;

    public static function playMusic (sound :Sound, gain :Number) :void
    {
        stopMusic();
        _currentMusic = sound.play();
    }

    public static function stopMusic () :void
    {
        if (_currentMusic != null) {
            _currentMusic.stop();
        }
    }

    protected static var _currentMusic :SoundChannel;
}

}
