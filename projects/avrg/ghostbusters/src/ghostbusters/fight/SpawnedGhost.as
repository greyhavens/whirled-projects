//
// $Id$

package ghostbusters.fight {

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;

import com.whirled.MobControl;

import ghostbusters.GhostBase;

public class SpawnedGhost extends GhostBase
{
    public function SpawnedGhost (control :MobControl)
    {
        super();

        _control = control;
    }

    public function updateHealth (percentHealth :Number) :void
    {
        var g :Graphics = _health.graphics;
        g.clear();

        g.lineStyle(0, HEALTH_BAR_COLOUR);
        g.beginFill(HEALTH_BAR_COLOUR);
        g.drawRect(-HEALTH_WIDTH/2, -HEALTH_HEIGHT/2, HEALTH_WIDTH * percentHealth, HEALTH_HEIGHT);
        g.endFill();

        g.lineStyle(1, HEALTH_BORDER_COLOUR);
        g.drawRect(-HEALTH_WIDTH/2, -HEALTH_HEIGHT/2, HEALTH_WIDTH, HEALTH_HEIGHT);
    }

    override protected function mediaReady () :void
    {
        new GameFrame();

        _clip.gotoAndStop(1, STATE_FIGHT);

        _control.setHotSpot((_bounds.left + _bounds.right)/2, _bounds.bottom, _bounds.height);

        _health = new Sprite();
        updateHealth(1.0);
        _control.setDecoration(_health);

        // TODO: switch to battle music? :)
    }

    protected var _control :MobControl;
    protected var _health :Sprite;

    protected static const HEALTH_WIDTH :int = 80;
    protected static const HEALTH_HEIGHT :int = 20;
    protected static const HEALTH_BORDER_COLOUR :int = 0xFFFFFF;
    protected static const HEALTH_BAR_COLOUR :int = 0x22FF44;

}
}
