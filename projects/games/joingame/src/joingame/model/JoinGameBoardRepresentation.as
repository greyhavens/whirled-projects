package joingame.model
{
    import com.threerings.util.HashSet;
    import com.threerings.util.Random;
    import com.whirled.contrib.simplegame.util.ObjectSet;
    import com.whirled.game.GameControl;
    
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import joingame.Constants;
    import joingame.net.JoinGameEvent;
    
    /**
     * A representation of the game board.  This is used by the server and the client.
     * The difference being, the client version updates the graphical representation and is dependent
     * on the server (via JoinGameModel) for updates.  The server version is the authority with no display hooks.  
     * This class does not request for changes to itself; that is left to the View/Controller classes
     * such as JoinGameBoardsView
     */
    public class JoinGameBoardRepresentation extends EventDispatcher
    {
        public function JoinGameBoardRepresentation( gamecontrol:GameControl = null)//rows:int, cols:int,
        {
            _control = gamecontrol;
            
            _playerID = -1;
            
            _boardPieceColors = new Array();
            _boardPieceTypes = new Array();
            
            _lastSwap = [0,0,0,0];
            
            _bottomRowTimer = new Timer(Constants.TIME_UNTIL_DEAD_BOTTOM_ROW_REMOVAL, 1);
            _bottomRowTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerEnd);
//            _bottomRowTimer.addEventListener(TimerEvent.TIMER, timerHandler);
            
            
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
                trace("timerend, dispatching kill bottom row event");
                var removeRowEvent :JoinGameEvent = new JoinGameEvent( this.playerID, JoinGameEvent.REMOVE_ROW_NOTIFICATION);
                dispatchEvent( removeRowEvent );
            }
            else {
                trace("timerEnd, but bottom row is not dead, timer should have been stopped previously, board:\n" + toString());
            }
            
            
//            if(isBottomRowDead)
//            {
//        
//                removeBottomRow();
//            }
//            
//            checkForDeadBottomRow();
        }
        
        
        public function destroy(): void
        {
            
        }
        
        public function removeRow( row :int ) :void
        {
            _boardPieceTypes.splice( row*_cols, _cols);
            _boardPieceColors.splice( row*_cols, _cols);
            _rows--;
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
            trace("Model: delta confirmed=" + index1 + " to " + index2 ); 
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
            return [_playerID, _rows, _cols, _boardPieceColors, _boardPieceTypes, _seed, _numberOfCallsToRandom];
        }
        
        public function setBoardFromCompactRepresentation(rep: Array):void
        {
            _playerID = rep[0] as int;
            _rows = rep[1] as int;
            _cols = rep[2] as int;
            _boardPieceColors = rep[3] as Array;
            _boardPieceTypes = rep[4] as Array;
            this.randomSeed = int(rep[5]);
            _numberOfCallsToRandom = int(rep[6]);
            
            for(var k:int = 0; k < _numberOfCallsToRandom; k++)
            {
                generateRandomPieceColor();
            }
            
            //Tell the board display (if on the client) to update the display.
            this.dispatchEvent(new JoinGameEvent(_playerID, JoinGameEvent.BOARD_UPDATED));
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
//            _playerID = newID;
//            if(newID != _playerID && _control != null)
//            {
//                //Request an entire board update, since we just started so have no pieces.
//                var msg :Object = new Object;
//                msg[0] = _control.game.getMyId();
//                msg[1] = _playerID;
////                LOG(" !!! Not Sending request update");
//                //This call causing class cast problems
//                _control.net.sendMessage(Server.BOARD_UPDATE_REQUEST,  msg, NetSubControl.TO_SERVER_AGENT);
//            }
//            else
//            {
//                trace("Control should not be null");
//            }
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
//            var isJoinsFound: Boolean = true;
            
            var pieceIndex: int;
            var i: int;
            var minx:int;
            var maxx:int;
            var miny:int;
            var maxy:int;
            var join: JoinGameJoin;
                
                
//            while(isJoinsFound)
//            {
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
                
                    if(a.length >= Constants.CONNECTION_MINIMUM && b.length >= Constants.CONNECTION_MINIMUM)
                    {
                        
                        join = new JoinGameJoin(a.length, b.length, _boardPieceColors[boardIndex], 0);
                        
                        //Double clears clear the whole "box"
                        minx = _cols;
                        maxx = 0;
                        miny = _rows;
                        maxy = 0;
                        
                        for(i = 0; i < a.length; i++)
                        {
                            pieceIndex = a[i];
                            join.addPiece( idxToX(pieceIndex), idxToY(pieceIndex));
                            piecesToRemove.add(pieceIndex);
                            
                            join.attackRow = (_rows-1) - idxToY( pieceIndex );
                            
                            var piecex:int = idxToX( pieceIndex);
                            var piecey:int = idxToY( pieceIndex);
                            
                            minx = Math.min(piecex, minx);
                            maxx = Math.max(piecex, maxx);
                            miny = Math.min(piecey, miny);
                            maxy = Math.max(piecey, maxy);
                        }
                        for(i = 0; i < b.length; i++)
                        {
                            pieceIndex = b[i];
                            join.addPiece( idxToX(pieceIndex), idxToY(pieceIndex));
                            piecesToRemove.add(pieceIndex);
                            
                            join._buildCol = idxToX( pieceIndex );
                            
                            minx = Math.min(piecex, minx);
                            maxx = Math.max(piecex, maxx);
                            miny = Math.min(piecey, miny);
                            maxy = Math.max(piecey, maxy);
                        }
                        
                        for(i = minx; i < maxx+1; i++)
                        {
                            for(var j: int = miny; j < maxy+1; j++)
                            {
                                join._piecesWithHealingPower.push( coordsToIdx(i,j )); 
                            }
                        }
                        
                        //Find out which pieces have the same row, this is the target row (from the bottom)
                        var attackRowCountingFromBottom: int = -1;
                        
                        tempjoins.push(join);
                    } 
                    else if(a.length >= Constants.CONNECTION_MINIMUM)
                    {
                        join = new JoinGameJoin(a.length, 1, _boardPieceColors[boardIndex], 0);
                        var sumXIndices: Number = 0;
                        
                        minx = _cols;
                        maxx = 0;
                        
                        for(i = 0; i < a.length; i++)
                        {
                            pieceIndex = a[i];
                            join.addPiece( idxToX(pieceIndex), idxToY(pieceIndex));
                            piecesToRemove.add(pieceIndex);
                            
                            piecex = idxToX( pieceIndex);
                            
                            minx = Math.min(piecex, minx);
                            maxx = Math.max(piecex, maxx);
                            
                            
                            //If the horizontal join is greater than 4, it becomes a healing clear
                            if(a.length > 4)
                            {
                                piecesWithHealingPower.push( pieceIndex ); 
                            }
                            
                            //The last swapped piece decides the direction of even numbered joins 
                            var middleX:int = minx + (a.length / 2.0) - 1;
                            
                            if( _lastSwap[0]  <= middleX)
                            {
                                join.attackSide = JoinGameJoin.LEFT;
                            }
                            else
                            {
                                join.attackSide = JoinGameJoin.RIGHT;
                            }
                            
                            join.attackRow = (_rows-1) - idxToY( pieceIndex);
                            
                        }
                        
                        tempjoins.push(join);
                    }
                    else if(b.length >= Constants.CONNECTION_MINIMUM)
                    {
                        join = new JoinGameJoin(a.length, b.length, _boardPieceColors[boardIndex], 0);
                        for(i = 0; i < b.length; i++)
                        {
                            pieceIndex = b[i];
                            join.addPiece( idxToX(pieceIndex), idxToY(pieceIndex));
                            piecesToRemove.add(pieceIndex);
                            
                            join._buildCol =  idxToX( pieceIndex );
                        }
                        tempjoins.push(join);
                    }
                }
                
                var removeArray: Array = piecesToRemove.toArray();
                
                
