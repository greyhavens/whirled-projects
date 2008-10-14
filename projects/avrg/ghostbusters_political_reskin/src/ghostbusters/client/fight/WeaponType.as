package ghostbusters.client.fight {
    
public class WeaponType
{
    public static const NAME_LANTERN :String = "Lantern";
    public static const NAME_OUIJA :String = "Ouija";
    public static const NAME_POTIONS :String = "Potions";
    public static const NAME_PLASMA :String = "Plasma";
    
    public var name :String;
    public var level :int;
    
    public function WeaponType (name :String, level :int)
    {
        this.name = name;
        this.level = level;
    }
    
    public function equals (rhs :WeaponType) :Boolean
    {
        if (null == rhs) {
            return false;
        }
        
        if (this == rhs) {
            return true;
        }
        
        return (name == rhs.name && level == rhs.level);
    }
    
    public function toString () :String
    {
        return name + " [level " + level + "]";
    }
    
    
}

}