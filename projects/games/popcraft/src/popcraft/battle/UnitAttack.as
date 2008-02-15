package popcraft.battle {
    
import com.whirled.contrib.core.*;
    
public class UnitAttack
{
    public function UnitAttack (targetUnitRef :AppObjectRef, sourceUnitRef :AppObjectRef, weapon :UnitWeapon)
    {
        _targetUnitRef = targetUnitRef;
        _sourceUnitRef = sourceUnitRef;
        _weapon = weapon;
    }
    
    public function get targetUnitRef () :AppObjectRef
    {
        return _targetUnitRef;
    }
    
    public function get targetUnit () :Unit
    {
        return _targetUnitRef.object as Unit;
    }
    
    public function get sourceUnitRef () :AppObjectRef
    {
        return _sourceUnitRef;
    }
    
    public function get sourceUnit () :Unit
    {
        return _targetUnitRef.object as Unit;
    }
    
    public function get weapon () :UnitWeapon
    {
        return _weapon;
    }
    
    protected var _targetUnitRef :AppObjectRef;
    protected var _sourceUnitRef :AppObjectRef;
    protected var _weapon :UnitWeapon;

}
}