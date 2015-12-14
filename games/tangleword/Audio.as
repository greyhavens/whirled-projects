package {

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;

import flash.utils.Dictionary;

public class Audio
{

    [Embed(source="rsrc/sound/Tangleword_1.mp3")]
    protected static const MUSIC :Class;
    [Embed(source="rsrc/sound/bubbles.mp3")]
    protected static const BUBBLES :Class;
    [Embed(source="rsrc/sound/click_letter.mp3")]
    protected static const CLICK_LETTER :Class;
    [Embed(source="rsrc/sound/not_on_board_1.mp3")]
    protected static const NOT_ON_BOARD :Class;
    [Embed(source="rsrc/sound/word_on_board.mp3")]
    protected static const WORD_ON_BOARD :Class;
    [Embed(source="rsrc/sound/scroll_over_letter.mp3")]
    protected static const HOVER_LETTER :Class;

    public static const click :Sound = new CLICK_LETTER() as Sound;
    public static const error :Sound = new NOT_ON_BOARD() as Sound;
    public static const success :Sound = new WORD_ON_BOARD() as Sound;
    public static const theme :Sound = new MUSIC() as Sound;
    public static const bubbles :Sound = new BUBBLES() as Sound;
    public static const hover :Sound = new HOVER_LETTER() as Sound;

    public static function playMusic (sound :Sound) :void
    {
        if (_musicChannel != null) {
            _musicChannel.stop();
        }

        _musicChannel = sound.play(0, int.MAX_VALUE);
    }

    public static function stopAll () :void
    {
        _musicChannel.stop();
    }

    protected static var _musicChannel :SoundChannel;
}

}
