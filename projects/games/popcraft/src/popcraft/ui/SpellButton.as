package popcraft.ui {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;

import popcraft.GameContext;
import popcraft.data.SpellData;

public class SpellButton extends SceneObject
{
    public function SpellButton (spellType :uint, slot :int)
    {
        _spellType = spellType;
        _slot = slot;

        var spellData :SpellData = GameContext.gameData.spells[spellType];

        _movie = SwfResource.instantiateMovieClip("dashboard", spellData.iconName);
        _movie.cacheAsBitmap = true;

        // animate into place
        var xLoc :Number = X_LOCS[slot];

        _movie.x = xLoc;
        _movie.y = Y_START;

        this.addTask(new SerialTask(
            LocationTask.CreateEaseOut(xLoc, Y_BOUNCE, 0.3),
            LocationTask.CreateEaseIn(xLoc, Y_END, 0.1)));
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    public function get clickableObject () :InteractiveObject
    {
        return _movie;
    }

    public function get spellType () :uint
    {
        return _spellType;
    }

    public function get slot () :int
    {
        return _slot;
    }

    protected var _movie :MovieClip;
    protected var _spellType :uint;
    protected var _slot :int;

    protected static const X_LOCS :Array = [ -113, -81, -48, -16, 16, 49, 81, 114 ];
    protected static const Y_START :Number = -47;
    protected static const Y_BOUNCE :Number = -90;
    protected static const Y_END :Number = -87;
}

}
