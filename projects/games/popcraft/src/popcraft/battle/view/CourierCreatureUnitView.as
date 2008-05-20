package popcraft.battle.view {

import flash.display.Bitmap;

import com.whirled.contrib.simplegame.resource.*;

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

    protected var _courier :CourierCreatureUnit;
    protected var _carriedSpellIcon :Bitmap;

}

}
