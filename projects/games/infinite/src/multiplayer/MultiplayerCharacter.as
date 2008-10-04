package multiplayer
{
	import arbitration.MovableCharacter;
	
	import whirled.WhirledCharacter;
	
	/**
	 * Interface defining the characteristics needed for a character that participates in a
	 * multiplayer game where interactions are passed between mutliple clients and a server.
	 */
	public interface MultiplayerCharacter extends WhirledCharacter, MovableCharacter
	{
		
	}
}