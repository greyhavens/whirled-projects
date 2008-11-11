package server.Messages
{
	import arithmetic.BoardCoordinates;
	
	import flash.utils.ByteArray;

	public class MoveProposal implements Serializable
	{
		public var timeFrame:Number;
		public var coordinates:BoardCoordinates;
		
		public function MoveProposal (timeFrame:Number, coordinates:BoardCoordinates)
		{
			this.timeFrame = timeFrame;
			this.coordinates = coordinates;
		}

		public function writeToArray (array:ByteArray):ByteArray
		{
			array.writeDouble(timeFrame);
			coordinates.writeToArray(array);
			return array;
		}
		
		public static function readFromArray (array:ByteArray) :MoveProposal
		{
			return new MoveProposal(
			    array.readDouble(),
			    BoardCoordinates.readFromArray(array)
			);
		}			
	}
}