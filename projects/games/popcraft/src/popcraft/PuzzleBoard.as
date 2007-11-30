package popcraft {

import com.threerings.util.Assert;
import flash.display.Sprite;

public class PuzzleBoard extends Sprite
{
	public function PuzzleBoard (columns :int, rows :int)
	{
		Assert.isTrue(columns > 0);
		Assert.isTrue(rows > 0);
		
		_cols = columns;
		_rows = rows;
	}
	
	protected var _cols :int;
	protected var _rows :int;
	protected var _board :Array;
}

}