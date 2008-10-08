package popcraft.battle.view {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;
import popcraft.util.ImageUtil;

public class UnitAnimationFactory
{
    public static function createBitmapFrames (unitData :UnitData, playerColor :uint,
        animNames :Array) :Array
    {
        var frames :Array = [];
        for each (var animName :String in animNames) {
            var movie :MovieClip = instantiateUnitAnimation(unitData, playerColor, animName);
            frames.push(ImageUtil.createSnapshot(movie));
        }

        return frames;
    }

    public static function instantiateUnitAnimation (unitData :UnitData, playerColor :uint,
        animName :String) :MovieClip
    {
        g_tintMatrix.reset();
        g_tintMatrix.colorize(playerColor);

        var anim :MovieClip = SwfResource.instantiateMovieClip(unitData.name, animName);
        if (null != anim) {
            // colorize the animation's recolor1, recolor2, etc children
            var i :int = 1;
            var success :Boolean;
            do {
                success = colorizeAnimation(anim, "recolor" + i++, g_tintMatrix);
            } while (success);

            colorizeAnimation(anim, "recolor", g_tintMatrix);
        }

        return anim;
    }

    protected static function colorizeAnimation (anim :MovieClip, childName :String,
        tintMatrix :ColorMatrix) :Boolean
    {
        var color :MovieClip = anim[childName];
        if (null != color) {
            color = color["recolor"];
            if (null != color) {
                color.filters = [ tintMatrix.createFilter() ];
            }
        }

        return (null != color);
    }

    protected static var g_tintMatrix :ColorMatrix = new ColorMatrix();
}

}
