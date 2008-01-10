//
// $Id$

package ghostbusters {

public class Content
{
    // clips
    [Embed(source="../../rsrc/HUD_visual.swf", mimeType="application/octet-stream")]
    public static const HUD_VISUAL :Class;

    [Embed(source="../../rsrc/Ghost_3.swf", mimeType="application/octet-stream")]
    public static const GHOST :Class;

    [Embed(source="../../rsrc/text_box.swf", mimeType="application/octet-stream")]
    public static const TEXT_BOX :Class;

    [Embed(source="../../rsrc/splash01.swf")]
    public static const SPLASH :Class;

    [Embed(source="../../rsrc/minigame_border.swf", mimeType="application/octet-stream")]
    public static const FRAME :Class;

    [Embed(source="../../rsrc/capturebar.swf", mimeType="application/octet-stream")]
    public static const CAPTURE_BAR :Class;

    // fonts
    [Embed(source="../../rsrc/SunnySide.ttf", fontName="SunnySide",
           unicodeRange="U+0020-U+007E,U+2022")]
    public static const FONT_SUNNYSIDE :Class;

    // audio
    [Embed(source="../../rsrc/473674_SOUNDDOGS_Am.mp3")]
    public static const LANTERN_LOOP_AUDIO :Class;

    [Embed(source="../../rsrc/473674_SOUNDDOGS_Am.mp3")]
    public static const BATTLE_LOOP_AUDIO :Class;

    [Embed(source="../../rsrc/143135_SOUNDDOGS_MO_modded.mp3")]
    public static const LANTERN_GHOST_SCREECH :Class;
}
}
