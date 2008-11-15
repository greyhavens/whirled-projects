package actions
{
	import arithmetic.BoardCoordinates;
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	import client.FrameEvent;
	import client.Objective;
	import client.player.Player;
	
	import contrib.Easing;
	
	import sprites.PlayerSprite;
	
	import world.Cell;
    
    	
	public class Fall implements PlayerAction
	{
		public function Fall(player:Player, sprite:PlayerSprite, objective:Objective, target:BoardCoordinates)
		{
			_player = player;
			_view = sprite;
			_objective = objective;
		
		    _targetCell = objective.cellAt(target);	
			
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
                _view.moveToCell(_objective, _targetCell);
                _view.moveComplete();               

			} else {
				ease(event);
			}
		}
	
		protected function ease(event:FrameEvent) :void
		{
			// Log.debug("easing time: "+event.since(_startTime) + ", _ystart: " + _yStart + ", _yDelta: " + _yDelta + ", _duration: " + _duration);
			_view.moveVertical(Easing.easeOutBounce(event.since(_startTime), _yStart, _yDelta, _duration));
			// Log.debug ("_view.y: "+_view.y);
		}
	
		protected var _yStart:int;
		protected var _yDelta:int;
		protected var _duration:Number;
		
		protected var _targetCell:Cell;
		protected var _view:PlayerSprite;
		protected var _startTime:Date;
		protected var _destination:GraphicCoordinates;
		protected var _player:Player; 
		protected var _objective:Objective;		
		
		protected static const RATE:int = 3;
	}
}