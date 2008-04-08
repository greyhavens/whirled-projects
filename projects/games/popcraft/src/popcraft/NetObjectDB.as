package popcraft {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.components.*;
import com.whirled.contrib.simplegame.objects.*;

import popcraft.battle.*;

public class NetObjectDB extends ObjectDB
{
    /*override protected function finalizeObjectDestruction (obj :SimObject) :void
    {
        // remove dead creatures from the collision grid
        if (obj is CreatureUnit) {
            var creature :CreatureUnit = obj as CreatureUnit;
            creature.removeFromCollisionGrid();
        }

        super.finalizeObjectDestruction(obj);
    }*/
}

}
