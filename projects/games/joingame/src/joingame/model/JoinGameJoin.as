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
            _piecesY = new Array();
            
            _piecesWithHealingPower = new Array();
            
            attackRow = -1;
            _buildCol = -1;
        }
        
        
        public function isContainsPiece(x :int, y :int): Boolean
        {
            for(var i:int  = 0; i < _piecesX.length; i++)
            {
                if(x == _piecesX[i] && y == _piecesY[i])
                {
                    return true;
                } 
            }
            return false;
        }
        
        public function addPiece(x :int, y :int): void
        {
            _piecesX.push(x);
            _piecesY.push(y);
        }
        
        public function toString() :String
        {
            var s :String = "Join[";
            
            for( var k :int = 0; k < _piecesX.length; k++){
                s += " (" + _piecesX[k] + ", " + _piecesY[k] + ")" ; 
            }
            s += "]"
            return s;
        }
        
        public var _widthInPieces: int;
        public var _heighInPiecest: int;
        public var _color: int;
        public var _joinType: int;
        public var _piecesX: Array;
        public var _piecesY: Array;
        public var _piecesWithHealingPower: Array;
        
        public var attackRow:int;
        
        //Attack left (-1) or right (1), or both (0)
        public var attackSide: int;
        
        public var _buildCol: int;
        
        public static const LEFT :int = -1;
        public static const RIGHT :int = 1;
        public static const ATTACK_BOTH :int = 0;
    }
}