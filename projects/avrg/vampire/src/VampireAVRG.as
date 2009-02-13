package {


import fakeavrg.AVRGameControlFake;

import flash.display.Sprite;
import flash.utils.Dictionary;

import vampire.client.ClientContext;
import vampire.client.VampireMain;
import vampire.data.Codes;
import vampire.data.Constants;
import vampire.server.VServer;

[SWF(width="700", height="500")]
public class VampireAVRG extends Sprite
{
    public static function generateRandomString(newLength:uint = 1, userAlphabet:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String
    {
        var alphabet:Array = userAlphabet.split("");
        var alphabetLength:int = alphabet.length;
        var randomLetters:String = "";
        for (var i:uint = 0; i < newLength; i++){
            randomLetters += alphabet[int(Math.floor(Math.random() * alphabetLength))];
        }
        return randomLetters;
    }

    public function VampireAVRG()
    {

//        trace( "null === null: " + (null === null));
//        var m :MinionHierarchy = new MinionHierarchy();
//        var d :Dictionary = new Dictionary();
//        var size :int = 50000;



//        var b :ByteArray = new ByteArray();
//        for( var i :int = 0; i < size; i++) {
//            b.writeInt( Rand.nextInt(0));//My id
//            b.writeUTF( generateRandomString(10) );//My name
//            b.writeInt( Rand.nextInt(0) );//Sire id
//        }
//        trace("uncomressed=" + b.length);
//        b.compress()
//        trace("comressed=" + b.length);



        var v :VServer = new VServer();
        Constants.LOCAL_DEBUG_MODE = true;
        ClientContext.gameCtrl = new AVRGameControlFake( this );

        setupFakeData();

        addChild( new VampireMain() );
//
//



//        var e :String = ControlEvent.CHAT_RECEIVED;

//        var m :MinionHierarchy = new MinionHierarchy();
//        m.setPlayerSire( 1, 2);
//        m.setPlayerSire( 3, 2);
//        m.setPlayerSire( 4, 2);
//        m.setPlayerSire( 5, 1);
//        m.setPlayerSire( 6, 1);
//        m.setPlayerSire( 7, 1);
//        m.setPlayerSire( 8, 1);
//
//        m.setPlayerSire( 4, 1);
//
//        m.setPlayerSire( 9, 5);
//        m.setPlayerSire( 10, 5);
//        m.setPlayerSire( 11, 5);
//
//        trace(m);
//
//        trace(m.getSireProgressionCount(5));
//
//        var m2 :MinionHierarchy = new MinionHierarchy();
//        m2.fromBytes( m.toBytes() );
//
//        trace(m2);


//        var m :MinionHierarchy = new MinionHierarchy();
//        m.setPlayerSire( 1, 2);
//        m.setPlayerSire( 3, 2);
//        m.setPlayerSire( 4, 1);
//        trace(m);
//
//        m.setPlayerSire( 2, 1);
//        trace(m);
//
//        m.setPlayerSire( 5, 4);
//        trace(m);
//
//        m.setPlayerSire( 5, 2);
//        trace(m);

//        return;





//        addChild( new HierarchyView() );



//        this.root.addEventListener(Event.ADDED_TO_STAGE, function(...ignored) :void {trace("Added to stage");});
//        addEventListener(Event.ADDED_TO_STAGE, function(...ignored) :void {trace("Added to stage");});
//        var a :AVRGameControlFake = new AVRGameControlFake( this );
//        var ac :AVRGameControl = new AVRGameControl( this );
//        var fake :AVRGameControlFAKE = new AVRGameControlFAKE( this );


//        ServerContext.ctrl = new AVRServerGameControlFake( this );



    }

    protected function setupFakeData() :void
    {
        ClientContext.ourPlayerId = 1;
        var c :AVRGameControlFake = AVRGameControlFake(ClientContext.gameCtrl);

        var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + c.player.getPlayerId();
        var dict :Dictionary = new Dictionary();
        //c.room.props.set( key, dict );

        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_ID] = 2;
        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_BLOOD] = 50;
        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_MAXBLOOD] = 100;
        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED] = 2;
        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME] = "Player " + 2;
        dict[ Codes.ROOM_PROP_PLAYER_DICT_INDEX_TARGET_DISPLAY_VISIBLE] = true;




    }
}
}
