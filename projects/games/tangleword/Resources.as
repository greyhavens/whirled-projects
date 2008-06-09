package
{

import flash.display.DisplayObject;
import flash.filters.GlowFilter;    
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import mx.core.BitmapAsset;

/** 
 * Storage class for embedded resources; 
 * later it may take over dynamic resources as well. 
 */
public class Resources
{
    // FORMATS

    /** Makes a default format instance. */
    public static function makeDefaultFormat () :TextFormat
    {
        // no css without flex? so sad.
        var format :TextFormat = new TextFormat();
        format.font = "Verdana";
        format.color = uint(0x77aabb);
        format.bold = true;
        return format;
    }        
    
    /** Returns a new instance of text style used for individual letters */
    public static function makeFormatForBoardLetters () :TextFormat
    {
        var format :TextFormat = makeDefaultFormat();
        format.align = TextFormatAlign.CENTER;
        format.bold = false;
        format.size = 42;
        return format;
    }

    /** Returns a new instance of text style used for game messages and UI */
    public static function makeFormatForUI () :TextFormat
    {
        var format :TextFormat = makeDefaultFormat();
        format.size = 18;
        return format;
    }

    /** Returns a new instance of a text style for the logging window */
    public static function makeFormatForLogger () :TextFormat
    {
        var format :TextFormat = makeDefaultFormat();
        format.size = 10;
        format.bold = false;
        return format;
    }

    /** Returns a new instance of a text style for the score window */
    public static function makeFormatForScore () :TextFormat
    {
        var format :TextFormat = makeDefaultFormat();
        format.color = uint(0x77aabb);
        format.size = 12;
        return format;
    }

    /** Returns a new instance of a text style for the countdown timer */
    public static function makeFormatForCountdown () :TextFormat
    {
        var format :TextFormat = makeDefaultFormat();
        format.align = TextFormatAlign.CENTER;
        format.color = uint(0xaa6666);
        format.size = 18;
        return format;
    }

    /** Returns a new instance of a text style for the stats display. */
    public static function makeFormatForStatsWinner () :TextFormat
    {
        var format :TextFormat = makeDefaultFormat();
        format.align = TextFormatAlign.CENTER;
        format.bold = false;
        format.size = 18;
        return format;
    }

    /** Returns a new instance of a text style for the stats display. */
    public static function makeFormatForStatsScore () :TextFormat
    {
        var format :TextFormat = makeFormatForStatsWinner();
        format.size = 16;
        return format;
    }

    /** Returns a new instance of a text style for the stats display. */
    public static function makeFormatForStatsWords () :TextFormat
    {
        var format :TextFormat = makeFormatForStatsWinner();
        format.size = 12;
        return format;
    }

    /** Returns a default border color */
    public static const defaultBorderColor :uint = 0xeeeeff;

    

    // FILTERS

    /** Returns a new instance of a filter suitable for a cursor */
    public static function makeCursorFilter () :GlowFilter
    {
        var filter :GlowFilter = new GlowFilter();
        filter.color = uint(0xeeeeff);
        filter.inner = true;
        return filter;
    }

    /** Returns a new instance of a filter suitable for a selected letter */
    public static function makeSelectedFilter () :GlowFilter
    {
        var filter :GlowFilter = new GlowFilter();
        filter.color = uint(0x446677);
        filter.inner = true;
        filter.blurX = filter.blurY = 32;
        return filter;
    }

    /** Returns a new instance of a filter for rolled-over button */
    public static function makeButtonOverFilter () :GlowFilter
    {
        var filter :GlowFilter = new GlowFilter();
        filter.color = uint(0xeeeeff);
        filter.inner = true;
        filter.blurX = filter.blurY = 8;
        return filter;
    }

    
    // RESOURCE DEFINITIONS

    [Embed(source="rsrc/background.swf")]
    public static const background :Class;
    [Embed(source="rsrc/splash.swf")]
    public static const splash :Class;

//    [Embed(source="rsrc/stats_fg.swf", mimeType="application/octet-stream")]
//    public static const stats_fg :Class;
//    [Embed(source="rsrc/stats_bg.swf", mimeType="application/octet-stream")]
//    public static const stats_bg :Class;

    [Embed(source="rsrc/logo.png")]
    public static const logo :Class;

    [Embed(source="rsrc/square.png")]
    public static const square :Class;

    [Embed(source="rsrc/ok_over.png")]
    public static const buttonOkOver :Class;
    [Embed(source="rsrc/ok.png")]
    public static const buttonOkOut :Class;

    [Embed(source="rsrc/play_over.png")]
    public static const buttonPlayOver :Class;
    [Embed(source="rsrc/play.png")]
    public static const buttonPlayOut :Class;

    [Embed(source="rsrc/help_over.png")]
    public static const buttonHelpOver :Class;
    [Embed(source="rsrc/help.png")]
    public static const buttonHelpOut :Class;
}
} // package
