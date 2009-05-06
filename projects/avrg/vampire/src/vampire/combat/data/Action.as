package vampire.combat.data
{
public class Action
{
    public static const ATTACK_BASIC :int = 1;
    public static const REST :int = 2;
    public static const BLOCK :int = 3;
    public static const DODGE :int = 4;
    public static const ATTACK_2 :int = 5;

    public static const ALL :Array = [
                                        ATTACK_BASIC,
                                        REST,
                                        BLOCK,
                                        DODGE,
                                        ATTACK_2,
                                     ]

}
}