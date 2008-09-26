package graphics
{
	import arithmetic.GraphicCoordinates;
	import arithmetic.GraphicRectangle;
	import arithmetic.Vector;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import sprites.SpriteUtil;
	
	public class OwnerLabel extends Sprite
	{
		public function OwnerLabel (objective:Objective)
		{
			_objective = objective;
			_text = new TextField();
			addChild(_text);
		}	

		public function displayOwnership (target:Labellable) :void
		{
			// the coordinate system of the label is the same coordinate system as the target
			x = 0;
			y = 0;
			
			trace (" label position is: "+x+", "+y);
			
			// update the text label
			_text.text = labelText(target);
			_text.x = 0;
			_text.y = 0;
			
			const rect:GraphicRectangle = new GraphicRectangle(0,0, _text.textWidth, _text.textHeight); 
			computeBackground(rect, target);			
			
			// redraw the background shape
			redrawBackground();
			
			x = target.view.x - (_text.textWidth + Config.cellSize.dy);
			y = target.view.y;
			visible = true;	
		}
		
		/**
		 * Compute the position of rectangle that is drawn behind the text, and the position of the
		 * arrowhead.
		 */
		protected function computeBackground (text:GraphicRectangle, target:Labellable) :void
		{
			trace ("objective center is "+_objective.centerPoint);
			
			_rectangle = text;
			// because the coordinate system of the label shape itself is the same as that of the 
			// cell, we can simply use the anchorpoint directly.
			_arrowHead = target.anchorPoint(
				_objective.distanceTo(target.graphicCenter).xComponent().normalize());
				
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
		}
		
		protected function labelText (target:Labellable) :String
		{
			return target.owner.name + "'s " + target.objectName;
		}
		
		public function hide() :void
		{
			visible = false;
		}

		protected var _rectangle:GraphicRectangle;
		protected var _arrowHead:GraphicCoordinates;

		protected var _text:TextField;
		
		protected var _objective:Objective;
	}
}