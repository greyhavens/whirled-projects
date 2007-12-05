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
    }

    // from Canvas
    override protected function createChildren () :void
    {
        super.createChildren();
    }

    // from GameMode
    override public function pushed () :void
    {
        super.pushed();
        trace("PUSHING GAME LOADER...");

        _unloadables = new Array();
        _unloadables.push(_display = new Display(_main));
        _unloadables.push(_board = new Board(_main, _boardDef));
        _unloadables.push(_validator = new Validator(_main, _board));
        _unloadables.push(_controller = new Controller(_main, _board));
        _unloadables.push(_game = new Game(_main, _board, _display, _controller));
        _unloadables.push(_monitor = new Monitor(_main, _board, _game));

        _display.init(_board, _game, _controller);

        addChild(_display);
    }
    
    // from GameMode
    override public function popped () :void
    {
        super.popped();
        trace("POPPING GAME LOADER...");

        removeChild(_display);
        _display = null;
        _board = null;
        _validator = null;
        _controller = null;
        _game = null;
        _monitor = null;
        
        for each (var listener :UnloadListener in _unloadables) {
                listener.handleUnload();
            };
    }

    protected var _unloadables :Array; // of UnloadableListener

    protected var _display :Display;
    protected var _board :Board;
    protected var _validator :Validator;
    protected var _controller :Controller;
    protected var _game :Game;
    protected var _monitor :Monitor;
    
    protected var _boardDefs :Array; // of BoardDefinition
    protected var _boardDef :BoardDefinition; 
}
}
