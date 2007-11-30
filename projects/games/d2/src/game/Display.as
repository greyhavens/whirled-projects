package game {


import def.BoardDefinition;

import modes.GameModeCanvas;

/**
 * General game board display class, which contains and manages everything that happens during the
 * game.
 */
public class Display extends GameModeCanvas
{
    public function Display (main :Main, board :BoardDefinition)
    {
        super(main);
        _board = board;
    }

    protected var _board :BoardDefinition;
}
}
