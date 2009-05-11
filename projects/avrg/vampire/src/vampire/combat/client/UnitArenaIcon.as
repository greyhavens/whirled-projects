package vampire.combat.client
{
import com.threerings.util.Command;
import com.whirled.contrib.simplegame.objects.SceneObjectParent;

import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.combat.debug.Factory;

public class UnitArenaIcon extends SceneObjectParent
{
    public function UnitArenaIcon(unit :UnitRecord)
    {
        super();
        _icon = Factory.createArenaIcon(unit);
        _displaySprite.addChild(_icon);
        Command.bind(_displaySprite, MouseEvent.CLICK, CombatController.UNIT_CLICKED, unit);
    }

    protected var _icon :Sprite;
}
}