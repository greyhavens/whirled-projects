package cells.wall
{
	import cells.views.Poolable;
	
	import client.Objective;
	
	import sprites.CellSprite;
	
	import world.Cell;

	public class WallView extends CellSprite implements Poolable
	{
		public function WallView(cell:Cell)
		{
			super(cell, wall);
		}

        override public function removeFromObjective(objective:Objective) :void
        {
            super.removeFromObjective(objective);
            objective.pool(this);
        }        

		[Embed(source="../../../rsrc/png/wall.png")]
		public static const wall:Class;		
	}
}
