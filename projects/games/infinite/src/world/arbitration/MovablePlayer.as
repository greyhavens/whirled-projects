package world.arbitration
{
	import flash.events.IEventDispatcher;
	
	import world.Cell;
	
	public interface MovablePlayer extends IEventDispatcher
	{
        function isMoving () :Boolean;
        
        function get cell () :Cell;
        
        function get id () :int;
        
        function get levelNumber () :int;      
 	}
}