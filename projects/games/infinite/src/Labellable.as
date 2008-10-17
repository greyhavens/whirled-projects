package
{
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	public interface Labellable 
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
		 * Get the anchor point that an arrow should attach to when the arrow points towards the
		 * graphic center in the direction specified by the supplied vector.
		 */
		function anchorPoint (v:Vector) :GraphicCoordinates;
		
		function get graphicCenter () :GraphicCoordinates;		 
	}
}