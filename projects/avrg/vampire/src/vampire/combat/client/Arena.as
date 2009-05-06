package vampire.combat.client
{
import com.whirled.contrib.DisplayUtil;
import com.whirled.contrib.simplegame.objects.DraggableObject;

import flash.display.DisplayObject;
import flash.display.Sprite;

/**
 * Shows all the units and terrain.
 *
 */
public class Arena extends DraggableObject
{
    override protected function addedToDB () :void
    {
        super.addedToDB();
        _displaySprite.graphics.beginFill(0xffffff);
        _displaySprite.graphics.drawRect(0, 0, 400, 400);
        _displaySprite.graphics.endFill();
        _displaySprite.graphics.lineStyle(2, 0x000000);
        _displaySprite.graphics.drawRect(0, 0, 400, 400);

        DisplayUtil.drawText(_displaySprite, "Arena", 30, 10);
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    protected var _displaySprite :Sprite = new Sprite();
}
}