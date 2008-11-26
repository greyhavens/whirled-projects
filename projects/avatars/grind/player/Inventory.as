package {

import flash.events.*;
import flash.display.*;
import flash.media.*;
import flash.text.*;

import com.whirled.*;

import com.threerings.util.Command;
import com.threerings.flash.TextFieldUtil;

import klass.Klass;

public class Inventory extends Sprite
{
    public static const MAX_BAGS :int = 100;

    public function Inventory (ctrl :EntityControl, klass :Klass, doll :Doll)
    {
        _ctrl = ctrl;
        _klass = klass;
        _doll = doll;

        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemory);

        addChild(_itemPreview);
        _itemText.x = (Doll.SIZE+8);
        addChild(_itemText);

        _bags = new Array(MAX_BAGS);
        for (var i :int = 0; i < MAX_BAGS; ++i) {
            var bag :InventoryBag = new InventoryBag();
            bag.x = Doll.SIZE*(i%10);
            bag.y = Doll.SIZE*int(i/10) + (Doll.SIZE+8);

            Command.bind(bag, MouseEvent.CLICK, equip, i);
            Command.bind(bag, MouseEvent.ROLL_OVER, preview, i);
            Command.bind(bag, MouseEvent.ROLL_OUT, clearPreview);

            _bags[i] = bag;
            addChild(bag);
        }

        _attackSounds = [];
        _attackSounds[Items.BOW] = Sound(new SOUND_BOW());
        _attackSounds[Items.CLUB] = Sound(new SOUND_CLUB());
        _attackSounds[Items.AXE] = Sound(new SOUND_AXE());
        _attackSounds[Items.SWORD] = Sound(new SOUND_SWORD());
        _attackSounds[Items.SPEAR] = Sound(new SOUND_SPEAR());
        _attackSounds[Items.MAGIC] = Sound(new SOUND_MAGIC());
        _attackSounds[Items.DAGGER] = Sound(new SOUND_DAGGER());

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
                // Unequip other items in this slot
                var mySlot :int = Items.TABLE[memory[0]][2];
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

    protected function preview (bag :int) :void
    {
        var memory :Array = _ctrl.getMemory("#" + bag) as Array;
        if (memory != null) {
            var item :Array = Items.TABLE[memory[0]];
            _itemPreview.layer([ item[0] ]);
            _itemText.text = "It's a " + item[1];
        }
    }

    protected function clearPreview () :void
    {
        _itemPreview.layer([]);
        _itemText.text = "Level ??";
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
        var base :Array = _klass.getBaseSprites();

        var sprites :Array = [];
        _equipment = [];
        for (var i :int = 0; i < MAX_BAGS; ++i) {
            var memory :Array = _ctrl.getMemory("#"+i) as Array;
            if (memory != null && memory[2] == true) {
                var item :Array = Items.TABLE[memory[0]];

                _equipment[item[2]] = item;

                if (item[2] == Items.BACK) {
                    base.unshift(item[0]);
                } else {
                    sprites[item[2]] = item[0];
                }
            }
        }

        _doll.layer(base.concat(sprites.splice(1)));
    }

    public function getRange () :Number
    {
        return (Items.HAND in _equipment) ? _equipment[Items.HAND][5] : 100;
    }

    public function getPower () :Number
    {
        return (Items.HAND in _equipment) ? _equipment[Items.HAND][4] : 100;
    }

    public function getDefence () :Number
    {
        var defence :int = 0;
        for each (var item :Array in _equipment) {
            // If it's not a weapon
            if (item[2] != Items.HAND) {
                defence += item[4];
            }
        }
        return defence;
    }

    public function getAttackSound () :Sound
    {
        return (Items.HAND in _equipment) ?
            _attackSounds[_equipment[Items.HAND][3]] : _attackSoundDefault;
    }

    [Embed(source="rsrc/fist.mp3")]
    protected static const SOUND_FIST :Class;
    [Embed(source="rsrc/bow.mp3")]
    protected static const SOUND_BOW :Class;
    [Embed(source="rsrc/club.mp3")]
    protected static const SOUND_CLUB :Class;
    [Embed(source="rsrc/axe.mp3")]
    protected static const SOUND_AXE :Class;
    [Embed(source="rsrc/sword.mp3")]
    protected static const SOUND_SWORD :Class;
    [Embed(source="rsrc/spear.mp3")]
    protected static const SOUND_SPEAR :Class;
    [Embed(source="rsrc/magic.mp3")]
    protected static const SOUND_MAGIC :Class;
    [Embed(source="rsrc/dagger.mp3")]
    protected static const SOUND_DAGGER :Class;

    protected var _itemPreview :Doll = new Doll();;
    protected var _itemText :TextField = TextFieldUtil.createField("",
        { textColor: 0xffffff, selectable: false,
            autoSize: TextFieldAutoSize.LEFT, outlineColor: 0x00000 },
        { font: "_sans", size: 12, bold: true });

    /** Maps item category to Sounds. */
    protected var _attackSounds :Array;

    protected var _attackSoundDefault :Sound = Sound(new SOUND_FIST());

    protected var _bags :Array;
    protected var _equipment :Array = []; // Maps slots to Items.TABLE rows

    protected var _ctrl :EntityControl;
    protected var _klass :Klass;
    protected var _doll :Doll;
}

}
