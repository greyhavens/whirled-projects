package vampire.client
{
    import com.threerings.flash.TextFieldUtil;
    import com.threerings.util.HashMap;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    public class TargetingOverlay extends SceneObject
    {
        /**
        * 
        * callback(playerIdSelected), callback(0) for no player clicked
        */
        public function TargetingOverlay( playerIds :Array, screenCoordsCenter :Array, 
              screenDimensions :Array, targetClickedCallback :Function = null,
              mouseOverTarget :Function  = null)
        {
            _displaySprite  = new Sprite();
            _displaySprite.mouseChildren = false;
            _displaySprite.mouseEnabled = true;
            _displaySprite.graphics.beginFill(0, 0);
            _displaySprite.graphics.drawRect(0, 0, 700, 500);
            _displaySprite.graphics.endFill();
            
            //For testing purposes
            
            _displaySprite.addChild( TextFieldUtil.createField("TargetingOverlay", {x:10, y:10, selectable:false}));
            
            _paintableOverlay = new Sprite();
            _displaySprite.addChild( _paintableOverlay );
            _paintableOverlay.mouseChildren = false;
            _paintableOverlay.mouseEnabled = false;
            
            _targetClickedCallback = targetClickedCallback;
            _mouseOverCallback = mouseOverTarget;
            
            if( _targetClickedCallback == null) {
                _targetClickedCallback = function (...ignored ) :void {
                    trace("Target Clicked, should replace targetClickedCallback");}
//                throw new Error("TargetingRoomOverlay(), callback cannot be null");
            }
            
            registerListener( _displaySprite, MouseEvent.MOUSE_MOVE, handleMouseMove);
            registerListener( _displaySprite, MouseEvent.CLICK, handleMouseClick);
            
            _rects = new HashMap();
            
            reset( playerIds, screenCoordsCenter, screenDimensions );
        }
        
        public function reset( playerIds :Array, screenCoordsCenter :Array, screenDimensions :Array) :void
        {
            _rects.clear();
            
            for( var i :int = 0; 
                i < playerIds.length && i < screenCoordsCenter.length && i < screenDimensions.length; 
                i++) {
                
                _rects.put( playerIds[i], new Rectangle(
                    screenCoordsCenter[i][0] - screenDimensions[i][0]/2,
                    screenCoordsCenter[i][1] - screenDimensions[i][1]/2,
                    screenDimensions[i][0],
                    screenDimensions[i][1]
                    ));
            }
            
            
        }
        
        override public function get displayObject () :DisplayObject
        {
            return _displaySprite;
        }
        
        protected function handleMouseMove( e :MouseEvent ) :void
        {
            var mouseMovedOverPlayerId :int = 0;
            var mouseOverRect :Rectangle;
            
            _rects.forEach( function( playerId :int, rect :Rectangle) :void {
                if( mouseMovedOverPlayerId ) {
                    return;
                }
                
                if( rect.contains( e.localX, e.localY )) {
                    mouseMovedOverPlayerId = playerId;
                    mouseOverRect = rect;
                }
                
            });
            if( _mouseOverCallback != null && mouseMovedOverPlayerId > 0) {
                _mouseOverCallback( mouseMovedOverPlayerId, mouseOverRect, _paintableOverlay );
            }
            else {
                _paintableOverlay.graphics.clear();
            }
        }
        
        protected function handleMouseClick( e :MouseEvent ) :void
        {
            var mouseClickedPlayerId :int = 0;
            var mouseClickedRect :Rectangle;
            
            _rects.forEach( function( playerId :int, rect :Rectangle) :void {
                if( mouseClickedPlayerId ) {
                    return;
                }
                
                if( rect.contains( e.localX, e.localY )) {
                    mouseClickedPlayerId = playerId;
                    mouseClickedRect = rect;
                }
                
            });
            
            if( _targetClickedCallback != null && mouseClickedPlayerId > 0) {
                _targetClickedCallback( mouseClickedPlayerId, mouseClickedRect, _paintableOverlay );
            }
            else {
                _paintableOverlay.graphics.clear();
            }
        }

        protected var _displaySprite :Sprite;
        
        protected var _paintableOverlay :Sprite;
        
        protected var _targetClickedCallback :Function;
        protected var _mouseOverCallback :Function;
        
        protected var _rects :HashMap;
        
    }
}