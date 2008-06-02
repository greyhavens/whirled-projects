package popcraft.ui {

import com.whirled.contrib.simplegame.SimObject;

import flash.events.MouseEvent;
import flash.geom.Point;

import popcraft.*;

public class SpellCastButtonManager extends SimObject
{
    public function SpellCastButtonManager ()
    {
        var loc :Point = Constants.FIRST_SPELL_BUTTON_LOC.clone();

        for (var spellType :uint = 0; spellType < Constants.SPELL_NAMES.length; ++spellType) {

            // single player levels can restrict the units that the player can purchase
            if (GameContext.isSinglePlayer && !GameContext.spLevel.isAvailableSpell(spellType)) {
                continue;
            }

            // create the button
            var button :SpellCastButton = new SpellCastButton(spellType);
            button.addEventListener(MouseEvent.CLICK, createButtonListener(spellType));

            button.x = loc.x;
            button.y = loc.y;

            GameContext.gameMode.modeSprite.addChild(button);

            _buttons.push(button);

            loc.x += SpellCastButton.WIDTH + BUTTON_X_OFFSET;
        }
    }

    protected function createButtonListener (spellType :uint) :Function
    {
        return function (e :MouseEvent) :void {
            buttonClicked(spellType);
        }
    }

    override protected function update (dt :Number) :void
    {
        var isNight :Boolean = GameContext.diurnalCycle.isNight;
        for each (var button :SpellCastButton in _buttons) {
            // creature spells are disabled during the day
            button.enabled =
                (isNight || button.spellType >= Constants.CREATURE_SPELL_TYPE__LIMIT) &&
                GameContext.localPlayerInfo.canCastSpell(button.spellType);

            button.updateSpellCount(GameContext.localPlayerInfo.getSpellCount(button.spellType));
        }
    }

    protected function buttonClicked (spellType :uint) :void
    {
        GameContext.gameMode.castSpell(GameContext.localPlayerId, spellType);
    }

    protected var _buttons :Array = [];

    protected static const BUTTON_X_OFFSET :int = 2;
}

}
