package popcraft.battle.view {

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;

public class CreatureAnimFactory
{
    public static function initAllBitmapAnims (playerColor :uint) :void
    {
        for (var unitType :int = 0; unitType < Constants.PLAYER_CREATURE_UNIT_NAMES.length;
            ++unitType) {

            for (var animName :String in BITMAP_ANIM_DESCS) {
                getBitmapAnim(unitType, playerColor, animName);
            }
        }
    }

    public static function getBitmapAnim (unitType :int, playerColor :uint, animName :String)
        :BitmapAnim
    {
        // get the colorFrameMap, which is a HashMap<playerColor, HashMap<animName, BitmapAnim>>
        var colorFrameMap :HashMap = g_bitmapAnimFrames[unitType];
        if (colorFrameMap == null) {
            colorFrameMap = new HashMap();
            g_bitmapAnimFrames[unitType] = colorFrameMap;
        }

        // get the animMap, which is a HashMap<animName, frameArray>
        var animMap :HashMap = colorFrameMap.get(playerColor);
        if (animMap == null) {
            animMap = new HashMap();
            colorFrameMap.put(playerColor, animMap);
        }

        // get the BitmapAnim for this animation (it might be null, which is ok)
        var animEntry :* = animMap.get(animName);
        var anim :BitmapAnim;
        if (animEntry !== undefined) {
            anim = animEntry as BitmapAnim;

        } else {
            var animMovie :MovieClip = instantiateUnitAnimation(
                GameContext.gameData.units[unitType], playerColor, animName);
            if (animMovie != null) {
                // create the frame array
                var creatureAnimDesc :CreatureBitmapAnimDesc = (BITMAP_ANIM_DESCS[unitType])[animName];
                var frames :Array = [];
                for each (var frameIndex :int in creatureAnimDesc.frameIndexes) {
                    animMovie.gotoAndPlay(frameIndex);
                    frames.push(BitmapAnimFrame.fromDisplayObject(animMovie));
                }

                anim = new BitmapAnim(frames, creatureAnimDesc.frameRate);
                animMap.put(animName, anim);
            }
        }

        return anim;
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

    // Array of HashMap<playerColor, HashMap<animName, frameArray>>
    protected static var g_bitmapAnimFrames :Array =
        ArrayUtil.create(Constants.UNIT_TYPE__CREATURE_LIMIT, null);
    protected static var g_tintMatrix :ColorMatrix = new ColorMatrix();

    protected static const BITMAP_ANIM_DESCS :Array = [
        // Street-Walker
        { attack_N: new CreatureBitmapAnimDesc([ 19, 24, 27 ], 59/60),
          attack_NW: new CreatureBitmapAnimDesc([ 19, 24, 27 ], 59/60),
          attack_S: new CreatureBitmapAnimDesc([ 19, 24, 27 ], 59/60),
          attack_SW: new CreatureBitmapAnimDesc([ 19, 24, 27 ], 59/60),

          die_N: new CreatureBitmapAnimDesc([ 30 ], 1, BitmapAnim.STOP),
          die_NW: new CreatureBitmapAnimDesc([ 30 ], 1, BitmapAnim.STOP),
          die_S: new CreatureBitmapAnimDesc([ 30 ], 1, BitmapAnim.STOP),
          die_SW: new CreatureBitmapAnimDesc([ 30 ], 1, BitmapAnim.STOP),

          stand_N: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_NW: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_S: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_SW: new CreatureBitmapAnimDesc([ 1 ], 1)
        },

        // Handy Man
        { attack_N: new CreatureBitmapAnimDesc([ 19, 24, 27 ], 55/30),
          attack_NW: new CreatureBitmapAnimDesc([ 19, 24, 27 ], 55/30),
          attack_S: new CreatureBitmapAnimDesc([ 19, 24, 27 ], 55/30),
          attack_SW: new CreatureBitmapAnimDesc([ 19, 24, 27 ], 55/30),

          die_N: new CreatureBitmapAnimDesc([ 35 ], 1, BitmapAnim.STOP),
          die_NW: new CreatureBitmapAnimDesc([ 35 ], 1, BitmapAnim.STOP),
          die_S: new CreatureBitmapAnimDesc([ 35 ], 1, BitmapAnim.STOP),
          die_SW: new CreatureBitmapAnimDesc([ 35 ], 1, BitmapAnim.STOP),

          stand_N: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_NW: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_S: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_SW: new CreatureBitmapAnimDesc([ 1 ], 1),

          walk_N: new CreatureBitmapAnimDesc([ 1, 13 ], 1),
          walk_NW: new CreatureBitmapAnimDesc([ 1, 13 ], 1),
          walk_S: new CreatureBitmapAnimDesc([ 1, 13 ], 1),
          walk_SW: new CreatureBitmapAnimDesc([ 1, 13 ], 1)
        },

        // Delivery Boy
        { die_N: new CreatureBitmapAnimDesc([ 4, 7, 13, 20 ], 21/30, BitmapAnim.STOP),
          die_NW: new CreatureBitmapAnimDesc([ 4, 7, 13, 20 ], 21/30, BitmapAnim.STOP),
          die_S: new CreatureBitmapAnimDesc([ 4, 7, 13, 20 ], 21/30, BitmapAnim.STOP),
          die_SW: new CreatureBitmapAnimDesc([ 4, 7, 13, 20 ], 21/30, BitmapAnim.STOP),

          stand_N: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_NW: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_S: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_SW: new CreatureBitmapAnimDesc([ 1 ], 1),

          walk_N: new CreatureBitmapAnimDesc([ 1, 6 ], 15/30),
          walk_NW: new CreatureBitmapAnimDesc([ 1, 6 ], 15/30),
          walk_S: new CreatureBitmapAnimDesc([ 1, 6 ], 15/30),
          walk_SW: new CreatureBitmapAnimDesc([ 1, 6 ], 15/30)
        },

        // Ladyfingers
        { die_N: new CreatureBitmapAnimDesc([ 20 ], 1, BitmapAnim.STOP),
          die_NW: new CreatureBitmapAnimDesc([ 20 ], 1, BitmapAnim.STOP),
          die_S: new CreatureBitmapAnimDesc([ 20 ], 1, BitmapAnim.STOP),
          die_SW: new CreatureBitmapAnimDesc([ 20 ], 1, BitmapAnim.STOP),

          stand_N: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_NW: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_S: new CreatureBitmapAnimDesc([ 1 ], 1),
          stand_SW: new CreatureBitmapAnimDesc([ 1 ], 1),

          walk_N: new CreatureBitmapAnimDesc([ 1, 11, 20 ], 22/30),
          walk_NW: new CreatureBitmapAnimDesc([ 1, 11, 20 ], 22/30),
          walk_S: new CreatureBitmapAnimDesc([ 1, 11, 20 ], 22/30),
          walk_SW: new CreatureBitmapAnimDesc([ 1, 11, 20 ], 22/30)
        },

        // Flesh Behemoth
        { die: new CreatureBitmapAnimDesc([ 5, 16, 33 ], 33/30, BitmapAnim.STOP),

          walk_N: new CreatureBitmapAnimDesc([ 1, 120, 240 ], 252/30),
          walk_NW: new CreatureBitmapAnimDesc([ 1, 11, 20 ], 252/30),
          walk_S: new CreatureBitmapAnimDesc([ 1, 11, 20 ], 252/30),
          walk_SW: new CreatureBitmapAnimDesc([ 1, 11, 20 ], 252/30)
        },

        // Prof. Weardd
        { die: new CreatureBitmapAnimDesc([ 5, 16, 33 ], 33/30, BitmapAnim.STOP),

          walk_N: new CreatureBitmapAnimDesc([ 1, 120, 240 ], 252/30),
          walk_NW: new CreatureBitmapAnimDesc([ 1, 11, 20 ], 252/30),
          walk_S: new CreatureBitmapAnimDesc([ 1, 11, 20 ], 252/30),
          walk_SW: new CreatureBitmapAnimDesc([ 1, 11, 20 ], 252/30)
        }
    ];
}

}
