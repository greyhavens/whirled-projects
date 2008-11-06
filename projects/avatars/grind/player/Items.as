package {

public class Items
{
    public static const BACK :int = 0;
    public static const TORSO :int = 1;
    public static const HAND :int = 2;

    public static const TABLE :Array = [
        // [ sprite, name, slot, bonus, (range) ]
        [ 94, "Loincloth", TORSO, 0 ],
        [ 95, "Fancy Tunic", TORSO, 1 ],
        [ 98, "Uber Armor", TORSO, 6 ],
        [ 321, "Crossbow", HAND, 1, 800 ],
        [ 304, "Sword", HAND, 2, 200 ],

        [ 249, "Black cloak", BACK, 1 ],
        [ 250, "Blue cloak", BACK, 1 ],
        [ 252, "Cyan cloak", BACK, 1 ],
        [ 254, "Green cloak", BACK, 1 ],
        [ 255, "Pink cloak", BACK, 1 ],
        [ 256, "Red cloak", BACK, 1 ],
        [ 257, "White cloak", BACK, 1 ],
        [ 258, "Yellow cloak", BACK, 1 ],

        [ 208, "Elegant robe", TORSO, 1 ],
        [ 209, "Scale mail", TORSO, 3 ],
        [ 210, "Chain mail", TORSO, 3 ],
        [ 211, "Yet another armor", TORSO, 2 ]
    ];
}

}
