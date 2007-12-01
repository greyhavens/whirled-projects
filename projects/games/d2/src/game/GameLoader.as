package game {

import modes.GameModeCanvas;

import def.BoardDefinition;

/**
 * Container class responsible for initializing and managing all game-related objects.
 */
public class GameLoader extends GameModeCanvas {

    public function GameLoader (main :Main, boardDefs :Array)
    {
        super(main);
        _boardDefs = boardDefs;
        _boardDef = boardDefs[0]; // temp

        _unloadables = new Array();
        _unloadables.push(_board = new Board(_main, _boardDef));
        _unloadables.push(_validator = new Validator(_main, _board));
    }

    // from Canvas
    override protected function createChildren () :void
    {
        super.createChildren();
    }

    // from GameMode
    override public function popped () :void
    {
        trace("POPPING GAME LOADER...");
        super.popped();
        for each (var listener :UnloadListener in _unloadables) {
                listener.handleUnload();
            };
    }

    protected var _unloadables :Array; // of UnloadableListener
    protected var _board :Board;
    protected var _validator :Validator;
    
    protected var _boardDefs :Array; // of BoardDefinition
    protected var _boardDef :BoardDefinition; 
}
}