//                //If there are "dead" pieces adjacent to the cleared pieces, "heal" them
//                if(Constants.HEALING_ALLOWED)
//                {
//                    for(i = 0; i < piecesWithHealingPower.length; i++)
//                    {
//                        piecex = idxToX( piecesWithHealingPower[i] );
//                        piecey = idxToY( piecesWithHealingPower[i]);
//                        var adjacentPiecesIndicies:Array = getAdjacentPieceIndices(piecex, piecey);
//                        for(var k: int = 0; k < adjacentPiecesIndicies.length; k++)
//                        {
//                            var adjacentPieceIndex: int = adjacentPiecesIndicies[k];
//                            if( _boardPieceTypes[adjacentPieceIndex] == Constants.PIECE_TYPE_DEAD)
//                            {
//                                _boardPieceTypes[adjacentPieceIndex] = Constants.PIECE_TYPE_NORMAL;
//                            }
//                        }
//                    }
//                }
//                
//                
//                
//                for( i = 0; i < removeArray.length; i++)
//                {
//                    _boardPieceTypes[ removeArray[i] ]  = Constants.PIECE_TYPE_EMPTY;
//                }
//                
//                if(piecesToRemove.size() > 0)
//                {
//                    replaceEmptyBlocks();
//                    addNewPieces();
//                }
//                else
//                {
//                    //While no new joins are found, we don't keep searching after the first scan.
//                    isJoinsFound = false;
//                }
                
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


        
        
