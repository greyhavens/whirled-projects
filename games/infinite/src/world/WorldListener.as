package world
{	
	import interactions.SabotageEvent;
	
	import world.arbitration.MoveEvent;
	import world.level.LevelEvent;
	
	public interface WorldListener
	{
        function handleLevelEntered (event:LevelEvent) :void;
 
        function handleLevelComplete (event:LevelEvent) :void;
        
        function handlePathStart (event:MoveEvent) :void;
        
        function handleNoPath (event:MoveEvent) :void;
                
        function handleItemReceived (event:InventoryEvent) :void;
        
        function handleItemUsed (event:InventoryEvent) :void;
        
        function handleSabotageTriggered (event:SabotageEvent) :void;
	}
}