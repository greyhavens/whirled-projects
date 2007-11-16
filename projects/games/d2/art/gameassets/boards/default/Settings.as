package {

import flash.display.MovieClip;

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
	 *
     *   name:     the board's name, which will be displayed during board selection
	 *
	 *   icon:     the board's icon, which will be displayed during board selection;
     *               the name should refer to a symbol in the library
	 *
	 *   --- board and playable area ---
	 * 
	 *   background:  the board's background; the name should refer to a symbol in the library
	 *
	 *   squares:     how many columns and rows are there on the play area, e.g.
	 *                  [20, 21] means 20 columns, 21 rows
	 *
	 *   size:        total size of the playable area, as width and height in pixels, e.g.
	 *                  [500, 300] means the play area will be 500 pixels by 300 pixels.
	 *
	 *   topleft:     upper left corner of the playable area, in pixels, e.g.
	 *                  [120, 100] means the play area starts at x=120, y=100
     *                NOTE: the entire playable area must fit in the game window, which is 700x500px
	 *
	 * 
	 *   --- unit definition elements ---
	 *   
     */
	public var boards :Array =
	[ 
	  { name:       "Playground",
		icon:       "Level01_BG.jpg",
		background: "Level01_BG",
		
		squares:    [ 17, 22 ],
		size:       [ 510, 440 ],
		topleft:    [ 40, 27 ]
		
      },
	  { name:       "Halloween",
	    icon:       "Level02_BG.jpg",
		background: "Level02_BG",

		squares:    [ 17, 22 ],
		size:       [ 510, 440 ],
		topleft:    [ 40, 27 ]
		
      } 
    ];
}
}
