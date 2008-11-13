package {

public class Items
{
    // Item slots, each of which can wear one item
    public static const BACK :int = 0;
    public static const TORSO :int = 1;
    public static const HAND :int = 2;

    // Item categories, for class-based bonuses
    public static const NONE :int = -1;
    public static const ARCANE :int = 0;
    public static const LIGHT :int = 1;
    public static const HEAVY :int = 2;

    public static const BOW :int = 3;
    public static const CLUB :int = 4;
    public static const AXE :int = 5;
    public static const SWORD :int = 6;
    public static const SPEAR :int = 7;
    public static const MAGIC :int = 8;
    public static const DAGGER :int = 9;

    public static const TABLE :Array = [
        // [ sprite, name, slot, bonus, (range) ]
        [ 94, "Loincloth", TORSO, NONE, 0 ],
        [ 95, "Fancy Tunic", TORSO, NONE, 1 ],
        [ 98, "Uber Armor", TORSO, HEAVY, 6 ],
        [ 321, "Crossbow", HAND, BOW, 1, 800 ],
        [ 304, "Sword", HAND, SWORD, 2, 200 ],

        [ 249, "Black cloak", BACK, NONE, 1 ],
        [ 250, "Blue cloak", BACK, NONE, 1 ],
        [ 252, "Cyan cloak", BACK, NONE, 1 ],
        [ 254, "Green cloak", BACK, NONE, 1 ],
        [ 255, "Pink cloak", BACK, NONE, 1 ],
        [ 256, "Red cloak", BACK, NONE, 1 ],
        [ 257, "White cloak", BACK, NONE, 1 ],
        [ 258, "Yellow cloak", BACK, NONE, 1 ],

        [ 208, "Elegant robe", TORSO, ARCANE, 1 ],
        [ 209, "Scale mail", TORSO, LIGHT, 3 ],
        [ 210, "Chain mail", TORSO, LIGHT, 3 ],
        [ 211, "Yet another armor", TORSO, HEAVY, 2 ],
    ];
}

}
