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

		public function displayOwnership (target:Labellable) :void
		{
			const center:GraphicCoordinates = _objective.centerOfView;
			Geometry.position(this, center);			
			_objectiveCoordinates = GraphicCoordinates.ORIGIN.correspondsTo(center);
			
			trace (" label position is: "+x+", "+y);			
			// update the text label
			_text.text = labelText(target);
			
			trace("unnormalized direction is: " + target.graphicCenter.distanceTo(_objective.centerOfView));
			trace("normalized direction is: " + target.graphicCenter.distanceTo(_objective.centerOfView).normalizeF());
			trace("compass direction is: " + target.graphicCenter.distanceTo(_objective.centerOfView).asCompassDiagonal());
			
//			const labelCenter:GraphicCoordinates = target.graphicCenter.translatedBy(target.graphicCenter.distanceTo(_objective.centerOfView).asCompassDiagonal().multiplyByScalar(Config.cellSize.dx)).from(_objectiveCoordinates);
//			const textRectangle:GraphicRectangle = GraphicRectangle.fromText(_text);
//			labelCenter.translatedBy(textRectangle.size.half).applyTo(_text);
			
			const direction:Vector = target.graphicCenter.distanceTo(_objective.centerOfView).xComponent().normalize();
			Geometry.position(_text, _objective.visibleArea.half(Vector.UP).half(direction).center.from(_objectiveCoordinates));			
			
			const rect:GraphicRectangle = new GraphicRectangle(_text.x, _text.y, _text.textWidth, _text.textHeight).paddedBy(10); 
			computeBackground(rect, target);
			
			// redraw the background shape
			redrawBackground();
						
			trace ("owner label at "+Geometry.coordsOf(this));			
			visible = true;	
		}
		
		/**
		 * Compute the position of rectangle that is drawn behind the text, and the position of the
		 * arrowhead.
		 */
		protected function computeBackground (text:GraphicRectangle, target:Labellable) :void
		{
			trace ("objective center is "+_objective.centerOfView);
			
			_rectangle = text;
						
			const direction:Vector = 
				_rectangle.center.distanceTo(target.graphicCenter.from(_objectiveCoordinates)).xComponent().normalize();

			trace ("direction = "+direction);

			_arrowHead = _objectiveCoordinates.toLocal(target.anchorPoint(direction));
//			_arrowHead = new GraphicCoordinates(0, 0);

			trace ("arrowhead position is "+_arrowHead);
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
			trace ("after drawing, arrowhead position is "+_arrowHead);
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
	}
}