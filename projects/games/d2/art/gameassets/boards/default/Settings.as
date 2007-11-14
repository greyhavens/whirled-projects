package {

import flash.display.*;


/**
 * A Settings class needs to provide an array of level definitions. See the description 
 * of the levelDefinitions member variable for details. 
 */
public class Settings extends MovieClip
{
	public function Settings () 
	{
		super();
	}
	
	/**
	 * Each board definition contains the following data:
     *   name:     the board's name, which will be displayed during board selection
	 *   icon:     the board's icon, which will be displayed during board selection;
     *               the name should refer to a symbol in the library
	 *   board:    the board's background; 
	 *               the name should refer to a symbol in the library
     */
	public var boards :Array =
	[ { name:  "Playground",
	    icon:  "Level01_BG.jpg",
		board: "Level01_BG"
	  },
	  { name:  "Halloween",
	    icon:  "Level02_BG.jpg",
		board: "Level02_BG"
	  } 
	  ];
	 
}
}