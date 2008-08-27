package {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import view.GameView;

public class ClientGameManager extends GameManager
{
    public function ClientGameManager (mainSprite :Sprite)
    {
        super(mainSprite);
        _mainSprite = mainSprite;
        AppContext.mainSprite = mainSprite;

        _gameView = new GameView();
        AppContext.gameView = _gameView;
        _mainSprite.addChild(_gameView);

        if (_gameCtrl.isConnected()) {
            mainSprite.root.loaderInfo.addEventListener(Event.UNLOAD,
                function (...ignored) :void {
                    shutdown();
                }
            );
        }

        // start the game when the player clicks the mouse
        mainSprite.addEventListener(MouseEvent.CLICK, onMouseDown);
    }

    protected function onMouseDown (...ignored) :void
    {
        if (firstStart()) {
            _mainSprite.removeEventListener(MouseEvent.CLICK, onMouseDown);
        }
    }

    protected var _mainSprite :Sprite;
    protected var _gameView :GameView;
}

}
