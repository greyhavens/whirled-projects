package popcraft {

import core.AppObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import popcraft.battle.UnitData;
import flash.display.Shape;

public class UnitPurchaseButtonManager extends AppObject
{
    public function UnitPurchaseButtonManager ()
    {
        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {

            var button :UnitPurchaseButton = new UnitPurchaseButton(unitType);

            button.addEventListener(MouseEvent.CLICK, createButtonListener(unitType));

            var buttonLoc :Point = (Constants.UNIT_BUTTON_LOCS[unitType] as Point);
            button.x = buttonLoc.x;
            button.y = buttonLoc.y;

            GameMode.instance.addChild(button);

            _buttons.push(button);

            var meter :UnitPurchaseMeter = new UnitPurchaseMeter(unitType);
            meter.displayObject.x = buttonLoc.x;
            meter.displayObject.y = buttonLoc.y + button.height + 2;
            GameMode.instance.addObject(meter, GameMode.instance);
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
        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {
            (_buttons[unitType] as UnitPurchaseButton).enabled = GameMode.instance.canPurchaseUnit(unitType);
        }
    }

    protected function buttonClicked (unitType :uint) :void
    {
        GameMode.instance.purchaseUnit(unitType);
    }

    protected var _buttons :Array = new Array();
}

}
