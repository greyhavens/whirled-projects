package {

import flash.display.Sprite;

/**
 * Game client entry point.
 */
[SWF(width="700", height="500")]
public class StarFight extends Sprite
{
    public function StarFight ()
    {
        _gameMgr = new ClientGameManager(this);
    }

    protected var _gameMgr :ClientGameManager;
}
}
