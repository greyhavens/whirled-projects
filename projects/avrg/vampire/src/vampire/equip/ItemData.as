package equip
{
public class ItemData
{
    public static const ITEM_TYPE_WEAPON :int = 1;
    public static const ITEM_TYPE_CLOTHING :int = 2;
    protected static const items :Array = [//code, name, type, graphic resource
                                            new Item(1, "sword", 1, "sword"),
                                            new Item(2, "pants", 2, "pants"),
                                       ]

   public static function get (itemId :int) :Item
   {
       for each (var it :Item in items) {
           if (it.id == itemId) {
               return it;
           }
       }
       return null;
   }
}
}
