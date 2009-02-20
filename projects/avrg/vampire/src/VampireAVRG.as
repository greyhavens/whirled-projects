package {


import fakeavrg.AVRGameControlFake;

import flash.display.Sprite;

import vampire.client.ClientContext;
import vampire.client.VampireMain;
import vampire.data.VConstants;
import vampire.server.BloomBloomManager;
import vampire.server.VServer;

[SWF(width="700", height="500")]
public class VampireAVRG extends Sprite
{
//    public static function generateRandomString(newLength:uint = 1, userAlphabet:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String
//    {
//        var alphabet:Array = userAlphabet.split("");
//        var alphabetLength:int = alphabet.length;
//        var randomLetters:String = "";
//        for (var i:uint = 0; i < newLength; i++){
//            randomLetters += alphabet[int(Math.floor(Math.random() * alphabetLength))];
//        }
//        return randomLetters;
//    }
    
    public function VampireAVRG()
    {
        
//        var r :BloomBloomStarter = new BloomBloomStarter(null);
//        var xx :AvatarGameBridge = new AvatarGameBridge( null, null);
        var v :VServer = new VServer();
        VConstants.LOCAL_DEBUG_MODE = true;
        ClientContext.gameCtrl = new AVRGameControlFake( this );
        addChild( new VampireMain() );
//        
//        setupFakeData();
//        var ob :ObjectDBThane = new ObjectDBThane();
        
        
        
//        var playerIDs :Array = [1,2];
//        var playerLocations :Array = [[100, 100], [300,300]];
//        var playerDims :Array = [[100, 100], [100,100]];
//        
//        var at :TargetingOverlayAvatars = new TargetingOverlayAvatars(null, null, null);
//        var t :TargetingOverlay = new TargetingOverlay(playerIDs, playerLocations, playerDims, mouseClicked, mouseOver);
//        
//        addChild( t.displayObject );
//        
//        function mouseOver( playerId :int, rect :Rectangle, sprite :Sprite ) :void
//        {
////            var targetSprite :Sprite = Sprite(t.displayObject);
//            sprite.graphics.clear();
//            sprite.graphics.lineStyle(2, 0);
//            sprite.graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
//            return;
//        }
//        
//        function mouseClicked( playerId :int, rect :Rectangle, sprite :Sprite ) :void
//        {
////            var targetSprite :Sprite = Sprite(t.displayObject);
//            sprite.graphics.clear();
//            sprite.graphics.beginFill(0);
//            sprite.graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
//            sprite.graphics.endFill();
//            return;
//        }
        
        
        
    }
    
//    protected function setupFakeData() :void
//    {
//        ClientContext.ourPlayerId = 1;
//        var c :AVRGameControlFake = AVRGameControlFake(ClientContext.gameCtrl);
//        
//        var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + c.player.getPlayerId();
//        var dict :Dictionary = new Dictionary();
//        PropertyGetSubControlFake(c.room.props).set( key, dict );
//        
//        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_ID] = 2;
//        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_BLOOD] = 50;
//        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_MAXBLOOD] = 100;
//        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED] = 2;
//        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME] = "Player " + 2;
//        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_DISPLAY_VISIBLE] = true;
//        
//        
//    }
}
}
