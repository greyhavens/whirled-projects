package popcraft.battle {

import com.whirled.contrib.simplegame.*;

public class UnitAttack
{
    public function UnitAttack (sourceUnitRef :SimObjectRef, weapon :UnitWeapon)
    {
        _sourceUnitRef = sourceUnitRef;
        _weapon = weapon;
    }

    public function get sourceUnitRef () :SimObjectRef
    {
        return _sourceUnitRef;
    }

    public function get sourceUnit () :Unit
    {
        return _sourceUnitRef.object as Unit;
    }

    public function get weapon () :UnitWeapon
    {
        return _weapon;
    }

    protected var _sourceUnitRef :SimObjectRef;
    protected var _weapon :UnitWeapon;

}
}
