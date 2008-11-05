package {

public class Items
{
    public static const TORSO :int = 0;
    public static const HAND :int = 1;

    public static const TABLE :Array = [
        // [ sprite, name, slot, bonus, (range) ]
        [ 94, "Loincloth", TORSO, 0 ],
        [ 95, "Fancy Tunic", TORSO, 1 ],
        [ 98, "Uber Armor", TORSO, 6 ],
        [ 321, "Crossbow", HAND, 1, 800 ],
        [ 304, "Sword", HAND, 2, 200 ]
    ];
}

}
