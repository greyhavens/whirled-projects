package client {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

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

        Resources.init(assetLoaded);

        // start the game when the player clicks the mouse
        mainSprite.addEventListener(MouseEvent.CLICK, onMouseDown);

        if (_gameCtrl.isConnected()) {
            _gameCtrl.local.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
            _gameCtrl.local.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
        }
    }

    protected function assetLoaded (success :Boolean) :void {
        if (success) {
            _assets++;
            if (_assets <= Codes.SHIP_TYPE_CLASSES.length) {
                ClientConstants.getShipResources(_assets - 1).loadAssets(assetLoaded);
                return;
            }
        }
    }

    override protected function createBoardController () :BoardController
    {
        return new ClientBoardController(_gameCtrl);
    }

    protected function onMouseDown (...ignored) :void
    {
        if (firstStart()) {
            _mainSprite.removeEventListener(MouseEvent.CLICK, onMouseDown);
        }
    }

    protected function keyPressed (event :KeyboardEvent) :void
    {
        if (_ownShipView != null) {
            _ownShipView.keyPressed(event);
        }
    }

    protected function keyReleased (event :KeyboardEvent) :void
    {
        if (_ownShipView != null) {
            _ownShipView.keyReleased(event);
        }
    }

    protected var _mainSprite :Sprite;
    protected var _gameView :GameView;
}

}
