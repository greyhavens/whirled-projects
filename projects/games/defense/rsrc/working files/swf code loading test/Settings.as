package {

import flash.display.*;

public class Settings extends MovieClip
{
	public function Settings () 
	{
		super();
	}
	
	public function testfn () :int { return 42; }
	public static function statictestfn () :int { return 42; }
	
	public var testvar :Array = [ 1, 2, 3 ];
	public static var statictestvar :Array = [ 1, 2, 3 ];
}
}