package popcraft.battle.view {

import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import popcraft.*;
import popcraft.game.*;
import popcraft.battle.CreatureUnit;
import popcraft.util.PerfMonitor;
import popcraft.util.SpriteUtil;

public class DeadCreatureUnitView extends BattlefieldSprite
{
    public function DeadCreatureUnitView (creature :CreatureUnit, facing :int)
    {
        _sprite = SpriteUtil.createSprite();

        if (Constants.FACING_NE == facing) {
            facing = Constants.FACING_NW;
            _flipX = true;
        } else if (Constants.FACING_SE == facing) {
            facing = Constants.FACING_SW;
            _flipX = true;
        }

        var playerColor :uint = creature.owningPlayerInfo.color;
        var animName :String = "die_" + Constants.FACING_STRINGS[facing];

        var useBitmapAnims :Boolean =
            PerfMonitor.framerate < Constants.BITMAP_DEATH_ANIM_THRESHOLDS[creature.unitType];

        if (useBitmapAnims) {
            var bitmapAnim :BitmapAnim = CreatureAnimFactory.getBitmapAnim(creature.unitType,
                playerColor, animName);
            if (null == bitmapAnim) {
                bitmapAnim = CreatureAnimFactory.getBitmapAnim(creature.unitType, playerColor,
                    "die");
            }

            _bitmapAnimView = new BitmapAnimView(bitmapAnim);
            GameCtx.gameMode.addObject(_bitmapAnimView, _sprite);

            // wait 2 seconds, then self destruct
            addTask(After(2, new SelfDestructTask()));

        } else {
            var movie :MovieClip = CreatureAnimFactory.instantiateUnitAnimation(
                creature.unitType, playerColor, animName);
            if (null == movie) {
                movie = CreatureAnimFactory.instantiateUnitAnimation(
                    creature.unitType, playerColor, "die");
            }

            _sprite.addChild(movie);

            // when the movie gets to the end, self-destruct
            addTask(new SerialTask(
                new WaitForFrameTask("end", movie),
                new SelfDestructTask()));
        }

        updateLoc(creature.x, creature.y);

        GameCtx.playGameSound("sfx_death_" + creature.unitData.name);
    }

    override protected function addedToDB () :void
    {
        // BattlefieldSprite will scale us if necessary
        super.addedToDB();

        // flip if necessary
        if (_flipX) {
            _sprite.scaleX *= -1;
        }
    }

    override protected function removedFromDB () :void
    {
        if (_bitmapAnimView != null) {
            _bitmapAnimView.destroySelf();
        }

        super.removedFromDB();
    }

    override protected function destroyed () :void
    {
        super.destroyed();
        if (_sprite.numChildren > 0) {
            var disp :DisplayObject = _sprite.getChildAt(0);
            if (disp is MovieClip) {
                CreatureAnimFactory.releaseUnitAnimation(disp as MovieClip);
            }
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _bitmapAnimView :BitmapAnimView;
    protected var _flipX :Boolean;
}

}
