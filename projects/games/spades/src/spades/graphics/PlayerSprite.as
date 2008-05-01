package spades.graphics {

import com.whirled.contrib.card.TurnTimer;
import com.whirled.contrib.card.Table;
import com.whirled.contrib.card.graphics.PlayerSprite;
import flash.geom.Point;

/** Spades player sprite.
 *  TODO: this is a placeholder, refactor into Resources class */
public class PlayerSprite extends com.whirled.contrib.card.graphics.PlayerSprite
{
    /** Create a new player. */
    public function PlayerSprite (
        table :Table,
        id :int, 
        timer :TurnTimer)
    {
        var team :int = table.getTeamFromId(id).index;
        var timerMovie :Class = TEAM_TIMERS[team] as Class;
        var background :Class = TEAM_IMAGES[team] as Class;
        var colors :Array = TEXT_COLORS[team] as Array;
        var textColor :uint = colors[0] as uint;
        var outlineColor :uint = colors[1] as uint;
        var captionOutlineColor :uint = 
            CAPTION_OUTLINE_COLORS[team] as uint;

        super(table, id, WIDTH, HEIGHT, timer, timerMovie, TIMER_POS, 
            background, textColor, outlineColor, WARNING_COLOR, CAPTION_COLOR,
            captionOutlineColor);
    }

    protected static const WIDTH :int = 165;
    protected static const HEIGHT :int = 115;

    [Embed(source="../../../rsrc/turn_blue.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_0 :Class;

    [Embed(source="../../../rsrc/turn_orange.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_1 :Class;

    [Embed(source="../../../rsrc/clock_blue.swf", mimeType="application/octet-stream")]
    protected static const TIMER_TEAM_0 :Class;

    [Embed(source="../../../rsrc/clock_orange.swf", mimeType="application/octet-stream")]
    protected static const TIMER_TEAM_1 :Class;

    protected static const TEAM_IMAGES :Array = [IMAGE_TEAM_0, IMAGE_TEAM_1];
    protected static const TEAM_TIMERS :Array = [TIMER_TEAM_0, TIMER_TEAM_1];

    protected static const WARNING_COLOR :uint = 0xFF2525;
    protected static const CAPTION_COLOR :uint = 0xFFFFFF;
    protected static const CAPTION_OUTLINE_COLORS :Array = [0x4186Af, 0xA86C04];

    protected static const TEXT_COLORS :Array = [
        [0xB7E8Fb, 0x153741], 
        [0xFFD461, 0x382407]];

    protected static const TIMER_POS :Point = new Point(62, 36);

    protected static const DROP_SHADOW_MAX_ALPHA :Number = 0.5;
}

}
