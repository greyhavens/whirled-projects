package graphics
{
	import arithmetic.CoordinateSystem;
	import arithmetic.Geometry;
	import arithmetic.GraphicCoordinates;
	import arithmetic.GraphicRectangle;
	import arithmetic.Vector;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import sprites.SpriteUtil;
	
	public class OwnerLabel extends Sprite
	{
		public function OwnerLabel (objective:Diagram)
		{
			_objective = objective;
			_text = new TextField();
			addChild(_text);
		}

        protected function updateText (target:Labellable) :void
        {
            _text.htmlText = "<font size='10' face='Helvetica, Arial, _sans'>"+ labelText(target) +"</font>"
            
            // decide whether the label should be to the left or right of the target.
            // if there is space to put the label on the left of the target then we always do
            // otherwise it goes on the right.            
            const visible:GraphicRectangle = _objective.visibleArea;
            const bounds:GraphicRectangle = target.bounds;
                        
            var x:int;
            var y:int;
            
            if (bounds.left - (SPACING*2) - _text.textWidth < visible.x) {
                // the label goes on the right
                x = bounds.right + SPACING;                 
            } else {
                // the label goes on the left
                x = bounds.left - SPACING - _text.textWidth;
            }
            
            // decide whether the label should be above or below the target
            // in order to avoid impinging on the player, the label will be placed above the target if
            // there is space for it, otherwise it will be below.
            if (bounds.top - (SPACING*2) - _text.textHeight < visible.y) {
                // the label goes on the bottom
                y = bounds.bottom + SPACING;
            } else {
                // the label goes on the top
                y = bounds.top - SPACING - _text.textHeight;
            }   
            
            // map the position back to the coordinate system of this sprite and apply it to the text field.
            const textPosition:GraphicCoordinates = new GraphicCoordinates(x, y);
            Geometry.position(_text, _objectiveCoordinates.toLocal(textPosition));
        }

		public function displayOwnership (target:Labellable) :void
		{
			const center:GraphicCoordinates = _objective.centerOfView;
			Geometry.position(this, center);			
			_objectiveCoordinates = GraphicCoordinates.ORIGIN.correspondsTo(center);
			
			// update the text label and position

            updateText(target);                			
            Log.debug (" label position is: "+x+", "+y);            

			const rect:GraphicRectangle = new GraphicRectangle(_text.x, _text.y, _text.textWidth, _text.textHeight).paddedBy(10); 
			computeBackground(rect, target);
			
			// redraw the background shape
			redrawBackground();
						
			Log.debug ("owner label at "+Geometry.coordsOf(this));			
			visible = true;	
		}
		
		
		
		/**
		 * Compute the position of rectangle that is drawn behind the text, and the position of the
		 * arrowhead.
		 */
		protected function computeBackground (text:GraphicRectangle, target:Labellable) :void
		{
			Log.debug ("objective center is "+_objective.centerOfView);
			
			_rectangle = text;
						
			const direction:Vector = 
				_rectangle.center.distanceTo(target.graphicCenter.from(_objectiveCoordinates));

			Log.debug ("direction = "+direction);

			_arrowHead = _objectiveCoordinates.toLocal(target.anchorPoint(direction));
//			_arrowHead = new GraphicCoordinates(0, 0);

			Log.debug ("arrowhead position is "+_arrowHead);
		}

        
		
		protected function redrawBackground() :void 
		{
			const g:Graphics = this.graphics;
			g.clear();
			g.beginFill(SpriteUtil.RED);
			const arrowLeft:Boolean = 
				_rectangle.origin.distanceTo(_arrowHead).xComponent().normalize().equals(Vector.LEFT);
			
			// draw the top
			g.moveTo(_rectangle.x, _rectangle.y);
			g.lineTo(_rectangle.right, _rectangle.y);
			
			// if the arrow head is on the right, go there
			if (! arrowLeft) {
				g.lineTo(_arrowHead.x, _arrowHead.y);
			} 
			g.lineTo(_rectangle.right, _rectangle.bottom);			
			
			// draw the bottom
			g.lineTo(_rectangle.x, _rectangle.bottom);
			
			// if the arrow head is on the left, go there
			if (arrowLeft) {
				g.lineTo(_arrowHead.x, _arrowHead.y);
			}
			g.lineTo(_rectangle.x, _rectangle.y);			
			Log.debug ("after drawing, arrowhead position is "+_arrowHead);
		}
		
		protected function labelText (target:Labellable) :String
		{
			return target.owner.name + "'s " + target.objectName;
		}
		
		public function hide() :void
		{
			visible = false;
		}
		
		protected var _objectiveCoordinates:CoordinateSystem;
		protected var _rectangle:GraphicRectangle;
		protected var _arrowHead:GraphicCoordinates;
		protected var _text:TextField;		
		protected var _objective:Diagram;
		
		// The ideal distance maximum between the label and either the side walls, or the object it's pointing at.
		protected static const SPACING:int = 25;
	}
}