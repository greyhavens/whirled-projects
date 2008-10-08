package popcraft.battle.view {

import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.CreatureUnit;

public class DeadCreatureUnitView extends BattlefieldSprite
{
    public function DeadCreatureUnitView (creature :CreatureUnit, facing :int)
    {
        if (Constants.FACING_NE == facing) {
            facing = Constants.FACING_NW;
            _flipX = true;
        } else if (Constants.FACING_SE == facing) {
            facing = Constants.FACING_SW;
            _flipX = true;
        }

        var playerColor :uint = GameContext.gameData.playerColors[creature.owningPlayerIndex];
        var animName :String = "die_" + Constants.FACING_STRINGS[facing];

        _movie = CreatureAnimFactory.instantiateUnitAnimation(creature.unitData, playerColor, animName);
        if (null == _movie) {
            _movie = CreatureAnimFactory.instantiateUnitAnimation(creature.unitData, playerColor, "die");
        }

        this.updateLoc(creature.x, creature.y);

        // when the movie gets to the end, self-destruct
        this.addTask(new SerialTask(new WaitForFrameTask("end"), new SelfDestructTask()));

        GameContext.playGameSound("sfx_death_" + creature.unitData.name);
    }

    override protected function addedToDB () :void
    {
        // BattlefieldSprite will scale us if necessary
        super.addedToDB();

        // flip if necessary
        if (_flipX) {
            _movie.scaleX *= -1;
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;
    protected var _flipX :Boolean;
}

}
