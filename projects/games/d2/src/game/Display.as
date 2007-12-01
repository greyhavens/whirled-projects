package game {


import def.BoardDefinition;

import modes.GameModeCanvas;

/**
 * General game board display class, which contains and manages everything that happens during the
 * game.
 */
public class Display extends GameModeCanvas
{
    public function Display (main :Main, boards :Array)
    {
        super(main);
    }

    // @Override from Canvas
    override protected function createChildren () :void
    {
        // note - this happens before init
        
        super.createChildren();
        
        // initialize graphics
        _backdrop = new Image();
        addChild(_backdrop);

        _boardSprite = new Canvas();
        _boardSprite.x = Board.BOARD_OFFSETX;
        _boardSprite.y = Board.BOARD_OFFSETY;
        addChild(_boardSprite);

        createUI();
        createOverlays();
        
        // initialize event handlers
        addEventListener(MouseEvent.CLICK, handleBoardClick);
        addEventListener(MouseEvent.MOUSE_MOVE, handleBoardMove);
        addEventListener(Event.ENTER_FRAME, handleFrame);
    }
  
    /** Creates buttons and other UI elements. */
    protected function createUI () :void
    {
        PopUpManager.addPopUp(_towerPanel = new TowerPanel(this), this, false);
        PopUpManager.addPopUp(_debugPanel = new DebugPanel(this), this, false);
        addChild(_statusBar = new StatusBar());

        _towerPanel.x = 580;
        _towerPanel.y = 40;
        
        hideUI();
        
        // these have to be created before we know how many players we actually have.
        // so let's make all of them, and later initialize those that get used.
        _scorePanels = new Array(MAX_PLAYERS);
        for (var ii :int = 0; ii < MAX_PLAYERS; ii++) {
            addChild(_scorePanels[ii] = new ScorePanel());
        }
        
        _counter = new Text();
        _counter.x = 5;
        _counter.y = 420;
        addChild(_counter);

        _splash = new Splash(handlePlayClicked);
        addChild(_splash);
    }


    protected var _allBoards :Array; // of BoardDefinition
    protected var _board :BoardDefinition;
}
}
