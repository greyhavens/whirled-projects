package popcraft.battle {

import popcraft.GameMode;
    
public class UnitAttack
{
    public function UnitAttack (sourceUnitId :uint, weapon :UnitWeapon)
    {
        _sourceUnitId = sourceUnitId;
        _weapon = weapon;
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
    
    protected var _sourceUnitId :uint;
    protected var _weapon :UnitWeapon;

}
}