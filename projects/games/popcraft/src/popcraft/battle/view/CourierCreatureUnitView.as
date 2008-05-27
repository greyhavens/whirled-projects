package popcraft.battle.view {

import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.WaitForFrameTask;

import flash.display.Bitmap;
import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;

public class CourierCreatureUnitView extends CreatureUnitView
{
    public function CourierCreatureUnitView (courier :CourierCreatureUnit)
    {
        super(courier);
        _courier = courier;
    }

    override protected function update (dt :Number) :void
    {
        // if the Courier is carrying a spell, display it
        var carriedSpell :SpellData = _courier.carriedSpell;
        if (null != carriedSpell && null == _carriedSpellIcon) {
            _carriedSpellIcon = ImageResource.instantiateBitmap(carriedSpell.iconName);
            _carriedSpellIcon.y = -_carriedSpellIcon.height;
            _sprite.addChild(_carriedSpellIcon);
        } else if (null == carriedSpell && null != _carriedSpellIcon) {
            _sprite.removeChild(_carriedSpellIcon);
            _carriedSpellIcon = null;
        }

        super.update(dt);
    }

    override protected function setNewAnimation (anim :MovieClip, newViewState :CreatureUnitViewState) :void
    {
        // don't interrupt the courier's movement animation - allow it to play to completion
        // (completion means currentLabel == "end")
        if (_lastViewState.moving) {
            var curAnim :MovieClip = MovieClip(_sprite.getChildAt(0));
            if (curAnim.currentLabel != "end") {
                return;
            }
        }

        super.setNewAnimation(anim, newViewState);
    }

    protected var _courier :CourierCreatureUnit;
    protected var _carriedSpellIcon :Bitmap;

}

}
