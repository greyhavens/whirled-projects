package popcraft.battle.view {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

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

        var movie :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(creature.unitData, playerColor, animName);

        if (null != movie) {
            if (flipX) {
                movie.scaleX = -1;
            }

            movie.x = creature.x;
            movie.y = creature.y;

            _displayObj = movie;
        } else {
            // if we don't have a movie, prevent crashes by creating a dummy sprite
            _displayObj = new Sprite();
        }

        this.addTask(After(2, new SelfDestructTask()));
    }

    override public function get displayObject () :DisplayObject
    {
        return _displayObj;
    }

    protected var _displayObj :DisplayObject;
}

}
