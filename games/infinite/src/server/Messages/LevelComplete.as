package server.Messages
{
    import flash.utils.ByteArray;

    public class LevelComplete implements Serializable
    {
        public var player:int;
        public var level:int;
        
        public function LevelComplete(player:int, level:int)
        {
            this.player = player;
            this.level = level;
        }

        public function writeToArray(array:ByteArray) :ByteArray
        {
            array.writeInt(player);
            array.writeInt(level);
            return array;
        }
        
        public static function readFromArray(array:ByteArray) :LevelComplete
        {
            return new LevelComplete(array.readInt(), array.readInt());
        }        
    }
}