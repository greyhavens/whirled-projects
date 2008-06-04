package popcraft.battle.view {

import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

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
        _movie.cacheAsBitmap = true;
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
