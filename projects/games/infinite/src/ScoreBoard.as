package
{
	import com.whirled.game.NetSubControl;
	
	public class ScoreBoard extends SlotObject
	{
		public function ScoreBoard(control :NetSubControl)
		{
			super(control, "scoreboard", "1");
		}

        public void setScore(id:int, value:Score) 
        {
        	writeInt(id, score);
        }        
        
        public void score (id:int) :int 
        {
        	return readInt(id, score);
        }
	}
}