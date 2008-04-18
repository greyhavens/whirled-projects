package popcraft.battle.view {

import com.whirled.contrib.ColorMatrix;

import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.*;

public class UnitAnimationFactory
{
    public static function instantiateUnitAnimation (unitData :UnitData, playerColor :uint, animName :String) :MovieClip
    {
        g_tintMatrix.reset();
        g_tintMatrix.colorize(playerColor);

        var anim :MovieClip = AppContext.instantiateMovieClip(unitData.name, animName);
        if (null != anim) {
            // colorize
            var color :MovieClip = anim.recolor;
            if (null != color && null != color.recolor) {
                color = color.recolor;
            }

            if (null != color) {
                color.filters = [ g_tintMatrix.createFilter() ];
            }
        }

        return anim;
    }

    protected static var g_tintMatrix :ColorMatrix = new ColorMatrix();
}

}
