package popcraft.ui {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.CreatureSpellSet;
import popcraft.data.SpellData;

public class SpellButton extends SceneObject
{
    public function SpellButton (spellType :int, slot :int, animateIn :Boolean)
    {
        _spellType = spellType;
        _slot = slot;

        var spellData :SpellData = GameContext.gameData.spells[spellType];

        _movie = SwfResource.instantiateMovieClip("dashboard", spellData.iconName);
        _movie.scaleX = BUTTON_SCALE;
        _movie.scaleY = BUTTON_SCALE;
        _movie.cacheAsBitmap = true;

        var xLoc :Number = X_LOCS[slot];

        if (animateIn) {
            // animate into place

            _movie.x = xLoc;
            _movie.y = Y_START;

            this.addTask(new SerialTask(
                LocationTask.CreateEaseOut(xLoc, Y_BOUNCE, 0.3),
                LocationTask.CreateEaseIn(xLoc, Y_END, 0.1)));
        } else {
            _movie.x = xLoc;
            _movie.y = Y_END;
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    public function get isCastable () :Boolean
    {
        if (_spellType < Constants.CREATURE_SPELL_TYPE__LIMIT) {
            // don't cast creature spells during the day
            if (GameContext.diurnalCycle.isDay) {
                return false;
            }

            // don't allow redundant creature spells
            var playerSpellSet :CreatureSpellSet =
                GameContext.getActiveSpellSet(GameContext.localPlayerIndex);
            if (playerSpellSet.isSpellActive(_spellType)) {
                return false;
            }
        }

        return true;
    }

    public function showUncastableJiggle () :void
    {
        var x :Number = _movie.x;
        var y :Number = _movie.y;

        var jiggleTask :SerialTask = new SerialTask();
        for (var i :int = 0; i < NUM_JIGGLES; ++i) {
            jiggleTask.addTask(LocationTask.CreateSmooth(x + (i % 2 ? 2 : -2), y, 0.07));
        }
        jiggleTask.addTask(LocationTask.CreateSmooth(x, y, 0.1));

        this.addNamedTask(JIGGLE_TASK_NAME, jiggleTask, true);
    }

    public function get clickableObject () :InteractiveObject
    {
        return _movie;
    }

    public function get spellType () :int
    {
        return _spellType;
    }

    public function get slot () :int
    {
        return _slot;
    }

    protected var _movie :MovieClip;
    protected var _spellType :int;
    protected var _slot :int;

    protected static const BUTTON_SCALE :Number = 0.88;
    protected static const X_LOCS :Array = [ -113, -85, -56, -28, 0, 28, 56, 85, 113 ];
    protected static const Y_START :Number = -47;
    protected static const Y_BOUNCE :Number = -90;
    protected static const Y_END :Number = -87;

    protected static const NUM_JIGGLES :int = 5;
    protected static const JIGGLE_TASK_NAME :String = "Jiggle";

}

}
