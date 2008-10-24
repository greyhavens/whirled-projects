package client
{
	import arithmetic.BoardCoordinates;
	
	import world.Cell;
	
	public interface Player
	{
        function enterLevel (level:int, position:BoardCoordinates) :void
        
        function get cell () :Cell
	}
}