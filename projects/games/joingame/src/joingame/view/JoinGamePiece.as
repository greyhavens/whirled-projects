package joingame.view
{
	import com.whirled.contrib.simplegame.objects.*;
	import com.whirled.contrib.simplegame.resource.*;
	import com.whirled.contrib.simplegame.tasks.*;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import joingame.*;
	
	public class JoinGamePiece extends Sprite
	{
		private var _color:int;
//		public var _sprite:Sprite;
		private var _size:int;
		public function JoinGamePiece(size:int, type: int = Constants.PIECE_TYPE_NORMAL, colorcode: int = -1)
		{
			super();
//			boardIndex = index;
//			_sprite = new Sprite();
			mouseEnabled = false;
			_size = size;
			if(colorcode >= 0 && colorcode <Constants.PIECE_COLORS_ARRAY.length)
			{ 
				_color = Constants.PIECE_COLORS_ARRAY[colorcode];
			}
			else
			{
				_color = Constants.PIECE_COLORS_ARRAY[randomNumber(0,Constants.PIECE_COLORS_ARRAY.length - 1)];
			}
			_type =type;
			
			update();
			
		}
		public function randomizeColor(): void
		{
			_color =Constants.PIECE_COLORS_ARRAY[randomNumber(0,Constants.PIECE_COLORS_ARRAY.length - 1)];
			update();
		}

			/** 
		* Generate a random number
		* @return Random Number
		* @error throws Error if low or high is not provided
		*/  
		protected function randomNumber(low:Number=NaN, high:Number=NaN):Number
		{
			var low:Number = low;
			var high:Number = high;
		
			if(isNaN(low))
			{
			throw new Error("low must be defined");
			}
			if(isNaN(high))
			{
			throw new Error("high must be defined");
			}
		
			return Math.round(Math.random() * (high - low)) + low;
		}
		
	public function get boardIndex () :int
	{
		return _boardIndex;
	}

	public function set boardIndex (newIndex :int) :void
	{
		_boardIndex = newIndex;
	}
	
	public function get color () :int
	{
		return _color;
	}

	public function set color (newColor :int) :void
	{
		_color = newColor;
		
		
		
			 // load the piece classes if they aren't already loaded
        if (null == SWF_CLASSES)
        {
            SWF_CLASSES = [];
            var swf :SwfResource = (ResourceManager.instance.getResource("puzzlePieces") as SwfResource);
            for each (var className :String in SWF_CLASS_NAMES)
            {
                SWF_CLASSES.push(swf.getClass(className));
            }
        }


//		trace("SWF_CLASSES.length=" + SWF_CLASSES.length);
//        _type = newtype;

        var pieceClass :Class = SWF_CLASSES[_color];
        var pieceMovie :MovieClip = new pieceClass();
		pieceMovie.mouseEnabled = false;
	    pieceMovie.mouseChildren = false;
//		this._size = pieceMovie
//        pieceMovie.x = -(pieceMovie.width * 0.5);
//        pieceMovie.y = -(pieceMovie.height * 0.5);

        pieceMovie.cacheAsBitmap = true;

//        _sprite = new Sprite();
//        _sprite.mouseChildren = false;
//        _sprite.mouseEnabled = false;

		_pieceMovie = pieceMovie;
//        this.addChild(pieceMovie);
        
        
        
		update();
	}
	
	public function get type() :int
	{
		return _type;
	}

	public function set size (newsize :int) :void
	{
		_size = newsize;
		update();	
	}
	public function get size () :int
	{
		return _size;
	}
	
	public function update(): void
	{
		
//		if( _sprite == null)
//		{
//			_sprite = new Sprite();
//		}
		
		if( _pieceMovie != null && contains( _pieceMovie) )
		{
			removeChild( _pieceMovie);		
		}
		
		if(_type ==Constants.PIECE_TYPE_DEAD)
		{
			graphics.clear();
			graphics.beginFill( 0xab6300, 1 );			
			graphics.drawRect( 0 , 0 , _size, _size );
			graphics.beginFill( 0x69635c, 1 );	
			graphics.drawRect( 5 , 5 , _size-10, _size-10 );
			graphics.endFill();
		}
		else if(_type ==Constants.PIECE_TYPE_EMPTY)
		{
			graphics.clear();
			graphics.beginFill( Constants.PIECE_COLOR_EMPTY, 0 );			
			graphics.drawRect( 0 , 0 , _size, _size );
			graphics.endFill();
		}
		else if(_type ==Constants.PIECE_TYPE_NORMAL)
		{
			graphics.clear();
//			if(_pieceMovie != null)
//			{
//				addChild(_pieceMovie);
//			}
			
			graphics.beginFill( Constants.PIECE_COLORS_ARRAY[_color], 1 );			
			graphics.drawRect( 0 , 0 , _size , _size );
			graphics.endFill();
		}
		else if(_type ==Constants.PIECE_TYPE_INACTIVE)
		{
			graphics.clear();
			graphics.beginFill( _color, 0 );			
			graphics.drawRect( 0 , 0 , _size, _size );
			graphics.endFill();
		}
		else if(_type ==Constants.PIECE_TYPE_POTENTIALLY_DEAD)
		{
			addChild(_pieceMovie);
			var opaqueCover :Shape = new Shape();
			opaqueCover.graphics.beginFill( _color, 1 );			
			opaqueCover.graphics.drawRect( 0 , 0 , _size, _size );
			opaqueCover.graphics.beginFill( Constants.PIECE_COLOR_POTENTIALLY_DEAD, 0.7 );			
			opaqueCover.graphics.drawRect( 0 , 0 , _size, _size );
			opaqueCover.graphics.endFill();
			addChild(opaqueCover);
		}
		
	}
	public function set type (newtype :int) :void
	{
	
        
        
        
        
        
        //////////////////////////
        
		if(newtype >= 0 && newtype<=Constants.PIECE_TYPE_POTENTIALLY_DEAD) 
		{
			_type = newtype;
			
		}
		else
			trace("JoinGamePiece, set type not known="+newtype);
		update();
		
	}
	
	public function convertToDeadIfLegal() :Boolean
	{
		if(_type ==Constants.PIECE_TYPE_POTENTIALLY_DEAD || _type ==Constants.PIECE_TYPE_NORMAL) 
		{
			_type =Constants.PIECE_TYPE_DEAD;
			update();
			return true;
		}
		return false;
	}
	
	
//	public function update(): void
//	{
//		graphics.clear();
//		graphics.beginFill( _color, 1 );			
//		graphics.drawRect( 0 , 0 , _size, _size );
//		graphics.endFill();
//	}


//	override public function toString(): String
//	{
//		return " [Piece index="+_boardIndex.toString() + "]";
//	}
//	public function get resourceType () :int
//	{
//		return _resourceType;
//	}

//	public function set resourceType (newType :int) :void
//	{
//		// load the piece classes if they aren't already loaded
//		if (null == SWF_CLASSES) {
//			SWF_CLASSES = [];
//			var swf :SwfResource = (ResourceManager.instance.getResource("puzzlePieces") as SwfResource);
//			for each (var className :String in SWF_CLASS_NAMES) {
//				SWF_CLASSES.push(swf.getClass(className));
//			}
//		}
//
//		_resourceType = newType;
//
//		var pieceClass :Class = SWF_CLASSES[newType];
//		var pieceMovie :MovieClip = new pieceClass();
//
//		pieceMovie.x = -(pieceMovie.width * 0.5);
//		pieceMovie.y = -(pieceMovie.height * 0.5);
//
//		pieceMovie.cacheAsBitmap = true;
//
//		_sprite = new Sprite();
//		_sprite.mouseChildren = false;
//		_sprite.mouseEnabled = false;
//
//		_sprite.addChild(pieceMovie);
//	}

		protected var _boardIndex :int;
		private var _type :int;
		private var _pieceMovie :MovieClip;
		
		
		
		protected static var SWF_CLASSES :Array;
    	protected static const SWF_CLASS_NAMES :Array = [ "piece_01", "piece_02", "piece_03", "piece_04", "piece_05" ];
//	protected var _resourceType :int;

//	protected static var SWF_CLASSES :Array;
//	protected static const SWF_CLASS_NAMES :Array = [ "A", "B", "C", "D" ];







//		public static constConstants.PIECE_TYPE_NORMAL :int = 0;
//		public static constConstants.PIECE_TYPE_DEAD :int = 1;
//		public static constConstants.PIECE_TYPE_EMPTY :int = 2;
//		public static constConstants.PIECE_TYPE_INVISIBLE :int = 3;
//		public static constConstants.PIECE_TYPE_POTENTIALLY_DEAD :int = 4;
//		
//		public static const COLOR_DEAD :int = 0x747474;
//		public static const COLOR_EMPTY :int = 0xffffff;
//		public static const COLOR_POTENTIALLY_DEAD :int = 0x999999;
//		
//		public static constConstants.PIECE_COLORS_ARRAY:Array = new Array(0x1add25, 0xf2ab11, 0x1161f2, 0xf211ab, 0x00dcff);
		
		
	}
}