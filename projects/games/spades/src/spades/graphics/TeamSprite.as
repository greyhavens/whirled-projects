package spades.graphics {

import com.whirled.contrib.card.trick.Scores;
import com.whirled.contrib.card.graphics.TeamSprite;
import com.threerings.flash.Vector2;

/** Spades team sprite.
 *  TODO: this is a placeholder, refactor into Resources class */
public class TeamSprite extends com.whirled.contrib.card.graphics.TeamSprite
{
    /** Create a new team sprite. */
    public function TeamSprite (
        scores :Scores,
        team :int,
        lastTrickPos :Vector2)
    {
        var background :Class = TEAM_IMAGES[team] as Class;
        var white :uint = 0xFFFFFF;
        var colors :Array = TEXT_COLORS[team] as Array;
        var color0 :uint = colors[0] as uint;
        var color1 :uint = colors[1] as uint;

        super(scores, team, HEIGHT, lastTrickPos, background, white, color0,
              color1, white, white, color0);
    }

    protected static const WIDTH :int = 180;
    protected static const HEIGHT :int = 80;

    [Embed(source="../../../rsrc/team_blue.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_0 :Class;

    [Embed(source="../../../rsrc/team_orange.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_1 :Class;

    protected static const TEAM_IMAGES :Array = [IMAGE_TEAM_0, IMAGE_TEAM_1];

    // first index is by team, second is 0 for label outline color, 1 for score text color
    protected static const TEXT_COLORS :Array = [
        [0x4186Af, 0x264C62], 
        [0xA86C04, 0x623F26]];
}

}
