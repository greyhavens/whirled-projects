package cells.views
{   
    import client.Objective;
	import flash.events.IEventDispatcher;
	
	public interface CellView extends Labellable, IEventDispatcher
	{
		function get cell () :Cell;
		
		function addToObjective (objective:Objective) :void

		function removeFromObjective (objective:Objective) :void
	}
}