//        protected function replaceEmptyBlocks(): void
//        {
//                
//            //Start at the bottom row moving up
//            //If there are any empty pieces, swap with the next highest fallable block
//            
//            
//            for(var j: int = _rows - 2; j >= 0 ; j--)
//            {
//                for(var i: int = 0; i <  _cols ; i++)
//                {
//                    var pieceIndex :int = coordsToIdx(i, j);
//            
//                    //Now drop the piece as far as there are empty spaces below it.
//                    if( !(_boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_NORMAL || _boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_DEAD || _boardPieceTypes[pieceIndex] == Constants.PIECE_TYPE_POTENTIALLY_DEAD))
//                    {
//                        continue;
//                    } 
//                    
//                    var yToFall: int = j;
//                
//                
//                    while(yToFall < _rows)
//                    {
//                        if(  isPieceAt(i, yToFall+1) &&  _boardPieceTypes[ coordsToIdx(i, yToFall+1) ] == Constants.PIECE_TYPE_EMPTY)
//                        {
//                            yToFall++;
//                        }
//                        else
//                        {
//                            break;
//                        }
//                    }
//                    
//                    
//                    if( yToFall != j)
//                    {
//                        swapPieces(coordsToIdx(i, j), coordsToIdx(i, yToFall));
//                    }
//                
//                
//                }
//            }
//
//            
//        }

//        protected function addNewPieces(): void
//        {
//            for( var i: int = 0; i < _boardPieceTypes.length; i++)
//            {
//                if(_boardPieceTypes[i] == Constants.PIECE_TYPE_EMPTY)
//                {
//                    _boardPieceTypes[i] = Constants.PIECE_TYPE_NORMAL;
//                    _boardPieceColors[i] = generateRandomPieceColor();
//                    //We record this for syncing the boards between players
//                    _numberOfCallsToRandom++;
//                }
//            }
//        }
        
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
                if(join.isContainsPiece(idxToX(pieceIndex), idxToY(pieceIndex)))
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
            if(side == Constants.ATTACK_LEFT)
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
            else if(side == Constants.ATTACK_RIGHT)
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
//            this.dispatchEvent(new JoinGameEvent(playerID, JoinGameEvent.BOARD_UPDATED));
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
        
            
        //New idea, you get a piece to the left and right as well 
        private function addNewPieceToColumn(newPieceColumnIndex: int): void
        {
//            trace("addNewPieceToColumn(" + newPieceColumnIndex + "), board=\n" + this.toString());
            var rowIndexFree: int = findRowIndexWhereThereIsAFreePieceAtColumn( newPieceColumnIndex );
//            trace("rowIndexFree="+rowIndexFree);
            if( rowIndexFree == -1)
            {
                addRow(Constants.PIECE_TYPE_INACTIVE);
                 rowIndexFree = findRowIndexWhereThereIsAFreePieceAtColumn( newPieceColumnIndex );
                
            }
            
            _boardPieceTypes[ coordsToIdx(newPieceColumnIndex, rowIndexFree) ] = Constants.PIECE_TYPE_NORMAL;
//            trace("end addNewPieceToColumn(" + newPieceColumnIndex + "), board=\n" + this.toString());
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
//            markPotentiallyDead();
            
//            this.dispatchEvent(new JoinGameEvent(playerID, JoinGameEvent.BOARD_UPDATED));
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
            var update:JoinGameEvent = new JoinGameEvent(_playerID, JoinGameEvent.BOARD_UPDATED);
            
            //ATM we just redraw the entire board.
            dispatchEvent(update);    
            
        }
        

        
        override public function toString() :String
        {
            var s :String = "player id=" + _playerID + "\n";
            for( var j :int = 0; j < _rows; j++){
                for( var i :int = 0; i < _cols; i++){
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
        
        
        
        
//        var addEventListener:Function;
//            var removeEventListener:Function;
//            var dispatchEvent:Function;
            
        public var _boardPieceColors :Array;
        public var _boardPieceTypes :Array;
            
        public var _rows : int;
        public var _cols : int;
        
        private var _bottomRowTimer:Timer;
        
        public var _control :GameControl;
        
        //x1, y1, x2, y2
        private var _lastSwap: Array;
        
        private var _playerID:int;
            
        private var r:Random;
        private var _seed:int;
        public var _numberOfCallsToRandom: int;

    }
}

