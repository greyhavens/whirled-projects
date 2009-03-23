package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;

import vampire.feeding.*;

public class SpecialStrainTallyView extends SceneObject
{
    public function SpecialStrainTallyView (type :int, initialStrainCount :int)
    {
        _type = type;
        _movie = ClientCtx.instantiateMovieClip("blood", "strain_tally");
        for (var ii :int = 0; ii < initialStrainCount; ++ii) {
            incrementStrainCount(false);
        }
    }

    public function playGotStrainAnim (x :int, y :int) :void
    {
        incrementStrainCount(true, new Point(x, y));
    }

    public function incrementStrainCount (animate :Boolean, startLoc :Point = null) :void
    {
        if (_strainCount >= SLOT_NAMES.length) {
            return;
        }

        var anim :GotSpecialStrainAnim = new GotSpecialStrainAnim(_type);
        GameCtx.gameMode.addSceneObject(anim, _movie);

        var slotMovie :MovieClip = _movie[SLOT_NAMES[_strainCount]];

        if (animate) {
            startLoc = _movie.globalToLocal(startLoc);
            anim.x = startLoc.x;
            anim.y = startLoc.y;
            anim.animate(new Point(slotMovie.x, slotMovie.y));
        } else {
            anim.x = slotMovie.x;
            anim.y = slotMovie.y;
            anim.scaleX = anim.scaleY = CELL_SCALE;
        }

        _strainCount++;
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _type :int;
    protected var _movie :MovieClip;
    protected var _strainCount :int;

    protected static const SLOT_NAMES :Array = [ "slot_01", "slot_02", "slot_03" ];
}

}

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.feeding.*;
import vampire.feeding.client.*;
import flash.geom.Point;
import flash.events.Event;

const CELL_SCALE :Number = 0.6;

class GotSpecialStrainAnim
    extends SceneObject
{
    public function GotSpecialStrainAnim (strain :int)
    {
        _strain = strain;
        _movie = ClientCtx.createSpecialStrainMovie(strain);
    }

    public function animate (end :Point) :void
    {
        _movie.gotoAndPlay(2);
        addTask(new SerialTask(
            new PlaySoundTask("sfx_got_special_strain"),
            new WaitForFrameTask(55, _movie),
            LocationTask.CreateSmooth(end.x, end.y, 1.25),
            new ScaleTask(CELL_SCALE, CELL_SCALE, 0.5),
            new GoToFrameTask(1, null, false)));
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;
    protected var _strain :int;
}
