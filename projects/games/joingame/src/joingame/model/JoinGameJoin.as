package joingame.model
{
    /**
     * Represents a type of join of pieces.
     * This information is used to decide the action, e.g. attack  or build up.
     */ 
    public class JoinGameJoin
    {
        public function JoinGameJoin(width: int, height:int, color:int, type:int=0)
        {
            _widthInPieces = width;
            _heighInPiecest = height;
            _color = color;
            _joinType = type;
            _piecesX = new Array();
            _piecesYFromBottom = new Array();
            
            _piecesWithHealingPower = new Array();
            _piecesHealed = new Array();
            
            
            attackRow = -1;
            _buildCol = -1;
            
            _searchIteration = 0;
            _delay = 0;
        }
        
        
        public function isContainsPiece(x :int, y :int): Boolean
        {
            for(var i:int  = 0; i < _piecesX.length; i++)
            {
                if(x == _piecesX[i] && y == _piecesYFromBottom[i])
                {
                    return true;
                } 
            }
            return false;
        }
        
        public function addPiece(x :int, y :int): void
        {
            _piecesX.push(x);
            _piecesYFromBottom.push(y);
        }
        
        public function toString() :String
        {
            var s :String = "Join[";
            
            for( var k :int = 0; k < _piecesX.length; k++){
                s += " (" + _piecesX[k] + ", " + _piecesYFromBottom[k] + ")" ; 
            }
            s += "]"
            return s;
        }
        
        /**
        * Measures the delay for animating the join, 
        * as succesive searches and joins found should
        * introduce a delay in the subsequent animations.
        */
        public var _searchIteration: int;
        
        /**
        * Delay in microseconds before animating the join.
        */
        public var _delay: Number;
        public var _widthInPieces: int;
        public var _heighInPiecest: int;
        public var _color: int;
        public var _joinType: int;
        public var _piecesX: Array;
        public var _piecesYFromBottom: Array;
        public var _piecesWithHealingPower: Array;
        public var _piecesHealed: Array;
        
        public var attackRow:int;
        public var _lastSwappedX: int;
        
        //Attack left (-1) or right (1), or both (0)
        public var attackSide: int;
        
        public var _buildCol: int;
        
        public static const LEFT :int = -1;
        public static const RIGHT :int = 1;
        public static const ATTACK_BOTH :int = 0;
    }
}