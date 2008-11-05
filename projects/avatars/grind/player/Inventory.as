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
            bag.x = Doll.SIZE*(i%10);
            bag.y = Doll.SIZE*int(i/10);
            Command.bind(bag, MouseEvent.CLICK, equip, i);
            _bags[i] = bag;
            addChild(bag);
        }

        updateBags();
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

    protected function updateBags () :void
    {
        for (var i :int = 0; i < MAX_BAGS; ++i) {
            var memory :Array = _ctrl.getMemory("#"+i) as Array;
            if (memory != null) {
                _bags[i].setItem(memory[0], memory[2]);
            }
        }
    }

    protected function updateDoll () :void
    {
        var base :Array = [ 59, 263 ]; // TODO: Configure this properly

        var sprites :Array = [];
        _equipment = [];
        for (var i :int = 0; i < MAX_BAGS; ++i) {
            var memory :Array = _ctrl.getMemory("#"+i) as Array;
            if (memory != null && memory[2] == true) {
                var item :Array = Items.TABLE[memory[0]];

                sprites[item[2]] = item[0];
                _equipment[item[2]] = item;
            }
        }

        _doll.layer(base.concat(sprites));
    }

    public function getRange () :Number
    {
        return (Items.HAND in _equipment) ? _equipment[Items.HAND][4] : 100;
    }

    public function getPower () :Number
    {
        return (Items.HAND in _equipment) ? _equipment[Items.HAND][3] : 100;
    }

    protected var _bags :Array;
    protected var _doll :Doll;
    protected var _equipment :Array = []; // Maps slots to Items.TABLE rows
    protected var _ctrl :EntityControl;
}

}
