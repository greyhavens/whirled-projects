package
{
	import arithmetic.*;
	
	import cells.CellInteractions;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import sprites.*;
	
	public class CellBase extends EventDispatcher implements Cell
	{
		public function CellBase(position:BoardCoordinates) :void 
		{
			_position = position;
		}

		public function get position () :BoardCoordinates
		{
			return _position;
		}

		public function get type () :String
		{
			return "base";
		}
		
		override public function toString () :String
		{
			return type+" cell at "+position;
		}

		public function get view () :DisplayObject
		{
			const s:Sprite = new Sprite();
			SpriteUtil.addBackground(s, UNIT.dx, UNIT.dy, SpriteUtil.GREY);
			labelPosition(s);
			return s;
		}

		protected function registerEventHandlers (source:EventDispatcher) :void
		{
			source.addEventListener(MouseEvent.MOUSE_DOWN, handleCellClicked);			
		}

		protected function handleCellClicked (event:MouseEvent) :void
		{
			dispatchEvent(new CellEvent(CellEvent.CELL_CLICKED, this));			
		}	

		/**
		 * Add a label with the current board position to the supplied container
		 */
		protected function labelPosition (s:DisplayObjectContainer) :void
		{
			const l:TextField = new TextField();
			l.text = "(" + _position.x + ", " + _position.y + ")";
			s.addChild(l);		
		}

		public function addToObjective(objective:Objective) :void
		{
			_objective = objective;
			_objective.showCell(this);
		}

		public function removeFromObjective() :void
		{
			if (_objective != null) {
				_objective.hideCell(this);
				_objective = null;
			}
		}

		public function iterator (board:BoardAccess, direction:Vector) :CellIterator
		{
			return new CellIterator(this, board, direction);
		} 

		/**
		 * Remember the state of this cell when it's scrolled out of view.
		 */
		public function rememberOffBoard() :void
		{
			_objective.remember(this);
		}
								
		/**	
		 * Cell affordances.
		 **
		 *  Deliberate 'relaxation' of style rules here for readability.  
		 */
		public function get climbDownTo() :Boolean { return false; }
		public function get climbUpTo() :Boolean { return false; }
		public function get climbLeftTo() :Boolean { return false; }
		public function get climbRightTo() :Boolean { return false; }
		public function get grip() :Boolean { return true; }
		public function get leave() :Boolean { return true; }
		public function get replacable() :Boolean { return false; }
		public function get canBecomeWindow() :Boolean { return false; }
		
		/**
		 * Cell interactions
		 */
		public function playerHasArrived (player:CellInteractions) :void
		{
			//debug cells don't care whether the player has arrived or not
		}		 				
		
		public function playerBeginsToDepart () :void
		{
 			// debug cells don't care whether the player begins to depart or not			
		}
		
		/**
		 * Most cells are not part of an 'object', however some are part of a composite such
		 * as a ladder.  When presented with another cell, these cells can determine whether
		 * that cell is connected to them or not.
		 */
		public function adjacentPartOf (other:Cell) :Boolean
		{
			return false;
		}
		
		public function isAboveGroundLevel () :Boolean
		{
			return _position.y < 0;
		}
		
		protected var _position:BoardCoordinates;
		
		protected var _objective:Objective;
				
		public static const UNIT:Vector = Config.cellSize;
		
		public static const DEBUG:Boolean = Config.cellDebug;		
	}
}