package popcraft.battle {
    
import com.whirled.contrib.simplegame.*;
    
public class UnitAttack
{
    public function UnitAttack (targetUnitRef :SimObjectRef, sourceUnitRef :SimObjectRef, weapon :UnitWeapon)
    {
        _targetUnitRef = targetUnitRef;
        _sourceUnitRef = sourceUnitRef;
        _weapon = weapon;
    }
    
    public function get targetUnitRef () :SimObjectRef
    {
        return _targetUnitRef;
    }
    
    public function get targetUnit () :Unit
    {
        return _targetUnitRef.object as Unit;
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
    
    protected var _targetUnitRef :SimObjectRef;
    protected var _sourceUnitRef :SimObjectRef;
    protected var _weapon :UnitWeapon;

}
}