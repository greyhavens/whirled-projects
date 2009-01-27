package vampire.client.actions.bloodbond
{
    
import com.threerings.flash.SimpleTextButton;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.contrib.EventHandlers;
import com.whirled.net.ElementChangedEvent;

import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.client.ClientContext;
import vampire.client.VampireController;
import vampire.client.actions.BaseVampireMode;
import vampire.data.SharedPlayerStateClient;
import vampire.data.SharedPlayerStateServer;
[RemoteClass(alias="vampire.client.modes.BloodBondMode")]

public class BloodBondMode extends BaseVampireMode
{
    public function BloodBondMode()
    {
        super();
    }
    
    override protected function setup() :void
    {
        super.setup();
        _bloodBondedView = new Sprite();
        
        var addTargetButton :SimpleTextButton = new SimpleTextButton("BloodBond Target");
        Command.bind( addTargetButton, MouseEvent.CLICK, VampireController.ADD_BLOODBOND);
        modeSprite.addChild( addTargetButton );
        addTargetButton.x = 20;
        addTargetButton.y = 30;
        
        modeSprite.addChild( _bloodBondedView );
        
        EventHandlers.registerListener( ClientContext.gameCtrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        
        showBloodBonded( SharedPlayerStateClient.getBloodBonded( ClientContext.ourPlayerId ) );
    }
    
    
    protected function elementChanged (e :ElementChangedEvent) :void
    {
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
        
        if( !isNaN( playerIdUpdated ) && playerIdUpdated == ClientContext.ourPlayerId) {
            
            if( e.index == SharedPlayerStateServer.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {
                showBloodBonded( e.newValue as Array );
            }
        }
    }
    
    
    override protected function destroy() :void
    {
        EventHandlers.unregisterListener( ClientContext.gameCtrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
    }
    
    
    override protected function setupUI() :void
    {
        super.setupUI();
    }
    
    protected function showBloodBonded( currentBloodBonded :Array ) :void
    {
        if( currentBloodBonded == null ) {
            log.warning("showBloodBonded(null)");
            return;
        }
        while( _bloodBondedView.numChildren > 0) { _bloodBondedView.removeChildAt(0);}
        
        var currentY :int = 100;
        for (var i :int = 0; i < currentBloodBonded.length; i += 2) {
            var playerId :int = int( currentBloodBonded[i] );
            if( playerId <= 0) {
                log.error("showBloodBonded(), currentBloodBonded[" + i + "]=" + currentBloodBonded[i] );
                continue;
            }
            var playerAvater :AVRGameAvatar = ClientContext.gameCtrl.room.getAvatarInfo( playerId );
            var buttonLabel :String = "" + playerId;
            if( playerAvater != null && playerAvater.name != null) {
                buttonLabel = playerAvater.name
            }
            else {
                buttonLabel = currentBloodBonded[i+1] as String;
            }
            var button :SimpleTextButton = new SimpleTextButton( buttonLabel );
            Command.bind( button, MouseEvent.CLICK, VampireController.REMOVE_BLOODBOND, playerId);
            button.y = currentY;
            currentY += 40;
            _bloodBondedView.addChild( button );
        }
        
        
    }
    
    protected var _bloodBondedView :Sprite;
    
    protected static const log :Log = Log.getLog( BloodBondMode );
    
}
}