//
// $Id$

package dictattack {

import flash.text.TextFormat;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;

import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import com.threerings.util.EmbeddedSwfLoader;

[Embed(source="../../rsrc/name_font.ttf", fontName="Name", mimeType="application/x-font-truetype")]

/**
 * Defines skinnable content. TODO: use the right format whenever Ray finally finalizes content
 * packs.
 */
public class Content
{
    /** Defines the dictionary we use for word validation and letter frequency. */
    public static const LOCALE :String = "en-us";

    /** The number of letters along one side of the board. This must be an odd number. */
    public static const BOARD_SIZE :int = 11;

    /** The border around the board in which the shooters reside. */
    public static const BOARD_BORDER :int = 50;

    /** The font used for the letters. */
    public static const FONT_NAME :String = "Verdana";

    /** The point size of our general purpose font. */
    public static const FONT_SIZE :int = 12;

    /** The foreground color of the letters. */
    public static const FONT_COLOR :uint = uint(0x336600);

    /** The foreground color of the letters. */
    public static const LETTER_FONT_COLOR :uint = uint(0xFFFFFF);

    /** The highlighted color of the letters. */
    public static const HIGH_FONT_COLOR :uint = uint(0xFF0000);

    /** The point size of the letters when rendered (TODO: scale?). */
    public static const TILE_FONT_SIZE :int = 12;

    /** The pixels size of the letter tiles (TODO: scale?). */
    public static const TILE_SIZE :int = 30;

    /** The outline colors for our various types of tiles. */
    public static const TILE_OUTLINE_COLORS :Array =
        [ uint(0x000000), uint(0x0066FF), uint(0xFF0033) ];

    /** The pixels size of the shooter. */
    public static const SHOOTER_SIZE :int = 25;

    /** The color of the shooters. */
    public static const SHOOTER_COLOR :Array =
        [ uint(0x6699CC), uint(0x336600), uint(0x996699), uint(0xCC6666) ];

    /** The location and dimensions of the input field. */
    public var inputRect :Rectangle = new Rectangle(100, 470, 250, 20);

    public var invaderColors :Array =
        [ makeTransform(0x99CC66), makeTransform(0x0066FF), makeTransform(0xFF0033) ];

    public function Content (pack :EmbeddedSwfLoader)
    {
        _pack = pack;
    }

    public function createInvader (type :int) :MovieClip
    {
        var suff :String = (type == 0) ? "01" : "03"
        return MovieClip(new (_pack.getClass("space_invader_" + suff))());
    }

    public function createShip () :MovieClip
    {
        return MovieClip(new (_pack.getClass("ship_color"))());
    }

    public function makeInputFormat () :TextFormat
    {
        var format :TextFormat = new TextFormat();
        format.font = FONT_NAME;
        format.color = FONT_COLOR;
        format.size = FONT_SIZE;
        return format;
    }

    public function makeMarqueeFormat () :TextFormat
    {
        var format :TextFormat = new TextFormat();
        format.font = "Name";
        format.bold = true;
        format.color = uint(0x000000);
        format.size = 18;
        return format;
    }

    protected function makeTransform (rgb :int) :ColorTransform
    {
        var red :int = (rgb >> 16) & 0xFF;
        var green :int = (rgb >> 8) & 0xFF;
        var blue :int = (rgb >> 0) & 0xFF;
        return new ColorTransform(red/0xFF, green/0xFF, blue/0xFF);
    }

    protected var _pack :EmbeddedSwfLoader;
}
}
