package cells
{
	import arithmetic.*;
	
	import server.Messages.CellState;
	
	import world.Cell;
	import world.board.*;
	import world.level.Level;
	
	public class CellBase implements Cell
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
		
		public function get objectName () :String
		{
			return "cell that needs debugging";
		}
		
		public function toString () :String
		{
			return type+" cell at "+position;
		}

		/**
		 * Add this cell to the objective.
		 */
		public final function addToObjective (objective:CellObjective) :void
		{
			_objective = objective;
			showView(objective);
		}

		public function addToLevel (level:Level) :void
		{
			_level = level;
		}
		
		/**
		 * Show all of the display objects associated with this cell.
		 */
		protected function showView (objective:CellObjective) :void
		{
			_objective.showCell(this);
		}

		/**
		 * Remove this cell from the objective.
		 */
		public final function removeFromObjective() :void
		{
			if (_objective != null) {
				hideView(_objective);
				_objective = null;
			}
		}
		
		/**
		 * Hide all of the display objects associated with this cell.
		 */
		protected function hideView (objective:CellObjective) :void
		{
			objective.hideCell(this);
		}

		public function iterator (board:BoardAccess, direction:Vector) :CellIterator
		{
			return new CellIterator(this, board, direction);
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
        public function get canBeStartingPosition() :Boolean { return false; }
		
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
		
		public function sameRowAs (other:Cell) :Boolean
		{
			return other.position.y == this.position.y;
		}
		
		public function canEnterBy (d:Vector) :Boolean
		{
			if (d.equals(Vector.LEFT)) {
				return this.climbLeftTo;
			} else if (d.equals(Vector.RIGHT)) {
				return this.climbRightTo;
			} else if (d.equals(Vector.UP)) {
				return this.climbUpTo;
			} else if (d.equals(Vector.DOWN)) {
				return this.climbDownTo;
			}
			return false;			
		}
		
		public function get owner () :Owner
		{
			return Nobody.NOBODY;
		}
				
		public function get code () :int
		{
			throw new Error(this + " has not been assigned a distinct code");
		}			
		
		public function get state () :CellState
		{
			return new CellState(code, position);
		}
		
		public function updateState (board:BoardInteractions, state:CellState) :void
		{
		    if (state.code != code) {
		    	const replacement:Cell = state.newCell(this);
		    	replacement.addToLevel(_level);
		        board.replace(replacement);
		    }
		}
		
		/**
		 * Cause the current state of the cell to be distributed to relevant clients.
		 */
		protected function distributeState () :void
		{
			_level.distributeState(this); 
		}
		
		protected var _position:BoardCoordinates;
		
		protected var _objective:CellObjective;

		protected var _level:Level;
				
		public static const UNIT:Vector = Config.cellSize;		
	}
}