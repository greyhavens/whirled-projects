package {

import flash.display.*;

public class InventoryBag extends Sprite
{
    public function InventoryBag ()
    {
        // Bordered background
        graphics.lineStyle(2, 0x0000ff);
        graphics.drawRect(0, 0, 32, 32);
        graphics.endFill();
    }

    public function setItem (item :int, equipped :Boolean) :void
    {
        if (_container != null) {
            removeChild(_container);
        }

        var doll :Doll = new Doll();
        var data :Array = Items.TABLE[item] as Array;
        doll.layer([data[0]]);
        trace(data.join());

        _container = new Sprite();
        if (equipped) {
            _container.graphics.beginFill(0xff0000, 0.2);
            _container.graphics.drawRect(2, 2, 30, 30);
            _container.graphics.endFill();
        }
        _container.addChild(doll);

        addChild(_container);
    }

    protected var _container :Sprite;
}

}
