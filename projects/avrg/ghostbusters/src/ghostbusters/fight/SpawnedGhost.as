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
        _clip.gotoAndStop(1, STATE_FIGHT);

        _control.setHotSpot((_bounds.left + _bounds.right)/2, _bounds.bottom, _bounds.height);

        addEventListener(MouseEvent.CLICK, ghostClicked);

        _health = new Sprite();
        updateHealth(1.0);
        _control.setDecoration(_health);

        // TODO: switch to battle music? :)
        // TODO: accept clicks & trigger minigame
    }

    protected function ghostClicked (evt :MouseEvent) :void
    {
        // TODO: high high time for a Model, as noted elsewhere
        var currentHealth :Number = _control.getAVRGameControl().state.getProperty("gh") as Number;
        if (currentHealth > 0.07) {
            _control.getAVRGameControl().state.setProperty("gh", currentHealth - 0.07, false);
        } else {
            _control.getAVRGameControl().despawnMob("ghost");
        }
    }


    protected var _control :MobControl;
    protected var _health :Sprite;

    protected static const HEALTH_WIDTH :int = 80;
    protected static const HEALTH_HEIGHT :int = 20;
    protected static const HEALTH_BORDER_COLOUR :int = 0xFFFFFF;
    protected static const HEALTH_BAR_COLOUR :int = 0x22FF44;

}
}
