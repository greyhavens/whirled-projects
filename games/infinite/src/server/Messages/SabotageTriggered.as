package server.Messages
{
    import flash.utils.ByteArray;

    public class SabotageTriggered implements Serializable
    {
        public var victimId:int;
        public var saboteurId:int;
        public var type:String;
        
        public function SabotageTriggered(victimId:int, saboteurId:int, type:String)
        {
            this.victimId = victimId;
            this.saboteurId = saboteurId;
            this.type = type;
        }

        public function writeToArray (array:ByteArray):ByteArray
        {
            array.writeInt(victimId);
            array.writeInt(saboteurId);
            array.writeUTF(type);
            return array;
        }
 
        public static function readFromArray (array:ByteArray) :SabotageTriggered
        {
            return new SabotageTriggered(array.readInt(), array.readInt(), array.readUTF());
        }
    }
}