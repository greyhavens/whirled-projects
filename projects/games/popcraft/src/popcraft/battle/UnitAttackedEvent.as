package popcraft.battle {
    
import flash.events.Event;

public class UnitAttackedEvent extends Event
{
    public static const TYPE :String = "UnitAttacked";
    
    public function UnitAttackedEvent (attack :UnitAttack)
    {
        super(TYPE, false, false);
        
        _attack = attack;
    }
    
    public function get attack () :UnitAttack
    {
        return _attack;
    }
    
    protected var _attack :UnitAttack;
    
}

}