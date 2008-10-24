package sprites
{
	import arithmetic.BoardCoordinates;
	import arithmetic.Geometry;
	import arithmetic.GraphicCoordinates;
	
	import client.Objective;
	
	import world.Cell;
	import client.player.Player;
	
	public class PlayerSprite extends AssetSprite
	{
		public function PlayerSprite(player:Player)
		{
			_player = player;
			super(simplePlayer, Config.cellSize.dx, Config.cellSize.dy);
		}

        /**
         * Return the graphics coordinates that puts the player at their resting position within
         * the cell.
         */
        public function positionInCell (objective:Objective, cell:BoardCoordinates) :GraphicCoordinates
        {
            const cellPos:GraphicCoordinates = objective.cellCoordinates(_player.cell.position);
            return new GraphicCoordinates(
                cellPos.x + (Config.cellSize.dx / 2) - (width / 2),
                cellPos.y + (Config.cellSize.dy - height)
            );
        }
        
        public function moveToCell (objective:Objective, cell:Cell) :void
        {
        	trace ("positioning player sprite in "+cell);
            Geometry.position(this, positionInCell(objective, cell.position));
        }
        
        public function cellBoundary() :GraphicCoordinates
        {
            return new GraphicCoordinates(
                x - ((Config.cellSize.dx / 2) - (width / 2)),
                y - (Config.cellSize.dy - height) 
            );
        }
        
        protected var _player:Player;

		[Embed(source="../../rsrc/png/simple-player.png")]
		protected static const simplePlayer:Class;			
	}
}