package popcraft.battle.view {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.CreatureUnit;

public class DeadCreatureUnitView extends SceneObject
{
    public function DeadCreatureUnitView (creature :CreatureUnit, facing :int)
    {
        var flipX :Boolean;
        if (Constants.FACING_NE == facing) {
            facing = Constants.FACING_NW;
            flipX = true;
        } else if (Constants.FACING_SE == facing) {
            facing = Constants.FACING_SW;
            flipX = true;
        }

        var playerColor :uint = GameContext.gameData.playerColors[creature.owningPlayerId];
        var animName :String = "die_" + Constants.FACING_STRINGS[facing];

        _movie = UnitAnimationFactory.instantiateUnitAnimation(creature.unitData, playerColor, animName);
        if (null == _movie) {
            _movie = UnitAnimationFactory.instantiateUnitAnimation(creature.unitData, playerColor, "die");
        }

        if (flipX) {
            _movie.scaleX = -1;
        }

        _movie.x = creature.x;
        _movie.y = creature.y;

        // when the movie gets to the end, self-destruct
        this.addTask(new SerialTask(new WaitForFrameTask("end"), new SelfDestructTask()));

        GameContext.playGameSound("sfx_death_" + creature.unitData.name);
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;
}

}
