//
// $Id$

package dictattack {

import flash.media.Sound;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import com.threerings.util.EmbeddedSwfLoader;

/**
 * Defines skinnable content. TODO: use the right format whenever Ray finally finalizes content
 * packs.
 */
public class Content
{
    /** Defines the dictionary we use for word validation and letter frequency. */
    public static const LOCALE :String = "en-us";

    /** The number of letters along one side of the board. This must be an odd number and correlate
     * with the various board patterns below. */
    public static const BOARD_SIZE :int = 11;

    /** The border around the board in which the shooters reside. */
    public static const BOARD_BORDER :int = 50;

    /** The font used for the letters. */
    public static const FONT_NAME :String = "Verdana";

    /** The point size of our general purpose font. */
    public static const FONT_SIZE :int = 12;

    /** The foreground color of the letters. */
    public static const FONT_COLOR :uint = uint(0xFFFFFF);

    /** The foreground color of the letters. */
    public static const LETTER_FONT_COLOR :uint = uint(0x000000);

    /** The highlighted color of the letters. */
    public static const HIGH_FONT_COLOR :uint = uint(0xFFFFFF);

    /** The point size of the letters when rendered (TODO: scale?). */
    public static const TILE_FONT_SIZE :int = 12;

    /** The pixels size of the letter tiles. This is scaled when the board is initialized. */
    public static var TILE_SIZE :int = 30;

    /** The outline colors for our various types of tiles. */
    public static const TILE_OUTLINE_COLORS :Array =
        [ uint(0x000000), uint(0x0066FF), uint(0xFF0033) ];

    /** The pixels size of the shooter. */
    public static const SHOOTER_SIZE :int = 25;

    /** The color of the shooters. */
    public static const SHOOTER_COLOR :Array =
        [ uint(0x6699CC), uint(0x336600), uint(0x996699), uint(0xCC6666) ];

    /** The location and dimensions of the input field. (y pos is determined automatically) */
    public var inputRect :Rectangle = new Rectangle(170, -1, 150, 20);

    /** The colors of the invaders that comprise a player's active letter set. */
    public var invaderColors :Array = [
        makeXform(0x00CC00), makeXform(0x0066FF), makeXform(0xFF0033) ];

    /** The colors of the invaders on the rest of the board. */
    public var dimInvaderColors :Array = [
        makeXform(0x00CC00, -64), makeXform(0x0066FF, -64), makeXform(0xFF0033, -64) ];

    /** The colors of "ghost" invaders whose normal version have been relocated to the bottom. */
    public var ghostInvaderColors :Array = [
        makeXform(0x00CC00, -128), makeXform(0x0066FF, -128), makeXform(0xFF0033, -128) ];

    /** A selection of single player board patterns. */
    public static const BOARDS_SINGLE :Array = [
        "x.x.x.x.x.x" +
        ".x.x.x.x.x." +
        "x.x.x.x.x.x" +
        ".x.x.x.x.x." +
        "x.x.x.x.x.x" +
        ".x.x.x.x.x." +
        "x.x.x.x.x.x" +
        ".x.x.x.x.x." +
        "x.x.x.x.x.x" +
        ".x.x.x.x.x." +
        "x.x.x.x.x.x",

        ".....x....." +
        "....xxx...." +
        "...xxxxx..." +
        "..xxxxxxx.." +
        ".xxxxxxxxx." +
        "xxxxxxxxxxx" +
        ".xxxxxxxxx." +
        "..xxxxxxx.." +
        "...xxxxx..." +
        "....xxx...." +
        ".....x.....",

        "xxxxxxxxxxx" +
        ".xxxxxxxxx." +
        "..xxxxxxx.." +
        "...xxxxx..." +
        "....xxx...." +
        ".....x....." +
        "....xxx...." +
        "...xxxxx..." +
        "..xxxxxxx.." +
        ".xxxxxxxxx." +
        "xxxxxxxxxxx",

        ".xx.....xx." +
        ".xx.....xx." +
        "...xxxxx..." +
        "..xx.x.xx.." +
        ".xxxxxxxxx." +
        ".xxxxxxxxx." +
        "..xxxxxxx.." +
        "...xxxxx..." +
        "..x.....x.." +
        ".x.......x." +
        ".x.......x.",

        "..xx...xx.." +
        "..xx...xx.." +
        "...xxxxx..." +
        "..xx.x.xx.." +
        ".xxxxxxxxx." +
        ".xxxxxxxxx." +
        "..xxxxxxx.." +
        "...xxxxx..." +
        "...x...x..." +
        ".xxx.xxx..." +
        ".xxx.xxx...",
        ];

    /** A selection of multiplayer board patterns (must be 4 way symmetrical). */
    public static const BOARDS_MULTI :Array = [
        "xxxxxxxxxxx" +
        "xxxxxxxxxxx" +
        "xxxxxxxxxxx" +
        "xxxxxxxxxxx" +
        "xxxxxxxxxxx" +
        "xxxxxxxxxxx" +
        "xxxxxxxxxxx" +
        "xxxxxxxxxxx" +
        "xxxxxxxxxxx" +
        "xxxxxxxxxxx" +
        "xxxxxxxxxxx",

        ".....x....." +
        "....xxx...." +
        "...xxxxx..." +
        "..xxxxxxx.." +
        ".xxxxxxxxx." +
        "xxxxxxxxxxx" +
        ".xxxxxxxxx." +
        "..xxxxxxx.." +
        "...xxxxx..." +
        "....xxx...." +
        ".....x.....",
        ];

    public function Content (pack :EmbeddedSwfLoader)
    {
        _pack = pack;
    }

    public function getShootSound () :Sound
    {
        return SHOOT_SOUND;
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

    public function createSaucer () :MovieClip
    {
        var saucer :MovieClip = MovieClip(new (_pack.getClass("alienship"))());
        saucer.scaleX = 0.3; // TODO: get Bill to redo source
        saucer.scaleY = 0.3;
        return saucer;
    }

    public function createExplosion () :Explosion
    {
        return new Explosion(MovieClip(new (_pack.getClass("explosion"))()));
    }

    public function createWordScoreDisplay () :MovieClip
    {
        var score :MovieClip = MovieClip(new (_pack.getClass("ProgressBar"))());
        score.scaleX = -1; // TODO: get Bill to redo source
        return score;
    }

    public function createRoundScoreIcon () :MovieClip
    {
        return MovieClip(new (_pack.getClass("ProgressIcon"))());
    }

    public function makeInputFormat (color :uint, bold :Boolean = false) :TextFormat
    {
        var format :TextFormat = new TextFormat();
        format.font = FONT_NAME;
        format.color = color;
        format.size = FONT_SIZE;
        format.bold = bold;
        return format;
    }

    public function makeMarqueeFormat (size :int = 16) :TextFormat
    {
        var format :TextFormat = new TextFormat();
        format.font = "Name";
        format.bold = true;
        format.color = FONT_COLOR;
        format.size = size;
        return format;
    }

    public function makeNameFormat () : TextFormat
    {
        var format : TextFormat = new TextFormat();
        format.font = "Name";
        format.color = FONT_COLOR;
        format.size = 16;
        return format;
    }

    public function makeButton (text :String) :SimpleButton
    {
        var button :SimpleButton = new SimpleButton();
        var foreground :int = uint(0xFFFFFF);
        var background :int = uint(0x000000);
        var highlight :int = uint(0x0000FF);
        button.upState = makeFace(text, foreground, background);
        button.overState = makeFace(text, highlight, background);
        button.downState = makeFace(text, background, highlight);
        button.hitTestState = button.upState;
        return button;
    }

    protected function makeFace (text :String, foreground :uint, background :uint) :Sprite
    {
        var face :Sprite = new Sprite();

        // create the label so that we can measure its size
        var label :TextField = new TextField();
        label.textColor = foreground;
        label.autoSize = TextFieldAutoSize.LEFT;
        label.selectable = false;
        label.defaultTextFormat = makeMarqueeFormat(10);
        label.embedFonts = true;
        label.text = text;
        face.addChild(label);

        var padding :int = 5;
        var w :Number = label.width + 2 * padding;
        var h :Number = label.height + 2 * padding;

        // draw our button background (and outline)
        face.graphics.beginFill(background);
        face.graphics.lineStyle(1, foreground);
        face.graphics.drawRect(0, 0, w, h);
        face.graphics.endFill();

        label.x = padding;
        label.y = padding;

        return face;
    }

    protected function makeXform (rgb :int, alphaOffset :Number = 0) :ColorTransform
    {
        var red :int = (rgb >> 16) & 0xFF;
        var green :int = (rgb >> 8) & 0xFF;
        var blue :int = (rgb >> 0) & 0xFF;
        return new ColorTransform(red/0xFF, green/0xFF, blue/0xFF, 1, 0, 0, 0, alphaOffset);
    }

    protected var _pack :EmbeddedSwfLoader;

    [Embed(source="../../rsrc/letter_font.ttf", fontName="Letter",
           mimeType="application/x-font-truetype")]
    protected static var LETTER_FONT :Class;

    [Embed(source="../../rsrc/name_font.ttf", fontName="Name",
           mimeType="application/x-font-truetype")]
    protected static var NAME_FONT :Class;

    // TODO: self and other shooting sounds
    [Embed(source="../../rsrc/shoot.mp3")]
    protected static var SHOOT_CLASS :Class;
    protected static const SHOOT_SOUND :Sound = Sound(new SHOOT_CLASS());
}

}
