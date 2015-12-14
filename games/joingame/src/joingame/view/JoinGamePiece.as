package joingame.view
{
    import com.whirled.contrib.simplegame.objects.*;
    import com.whirled.contrib.simplegame.resource.*;
    import com.whirled.contrib.simplegame.tasks.*;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Sprite;
    
    import joingame.*;
    
    public class JoinGamePiece extends SceneObject 
        implements ChangeableTargetLocation
    {

        public function JoinGamePiece(size:int = Constants.PUZZLE_TILE_SIZE, type: int = Constants.PIECE_TYPE_NORMAL, colorcode: int = -1)
        {
            super();
            if (null == SWF_CLASSES)
            {
                SWF_CLASSES = [];
                var swf :SwfResource = (ResourceManager.instance.getResource("puzzlePieces") as SwfResource);
                for each (var className :String in SWF_CLASS_NAMES)
                {
                    SWF_CLASSES.push(swf.getClass(className));
                }
                
                SWF_CLASSES_HORIZ = [];
                for each (className in SWF_CLASS_NAMES_HORIZ)
                {
                    SWF_CLASSES_HORIZ.push(swf.getClass(className));
                }
                
                SWF_CLASSES_VERT = [];
                for each (className in SWF_CLASS_NAMES_VERT)
                {
                    SWF_CLASSES_VERT.push(swf.getClass(className));
                }
            }
        
        
//            boardIndex = index;
//            _sprite = new Sprite();
//            mouseEnabled = false;

            _sprite = new Sprite();
            _sprite.mouseEnabled = false;
            _sprite.mouseChildren = false;
            
            _size = size;
            _color = colorcode;
            _visibiltyDependsOnY = false;
            
//            if(colorcode >= 0 && colorcode < Constants.PIECE_COLORS_ARRAY.length)
//            { 
//                _color = Constants.PIECE_COLORS_ARRAY[colorcode];
//            }
//            else
//            {
//                _color = Constants.PIECE_COLORS_ARRAY[randomNumber(0,Constants.PIECE_COLORS_ARRAY.length - 1)];
//            }
            _type = type;
            
            _inactivecover = new Shape();
            _inactivecover.graphics.beginFill( 1, 0.0 );            
            _inactivecover.graphics.drawRect( -_size/2 , -_size/2 , _size, _size );
            _inactivecover.graphics.endFill();
                
            _potentiallyDeadCover = new Shape();
            _potentiallyDeadCover.graphics.beginFill( Constants.PIECE_COLORS_ARRAY[_color], 1 );            
            _potentiallyDeadCover.graphics.drawRect( -_size/2 , -_size/2 , _size, _size );
            _potentiallyDeadCover.graphics.endFill();
            
            _opaqueCover = new Shape();
            _opaqueCover.graphics.beginFill( Constants.PIECE_COLOR_POTENTIALLY_DEAD, 0.3 );            
            _opaqueCover.graphics.drawRect( 0 , 0 , _size, _size );
            _opaqueCover.graphics.endFill();
            
            updateImage();
            
        }
        public function randomizeColor(): void
        {
            _color = Constants.PIECE_COLORS_ARRAY[randomNumber(0,Constants.PIECE_COLORS_ARRAY.length - 1)];
            updateImage();
        }


    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    /** Called once per update tick. (Subclasses can override this to do something useful.) */
    override protected function update (dt :Number) :void
    {
        if( _visibiltyDependsOnY && !visible) {
            makeVisibleWhenOverYTrigger();
        }
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
//        if (null == SWF_CLASSES)
//        {
//            SWF_CLASSES = [];
//            var swf :SwfResource = (ResourceManager.instance.getResource("puzzlePieces") as SwfResource);
//            for each (var className :String in SWF_CLASS_NAMES)
//            {
//                SWF_CLASSES.push(swf.getClass(className));
//            }
//        }


//        trace("SWF_CLASSES.length=" + SWF_CLASSES.length);
//        _type = newtype;


//        trace("creating the pieceMovie from the class");
        var pieceClass :Class = SWF_CLASSES[_color];
        _pieceMovie = new pieceClass();
        _pieceMovie.mouseEnabled = false;
        _pieceMovie.mouseChildren = false;
//        _pieceMovie.x = -(_pieceMovie.width * 0.5);
//        _pieceMovie.y = -(_pieceMovie.height * 0.5);

        _pieceMovie.cacheAsBitmap = true;
        
        updateImage();
    }
    
    
    public function convertToEmpty() :void
    {
        this.type = Constants.PIECE_TYPE_EMPTY;
        trace("!!!!!!! convertToEmpty " + _boardIndex);
    }
    
    
    public function get type() :int
    {
        return _type;
    }

    public function set size (newsize :int) :void
    {
        _size = newsize;
        updateImage();    
    }
    public function get size () :int
    {
        return _size;
    }
    
    public function updateImage(): void
    {
        for each (var dis :DisplayObject in [_opaqueCover, _potentiallyDeadCover, _inactivecover, _pieceMovie]) {
            if( dis != null && _sprite.contains( dis ) ) {
                _sprite.removeChild( dis );
            }
        }
        
        
        
        
//        while( _sprite.numChildren > 0) {
//            _sprite.removeChildAt( 0 );
//        }
        
        if(_type == Constants.PIECE_TYPE_DEAD)
        {
            var pieceClass :Class = SWF_CLASSES[0];
            _pieceMovie = new pieceClass();
            _pieceMovie.mouseEnabled = false;
            _pieceMovie.mouseChildren = false;
            _pieceMovie.cacheAsBitmap = true;
            _sprite.addChild(_pieceMovie);
            
            
//            _pieceMovie.x = -(_pieceMovie.width * 0.5);
//            _pieceMovie.y = -(_pieceMovie.height * 0.5);
        }
        else if(_type == Constants.PIECE_TYPE_EMPTY)
        {
//            var deadcover :Shape = new Shape();
//            deadcover.graphics.lineStyle(1, Constants.PIECE_COLOR_EMPTY, 1 );            
//            deadcover.graphics.drawRect( -_size/2 , -_size/2 , _size, _size );
            _sprite.addChild(_inactivecover);
            
        }
        else if(_type == Constants.PIECE_TYPE_NORMAL)
        {
            if(ANIMATED_PIECES){
                if(_pieceMovie != null){
                    _sprite.addChild(_pieceMovie);
//                    _pieceMovie.x = -(_pieceMovie.width * 0.5);
//                    _pieceMovie.y = -(_pieceMovie.height * 0.5);
                }
                else {
//                    trace("Animated pieces chosen, but the pieceMovie is null");
                }
            }
            else{
                
                var cover :Shape = new Shape();
                cover.graphics.beginFill( Constants.PIECE_COLORS_ARRAY[_color], 1 );            
                cover.graphics.drawRect( -_size/2 , -_size/2 , _size, _size );
                cover.graphics.endFill();
                _sprite.addChild(cover);
            }
            
        }
        else if(_type == Constants.PIECE_TYPE_INACTIVE)
        {
//            var inactivecover :Shape = new Shape();
//            inactivecover.graphics.beginFill( 1, 0.0 );            
//            inactivecover.graphics.drawRect( -_size/2 , -_size/2 , _size, _size );
//            inactivecover.graphics.endFill();
            _sprite.addChild(_inactivecover);
        }
        else if(_type == Constants.PIECE_TYPE_POTENTIALLY_DEAD)
        {
            if(ANIMATED_PIECES){
                if(_pieceMovie != null){
                    _sprite.addChild(_pieceMovie);
//                    _pieceMovie.x = -(_pieceMovie.width * 0.5);
//                    _pieceMovie.y = -(_pieceMovie.height * 0.5);
                }
            }
            else{
                
//                var potentiallyDeadCover :Shape = new Shape();
//                potentiallyDeadCover.graphics.beginFill( Constants.PIECE_COLORS_ARRAY[_color], 1 );            
//                potentiallyDeadCover.graphics.drawRect( -_size/2 , -_size/2 , _size, _size );
//                potentiallyDeadCover.graphics.endFill();
                _sprite.addChild(_potentiallyDeadCover);
            
            }
            
//            var opaqueCover :Shape = new Shape();
//            opaqueCover.graphics.beginFill( Constants.PIECE_COLOR_POTENTIALLY_DEAD, 0.3 );            
//            opaqueCover.graphics.drawRect( 0 , 0 , _size, _size );
//            opaqueCover.graphics.endFill();
            _sprite.addChild(_opaqueCover);
        }
    }
    
    public function set type (newtype :int) :void
    {
        if(newtype >= 0 && newtype <= Constants.PIECE_TYPE_POTENTIALLY_DEAD) 
        {
            _type = newtype;
        }
        else
            trace("JoinGamePiece, set type not known="+newtype);
        updateImage();
    }
    
    public function convertToDeadIfLegal() :Boolean
    {
        if(_type ==Constants.PIECE_TYPE_POTENTIALLY_DEAD || _type ==Constants.PIECE_TYPE_NORMAL) 
        {
            _type =Constants.PIECE_TYPE_DEAD;
            updateImage();
            return true;
        }
        return false;
    }
//    public function get x () :int
//    {
//        return _sprite.x;
//    }
//    
//    public function get x () :int
//    {
//        return _sprite.x;
//    }
    
//    public function update(): void
//    {
//        graphics.clear();
//        graphics.beginFill( _color, 1 );            
//        graphics.drawRect( 0 , 0 , _size, _size );
//        graphics.endFill();
//    }


    override public function toString(): String
    {
        return " [Piece index="+_boardIndex.toString() + ", color=" + color + ", type=" + type + "]";
    }
    
    public function convertToNormal() :void
    {
        this.type = Constants.PIECE_TYPE_NORMAL;
    }
    
    public function toHorizontalJoin() :void 
    {
        var pieceClass :Class = SWF_CLASSES_HORIZ[_color];
        _pieceMovie = new pieceClass();
        _pieceMovie.mouseEnabled = false;
        _pieceMovie.mouseChildren = false;
        _pieceMovie.cacheAsBitmap = true;
        updateImage();
    }
    
    public function toVerticalJoin() :void 
    {
        var pieceClass :Class = SWF_CLASSES_VERT[_color];
        _pieceMovie = new pieceClass();
        _pieceMovie.mouseEnabled = false;
        _pieceMovie.mouseChildren = false;
        _pieceMovie.cacheAsBitmap = true;
        updateImage();
    }
    
    public function makeVisibleWhenOverYTrigger() :void
    {
        if( y >= _yTrigger) {
            visible = true;
            _visibiltyDependsOnY = false;
        }
    }


    public function get targetX() :int
    {
        return _targetX;
    }
    
    public function get targetY() :int
    {
        return _targetY;
    } 
        
        
//    public function get resourceType () :int
//    {
//        return _resourceType;
//    }

//    public function set resourceType (newType :int) :void
//    {
//        // load the piece classes if they aren't already loaded
//        if (null == SWF_CLASSES) {
//            SWF_CLASSES = [];
//            var swf :SwfResource = (ResourceManager.instance.getResource("puzzlePieces") as SwfResource);
//            for each (var className :String in SWF_CLASS_NAMES) {
//                SWF_CLASSES.push(swf.getClass(className));
//            }
//        }
//
//        _resourceType = newType;
//
//        var pieceClass :Class = SWF_CLASSES[newType];
//        var _pieceMovie :MovieClip = new pieceClass();
//
//        _pieceMovie.x = -(_pieceMovie.width * 0.5);
//        _pieceMovie.y = -(_pieceMovie.height * 0.5);
//
//        _pieceMovie.cacheAsBitmap = true;
//
//        _sprite = new Sprite();
//        _sprite.mouseChildren = false;
//        _sprite.mouseEnabled = false;
//
//        _sprite.addChild(_pieceMovie);
//    }

        protected var _boardIndex :int;
        private var _type :int;
        private var _pieceMovie :MovieClip;
        
        
        public var _sprite :Sprite;
        
        
        protected static var SWF_CLASSES :Array;
        protected static const SWF_CLASS_NAMES :Array = [ "piece_00", "piece_01", "piece_02", "piece_03", "piece_04", "piece_05" ];
        
        protected static var SWF_CLASSES_HORIZ :Array;
        protected static const SWF_CLASS_NAMES_HORIZ :Array = [ "piece_00_horiz", "piece_01_horiz", "piece_02_horiz", "piece_03_horiz", "piece_04_horiz", "piece_05_horiz" ];
        
        protected static var SWF_CLASSES_VERT :Array;
        protected static const SWF_CLASS_NAMES_VERT :Array = [ "piece_00_vert", "piece_01_vert", "piece_02_vert", "piece_03_vert", "piece_04_vert", "piece_05_vert" ];
        
        private var _color :int;
        private var _size :int;
        
        /**
        * Used in animations.  When this y >= _yTrigger, 
        * make visible.
        */
        public var _yTrigger :int;
        
        public var _targetX :int;
        public var _targetY :int;
        
        public var _visibiltyDependsOnY :Boolean;
        
        protected var _potentiallyDeadCover :Shape;
        protected var _inactivecover :Shape;
        protected var _opaqueCover :Shape;
        
        public static const ANIMATED_PIECES :Boolean = true;
        
//    protected var _resourceType :int;

//    protected static var SWF_CLASSES :Array;
//    protected static const SWF_CLASS_NAMES :Array = [ "A", "B", "C", "D" ];







//        public static constConstants.PIECE_TYPE_NORMAL :int = 0;
//        public static constConstants.PIECE_TYPE_DEAD :int = 1;
//        public static constConstants.PIECE_TYPE_EMPTY :int = 2;
//        public static constConstants.PIECE_TYPE_INVISIBLE :int = 3;
//        public static constConstants.PIECE_TYPE_POTENTIALLY_DEAD :int = 4;
//        
//        public static const COLOR_DEAD :int = 0x747474;
//        public static const COLOR_EMPTY :int = 0xffffff;
//        public static const COLOR_POTENTIALLY_DEAD :int = 0x999999;
//        
//        public static constConstants.PIECE_COLORS_ARRAY:Array = new Array(0x1add25, 0xf2ab11, 0x1161f2, 0xf211ab, 0x00dcff);
        
        
    }
}