//
// $Id$

package popcraft.battle.view {

import com.threerings.flashbang.GameObjectRef;
import com.threerings.flashbang.resource.*;
import com.threerings.flashbang.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;

public class SpellDropView extends BattlefieldSprite
{
    public function SpellDropView (spellDrop :SpellDropObject)
    {
        _spellObjRef = spellDrop.ref;

        var spellData :SpellData = spellDrop.spellData;
        _movie = ClientCtx.instantiateMovieClip("infusions", spellData.iconName, true, true);

        // pulse animation, to draw players' attention
        addTask(new RepeatingTask(
            ScaleTask.CreateEaseIn(1.3, 1.3, 0.3),
            ScaleTask.CreateEaseOut(1, 1, 0.3)));
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
        super.destroyed();
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_spellObjRef.isNull) {
            destroySelf();
        }
    }

    protected var _spellObjRef :GameObjectRef;
    protected var _movie :MovieClip;
}

}
