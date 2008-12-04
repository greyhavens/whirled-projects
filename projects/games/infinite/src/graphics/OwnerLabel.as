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
	import flash.text.TextFieldAutoSize;
	
	import sprites.SpriteUtil;
	
	public class OwnerLabel extends Sprite
	{
		public function OwnerLabel (objective:Diagram)
		{
			_objective = objective;
			_text = new TextField();
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.condenseWhite = true;
			_text.multiline = true;
			_text.background = true;
			_text.backgroundColor = SpriteUtil.PURPLE_DESATURATED;
		    _text.border = false;
		    _text.borderColor = SpriteUtil.BLACK;
			addChild(_text);
            AnnotationShadow.applyTo(this);
 		}

        protected function updateText (target:Labellable) :void
        {
            _text.htmlText = "<textformat leftmargin='4' rightmargin='4'><font size='17' color='#FFFFFF' face='Helvetica, Arial, _sans'>"+
                labelText(target) +"</font></textformat>"
            
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
//            const rect:GraphicRectangle = new GraphicRectangle(_text.x, _text.y, _text.width, _text.height).paddedBy(10); 
			computeBackground(rect, target);
			
			// redraw the background shape
			//redrawBackground();
			
			simpleArrowHead(_arrowHead);
						
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

			Log.debug ("arrowhead position is "+_arrowHead);
		}

        protected function simpleArrowHead(target:GraphicCoordinates) :void
        {
            // set up the graphics context
            const g:Graphics = this.graphics;
            g.clear();
            g.beginFill(SpriteUtil.PURPLE_DESATURATED);
            
            if (target.x > _text.x) {
                // the arrow is pointing to the right
                g.moveTo(_text.x + _text.width, _text.y);
                g.lineTo(target.x, target.y);
                g.lineTo(_text.x + _text.width, _text.y + _text.height);
            } else {
                // the arrow is pointing to the left
                g.moveTo(_text.x, _text.y);
                g.lineTo(target.x, target.y);
                g.lineTo(_text.x, _text.y + _text.height);
            }
            
            g.endFill();
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