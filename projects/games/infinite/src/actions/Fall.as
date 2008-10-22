package actions
{
	import arithmetic.BoardIterator;
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	import contrib.Easing;
	
	import sprites.PlayerSprite;
	import client.Objective;	
    import client.FrameEvent;
    
    import world.Cell;
    
    	
	public class Fall implements PlayerAction
	{
		public function Fall(player:PlayerCharacter, objective:Objective)
		{
			_player = player;
			_view = objective.playerView;
			_objective = objective;
			
			// The player will fall until they reach a cell that they can grip
			const search:BoardIterator = new BoardIterator(player.cell.position, Vector.DOWN);
			trace ("player starting to fall from "+player.cell);
			do {
				var test:Cell = objective.cellAt(search.next());
				if (test.grip) {
					_targetCell = test;
				}
			} while (_targetCell == null);
			trace ("falling to "+_targetCell);
			
			_yStart = _view.positionInCell(_objective, player.cell.position).y;
			_yDelta = _view.positionInCell(_objective, _targetCell.position).y - _yStart;
			
			_destination = _view.positionInCell(_objective, _targetCell.position);
			_duration = (_yDelta * 250 / Config.cellSize.multiplyByVector(new Vector(0,1)).length) 
		}

		public function handleFrameEvent(event:FrameEvent):void
		{
			// is this the first event?
			if (_startTime == null) {
				_startTime = event.previousTime;
				_duration -= event.duration / 2;
				_player.cell.playerBeginsToDepart();
			}

			// if we're close enough to the end time finish up
			if (event.currentTime.time - _startTime.time > _duration) {
				// setting the player's position to the target cell sets their graphics position
				// automatically.
				_player.actionComplete();				
				_player.arriveInCell(_targetCell);
				_objective.scrollViewPointToPlayer();
			} else {
				ease(event);
                _objective.scrollViewPointToPlayer();
			}
		}
	
		protected function ease(event:FrameEvent) :void
		{
			// trace("easing time: "+event.since(_startTime) + ", _ystart: " + _yStart + ", _yDelta: " + _yDelta + ", _duration: " + _duration);
			_view.y = Easing.easeOutBounce(event.since(_startTime), _yStart, _yDelta, _duration);
			// trace ("_view.y: "+_view.y);
		}
	
		protected var _yStart:int;
		protected var _yDelta:int;
		protected var _duration:Number;
		
		protected var _targetCell:Cell;
		protected var _view:PlayerSprite;
		protected var _startTime:Date;
		protected var _destination:GraphicCoordinates;
		protected var _player:PlayerCharacter; 
		protected var _objective:Objective;		
		
		protected static const RATE:int = 3;
	}
}