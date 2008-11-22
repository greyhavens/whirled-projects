package world
{	
	import world.arbitration.MoveEvent;
	import world.level.LevelEvent;
	
	public interface WorldListener
	{
        function handleLevelEntered (event:LevelEvent) :void;
 
        function handleLevelComplete (event:LevelEvent) :void;
        
        function handlePathStart (event:MoveEvent) :void;
        
        function handleNoPath (event:MoveEvent) :void;
        
        function handleCellStateChange (event:CellStateEvent) :void;
        
        function handleItemReceived (event:InventoryEvent) :void;
        
        function handleItemUsed (event:InventoryEvent) :void;
	}
}