package popcraft {

import com.whirled.contrib.simplegame.SimObject;

import flash.events.MouseEvent;
import flash.geom.Point;

import popcraft.battle.UnitData;

public class UnitPurchaseButtonManager extends SimObject
{
    public function UnitPurchaseButtonManager ()
    {
        var loc :Point = Constants.FIRST_UNIT_BUTTON_LOC.clone();

        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {

            // create the button
            var button :UnitPurchaseButton = new UnitPurchaseButton(unitType);
            button.addEventListener(MouseEvent.CLICK, createButtonListener(unitType));

            button.x = loc.x;
            button.y = loc.y;

            GameContext.gameMode.modeSprite.addChild(button);

            _buttons.push(button);

            var meter :UnitPurchaseMeter = new UnitPurchaseMeter(unitType);
            meter.displayObject.x = button.x;
            meter.displayObject.y = button.y + UnitPurchaseButton.HEIGHT + 2;
            GameContext.gameMode.addObject(meter, GameContext.gameMode.modeSprite);

            loc.x += UnitPurchaseButton.WIDTH + BUTTON_X_OFFSET;
        }
    }

    // Method closures in ActionScript share their parent function's scope, rather
    // than getting their own copy. This will probably screw me up till the end of my days.
    protected function createButtonListener (unitType :uint) :Function
    {
        return function (e :MouseEvent) :void {
            buttonClicked(unitType);
        }
    }

    override protected function update (dt :Number) :void
    {
        var isNight :Boolean = GameContext.diurnalCycle.isNight;

        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {
            var button :UnitPurchaseButton = (_buttons[unitType] as UnitPurchaseButton);
            button.enabled = isNight && GameContext.localPlayerData.canPurchaseUnit(unitType);
        }
    }

    protected function buttonClicked (unitType :uint) :void
    {
        GameContext.gameMode.buildUnit(GameContext.localPlayerId, unitType);
    }

    protected var _buttons :Array = [];

    protected static const BUTTON_X_OFFSET :int = 2;
}

}
