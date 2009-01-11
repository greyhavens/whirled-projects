package lawsanddisorder {

import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.media.Sound;
import flash.media.SoundChannel;

/**
 * Static helper functions for defining styles common to multiple components.
 */
public class Content
{
    [Embed(source="../../rsrc/symbols.swf#monieback")]
    public static const MONIE_BACK :Class;

    [Embed(source="../../rsrc/symbols.swf#cardback")]
    public static const CARD_BACK :Class;
    
    /** Embed the font used for everything */
    [Embed(source="../../rsrc/TrajanDark.ttf", fontFamily="lawsfont")]
    protected static var LAWS_FONT :Class;
    
    [Embed(source="../../rsrc/sound/theme_loop.mp3")]
    protected static const THEME_MUSIC_CLASS :Class;
    
    [Embed(source="../../rsrc/sound/gavel.mp3")]
    protected static const SFX_GAVEL_CLASS :Class;
    
    [Embed(source="../../rsrc/sound/focus_ding.mp3")]
    protected static const SFX_FOCUS_DING_CLASS :Class;

    public static const THEME_MUSIC :Sound = new THEME_MUSIC_CLASS() as Sound;
    public static const SFX_LAW_CREATED :Sound = new SFX_GAVEL_CLASS() as Sound;
    public static const SFX_FOCUS_DING :Sound = new SFX_FOCUS_DING_CLASS() as Sound;
    public static const SFX_POWER_USED :Sound = new SFX_GAVEL_CLASS() as Sound;
    public static const SFX_GAME_OVER :Sound = new SFX_GAVEL_CLASS() as Sound;
    
    /**
     * Return a string like "a card" or "3 cards".
     */
    public static function cardCount (count :int) :String
    {
        if (count == 0) {
            return "no cards";
        } else if (count == 1) {
            return "a card";
        } else {
            return count + " cards";
        }
    }
    
    /**
     * Return a string like "no monies" or "3 monies".
     */
    public static function monieCount (count :int) :String
    {
        if (count == 0) {
            return "no monies";
        } else if (count == 1) {
            return "1 monie";
        } else {
            return count + " monies";
        }
    }
    
    /**
     * Build and return a new text field with default style and format.
     * If percentSize is given, the font will default to that percentage of the default font size.
     */
    public static function defaultTextField (
        percentSize :Number = 1, align :String = "center") :TextField
    {
        var field :TextField = new TextField();
        field.defaultTextFormat = defaultTextFormat(percentSize, align);
        field.antiAliasType = AntiAliasType.ADVANCED;
        field.embedFonts = true;
        field.mouseEnabled = false;
        field.wordWrap = true;

        return field;
    }

    /**
     * Build and return a new text format with default settings
     */
    protected static function defaultTextFormat (percentSize :Number, align :String) :TextFormat
    {
        var format :TextFormat = new TextFormat();
        format.align = align;
        format.font = "lawsfont";
        format.size = Math.round(10 * percentSize);
        format.bold = true;

        return format;
    }
    
    /**
     * Plays a sound effect a single time.  Will stop any sfx currently running.
     */
    public static function playSound (sound :Sound) :void
    {
        if (_sfxChannel != null) {
            _sfxChannel.stop();
        }
        _sfxChannel = sound.play(0, 0);
    }

    /**
     * Begins to play a music loop.  Will stop any other music currently playing.
     */
    public static function playMusic (sound :Sound) :void
    {
        if (_musicChannel != null) {
            _musicChannel.stop();
        }
        _musicChannel = sound.play(0, int.MAX_VALUE);
    }
    
    /**
     * Immediately halt any looping music that is playing.
     */
    public static function stopMusic () :void
    {
        if (_musicChannel != null) {
            _musicChannel.stop();
        }
    }

    protected static var _musicChannel :SoundChannel;
    protected static var _sfxChannel :SoundChannel;
}
}