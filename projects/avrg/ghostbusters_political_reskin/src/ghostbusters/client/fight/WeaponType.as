package ghostbusters.client.fight {
    
public class WeaponType
{
    public static const NAME_FIND_TRUE_QUOTE :String = "Find Quote";
    public static const NAME_GHOST_WRITER :String = "Ghost writer";
    public static const NAME_GET_OUT_OF_IRAQ :String = "Iraq";
    public static const NAME_GET_TO_VOTING_BOOTH :String = "Vote";
//    public static const NAME_POTIONS :String = "Potions";
    public static const NAME_QUESTION_BLASTER :String = "Questions";
    
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