package
{
	import flash.display.DisplayObject;
	
	public interface Labellable extends Viewable
	{
    	/**
		 * Return the character who placed this cell.
		 */
		 function get owner () :Character
	}
}