//
// $Id$

package ghostbusters.fight {

import com.whirled.MobControl;

import ghostbusters.GhostBase;

public class SpawnedGhost extends GhostBase
{
    public function SpawnedGhost (control :MobControl, health :int, maxHealth :int) :void
    {
        super();

        _control = control;

        _health = new HealthBar(HEALTH_WIDTH, HEALTH_HEIGHT);

        updateHealth(health, maxHealth);
    }

    public function updateHealth (curHealth :Number, maxHealth :Number) :void
    {
        _health.updateHealth(curHealth / maxHealth);
    }

    override protected function mediaReady () :void
    {
        _clip.gotoAndStop(1, STATE_FIGHT);

        _control.setHotSpot((_bounds.left + _bounds.right)/2, _bounds.bottom, _bounds.height);

        _control.setDecoration(_health);

        // TODO: switch to battle music? :)
    }

    protected var _control :MobControl;
    protected var _health :HealthBar;

    protected static const HEALTH_WIDTH :int = 80;
    protected static const HEALTH_HEIGHT :int = 14;
}
}
