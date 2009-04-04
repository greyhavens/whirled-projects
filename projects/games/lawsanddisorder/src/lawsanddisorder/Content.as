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
    [Embed(source="../../rsrc/TrajanDark.ttf", fontFamily="lawsfont")]
    protected static var LAWS_FONT :Class;
    [Embed(source="../../rsrc/sound/theme_loop.mp3")]
    protected static const THEME_MUSIC_CLASS :Class;
    [Embed(source="../../rsrc/sound/gavel.mp3")]
    protected static const SFX_GAVEL_CLASS :Class;
    [Embed(source="../../rsrc/sound/focus_ding.mp3")]
    protected static const SFX_FOCUS_DING_CLASS :Class;
    [Embed(source="../../rsrc/sound/coinflip.mp3")]
    protected static const SFX_COIN_CLASS :Class;
    [Embed(source="../../rsrc/sound/carddrop.mp3")]
    protected static const SFX_CARD_CLASS :Class;
    [Embed(source="../../rsrc/sound/shuffling.mp3")]
    protected static const SFX_SHUFFLING_CLASS :Class;

    /** Theme music for the game.  Volume controls are in Whirled */
    public static const THEME_MUSIC :Sound = new THEME_MUSIC_CLASS() as Sound;
    
    /** Sound played when any player creates a new law */
    public static const SFX_LAW_CREATED :Sound = new SFX_GAVEL_CLASS() as Sound;
    
    /** Sound played when your turn starts or your input is required */
    public static const SFX_FOCUS_DING :Sound = new SFX_FOCUS_DING_CLASS() as Sound;
    
    /** Sound played when any player uses their power */
    public static const SFX_POWER_USED :Sound = null;
    
    /** Sound played when the game begins and music starts. */
    public static const SFX_GAME_START :Sound = new SFX_SHUFFLING_CLASS() as Sound;
    
    /** Sound played when the game is almost over. */
    public static const SFX_DECK_NEAR_EMPTY :Sound = new SFX_SHUFFLING_CLASS() as Sound;
    
    /** Sound played when the game ends and the music stops. */
    public static const SFX_GAME_OVER :Sound = new SFX_SHUFFLING_CLASS() as Sound;
    
    /** Sound played when you get coins */
    public static const SFX_COINS_GAINED :Sound = new SFX_COIN_CLASS() as Sound;
    
    /** Sound played when you lose coins */
    public static const SFX_COINS_LOST :Sound = new SFX_COIN_CLASS() as Sound;
    
    /** Sound played when one or more cards is added to your hand */
    public static const SFX_CARDS_GAINED :Sound = new SFX_CARD_CLASS() as Sound;
    
    /** Sound played when one or more cards is removed from your hand */
    public static const SFX_CARDS_LOST :Sound = new SFX_CARD_CLASS() as Sound;
    
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
     * Plays a sound effect a single time.  Will NOT stop any sfx currently running.
     */
    public static function playSound (sound :Sound) :void
    {
    	if (sound == null) {
    		return;
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