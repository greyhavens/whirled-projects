package vampire.combat.client
{
import com.whirled.contrib.DisplayUtil;
import com.whirled.contrib.simplegame.objects.SceneObjectParent;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;

/**
 * Shows all the units and terrain.
 *
 */
public class Arena extends SceneObjectParent
{
    public static const SIZE :Point = new Point(500, 400);
    override protected function addedToDB () :void
    {
        trace("Arena, added to db");
        super.addedToDB();
        _displaySprite.addChild(_draggableSprite);
        var g :Graphics = _draggableSprite.graphics;
        g.beginFill(0xffffff);
        g.drawRect(0, 0, SIZE.x, SIZE.y);
        g.endFill();
        g.lineStyle(2, 0x000000);
        g.drawRect(0, 0, SIZE.x, SIZE.y);

        DisplayUtil.drawText(_displaySprite, "Arena", 30, -20);

        var labels :Array = ["Friendly Ranged", "Friendly Close", "Enemy Close", "Enemy Ranged"];
        for (var ii :int = 0; ii < labels.length; ++ii) {
            var p :Point = DisplayUtil.distributionPoint(ii, labels.length, 0, -20, SIZE.x, -20);
            DisplayUtil.drawText(_displaySprite, labels[ii], p.x, p.y);
        }
    }

//    override protected function get draggableObject () :InteractiveObject
//    {
//        return _draggableSprite;
//    }

    protected var _draggableSprite :Sprite = new Sprite();


//    public function addUnit (u :CombatUnitInfoView) :void
//    {
//        addSimObject(u, _displaySprite);
//    }

}
}