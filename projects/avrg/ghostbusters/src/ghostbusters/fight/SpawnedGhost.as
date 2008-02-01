//
// $Id$

package ghostbusters.fight {

import ghostbusters.Codes;
import ghostbusters.GhostBase;

public class SpawnedGhost extends GhostBase
{
    public function SpawnedGhost ()
    {
        super();
    }

    public function fighting () :void
    {
        handler.gotoScene(Codes.ST_GHOST_FIGHT, function () :String {
            return Codes.ST_GHOST_FIGHT;
        });
    }

    public function damaged () :void
    {
        handler.gotoScene(Codes.ST_GHOST_REEL, function () :String {
            return Codes.ST_GHOST_FIGHT;
        });
    }

    override protected function mediaReady () :void
    {
        // TODO: switch to battle music? :)
        super.mediaReady();
    }
}
}
