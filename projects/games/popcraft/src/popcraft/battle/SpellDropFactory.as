package popcraft.battle {

import com.threerings.flash.Vector2;

import com.whirled.contrib.simplegame.audio.*;

import popcraft.*;
import popcraft.battle.view.SpellDropView;

public class SpellDropFactory
{
    public static function createSpellDrop (spellType :uint, loc :Vector2, playSound :Boolean) :SpellDropObject
    {
        var spellDrop :SpellDropObject = new SpellDropObject(spellType);
        spellDrop.x = loc.x;
        spellDrop.y = loc.y;

        GameContext.netObjects.addObject(spellDrop);

        // create the view after adding the spellDrop to the game, so that its
        // SimObjectRef is valid
        var spellDropView :SpellDropView = new SpellDropView(spellDrop);
        GameContext.gameMode.addObject(spellDropView, GameContext.battleBoardView.spellDropViewParent);

        if (playSound) {
            AudioManager.instance.playSoundNamed("sfx_spelldrop");
        }

        return spellDrop;
    }
}

}
