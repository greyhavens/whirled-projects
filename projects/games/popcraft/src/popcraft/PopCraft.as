//
// $Id$

package popcraft {

import com.whirled.WhirledGameControl;
import com.threerings.util.Assert;

import core.CoreApp;

[SWF(width="700", height="500")]
public class PopCraft extends CoreApp
{
	/**
	 * Returns the singleton PopCraft instance
	 */
	public static function get instance() :PopCraft
	{
		Assert.isTrue(null != g_instance);
		return g_instance;
	}
	
    public function PopCraft ()
    {
    	Assert.isTrue(null == g_instance);
    	g_instance = this;
    	
    	_gameCtrl = new WhirledGameControl(this);
    	_board = new PuzzleBoard(6, 6);
    }
    
    public function get control () :WhirledGameControl
    {
    	return _gameCtrl;
    }
    
    public function get config () :Object
    {
    	return _gameCtrl.getConfig();
    }
    
    public function get board () :PuzzleBoard
    {
    	return _board;
    }
    
    protected static var g_instance :PopCraft;
    
    protected var _gameCtrl :WhirledGameControl;
    protected var _board :PuzzleBoard;
}

}
