package vampire.combat.client
{
import com.whirled.contrib.DisplayUtil;
import com.whirled.contrib.simplegame.objects.SceneObjectParent;

import vampire.combat.CombatUnit;

//Placeholder for showing unit stuff.
public class UnitDisplay extends SceneObjectParent
{
    public function UnitDisplay(unit :CombatUnit)
    {
        super();

        _displaySprite.graphics.beginFill(0xffffff);
        _displaySprite.graphics.drawRect(-50, -50, 100, 100);
        _displaySprite.graphics.endFill();
        DisplayUtil.drawText(_displaySprite, "id" + unit.profile.id, -40, -40);
    }

    protected var _unit :CombatUnit;

}
}