package popcraft.battle {

import com.whirled.contrib.simplegame.*;

import popcraft.data.*;

public class UnitAttack
{
    public function UnitAttack (sourceUnit :Unit, weapon :UnitWeaponData)
    {
        _sourceUnitRef = sourceUnit.ref;
        _weapon = weapon;

        _attackingUnitOwningPlayerIndex = sourceUnit.owningPlayerIndex;
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

    public function get attackingUnitOwningPlayerIndex () :int
    {
        return _attackingUnitOwningPlayerIndex;
    }

    protected var _sourceUnitRef :SimObjectRef;
    protected var _weapon :UnitWeaponData;
    protected var _attackingUnitOwningPlayerIndex :int;

}
}
