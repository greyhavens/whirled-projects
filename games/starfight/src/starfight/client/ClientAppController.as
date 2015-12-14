package starfight.client {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import starfight.*;

public class ClientAppController extends AppController
{
    public function ClientAppController (mainSprite :Sprite)
    {
        super(mainSprite);

        mainSprite.addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        ClientContext.mainSprite = mainSprite;
        ClientContext.sounds = new SoundManager();
        ClientContext.gameView = new GameView();
        ClientContext.myId = AppContext.gameCtrl.game.getMyId();

        mainSprite.addChild(ClientContext.gameView);

        // start the game when the player clicks the mouse
        mainSprite.addEventListener(MouseEvent.CLICK, onMouseDown);

        Resources.init(assetLoaded);

        // let the ShipTypeResources know who their ship types are
        for (var shipTypeId :int = 0; shipTypeId < Constants.SHIP_TYPE_CLASSES.length; shipTypeId++) {
            var shipType :ShipType = Constants.getShipType(shipTypeId);
            var shipTypeResources :ShipTypeResources = ClientConstants.getShipResources(shipTypeId);
            shipTypeResources.setShipType(shipType);
        }
    }

    override protected function run () :void
    {
        super.run();

        // TODO - handle starting a game in between rounds
        if (AppContext.gameCtrl.game.isInPlay()) {
            handleGameStarted();
        }
    }

    override public function shutdown () :void
    {
        ClientContext.gameView.shutdown();
        ClientContext.sounds.stopAllSounds();
        super.shutdown();
    }

    override protected function createGameManager () :GameController
    {
        return new ClientGameController(AppContext.gameCtrl);
    }

    override protected function createBoardController () :BoardController
    {
        return new ClientBoardController(AppContext.gameCtrl);
    }

    protected function assetLoaded (success :Boolean) :void
    {
        if (success) {
            _numLoadedAssets++;
            if (_numLoadedAssets <= Constants.SHIP_TYPE_CLASSES.length) {
                ClientConstants.getShipResources(_numLoadedAssets - 1).loadAssets(assetLoaded);
                return;
            }
        }
    }

    protected function onMouseDown (...ignored) :void
    {
        if (resourcesLoaded) {
            ClientContext.mainSprite.removeEventListener(MouseEvent.CLICK, onMouseDown);
            run();
        }
    }

    protected function get resourcesLoaded () :Boolean
    {
        return _numLoadedAssets > Constants.SHIP_TYPE_CLASSES.length;
    }

    protected function handleUnload (...ignored) :void
    {
        shutdown();
    }

    protected var _numLoadedAssets :int;
}

}
