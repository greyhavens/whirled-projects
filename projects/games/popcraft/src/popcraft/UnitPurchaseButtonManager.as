package popcraft {

import com.whirled.contrib.simplegame.SimObject;

import flash.events.MouseEvent;
import flash.geom.Point;

public class UnitPurchaseButtonManager extends SimObject
{
    public function UnitPurchaseButtonManager ()
    {
        _localPlayerData = GameMode.instance.localPlayerData;

        var loc :Point = Constants.FIRST_UNIT_BUTTON_LOC.clone();

        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {

            var button :UnitPurchaseButton = new UnitPurchaseButton(unitType);

            button.addEventListener(MouseEvent.CLICK, createButtonListener(unitType));

            button.x = loc.x;
            button.y = loc.y;

            GameMode.instance.modeSprite.addChild(button);

            _buttons.push(button);

            var meter :UnitPurchaseMeter = new UnitPurchaseMeter(unitType);
            meter.displayObject.x = button.x;
            meter.displayObject.y = button.y + button.height + 2;
            GameMode.instance.addObject(meter, GameMode.instance.modeSprite);

            loc.x += button.width + 2;
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
            (_buttons[unitType] as UnitPurchaseButton).enabled = _localPlayerData.canPurchaseUnit(unitType);
        }
    }

    protected function buttonClicked (unitType :uint) :void
    {
        GameMode.instance.purchaseUnit(unitType);
    }

    protected var _buttons :Array = new Array();
    protected var _localPlayerData :LocalPlayerData;
}

}
