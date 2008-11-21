package sprites
{
	import actions.Climb;
	import actions.Fall;
	import actions.MoveSideways;
	
	import arithmetic.BoardCoordinates;
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	import client.FrameEvent;
	import client.Objective;
	import client.player.Player;
	import client.player.PlayerEvent;
	
	import paths.PathFollower;
	
	import world.Cell;
	
	public class PlayerSprite extends AssetSprite implements PathFollower
	{
		public function PlayerSprite(objective:Objective, player:Player)
		{
			_objective = objective;
			_player = player;
			super(simplePlayer, Config.cellSize.dx, Config.cellSize.dy);
			_player.addEventListener(PlayerEvent.PATH_STARTED, handlePathStarted);
		}

        /**
         * Return the graphics coordinates that puts the player at their resting position within
         * the cell.
         */
        public function positionInCell (objective:Objective, cell:BoardCoordinates) :GraphicCoordinates
        {
            const cellPos:GraphicCoordinates = objective.cellCoordinates(cell);
            return new GraphicCoordinates(
                cellPos.x + (Config.cellSize.dx / 2) - (width / 2),
                cellPos.y + (Config.cellSize.dy - height)
            );
        }
        
        public function moveToCell (objective:Objective, cell:Cell) :void
        {
        	//Log.debug ("positioning player sprite in "+cell);
            moveTo(positionInCell(objective, cell.position));
        }
        
        public function cellBoundary() :GraphicCoordinates
        {
            return new GraphicCoordinates(
                x - ((Config.cellSize.dx / 2) - (width / 2)),
                y - (Config.cellSize.dy - height) 
            );
        }
 
        public function get player () :Player
        {
        	return _player;
        }
        
        public function handlePathStarted (event:PlayerEvent) :void
        {
        	event.player.path.applyTo(this);
        }
        
        /**
         * Move sideways to the given cell.
         */
        public function moveSideways (newCell:BoardCoordinates) :void
        {
            startMovement(new MoveSideways(_player, this, _objective, _objective.cellAt(newCell)));
        }
        
        /**
         * Climb up or down to the given cell.
         */
        public function climb (newCell:BoardCoordinates) :void
        {
            startMovement(new Climb(_player, this, _objective, _objective.cellAt(newCell)));
        }
        
        public function fall (newCell:BoardCoordinates) :void
        {
        	startMovement(new Fall(_player, this, _objective, newCell));
        }
        
        protected function startMovement(action:PlayerAction) :void
        {   
            Log.debug(this+" starting to move");
            
        	_action = action;
        	_objective.frameTimer.addEventListener(FrameEvent.FRAME_START, _action.handleFrameEvent);        	
        }
        
        public function moveComplete () :void
        {
        	_objective.frameTimer.removeEventListener(FrameEvent.FRAME_START, _action.handleFrameEvent);
        	_action = null;
        	Log.debug(this+" completed movement.  Notifying player");
        	_player.pathComplete();
        }
         
        public function moveBy (v:Vector) :void
        {
        	x += v.dx;
        	y += v.dy;
        	dispatchEvent(new ViewEvent(ViewEvent.MOVED, this));
        }
        
        public function moveTo (coords:GraphicCoordinates) :void
        {
        	x = coords.x;
        	y = coords.y;
            dispatchEvent(new ViewEvent(ViewEvent.MOVED, this));        	
        }
         
        /**        
         * Change the y coordinate of this sprite and dispatch a movement event.
         */  
        public function moveVertical (y:int) :void
        {
        	this.y = y;
            dispatchEvent(new ViewEvent(ViewEvent.MOVED, this));            
        }
        
                 
        protected var _action:PlayerAction;
        protected var _objective:Objective;
        protected var _player:Player;

		[Embed(source="../../rsrc/png/simple-player.png")]
		protected static const simplePlayer:Class;			
	}
}