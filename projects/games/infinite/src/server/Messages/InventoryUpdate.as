package server.Messages
{
	import flash.utils.ByteArray;

	public class InventoryUpdate implements Serializable
	{
		public var position:int;
		public var attributes:Object;
		
		public function InventoryUpdate (position:int, attributes:Object)
		{
			this.position = position;
			this.attributes = attributes;
		}

		public function writeToArray (array:ByteArray) :ByteArray
		{
			array.writeInt(position);
			array.writeObject(attributes);
			return array;
		}
				
		public function readFromArray (array:ByteArray) :InventoryUpdate
		{
			return new InventoryUpdate(
				array.readInt(),
				array.readObject()
			);
		}
	}
}