package popcraft.battle.view {

import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;

public class SpellDropView extends SceneObject
{
    public function SpellDropView (spellDrop :SpellDropObject)
    {
        _spellObjRef = spellDrop.ref;

        var spellData :SpellData = spellDrop.spellData;
        _movie = SwfResource.instantiateMovieClip("infusions", spellData.iconName);

        // pulse animation, to draw players' attention
        this.addTask(new RepeatingTask(
            ScaleTask.CreateEaseIn(1.3, 1.3, 0.3),
            ScaleTask.CreateEaseOut(1, 1, 0.3)));
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_spellObjRef.isNull) {
            this.destroySelf();
        }
    }

    protected var _spellObjRef :SimObjectRef;
    protected var _movie :MovieClip;
}

}
