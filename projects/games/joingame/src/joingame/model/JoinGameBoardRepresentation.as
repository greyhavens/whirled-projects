package joingame.model
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.ClassUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    import com.threerings.util.Random;
    import com.whirled.contrib.simplegame.util.ObjectSet;
    import com.whirled.game.GameControl;
    
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import joingame.AppContext;
    import joingame.Constants;
    import joingame.net.InternalJoinGameEvent;
    
    /**
     * A representation of the game board.  This is used by the server and the client.
     * The difference being, the client version updates the graphical representation and is dependent
     * on the server (via JoinGameModel) for updates.  The server version is the authority with no display hooks.  
     * This class does not request for changes to itself; that is left to the View/Controller classes
     * such as JoinGameBoardsView
     */
    public class JoinGameBoardRepresentation extends EventDispatcher
    {
        public function JoinGameBoardRepresentation( playerid :int = -1, ctrl :GameControl = null )//rows:int, cols:int,
        {
            Log.setLevel(ClassUtil.getClassName(JoinGameBoardRepresentation), Log.WARNING);
            
            _playerID = playerid;
            
            if(ctrl != null) {
                getFromPropertySpaces( playerid, ctrl);
            }
            else {
            
                _boardPieceColors = new Array();
                _boardPieceTypes = new Array();
                
                
            }
            
            _bottomRowTimer = new Timer(Constants.TIME_UNTIL_DEAD_BOTTOM_ROW_REMOVAL, 1);
            _bottomRowTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerEnd);
            _lastSwap = [0,0,0,0];
            _state = STATE_ACTIVE;
//            _isGettingKnockedOut = false;
            
        }

        
        public function startBottomRowTimer() :void
        {
            if( !_bottomRowTimer.running) {
                _bottomRowTimer.start();    
            }
            
        }
        
        public function stopBottomRowTimer() :void
        {
            _bottomRowTimer.reset();
        }
        
        
        public function isBottomRowDead() :Boolean 
        {
            var isBottomRowAlreadyDead :Boolean = true;
            for(var i :int = 0; i < _cols; i++){
                var pieceType :int = _boardPieceTypes[ coordsToIdx(i, _rows - 1) ] as int;
                if( pieceType == Constants.PIECE_TYPE_NORMAL){
                    isBottomRowAlreadyDead = false;
                    break;
                }
            }    
            return isBottomRowAlreadyDead; 
        }
        
        
        private function timerEnd(event: TimerEvent):void
        {
            _bottomRowTimer.reset();
            var isBottomRowDead: Boolean = true;
            for(var i: int = 0; i < _cols; i++) {
                var piecetype : int = _boardPieceTypes[ coordsToIdx(i, _rows - 1) ] as int;
                if(piecetype == Constants.PIECE_TYPE_NORMAL){
                    isBottomRowDead = false;
                    break;
                }
            }
            
            if(isBottomRowDead) {
                var removeRowEvent :InternalJoinGameEvent = new InternalJoinGameEvent( this.playerID, InternalJoinGameEvent.REMOVE_ROW_NOTIFICATION);
                dispatchEvent( removeRowEvent );
            }
        }
        
        
        public function destroy(): void
        {
            _bottomRowTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerEnd);
            _bottomRowTimer.stop();
            
        }
        
        public function removeRow( row :int ) :void
        {
            _boardPieceTypes.splice( row*_cols, _cols);
            _boardPieceColors.splice( row*_cols, _cols);
            _rows--;
        }
        
        public function clearRow( row :int ) :void
        {
            for( var i :int = 0; i < _cols; i++) {
                if( _boardPieceTypes[ coordsToIdx(i, row) ] != Constants.PIECE_TYPE_INACTIVE) {
                    _boardPieceTypes[ coordsToIdx(i, row) ] = Constants.PIECE_TYPE_EMPTY;
                }
            }
        }
        
        public function get visiblePuzzleHeightInPieces() :int
        {
            var height :int = 0;
            for( var j :int = _rows - 1; j >= 0; j--){
                var isVisiblePiece :Boolean = false;
                for( var i :int = _cols - 1; i >= 0; i--){
                    var type :int = _boardPieceTypes[ coordsToIdx( i, j) ] as int;
                    if(  type == Constants.PIECE_TYPE_NORMAL || type == Constants.PIECE_TYPE_POTENTIALLY_DEAD || type == Constants.PIECE_TYPE_DEAD) {
                        isVisiblePiece = true;
                        break;
                    }
                }
                if( isVisiblePiece ) {
                    height++;
                } 
            }    
            return height;
        }
        public function movePieceToLocationAndShufflePieces(index1 :int, index2 :int) :void
        {
//            trace("Model: delta confirmed=" + index1 + " to " + index2 ); 
            var px1 :int = idxToX(index1);
            var py1 :int = idxToY(index1);
            var px2 :int = idxToX(index2);
            var py2 :int = idxToY(index2);
            
            if(px1 != px2)
            {
                return;
            }
            
            var increment:int = py1 > py2 ? -1 : 1;
            //Swap up or down, depending on the relative position of the pieces.
            for( var j:int = py1; py1 > py2 ? j > py2 : j < py2 ; j+= increment)
            {
                var swap1:int  = coordsToIdx(px1, j);
                var swap2:int  = coordsToIdx(px1, j + increment);
                
                swapPieces (swap1,swap2);
            }
        }
        
        
        public function swapPieces (index1 :int, index2 :int) :void
        {
            var temp:int = _boardPieceColors[index1];
            _boardPieceColors[index1] = _boardPieceColors[index2];
            _boardPieceColors[index2] = temp;
            
            temp = _boardPieceTypes[index1];
            _boardPieceTypes[index1] = _boardPieceTypes[index2];
            _boardPieceTypes[index2] = temp;
            
            
            _lastSwap[0] = idxToX(index1);
            _lastSwap[1] = idxToY(index1);
            _lastSwap[2] = idxToX(index2);
            _lastSwap[3] = idxToY(index2);
        }
        
        
        public function coordsToIdx (x :int, y :int) :int
        {
            return (y * _cols) + x;
        }
    
        public function idxToX (index :int) :int
        {
            return (index % _cols);
        }
        
        public function idxToY (index :int) :int
        {
            return (index / _cols);
        }
        
        public function isPieceAt (x :int, y :int) :Boolean
        {
            return x >= 0 && x < _cols && y >= 0 && y < _rows;
        }
        
        
        /**
         * Returns an array of arrays of ints representing 
         * the state of the game.
         * This representation *could* be much more compact, 
         * however it is only sent once, from then on deltas
         * are sent.  So optimization will be implemented if
         * actually needed.
         */
        public function getBoardAsCompactRepresentation(): Array
        {
            return [_playerID, _rows, _cols, _boardPieceColors.slice(), _boardPieceTypes.slice(), _seed, _numberOfCallsToRandom, _state, _isComputerPlayer ? 1 : 0, _computerPlayerLevel];
        }
        

        
        public function getPieceTypeAt(i:int, j:int): int
        {
            return _boardPieceTypes[ coordsToIdx(i, j) ];
        }
        
        public function getPieceColorAt(i:int, j:int): int
        {
            return _boardPieceColors[ coordsToIdx(i, j) ];
        }
        
        public function set playerID(newID:int):void
        {
            _playerID = newID;
        }
        
        public function get playerID():int
        {
            return _playerID;
        }
        
        
        

        /**
         * Checks a board for joins and returns those found.
         * This must be called until no joins are found, otherwise the
         * board might be left with joins not acted upon.
         */
        public function checkForJoins(): Array
        {
            var joins: Array = new Array();
            
            var pieceIndex: int;
            var i: int;
            var minx:int;
            var maxx:int;
            var miny:int;
            var maxy:int;
            var join: JoinGameJoin;
            var piecex:int;
            var piecey:int; 
                
                
                //Joins found in this cycle, afterwards pieces fall and these joins are not related to the others found.
                var tempjoins: Array = new Array();
                var piecesToRemove: ObjectSet = new ObjectSet();//Contains piece indices
                var piecesWithHealingPower: Array = new Array();//Contains piece indices
                
                for(var boardIndex:int  = 0; boardIndex < _boardPieceColors.length; boardIndex++)
                {
                    if(isPieceInJoins(tempjoins, boardIndex))
                    {
                        continue;
                    }
                    
                    
                    var a: Array = findHorizontallyConnectedSimilarPiecesAtLeastXlong (idxToX( boardIndex ), idxToY( boardIndex ), Constants.CONNECTION_MINIMUM);
                    var b: Array = findVerticallyConnectedSimilarPiecesAtLeastXlong (idxToX( boardIndex), idxToY( boardIndex), Constants.CONNECTION_MINIMUM);
                
                    minx = _cols;
                    maxx = 0;
                    miny = _rows;
                    maxy = 0;

                    if(a.length >= Constants.CONNECTION_MINIMUM && b.length >= Constants.CONNECTION_MINIMUM)
                    {
                        
                        join = new JoinGameJoin(a.length, b.length, _boardPieceColors[boardIndex], 0);
                        addPiecesToHorizontalJoin(a);
                        addPiecesToVerticalJoin(b);
                        addPiecesWithHealingPower();
                        
                        //Find out which pieces have the same row, this is the target row (from the bottom)
                        tempjoins.push(join);
                    } 
                    else if(a.length >= Constants.CONNECTION_MINIMUM)
                    {
                        join = new JoinGameJoin(a.length, 1, _boardPieceColors[boardIndex], 0);
                        addPiecesToHorizontalJoin(a);
                        addPiecesWithHealingPower();
                        tempjoins.push(join);
                    }
                    else if(b.length >= Constants.CONNECTION_MINIMUM)
                    {
                        
                        join = new JoinGameJoin(a.length, b.length, _boardPieceColors[boardIndex], 0);
                        addPiecesToVerticalJoin(b);
                        addPiecesWithHealingPower();
                        tempjoins.push(join);
                        
                        
                    }
                }
                
//                //If there are "dead" pieces adjacent to the cleared pieces, "heal" them
                if(Constants.HEALING_ALLOWED)
                {
                    for(i = 0; i < piecesWithHealingPower.length; i++)
                    {
                        piecex = idxToX( piecesWithHealingPower[i] );
                        piecey = idxToY( piecesWithHealingPower[i] );
                        
                        join._piecesWithHealingPower.push( [i,convertFromTopYToFromBottomY(piecey)]); 
                        
                        
                        var adjacentPiecesIndicies:Array = getAdjacentPieceIndices(piecex, piecey);
                        for(var k: int = 0; k < adjacentPiecesIndicies.length; k++)
                        {
                            var adjacentPieceIndex: int = adjacentPiecesIndicies[k];
                            if( _boardPieceTypes[adjacentPieceIndex] == Constants.PIECE_TYPE_DEAD)
                            {
                                _boardPieceTypes[adjacentPieceIndex] = Constants.PIECE_TYPE_NORMAL;
                                join._piecesHealed.push( [idxToX(adjacentPieceIndex), convertFromTopYToFromBottomY( idxToY(adjacentPieceIndex))]);
                            }
                        }
                    }
                }
                
                
                
                function addPiecesToHorizontalJoin( a :Array) :void {
                        
                        for(i = 0; i < a.length; i++)
                        {
                            pieceIndex = a[i];
                            join.addPiece( idxToX(pieceIndex), convertFromTopYToFromBottomY(idxToY(pieceIndex)));
                            
                            minx = Math.min( idxToX( pieceIndex), minx);
                            maxx = Math.max( idxToX( pieceIndex), maxx);
                            
                            
                            //If the horizontal join is greater than 4, it becomes a healing clear
                            if(a.length > 4)
                            {
                                piecesWithHealingPower.push( pieceIndex ); 
                            }
                            
                            //The last swapped piece decides the direction of even numbered joins 
                            var middleX:int = minx + (a.length / 2.0) - 1;
                            
                            join._lastSwappedX = _lastSwap[0];
                            
                            if( _lastSwap[0]  <= middleX)
                            {
                                join.attackSide = JoinGameJoin.RIGHT;
                            }
                            else
                            {
                                join.attackSide = JoinGameJoin.LEFT;
                            }
                            
                            join.attackRow = (_rows-1) - idxToY( pieceIndex);
                            
                        }
                }
                
                function addPiecesToVerticalJoin( b :Array) :void {
                    for(i = 0; i < b.length; i++) {
                            pieceIndex = b[i];
                            join.addPiece( idxToX(pieceIndex), convertFromTopYToFromBottomY(idxToY(pieceIndex)));
                            
                            join._buildCol = idxToX( pieceIndex );
                            
                            minx = Math.min(piecex, minx);
                            maxx = Math.max(piecex, maxx);
                            miny = Math.min(piecey, miny);
                            maxy = Math.max(piecey, maxy);
                        }
                }
                
                function addPiecesWithHealingPower() :void {
                    if(a.length > 4) {
                        for(i = 0; i < a.length; i++)
                        {
                            pieceIndex = a[i];
                            if( !ArrayUtil.contains( piecesWithHealingPower, pieceIndex)) {
                                piecesWithHealingPower.push( pieceIndex );
                            }
                        }
                    }
                    
                    if(b.length > 4) {
                        for(i = 0; i < b.length; i++)
                        {
                            pieceIndex = b[i];
                            if( !ArrayUtil.contains( piecesWithHealingPower, pieceIndex)) {
                                piecesWithHealingPower.push( pieceIndex );
                            }
                        }
                    }
                }
                
                //Add the joins to the total list
                if(tempjoins.length > 0)
                {
                    for(i = 0; i < tempjoins.length; i++)
                    {
                        joins.push( tempjoins[i]);
                    }
                }
                
//            }
            return joins;
        }

        
        public function generateRandomPieceColor(): int
        {
            return r.nextInt(Constants.PIECE_COLORS_ARRAY.length) + 1;
        }

        public function getAdjacentPieceIndices(x: int, y: int): Array
        {
            var pieces:Array = new Array();
            
            if( isPieceAt(x , y - 1) )
            {
                pieces.push(coordsToIdx(x , y - 1));
            }
            if( isPieceAt(x - 1, y ))
            {
                pieces.push(coordsToIdx(x - 1, y ));
            }
            if( isPieceAt(x + 1, y ))
            {
                pieces.push(coordsToIdx(x + 1, y ));
            }
            if( isPieceAt(x , y + 1))
            {
                pieces.push(coordsToIdx(x , y + 1));
            }
            
            
            return pieces;
        }
        
        private function isPieceInJoins(joinArray: Array, pieceIndex: int): Boolean
        {
            for(var joinIndex:int  = 0; joinIndex < joinArray.length; joinIndex++)
            {
                var join: JoinGameJoin = joinArray[joinIndex] as JoinGameJoin;
                if(join.isContainsPiece(idxToX(pieceIndex), convertFromTopYToFromBottomY(idxToY(pieceIndex))))
                {
                    return true;
                }
            }
            return false;
        }

        
        
        private function findHorizontallyConnectedSimilarPiecesAtLeastXlong (x :int, y :int, X: int) :Array
        {
            var pieces :ObjectSet = new ObjectSet();
    
            var thisIndex :int = coordsToIdx(x, y);
            if ( _boardPieceTypes[thisIndex] == Constants.PIECE_TYPE_NORMAL)
            {
                findHorizontallyConnectedSimilarPiecesInternal(x, y, _boardPieceColors[thisIndex], pieces);
                if(pieces.size() < X)
                {
                    pieces.clear();
                }
            }
    
            return pieces.toArray();
        }
        
        private function findHorizontallyConnectedSimilarPiecesInternal (x :int, y :int, color :int, pieces :ObjectSet) :void
        {
            if( x < 0 || x >= _cols || y < 0 || y >= _rows){
                return;
            }
            
            var thisIndex :int = coordsToIdx(x, y);
            // don't recurse unless we have a valid piece and it's not already in the set
            if (_boardPieceTypes[thisIndex] == Constants.PIECE_TYPE_NORMAL && _boardPieceColors[thisIndex] == color && pieces.add(thisIndex))
            {
                findHorizontallyConnectedSimilarPiecesInternal(x - 1, y, color, pieces);
                findHorizontallyConnectedSimilarPiecesInternal(x + 1, y, color, pieces);
            }
        }
        
        
        protected function findVerticallyConnectedSimilarPiecesAtLeastXlong (x :int, y :int, X: int) :Array
        {
            var pieces :ObjectSet = new ObjectSet();
    
            var thisIndex :int = coordsToIdx(x, y);
            if (_boardPieceTypes[thisIndex] == Constants.PIECE_TYPE_NORMAL)
            {
                findVerticallyConnectedSimilarPiecesInternal(x, y, _boardPieceColors[thisIndex], pieces);
                if(pieces.size() < X)
                {
                    pieces.clear();
                }
            }
    
            return pieces.toArray();
        }
        
        protected function findVerticallyConnectedSimilarPiecesInternal (x :int, y :int, color :int, pieces :ObjectSet) :void
        {
            if( x < 0 || x >= _cols || y < 0 || y >= _rows){
                return;
            }
            
            var thisIndex :int = coordsToIdx(x, y);
            // don't recurse unless we have a valid piece and it's not already in the set
            if (_boardPieceTypes[thisIndex] == Constants.PIECE_TYPE_NORMAL && _boardPieceColors[thisIndex] == color && pieces.add(thisIndex))
            {
                findVerticallyConnectedSimilarPiecesInternal(x, y - 1, color, pieces);
                findVerticallyConnectedSimilarPiecesInternal(x, y + 1, color, pieces);
            }
        }
        

        
        /**
         * Side: left=false, right=true
         */
        public function turnPieceDeadAtRowAndSide(row: int, side:int):void
        {
            var i: int;
            var index: int;
            if(side == Constants.LEFT)
            {
                for(i = 0; i < _cols; i++)
                {
                    index = coordsToIdx(i, row);
                    if(isPieceAt( i, row ) && (_boardPieceTypes[ coordsToIdx(i, row) ] == Constants.PIECE_TYPE_POTENTIALLY_DEAD || _boardPieceTypes[ coordsToIdx(i, row) ] == Constants.PIECE_TYPE_NORMAL))
                    {
                        _boardPieceTypes[ coordsToIdx(i, row) ] = Constants.PIECE_TYPE_DEAD;
                        break;
                    }
                }
            }
            else if(side == Constants.RIGHT)
            {
                for(i = _cols-1; i >= 0; i--)
                {
                    index = coordsToIdx(i, row);
                    if(isPieceAt( i, row ) && (_boardPieceTypes[ coordsToIdx(i, row) ] == Constants.PIECE_TYPE_POTENTIALLY_DEAD || _boardPieceTypes[ coordsToIdx(i, row) ] == Constants.PIECE_TYPE_NORMAL))
                    {
                        _boardPieceTypes[ coordsToIdx(i, row) ] = Constants.PIECE_TYPE_DEAD;
                        break;
                    }
                }
            }
        }
        
        public function  isAlive(): Boolean
        {
            return !(countPiecesWithType(Constants.PIECE_TYPE_NORMAL) < Constants.MINIMUM_PIECES_TO_STAY_ALIVE || _rows <= 0 || _cols <= 0);
        }
        
        private function countPiecesWithType(type: int): int
        {
            var count: int = 0;
            for(var i: int = 0; i < _boardPieceTypes.length; i++)
            {
                if(_boardPieceTypes[i] == type)
                {
                    count++
                }
            }
            return count;
        }    
        
        /**
        * This method is too complicated.
        */
        public function getBestJoinLengthAndColorForEachRow() :Array
        {
            var joinLengths :Array = new Array();
            var joinColors :Array = new Array(); 
//            var joinStartAndStopCol :Array = new Array(); 
            
            var row :int;
            var col :int;
            var color :int;
//            var col2AvailableColors :HashMap = new HashMap();
            var color2CurrentLongestLength :HashMap = new HashMap();
            var color2CurrentLength :HashMap = new HashMap();
            var color2CurrentStart :HashMap = new HashMap();
            var color2LongestJoinStart :HashMap = new HashMap();
            var color2CurrentStop :HashMap = new HashMap();
            var color2LongestStop :HashMap = new HashMap();
            var bestlength :int;
            var bestcolor :int;
            var bestStartCol :int;
            var bestStopCol :int;
            
//            var currentLongestLength :int;
            for ( row = 0; row < _rows; row++) {
                
                for( col = 0; col < _cols; col++) {
                    color2CurrentLongestLength.put( col, 0);
                    color2CurrentLength.put( col, 0)
                }
                
                for( col = 0; col < _cols; col++) {
                    var colorsAvailable :Array = getAvailableColorsFromLocation(col, row);
                    for ( color = 0; color < Constants.PIECE_COLORS_ARRAY.length; color++) {
                        if( ArrayUtil.contains( colorsAvailable, color)) {
                            color2CurrentLength.put( color, int(color2CurrentLength.get(color))+1);
                            color2CurrentLongestLength.put( color, 
                                Math.max( 
                                            int(color2CurrentLength.get(color)), 
                                            int(color2CurrentLongestLength.get(color)) 
                                        )
                                );
                                
                                               
                        }
                        else {
                            color2CurrentLength.put( color, 0);
                        }
                    }
                }
                
                //Now we have the longest possible join for each color in the row.
                //Just take the first/best color
                bestcolor = 0;
                bestlength = int(color2CurrentLongestLength.get( bestcolor ));
                
                for( color = 1; color < Constants.PIECE_COLORS_ARRAY.length; color++) {
                    if( int(color2CurrentLongestLength.get( color )) > bestlength) {
                        bestcolor = color;
                        bestlength = int(color2CurrentLongestLength.get( color ));
                    }
                }
                
                joinColors.push( bestcolor );
                joinLengths.push( bestlength );
            }
            
            
            return [joinLengths, joinColors];
        }
        
        protected function getAvailableColorsFromLocation( locX :int, locY :int ) :Array
        {
            var results :HashMap = new HashMap();
            if( _boardPieceTypes[ coordsToIdx( locX, locY ) ] != Constants.PIECE_TYPE_NORMAL ) {
                return results.keys();
            }
            var j :int;
            results.put(  _boardPieceColors[ coordsToIdx( locX, locY )], 0);
            
            /* Look up*/
            for ( j = locY - 1; j >= 0; j--) {
                if( _boardPieceTypes[ coordsToIdx( locX, j ) ] != Constants.PIECE_TYPE_NORMAL ) {
                    break;
                }
                results.put( _boardPieceColors[ coordsToIdx( locX, j )], 0);
            }
            
            /* Look down*/
            for ( j = locY + 1; j < _rows; j++) {
                if( _boardPieceTypes[ coordsToIdx( locX, j ) ] != Constants.PIECE_TYPE_NORMAL ) {
                    break;
                }
                results.put( _boardPieceColors[ coordsToIdx( locX, j )], 0);
            }
            
            
            return results.keys();
        }
            
        //New idea, you get a piece to the left and right as well 
        private function addNewPieceToColumn(newPieceColumnIndex: int): void
        {
            var rowIndexFree: int = findRowIndexWhereThereIsAFreePieceAtColumn( newPieceColumnIndex );

            if( Constants.TESTING_NEW_MECHANIC && _rows >= Constants.MAX_ROWS && rowIndexFree < 0) {
                return;
            }
            
            if( rowIndexFree == -1 )
            {
                addRow(Constants.PIECE_TYPE_INACTIVE);
                 rowIndexFree = findRowIndexWhereThereIsAFreePieceAtColumn( newPieceColumnIndex );
                
            }
            
            _boardPieceTypes[ coordsToIdx(newPieceColumnIndex, rowIndexFree) ] = Constants.PIECE_TYPE_EMPTY;
        }    
        
        
        /**
         * Get sets of pieces that are contiguous.
         */
        public function getContiguousRegions():Array
        {
            var connectedPieceArrays:Array = new Array();
            var piecesAlreadyAssignedToAnArray: HashSet = new HashSet();
            
            //The types array contains the types that we consider equivalent.
            var types:Array = new Array();
            types.push(Constants.PIECE_TYPE_NORMAL);
            types.push( Constants.PIECE_TYPE_POTENTIALLY_DEAD);
            
            for(var i: int = 0; i < _boardPieceTypes.length; i++)
            {
                if(( _boardPieceTypes[i] == Constants.PIECE_TYPE_NORMAL || _boardPieceTypes[i] == Constants.PIECE_TYPE_POTENTIALLY_DEAD) && !piecesAlreadyAssignedToAnArray.contains(i))
                {
                    var connectedPieces:Array = findConnectedSimilarPieces( idxToX(i), idxToY(i), types);
                    connectedPieceArrays.push(connectedPieces);
                    for(var k: int = 0; k < connectedPieces.length; k++)
                    {
                        piecesAlreadyAssignedToAnArray.add( connectedPieces[k] as int );
                    }
                    
                }
            }
            return connectedPieceArrays;
            
        }
        


        
        //New idea, you get a piece to the left and right as well 
        public function addNewPieceToColumnAndLeftAndRight(newPieceColumnIndex: int): void
        {
            addNewPieceToColumn(newPieceColumnIndex );
            //Add to left and right
            if( newPieceColumnIndex > 0)
            {
                addNewPieceToColumn(newPieceColumnIndex - 1);
            }
            
            if( newPieceColumnIndex < _cols - 1)
            {
                addNewPieceToColumn(newPieceColumnIndex + 1);
            }
        }
        
        /**
        * Does what it says.
        */
        public function getHighestRowBelowEmptyPieceOrJustTheHighestPiece( col :int) :int
        {
            if(col < 0 || col >= _cols){
                throw Error("getHighestRowWithNonEmptyPiece(col is bad=" + col + ")");
                return -1;
            }
            for( var j :int = _rows - 1; j > 0; j--){
                
                if( _boardPieceTypes[ coordsToIdx( col, j - 1) ] == Constants.PIECE_TYPE_EMPTY){
                    return j;
                }
            }
            return 0;
        }
        
        
        public function getHighestActiveRow( col :int ) :int
        {
            for( var j :int = 0; j < _rows; j++) {
                if( _boardPieceTypes[ coordsToIdx( col, j) ] != Constants.PIECE_TYPE_INACTIVE) {
                    return j;
                }
            }
            return -1;
        }
        
        
        /**
         * Mark normal pieces that do not have any available joins, 
         * and are not connected to any pieces with possible joins, 
         * as 'potentially dead'.
         * 
         */
        public function markPotentiallyDeadDELETE():void
        {
            var k: int;
            var i: int;
            for(k = 0; k < _boardPieceTypes.length; k++)
            {
                if(_boardPieceTypes[ k ] == Constants.PIECE_TYPE_POTENTIALLY_DEAD)
                {
                    _boardPieceTypes[ k ] = Constants.PIECE_TYPE_NORMAL;
                }
            }
            var contiguousRegions:Array = getContiguousRegions();
            
            for( k = 0; k < contiguousRegions.length; k++)
            {
                var arrayOfContiguousPieces:Array = contiguousRegions[k] as Array;
                var convertToDead: Boolean = true;
                for( i = 0; i < arrayOfContiguousPieces.length; i++)
                {
                    var pieceIndex: int = arrayOfContiguousPieces[i] as int;
                    
                    if( !isNoMoreJoinsPossibleWithPiece( idxToX(pieceIndex), idxToY(pieceIndex)) )
                    {
                        convertToDead = false;
                        break;
                    } 
                }
                
                if(convertToDead)
                {
                    for( i = 0; i < arrayOfContiguousPieces.length; i++)
                    {
                        _boardPieceTypes[ arrayOfContiguousPieces[i] as int ] = Constants.PIECE_TYPE_POTENTIALLY_DEAD;
                    }
                }
            }
            
        }
        
        
        public function isNoMoreJoinsPossibleWithPiece(piecex: int, piecey: int, piecesPartOfAJoin:HashSet = null): Boolean
        {
            var neededColor:int = _boardPieceColors[ coordsToIdx(piecex, piecey) ];
            
            var horizontalJoinDistanceSoFar:int = 1;
            var currentDistanceFromPiece: int = 0;
            var positiveDistance: Boolean = false;
            
            var stillCheckingLeft:Boolean = true;
            var stillCheckingRight:Boolean = true;
            
            var currentRow:int = piecex;
            
            var k: int;
            var j: int;
            var pieceIndex: int;
                
            while(currentDistanceFromPiece <= 6 && horizontalJoinDistanceSoFar < 4)
            {
                
                
                
                //Increment the distance first
                if(positiveDistance)
                {
                    positiveDistance = !positiveDistance;
                }
                else
                {
                    currentDistanceFromPiece++;
                    positiveDistance = true;
                }
                
                //Make sure we don't check for rows that we cannot reach because a closer piece is not connectable
                if(!stillCheckingLeft && !positiveDistance)
                {
                    continue;
                }
                if(!stillCheckingRight && positiveDistance)
                {
                    continue;
                }
                
                currentRow = piecex + (positiveDistance ? currentDistanceFromPiece : -currentDistanceFromPiece);
                if(currentRow < 0)
                {
                    stillCheckingLeft = false;
                    continue;
                }
                else if(currentRow >= _cols)
                {
                    stillCheckingRight = false;
                    continue;
                }
                
                
                var type: int = _boardPieceTypes[ coordsToIdx(currentRow, piecey) ] ;
                if(type == Constants.PIECE_TYPE_NORMAL)
                {
                    //Now we search in this column for pieces of the same color.  If so 
                    //we increment the horizontalJoinDistanceSoFar
                    
                    //Search up until we hit something bad
                    var foundPieceInColumn: Boolean = false;
                    
                    for(j = piecey; j >= 0; j--)
                    {
                        pieceIndex = coordsToIdx(currentRow, j);
                        
                        if(_boardPieceTypes[ pieceIndex ] == Constants.PIECE_TYPE_NORMAL)
                        {
                            if(_boardPieceColors[ pieceIndex ]  == neededColor)
                            {
                                foundPieceInColumn = true;
                                horizontalJoinDistanceSoFar++;
                                break;
                            }
                        }
                        else
                        {
                            break;
                        }
                    }
                    
                    //Search down until we hit something bad
                    if(!foundPieceInColumn)
                    {
                        for( j = piecey+1; j < _rows; j++)
                        {
                            pieceIndex = coordsToIdx(currentRow, j);
                            if( _boardPieceTypes[ pieceIndex ] == Constants.PIECE_TYPE_NORMAL)
                            {
                                if(_boardPieceColors[ pieceIndex ] == neededColor)
                                {
                                    horizontalJoinDistanceSoFar++;
                                    break;
                                }
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                    
                    if(!foundPieceInColumn)
                    {
                        if(positiveDistance)
                        {
                            stillCheckingRight = false;
                        }
                        else
                        {
                            stillCheckingLeft = false;
                        }
                    }
                    
                }
                else
                {
                    if(positiveDistance)
                    {
                        stillCheckingRight = false;
                    }
                    else
                    {
                        stillCheckingLeft = false;
                    }
                }
                
                
                
            }
            return horizontalJoinDistanceSoFar < 4;
        }
        

        
        
        protected function findConnectedSimilarPiecesInternal (x :int, y :int, types :Array, pieces :ObjectSet) :void
        {
            
            
            if (!isPieceAt(x, y))
            {
                return;
            }
            var thisPieceIndex :int = coordsToIdx(x, y);
            
            var isSameType:Boolean = false;
            for(var k:int = 0; k < types.length; k++)
            {
                if(_boardPieceTypes[ thisPieceIndex ]  == types[k])
                {
                    isSameType = true;
                    break;
                }
            }
            if ( isSameType && pieces.add(thisPieceIndex))
            {
                findConnectedSimilarPiecesInternal(x - 1, y,     types, pieces);
                findConnectedSimilarPiecesInternal(x + 1, y,     types, pieces);
                findConnectedSimilarPiecesInternal(x,     y - 1, types, pieces);
                findConnectedSimilarPiecesInternal(x,     y + 1, types, pieces);
            }
        }
        
        protected function findConnectedSimilarPieces (x :int, y :int, types:Array ) :Array
        {
            var pieces :ObjectSet = new ObjectSet();

            if (isPieceAt(x, y))
            {
                var thisPieceIndex :int = coordsToIdx(x, y);
                findConnectedSimilarPiecesInternal(x, y, types, pieces);
            }
            
            return pieces.toArray();
        }
        
        
        private function addRow(pieceType:int):void
        {
            _rows++;
            
            var newColors: Array= new Array();
            var newTypes: Array= new Array();
            var i: int;
            for( i = 0; i < _cols; i++)
            {
                newColors.push( generateRandomPieceColor() );
                _numberOfCallsToRandom++;
                newTypes.push(pieceType);
            }
            for( i = 0; i < _boardPieceTypes.length; i++)
            {
                newColors.push( _boardPieceColors[i]);
                newTypes.push( _boardPieceTypes[i]);
            }
            _boardPieceColors = newColors;
            _boardPieceTypes = newTypes;
            
//            this.dispatchEvent(new JoinGameEvent(playerID, JoinGameEvent.BOARD_UPDATED));
            
        }
        
        /**
         * Asks if there is a free space at the column, returns the row, -1 if the colums is full of pieces
         */
        protected function findRowIndexWhereThereIsAFreePieceAtColumn( colIndex: int) : int     
        {
//            trace("findRowIndexWhereThereIsAFreePieceAtColumn(), start board=" + this.toString());
            var rowWithFreeIndex: int = -1;
            for(var j: int = _rows - 1; j >= 0; j--)
            {
//                trace("checking (" + colIndex + ", " + j + "), idx=" + coordsToIdx(colIndex, j) );
                if( _boardPieceTypes[ coordsToIdx(colIndex, j) ] == Constants.PIECE_TYPE_INACTIVE)// || _boardPieceTypes[ coordsToIdx(colIndex, j) ] == Constants.PIECE_TYPE_EMPTY )
                {
//                    trace("returning " + j);
                    return j;
                }
//                else
//                {
//                    break;
//                }
            }
//            trace("returning " + rowWithFreeIndex);
            return rowWithFreeIndex;
        }
        
        public function set randomSeed(seed:int):void
        {
            _seed = seed;
            r = new Random(_seed);
        }
        
        public function get randomSeed():int
        {
            return _seed;
        }
        
        
        public function sendBoardUpdateEvent() :void
        {
            var update:InternalJoinGameEvent = new InternalJoinGameEvent(_playerID, InternalJoinGameEvent.BOARD_UPDATED);
            
            //ATM we just redraw the entire board.
            dispatchEvent(update);    
            
        }
        

        
        override public function toString() :String
        {
            var i :int;
            var j :int;
            var s :String = "player id=" + _playerID + "\n";
            for( j = 0; j < _rows; j++){
                for( i = 0; i < _cols; i++){
                       s += "\t" + _boardPieceTypes[ coordsToIdx(i,j)];
                }
                s += "\n";
            }
            s += "\n";
            for( j = 0; j < _rows; j++){
                for( i = 0; i < _cols; i++){
                    s += "\t" + _boardPieceColors[ coordsToIdx(i,j)]
                }
                s += "\n";
            }
            return s;
        }
        
        public function setIntoPropertySpaces( ctrl :GameControl) :void
        {
            ctrl.net.set(_playerID + COLORS_STRING, _boardPieceColors);
            ctrl.net.set(_playerID + TYPES_STRING, _boardPieceTypes);
            ctrl.net.set(_playerID + DIMENSION_STRING, new Array( _rows, _cols));
            ctrl.net.set(_playerID + SEED_STRING, _seed);
            ctrl.net.set(_playerID + NUMBER_OF_CALLS_TO_RANDOM_STRING, _numberOfCallsToRandom);
            ctrl.net.set(_playerID + STATE, _state);
            ctrl.net.set(_playerID + IS_ROBOT, _isComputerPlayer);
            ctrl.net.set(_playerID + ROBOT_PLAYER_LEVEL, _computerPlayerLevel);
        }
        
        public function setIntoPropertySpacesWhereDifferent( ctrl :GameControl) :void
        {
            if( !AppContext.isConnected ) {
                log.info("setIntoPropertySpacesWhereDifferent(), we are not connected.");
                return;
            }
            
            function same( a :Array, b :Array) :Boolean {
                if(a == null || b == null || a.length != b.length ) {
                    return false;
                }
                for(var i :int = 0; i < a.length; i++) {
                    if(a[i] != b[i]) {
                        return false;
                    }
                }
                
                return true;
            }
            
            
            var serverBoardColors :Array = ctrl.net.get(_playerID + COLORS_STRING) as Array;
            if( !same(serverBoardColors, _boardPieceColors)) {
                ctrl.net.set(_playerID + COLORS_STRING, _boardPieceColors);
            }
            
            var serverBoardTypes :Array = ctrl.net.get(_playerID + TYPES_STRING) as Array;
            if( !same(serverBoardTypes, _boardPieceTypes)) {
                ctrl.net.set(_playerID + TYPES_STRING, _boardPieceTypes);
            }
            var dims :Array = ctrl.net.get(_playerID + DIMENSION_STRING) as Array;
            if( dims == null || dims[0] != _rows || dims[1] != _cols) {
                ctrl.net.set(_playerID + DIMENSION_STRING, new Array(_rows, _cols));
            }
            var seed :int = ctrl.net.get(_playerID + SEED_STRING) as int;
            if( seed != _seed) {
                ctrl.net.set(_playerID + SEED_STRING, _seed);
            }
            
            var randoms :int = ctrl.net.get(_playerID + NUMBER_OF_CALLS_TO_RANDOM_STRING) as int;
            if( randoms != _numberOfCallsToRandom) {
                ctrl.net.set(_playerID + NUMBER_OF_CALLS_TO_RANDOM_STRING, _numberOfCallsToRandom);
            }
            
            var state :int = ctrl.net.get(_playerID + STATE) as int;
            if( state != _state) {
                ctrl.net.set(_playerID + STATE, _state);
            }
            
            var computerPlayer :Boolean = ctrl.net.get(_playerID + IS_ROBOT) as Boolean;
            if( computerPlayer != _isComputerPlayer) {
                ctrl.net.set(_playerID + IS_ROBOT, _isComputerPlayer);
            }
            
            var robotLevel :int = ctrl.net.get(_playerID + ROBOT_PLAYER_LEVEL) as int;
            if( robotLevel != _computerPlayerLevel) {
                ctrl.net.set(_playerID + ROBOT_PLAYER_LEVEL, _computerPlayerLevel);
            }
            
        }


        public function convertFromTopYToFromBottomY( j :int ) :int
        {
            return (_rows - 1) - j;
        }  
        
        public function convertFromBottomYToFromTopY( j :int ) :int
        {
            return (_rows - 1) - j;
        }       
        
        public function setBoardFromCompactRepresentation(rep: Array):void
        {
            _playerID = rep[0] as int;
            _rows = rep[1] as int;
            _cols = rep[2] as int;
            _boardPieceColors = (rep[3] as Array).slice();
            _boardPieceTypes = (rep[4] as Array).slice();
            this.randomSeed = int(rep[5]);
            _numberOfCallsToRandom = int(rep[6]);
            _state = int(rep[7]);
            _isComputerPlayer = int(rep[8]) == 1;
            _computerPlayerLevel = int(rep[9]);
            
            for(var k:int = 0; k < _numberOfCallsToRandom; k++)
            {
                generateRandomPieceColor();
            }
            
            //Tell the board display (if on the client) to update the display.
            this.dispatchEvent(new InternalJoinGameEvent(_playerID, InternalJoinGameEvent.BOARD_UPDATED));
        }
        
        
        public function getFromPropertySpaces( playerid :int, ctrl :GameControl) :void
        {
            _playerID = playerid;
            _rows = (ctrl.net.get(_playerID + DIMENSION_STRING) as Array)[0];
            _cols = (ctrl.net.get(_playerID + DIMENSION_STRING) as Array)[1];
            _boardPieceColors = (ctrl.net.get(_playerID + COLORS_STRING) as Array).slice();
            _boardPieceTypes = (ctrl.net.get(_playerID + TYPES_STRING) as Array).slice();
            this.randomSeed = ctrl.net.get(_playerID + SEED_STRING) as int;
            _numberOfCallsToRandom = ctrl.net.get(_playerID + NUMBER_OF_CALLS_TO_RANDOM_STRING) as int;
            for(var k:int = 0; k < _numberOfCallsToRandom; k++)
            {
                generateRandomPieceColor();
            }
            _state = ctrl.net.get(_playerID + STATE) as int;
            _isComputerPlayer = ctrl.net.get(_playerID + IS_ROBOT) as Boolean;
            _computerPlayerLevel = ctrl.net.get(_playerID + ROBOT_PLAYER_LEVEL) as int;
            
            this.dispatchEvent(new InternalJoinGameEvent(_playerID, InternalJoinGameEvent.BOARD_UPDATED));
        }
        
        public function getActiveRows() :Array
        {
            var activeRows :Array = new Array();
            for( var row :int = 0; row < _rows; row++ ) {
                if( isRowActive(row) ) {
                    activeRows.push( row);
                }
            }
            return activeRows;
        }
        
        public function isRowActive( row :int ) :Boolean
        {
            for(var col :int = 0; col < _cols; col++) {
                if( _boardPieceTypes[ coordsToIdx(col, row) ] == Constants.PIECE_TYPE_NORMAL ) {
                    return true;
                }
            }
            return false;
        }
        public function getDamageForRow( row :int ) :int
        {
            var damage :int = 0;
            for(var col :int = 0; col < _cols; col++) {
                if( _boardPieceTypes[ coordsToIdx(col, row) ] == Constants.PIECE_TYPE_DEAD ) {
                    damage++;
                }
            }
            return damage;
        }
        
        /**

        */
        public function getRowsAndDamage() :HashMap
        {
            var rowsAndDamage :HashMap = new HashMap();
            
            for( var row :int = 0; row < _rows; row++ ) {
                var damage :int = getDamageForRow( row );
                rowsAndDamage.put( row, damage );
            }
//            rowsAndDamage.sort( damageSort );
//            
//            function damageSort(a :Array, b :Array) :int 
//            {
//                if( int(a[1]) > int(b[1]) ) {
//                    return -1;
//                }
//                else if( int(a[1]) < int(b[1]) ) {
//                    return 1;
//                }
//                else {
//                    return 0
//                }
//            }
            
            
            return rowsAndDamage;
        }
        
        
        /**
         * This is the main role of the server: checking the validity of moves
         * to prevent cheating.  Only valid moves are returned approved.
         */
        public function isLegalMove( fromIndex:int, toIndex:int): Boolean
        {
            if( _state > STATE_ACTIVE ) {
                return false;
            }
            //Make sure the pieces are in the same column
            var i:int = idxToX(fromIndex);
            if(i < 0 || i != idxToX(toIndex) )
            {
                log.debug("  isLegalMove(), pieces not in same column");
                return false;
            }
            
            //And finally check that both pieces are valid, and all the inbetween pieces.
            for(var j:int =  Math.min( idxToY( fromIndex), idxToY(toIndex)); j <=  Math.max( idxToY(fromIndex), idxToY(toIndex)); j++)
            {
                if( _boardPieceTypes[ coordsToIdx( i, j)] != Constants.PIECE_TYPE_NORMAL)
                {
                    return false;    
                }
            }
            return true;
        }
        
        
        public function isColumnContainsColor( col :int, color :int) :Boolean
        {
            for( var j :int = 0; j < _rows; j++) {
                if( _boardPieceTypes[ coordsToIdx( col, j) ] == Constants.PIECE_TYPE_NORMAL &&
                    _boardPieceColors[ coordsToIdx( col, j) ] == color) {
                        return true;
                }
            }
            return false;
        }
        
        public function isVerticalJoinPossible( col :int, color :int) :int
        {
            var highestConsecutiveColoredPieces :int = 0;
            var rowWithhighestConsecutiveColoredPieces :int = -1; 
            var consecutiveColoredPieces :int = 0;
            for( var j :int = 0; j < _rows; j++) {
                if( _boardPieceTypes[ coordsToIdx( col, j) ] == Constants.PIECE_TYPE_NORMAL) {
                    if( _boardPieceColors[ coordsToIdx( col, j) ] == color) {
                        consecutiveColoredPieces++;
                        if( consecutiveColoredPieces > highestConsecutiveColoredPieces) {
                            highestConsecutiveColoredPieces = consecutiveColoredPieces;
                            rowWithhighestConsecutiveColoredPieces = j;
                      }
                    }
                }
                else {
                    consecutiveColoredPieces = 0;
                }
            }
            
//            trace("isVerticalJoinPossible(col=" + col + ", color=" + color + ")");
//            trace("    highestConsecutiveColoredPieces=" + highestConsecutiveColoredPieces);
//            trace("    rowWithhighestConsecutiveColoredPieces=" + rowWithhighestConsecutiveColoredPieces);

            if( highestConsecutiveColoredPieces >= 4) {
                if( _boardPieceTypes[ coordsToIdx( col, rowWithhighestConsecutiveColoredPieces) ] != Constants.PIECE_TYPE_NORMAL) {
                    trace("WTF, saying isVerticalJoinPossible at(" + col + ", " + rowWithhighestConsecutiveColoredPieces + ")");
                    trace(" but whatever, that piece is not live");
                    trace("board:" + this.toString());
                }
            }
            return highestConsecutiveColoredPieces >= 4 ? rowWithhighestConsecutiveColoredPieces : -1;
        }
        public function getHorizontallyClosestPieceIndexWithColor( xLoc :int, yLoc :int, color :int) :int
        {
            var index :int;
            var j :int;
             
            for( j = yLoc + 1; j < _rows; j++) {
                index = coordsToIdx( xLoc, j);
                if( index > -1) {
                    if( _boardPieceTypes[ index ] != Constants.PIECE_TYPE_NORMAL) {
                        break;
                    }
                    if( _boardPieceColors[ index ] == color) {
                            return index;
                    }
                }
            }
            
            for( j = yLoc - 1; j >= 0; j--) {
                index = coordsToIdx( xLoc, j);
                if( index > -1) {
                    if( _boardPieceTypes[ index ] != Constants.PIECE_TYPE_NORMAL) {
                        break;
                    }
                    if( _boardPieceColors[ index ] == color) {
                            return index;
                    }
                }
            }
            
            return -1;
            
//            
//            var closestRow :int = -1;
////            var j :int;
//            var index :int;
//            
//            //Look up
//            for( j = yLoc - 1; j >= 0; j--) {
//                index = coordsToIdx( xLoc, j);
//                if( _boardPieceTypes[ index ] == Constants.PIECE_TYPE_NORMAL) {
//                    if( _boardPieceColors[ index ] == color) {
//                        closestRow = j;
//                        break;
//                    }
//                }
//                else {
//                    break;
//                }
//            }
//            
//            //Look up
//            for( j = yLoc + 1; j < _rows; j++) {
//                index = coordsToIdx( xLoc, j);
//                if( _boardPieceTypes[ index ] == Constants.PIECE_TYPE_NORMAL) {
//                    if( _boardPieceColors[ index ] == color) {
//                        closestRow = j;
//                        break;
//                    }
//                }
//                else {
//                    break;
//                }
//            }
//            
//            return -1;
//            
//            
//            
//            var up :Boolean = true;
//            
//            var currentRow :int;
//            
//            
//            
//            var canGoUp :Boolean = true;
//            var canGoDown :Boolean = true;
//            
//            
//            
//            
//            
//            
//            for( var modifier :int = 0; modifier < _rows; modifier++) {
//                
//                //Up
//                if( canGoUp ) {
//                    currentRow = yLoc - modifier;
//                    if( currentRow >= 0 && currentRow < _rows) {
//                        index = coordsToIdx( xLoc, yLoc - modifier);
//                        if( _boardPieceTypes[ index ] == Constants.PIECE_TYPE_NORMAL) {
//                            if( _boardPieceColors[ index ] == color) {
//                                return index;
//                            }
//                        }
//                        else {
//                            canGoUp = false;
//                        }
//                    }
//                }
//                else if(canGoDown) {
//                    currentRow = yLoc + modifier;
//                    if( currentRow >= 0 && currentRow < _rows) {
//                        index = coordsToIdx( xLoc, yLoc + modifier);
//                        if( _boardPieceTypes[ index ] == Constants.PIECE_TYPE_NORMAL) {
//                            if( _boardPieceColors[ index ] == color) {
//                                return index;
//                            }
//                        }
//                        else {
//                            canGoDown = false;
//                        }
//                    }
//                }
//                
//            }
//            
//            return -1;
        }
        public function getRowWithTheMostDamage() :int
        {
            var mostDamagedRow :int = -1;
            var mostDamage :int = 0;
            for( var row :int = 0; row < _rows; row++ ) {
                var damage :int = getDamageForRow( row );
                if( damage > mostDamage ) {
                    mostDamage = damage;
                    mostDamagedRow = row;
                }
            }
            return mostDamagedRow;
        }
        
        
        public static const COLORS_STRING: String = "Colors";
        public static const TYPES_STRING: String = "Types";
        public static const DIMENSION_STRING: String = "Dimension";
        public static const SEED_STRING: String = "Seed";
        public static const NUMBER_OF_CALLS_TO_RANDOM_STRING: String = "CallsToRandom";
        public static const STATE: String = "State";
        public static const IS_ROBOT: String = "IsRobot";
        public static const ROBOT_PLAYER_LEVEL: String = "RobotLevel";
        
            
        public var _boardPieceColors :Array;
        public var _boardPieceTypes :Array;
            
        public var _rows : int;
        public var _cols : int;
        
        private var _bottomRowTimer:Timer;
        
        private var _lastSwap: Array;
        
        private var _playerID:int;
            
        private var r:Random;
        private var _seed:int;
        public var _numberOfCallsToRandom: int;
        
        public var _isComputerPlayer: Boolean;
        
        public var _computerPlayerLevel: int;
        
        /** This counts from the bottom (0) up*/
        public var currentPotentialJoinRowCountingFromBottom: int;
        public var currentPotentialJoinColor: int;
        public var currentPotentialJoinLength: int;
        public var changeCurrentPotentialJoin: Boolean = true;
        
        
        
        /** There is a slight delay between being destroyed and the next player replacement */  
//        public var _isGettingKnockedOut :Boolean;
        public var _state :int;
        
        public static const STATE_ACTIVE :int = 0;
        public static const STATE_GETTING_KNOCKED_OUT :int = 1;
        public static const STATE_REMOVED :int = 2;
        
        private static const log :Log = Log.getLog(JoinGameBoardRepresentation);

    }
}

