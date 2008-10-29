package server.Messages
{
	import flash.utils.ByteArray;
	
	public interface Serializable
	{
		function writeToArray(array:ByteArray) :ByteArray		
	}
}