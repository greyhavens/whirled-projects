//
// $Id$

package ghostbusters {

public class Content
{
    // UI clips
    [Embed(source="../../rsrc/UI/hud_vertical.swf", mimeType="application/octet-stream")]
    public static const HUD_VISUAL :Class;

    [Embed(source="../../rsrc/UI/minigame_frame.swf", mimeType="application/octet-stream")]
    public static const FRAME :Class;

    [Embed(source="../../rsrc/UI/ghost_defeated.swf", mimeType="application/octet-stream")]
    public static const GHOST_DEFEATED :Class;

    [Embed(source="../../rsrc/UI/player_died.swf", mimeType="application/octet-stream")]
    public static const PLAYER_DIED :Class;

    // ghost clips
    [Embed(source="../../rsrc/Ghosts/Ghost_Duchess.swf", mimeType="application/octet-stream")]
    public static const GHOST_DUCHESS :Class;

    [Embed(source="../../rsrc/Ghosts/Ghost_Widow.swf", mimeType="application/octet-stream")]
    public static const GHOST_WIDOW :Class;

    [Embed(source="../../rsrc/Ghosts/Ghost_Pincher.swf", mimeType="application/octet-stream")]
    public static const GHOST_PINCHER :Class;

    [Embed(source="../../rsrc/Ghosts/Ghost_Demon.swf", mimeType="application/octet-stream")]
    public static const GHOST_DEMON :Class;


    // fonts
    [Embed(source="../../rsrc/Fonts/SunnySide.ttf", fontName="SunnySide",
           unicodeRange="U+0020-U+007E,U+2022")]
    public static const FONT_SUNNYSIDE :Class;

    // audio
    [Embed(source="../../rsrc/Sounds/473674_SOUNDDOGS_Am.mp3")]
    public static const LANTERN_LOOP_AUDIO :Class;

    [Embed(source="../../rsrc/Sounds/473674_SOUNDDOGS_Am.mp3")]
    public static const BATTLE_LOOP_AUDIO :Class;

    [Embed(source="../../rsrc/Sounds/143135_SOUNDDOGS_MO_modded.mp3")]
    public static const LANTERN_GHOST_SCREECH :Class;
}
}
