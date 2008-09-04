package {

import client.ClientGameManager;
import client.ClientLocalUtility;

import flash.display.Sprite;

/**
 * Game client entry point.
 */
[SWF(width="700", height="500")]
public class StarFight extends Sprite
{
    public function StarFight ()
    {
        AppContext.local = new ClientLocalUtility();

        _gameMgr = new ClientGameManager(this);
    }

    protected var _gameMgr :ClientGameManager;
}
}
