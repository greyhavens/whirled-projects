package {

import flash.events.*;
import flash.display.*;
import com.whirled.*;

import com.threerings.util.Command;

public class Inventory extends Sprite
{
    public static const MAX_BAGS :int = 100;

    public function Inventory (ctrl :EntityControl, doll :Doll)
    {
        _ctrl = ctrl;
        _doll = doll;

        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemory);

        _bags = new Array(MAX_BAGS);
        for (var i :int = 0; i < MAX_BAGS; ++i) {
            var bag :InventoryBag = new InventoryBag();
            bag.x = 32*(i%10);
            bag.y = 32*int(i/10);
            Command.bind(bag, MouseEvent.CLICK, equip, i);
            _bags[i] = bag;
            addChild(bag);
        }

        updateDoll();
    }

    public function deposit (item :int, bonus :int) :Boolean
    {
        for (var i :int = 0; i < MAX_BAGS; ++i) {
            var memory :Array = _ctrl.getMemory("#"+i) as Array;
            if (memory == null) {
                _ctrl.setMemory("#"+i, [item, bonus]);
                return true;
            }
        }

        trace("I'm full!");
        return false;
    }

    protected function equip (bag :int) :void
    {
        var memory :Array = _ctrl.getMemory("#" + bag) as Array;
        if (memory != null) {
            if (memory[2] == true) {
                delete memory[2];

            } else {
                // Unequip other items in this slots
                var mySlot = Items.TABLE[memory[0]][2];
                for (var i :int = 0; i < MAX_BAGS; ++i) {
                    var other :Array = _ctrl.getMemory("#"+i) as Array;
                    if (other != null && Items.TABLE[other[0]][2] == mySlot && other[2] == true) {
                        delete other[2];
                        _ctrl.setMemory("#"+i, other);
                    }
                }
                memory[2] = true;
            }
            _ctrl.setMemory("#" + bag, memory);
        }
    }

    protected function handleMemory (event :ControlEvent) :void
    {
        if (event.name.charAt(0) == "#") {
            var bag :int = int(event.name.substr(1));
            var item :int = event.value[0] as int;
            var bonus :int = event.value[1] as int;
            var equipped :Boolean = event.value[2] as Boolean;

            // Update the inventory bag
            _bags[bag].setItem(item, equipped);

            updateDoll();
        }
    }

    protected function updateDoll () :void
    {
        var layers :Array = [ 59 ]; // TODO: Configure this properly

        for (var i :int = 0; i < MAX_BAGS; ++i) {
            var memory :Array = _ctrl.getMemory("#"+i) as Array;
            if (memory != null && memory[2] == true) {
                var item :Array = Items.TABLE[memory[0]];
                layers[item[2]] = item[0];
            }
        }

        _doll.layer(layers);
    }

    protected var _bags :Array;
    protected var _doll :Doll;
    protected var _ctrl :EntityControl;
}

}
