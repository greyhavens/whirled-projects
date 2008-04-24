package popcraft.battle {

import com.whirled.contrib.simplegame.*;

import popcraft.data.*;

public class UnitAttack
{
    public function UnitAttack (sourceUnitRef :SimObjectRef, weapon :UnitWeaponData)
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

    public function get weapon () :UnitWeaponData
    {
        return _weapon;
    }

    protected var _sourceUnitRef :SimObjectRef;
    protected var _weapon :UnitWeaponData;

}
}
