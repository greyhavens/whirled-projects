//
// $Id$

package ghostbusters {

import flash.display.Graphics;
import flash.display.Sprite;

import com.threerings.util.Log;

import com.whirled.MobControl;

public class SpawnedGhost extends GhostBase
{
    public function SpawnedGhost (control :MobControl)
    {
        super();

        _control = control;
    }

    override protected function mediaReady () :void
    {
        _health = new Sprite();
        var g :Graphics = _health.graphics;
        g.lineStyle(0, 0x22FF44);
        g.beginFill(0x22FF44);
        g.drawRect(-40, -8, 50, 16);
        g.endFill();

        g.lineStyle(1, 0xFFFFFF);
        g.drawRect(-40, -8, 80, 16);

        _control.setDecoration(_health);
    }

    protected var _control :MobControl;

    protected var _health :Sprite;
}
}
