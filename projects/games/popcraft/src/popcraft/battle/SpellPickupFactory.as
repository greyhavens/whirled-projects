package popcraft.battle {

import com.threerings.flash.Vector2;

import popcraft.*;
import popcraft.battle.view.SpellPickupObjectView;

public class SpellPickupFactory
{
    public static function createSpellPickup (spellType :uint, loc :Vector2) :SpellPickupObject
    {
        var spellPickup :SpellPickupObject = new SpellPickupObject(spellType);
        spellPickup.x = loc.x;
        spellPickup.y = loc.y;

        GameContext.netObjects.addObject(spellPickup);

        // create the view after adding the spellPickup to the game, so that its
        // SimObjectRef is valid
        var spellPickupView :SpellPickupObjectView = new SpellPickupObjectView(spellPickup);
        GameContext.gameMode.addObject(spellPickupView, GameContext.battleBoardView.spellPickupViewParent);

        return spellPickup;
    }
}

}
