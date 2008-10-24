package world
{
	import world.level.LevelEvent;
	
	public interface WorldListener
	{
        function handleLevelEntered(event:LevelEvent) :void		
	}
}