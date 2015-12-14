package graphics
{
	import arithmetic.GraphicCoordinates;
	import arithmetic.GraphicRectangle;
	import arithmetic.Vector;
	
	public interface Diagram
	{
		/**
		 * Return the center point of the viewable area of the diagram.
		 */
		function get centerOfView () :GraphicCoordinates 

		/**
		 * Return a rectangle describing the visible area.
		 */
		function get visibleArea () :GraphicRectangle
		
		/**
		 * Return the distance to a given display object from the center point of the viewable area. 
		 */
		function centerTo (targetPoint:GraphicCoordinates) :Vector
	}
}