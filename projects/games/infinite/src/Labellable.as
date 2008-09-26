package
{
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	public interface Labellable extends Viewable
	{
    	/**
		 * Return the character who placed this cell.
		 */
		function get owner () :Owner;
		
		/**
		 * The name of the object.
		 */
		function get objectName () :String;
		
		/**
		 * Get the anchor point that an arrow should attach to when the supplied vector points in
		 * the direction of the edge of the desired anchor.
		 */
		function anchorPoint (v:Vector) :GraphicCoordinates;
		
		function get graphicCenter () :GraphicCoordinates;		 
	}
}