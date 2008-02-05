package popcraft.battle {

import popcraft.GameMode;
    
public class UnitAttack
{
    public function UnitAttack (targetUnitId :uint, sourceUnitId :uint, weapon :UnitWeapon)
    {
        _targetUnitId = targetUnitId;
        _sourceUnitId = sourceUnitId;
        _weapon = weapon;
    }
    
    public function get targetUnitId () :uint
    {
        return _targetUnitId;
    }
    
    public function get targetUnit () :Unit
    {
        return (GameMode.getNetObject(_targetUnitId) as Unit);
    }
    
    public function get sourceUnitId () :uint
    {
        return _sourceUnitId;
    }
    
    public function get sourceUnit () :Unit
    {
        return (GameMode.getNetObject(_sourceUnitId) as Unit);
    }
    
    public function get weapon () :UnitWeapon
    {
        return _weapon;
    }
    
    protected var _targetUnitId :uint;
    protected var _sourceUnitId :uint;
    protected var _weapon :UnitWeapon;

}
}