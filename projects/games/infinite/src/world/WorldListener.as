package world
{	
	import world.arbitration.MoveEvent;
	
	import world.level.LevelEvent;
	
	public interface WorldListener
	{
        function handleLevelEntered (event:LevelEvent) :void
        
        function handlePathStart (event:MoveEvent) :void	
	}
}