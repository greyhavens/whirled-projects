package {

import client.ClientAppController;

import flash.display.Sprite;
import flash.geom.Rectangle;

/**
 * Game client entry point.
 */
[SWF(width="700", height="500")]
public class StarFight extends Sprite
{
    public function StarFight ()
    {
        _appCtrl = new ClientAppController(this);
    }

    protected var _appCtrl :ClientAppController;
}

}
