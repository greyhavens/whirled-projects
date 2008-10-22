package actions
{	
	import arithmetic.*;
	
	import sprites.PlayerSprite;
	
	public class Movement
	{
		public function Movement(
			player:PlayerCharacter, objective:Objective, targetCell:Cell)
		{		
			_player = player;
			_objective = objective;
			_view = objective.playerView;			
			_targetCell = targetCell;
			_destination = _view.positionInCell(_objective, targetCell.position);

            trace("movement from "+Geometry.coordsOf(_view)+" to "+_destination);
            
			const move:Vector = Geometry.coordsOf(_view).distanceTo(_destination);
			trace ("complete movement is: "+move);
			const cells:Number = move.length / Config.cellSize.dy;
			trace ("which is "+cells+" cells");
			_duration = durationInMillis(cells);
			trace ("duration is "+_duration);
			_delta = move.divideByScalarF(_duration);
			trace ("moving by: "+_delta+" per ms");
		}
		
    	protected function durationInMillis(cellsToTraverse:Number) :int
		{
			return Math.abs(cellsToTraverse*1000 / SPEED);
		}
		
		public function handleFrameEvent(event:FrameEvent) :void
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
				_player.arriveInCell(_targetCell);
				_view.moveToCell(_objective, _targetCell);
 				_objective.scrollViewPointToPlayer();
                _player.actionComplete();               
			} else {
				const step:Vector = _delta.multiplyByScalar(event.duration).toVector();
				Geometry.moveBy(step, _view);
                _objective.scrollViewPointToPlayer();
			}
		}
		
		protected var _view:PlayerSprite;
		protected var _player:PlayerCharacter;
		protected var _objective:Objective;
		protected var _targetCell:Cell;
		protected var _destination:GraphicCoordinates;
		protected var _delta:FloatVector;
		protected var _duration:int; // duration of the complete movement in milliseconds				
		protected var _startTime:Date;		

		public static const SPEED:Number = 4; // speed in cells per second
	}
}