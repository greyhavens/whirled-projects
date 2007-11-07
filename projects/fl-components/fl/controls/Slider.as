// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {
	
	import fl.controls.BaseButton;
	import fl.controls.SliderDirection;
	import fl.controls.ScrollBar;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import fl.events.SliderEvent;
	import fl.events.InteractionInputType;
	import fl.events.SliderEventClickTarget;
	import fl.managers.IFocusManagerComponent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;	

    //--------------------------------------
    //  Events
    //--------------------------------------
	/**
	 * Dispatched when the slider thumb is pressed. 
	 *
     * @eventType fl.events.SliderEvent.THUMB_PRESS
     *
     * @see #event:thumbDrag
     * @see #event:thumbRelease
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="thumbPress", type="fl.events.SliderEvent")]
	
	/**
	 * Dispatched when the slider thumb is pressed and released.
	 *
     * @eventType fl.events.SliderEvent.THUMB_RELEASE
     *
     * @includeExample examples/Slider.thumbRelease.1.as -noswf
     *
     * @see #event:thumbDrag
     * @see #event:thumbPress
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="thumbRelease", type="fl.events.SliderEvent")]
	
	/**
	 * Dispatched when the slider thumb is pressed and 
	 * then moved by the mouse. This event is always preceded by a 
     * <code>thumbPress</code> event. 
	 *
     * @eventType fl.events.SliderEvent.THUMB_DRAG
     *
     * @includeExample examples/Slider.thumbDrag.1.as -noswf
     *
     * @see #event:thumbPress
     * @see #event:thumbRelease
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="thumbDrag", type="fl.events.SliderEvent")]
	
	/**
	 * Dispatched when the value of the Slider component changes as a result of mouse or keyboard 
     * interaction. If the <code>liveDragging</code> property is <code>true</code>, the event is 
	 * dispatched continuously as the user moves the thumb. If 
     * <code>liveDragging</code> is <code>false</code>, the event is dispatched when the user 
	 * releases the slider thumb.
	 *
     * @eventType fl.events.SliderEvent.CHANGE
     *
     * @see #liveDragging
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="change", type="fl.events.SliderEvent")]	
	
    //--------------------------------------
    //  Styles
    //--------------------------------------
    /**
     *  @copy fl.controls.ScrollBar#style:thumbUpSkin
     *
     *  @default SliderThumb_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="thumbUpSkin", type="Class")]

    /**
     *  @copy fl.controls.ScrollBar#style:thumbOverSkin
     *
     *  @default SliderThumb_overSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="thumbOverSkin", type="Class")] 
 
    /**
     *  @copy fl.controls.ScrollBar#style:thumbDownSkin
     *
     *  @default SliderThumb_downSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="thumbDownSkin", type="Class")]

    /**
     *  @copy fl.controls.ScrollBar#style:thumbDisabledSkin
     *
     *  @default SliderThumb_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="thumbDisabledSkin", type="Class")]

    /**
     *  The skin for the track in a Slider component.
     *
     *  @default SliderTrack_skin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="sliderTrackSkin", type="Class")]

    /**
     *  The skin for the track in a Slider component that is disabled.
     *
     *  @default SliderTrack_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="sliderTrackDisabledSkin", type="Class")]

    /**
     *  The skin for the ticks in a Slider component.
     *
     *  @default SliderTick_skin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="tickSkin", type="Class")]


    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The Slider component lets users select a value by moving a slider 
	 * thumb between the end points of the slider track. The current 
	 * value of the Slider component is determined by the relative location of 
	 * the thumb between the end points of the slider, corresponding to 
     * the <code>minimum</code> and <code>maximum</code> values of the Slider
	 * component.
	 *
     * @includeExample examples/SliderExample.as
     *
     * @see fl.events.SliderEvent SliderEvent
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class Slider extends UIComponent implements IFocusManagerComponent {
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _direction:String = SliderDirection.HORIZONTAL;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _minimum:Number = 0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _maximum:Number = 10;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _value:Number = 0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _tickInterval:Number = 0;   
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _snapInterval:Number = 0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _liveDragging:Boolean = false;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var tickContainer:Sprite;
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var thumb:BaseButton;
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var track:BaseButton;
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected static var defaultStyles:Object = {
			thumbUpSkin: "SliderThumb_upSkin",
			thumbOverSkin : "SliderThumb_overSkin", 
			thumbDownSkin: "SliderThumb_downSkin",
			thumbDisabledSkin: "SliderThumb_disabledSkin",
			sliderTrackSkin: "SliderTrack_skin",
			sliderTrackDisabledSkin: "SliderTrack_disabledSkin",
			tickSkin: "SliderTick_skin",
			focusRectSkin:null,
			focusRectPadding:null
		}
		
        /**
         * @copy fl.core.UIComponent#getStyleDefinition()
         *
		 * @includeExample ../core/examples/UIComponent.getStyleDefinition.1.as -noswf
		 *
         * @see fl.core.UIComponent#getStyle() UIComponent.getStyle()
         * @see fl.core.UIComponent#setStyle() UIComponent.setStyle()
         * @see fl.managers.StyleManager StyleManager
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public static function getStyleDefinition():Object { return defaultStyles; }
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected static const TRACK_STYLES:Object = {
			upSkin: "sliderTrackSkin",
			overSkin: "sliderTrackSkin",
			downSkin: "sliderTrackSkin",
			disabledSkin: "sliderTrackDisabledSkin"
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected static const THUMB_STYLES:Object = {
			upSkin: "thumbUpSkin",
			overSkin: "thumbOverSkin",
			downSkin: "thumbDownSkin",
			disabledSkin: "thumbDisabledSkin"
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected static const TICK_STYLES:Object = {
			upSkin: "tickSkin"
		}
		
		/**
         * Creates a new Slider component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function Slider() { 
			super(); 
			setStyles();
		}
		
		[Inspectable(enumeration="horizontal,vertical", defaultValue="horizontal")]
		/**
         * Sets the direction of the slider. Acceptable values are <code>SliderDirection.HORIZONTAL</code> and 
         * <code>SliderDirection.VERTICAL</code>. 
         *
         * @default SliderDirection.HORIZONTAL
         *
		 * @includeExample examples/Slider.direction.1.as -noswf
		 *
         * @see SliderDirection
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get direction():String { 
			return _direction;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set direction(value:String):void {
			_direction = value;

			var vertical:Boolean = (_direction == SliderDirection.VERTICAL);

			if (isLivePreview) {
				if (vertical) {
					setScaleY(-1);
					y = track.height;
				} else {
					setScaleY(1);
					y = 0;
				}
				positionThumb();
				return;
			}

			if (vertical && componentInspectorSetting) {
				if (rotation % 90 == 0) {
					setScaleY(-1);
				}
			}
			
			if (!componentInspectorSetting) {
				rotation = (vertical)?90:0;
			}
		}
		
		[Inspectable(defaultValue=0)]
		/**
		 * The minimum value allowed on the Slider component instance.
         *
         * @default 0
         *
         * @see #maximum
         * @see #value
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get minimum():Number { return _minimum; }
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set minimum(value:Number):void {
			_minimum = value;
			this.value = Math.max(value, this.value);
			invalidate(InvalidationType.DATA);
		}
		
		[Inspectable(defaultValue=10)]
		/**
		 * The maximum allowed value on the Slider component instance.
         *
         * @default 10
         *
         * @see #minimum
         * @see #value
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		 
		public function get maximum():Number {
			return _maximum;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set maximum(value:Number):void {
			_maximum = value;
			this.value = Math.min(value, this.value);
			invalidate(InvalidationType.DATA);
		}
		
		[Inspectable(defaultValue=0)]
		/**
		 * The spacing of the tick marks relative to the maximum value 
		 * of the component. The Slider component displays tick marks whenever 
         * you set the <code>tickInterval</code> property to a nonzero value.
         *
         * @default 0
         *
         * @see #snapInterval
         *
		 * @includeExample examples/Slider.tickInterval.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		 
		public function get tickInterval():Number {
			return _tickInterval;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set tickInterval(value:Number):void { 
			_tickInterval = value;
			invalidate(InvalidationType.SIZE);
		}
		
		[Inspectable(defaultValue=0)]
		/**
		 * Gets or sets the increment by which the value is increased or decreased
		 * as the user moves the slider thumb. 
		 *
		 * <p>For example, this property is set to 2, the <code>minimum</code> value is 0, 
		 * and the <code>maximum</code> value is 10, the position of the thumb will always  
		 * be at 0, 2, 4, 6, 8, or 10. If this property is set to 0, the slider 
		 * moves continuously between the <code>minimum</code> and <code>maximum</code> values.</p>
         *
         * @default 0
         *
         * @includeExample examples/Slider.snapInterval.2.as -noswf
         * @includeExample examples/Slider.snapInterval.1.as -noswf
         *
         * @see #tickInterval
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get snapInterval():Number {
			return _snapInterval;
		}
		
		/**
         * @private (setter)
         *
		 * @includeExample examples/Slider.snapInterval.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set snapInterval(value:Number):void {
			_snapInterval = value;
		}
		
		[Inspectable(defaultValue=false)]
		/**
         * Gets or sets a Boolean value that indicates whether the <code>SliderEvent.CHANGE</code> 
		 * event is dispatched continuously as the user moves the slider thumb. If the 
		 * <code>liveDragging</code> property is <code>false</code>, the <code>SliderEvent.CHANGE</code> 
		 * event is dispatched when the user releases the slider thumb.
         *
         * @default false
         *
		 * @includeExample examples/Slider.liveDragging.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		 
		public function set liveDragging(value:Boolean):void {
			_liveDragging = value;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get liveDragging():Boolean {
			return _liveDragging;
		}
				
		[Inspectable(defaultValue=true, verbose=1)]
		/**
		 * @copy fl.core.UIComponent#enabled
         *
         * @default true
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get enabled():Boolean {
			return super.enabled;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set enabled(value:Boolean):void {
			if (enabled == value) { return; }
			super.enabled = value;
			track.enabled = thumb.enabled = value;
		}
		
		/**
         * @copy fl.core.UIComponent#setSize()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function setSize(w:Number, h:Number):void {			
			if (_direction == SliderDirection.VERTICAL && !isLivePreview) {
				super.setSize(h, w);
			} else {
				super.setSize(w, h);
			}			
			invalidate(InvalidationType.SIZE);
		}
		
		[Inspectable(defaultValue=0)]
		/**
         * Gets or sets the current value of the Slider component. This value is 
		 * determined by the position of the slider thumb between the minimum and 
		 * maximum values.
         *
         * @default 0
         *
         * @see #maximum
         * @see #minimum
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		 
		public function get value():Number {
			return _value;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set value(value:Number):void {
			doSetValue(value);
		}	
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function doSetValue(val:Number, interactionType:String=null, clickTarget:String=null, keyCode:int=undefined):void {
			var oldVal:Number = _value;
			if (_snapInterval != 0 && _snapInterval != 1) { 
				var pow:Number = Math.pow(10, getPrecision(snapInterval));
				var snap:Number = _snapInterval * pow;
				var rounded:Number = Math.round(val * pow);
				var snapped:Number = Math.round(rounded / snap) * snap;
				var val:Number = snapped / pow;
				_value = Math.max(minimum, Math.min(maximum,val));
			} else {
				_value = Math.max(minimum, Math.min(maximum, Math.round(val)));
			}
			// Only dispatch if value has changed
			// Dispatch when dragging			
			if (oldVal != _value && ((liveDragging && clickTarget != null) || (interactionType == InteractionInputType.KEYBOARD))) {
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE, value, clickTarget, interactionType, keyCode));
			}
			
			positionThumb();
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setStyles():void {
			copyStylesToChild(thumb, THUMB_STYLES);
			copyStylesToChild(track, TRACK_STYLES);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) { 
				setStyles();
				invalidate(InvalidationType.SIZE, false);
			}
			
			if (isInvalid(InvalidationType.SIZE)) {
				track.setSize(_width, track.height);
				track.drawNow();
				thumb.drawNow();
			}
			if (tickInterval > 0) {
				drawTicks();
			} else {
				clearTicks();
			}
			
			positionThumb();
			super.draw();
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function positionThumb():void {
			thumb.x = ((_direction == SliderDirection.VERTICAL) ? (maximum-minimum-value) : (value-minimum))/(maximum-minimum)*(_width);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawTicks():void {
			clearTicks();
			tickContainer = new Sprite();
			var divisor:Number = (maximum<1)?tickInterval/100:tickInterval;
			var l:Number = (maximum-minimum)/divisor;
			var dist:Number = _width/l;
			for (var i:uint=0;i<=l;i++) {
				var tick:DisplayObject = getDisplayObjectInstance(getStyleValue("tickSkin"));
				tick.x = dist * i;
				tick.y = (track.y - tick.height) - 2;
				tickContainer.addChild(tick);
			}
			addChild(tickContainer);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function clearTicks():void {
			if (!tickContainer || !tickContainer.parent) { return; }
			removeChild(tickContainer);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function calculateValue(pos:Number, interactionType:String, clickTarget:String, keyCode:int = undefined):void {
			var newValue:Number = (pos/_width)*(maximum-minimum);
			if (_direction == SliderDirection.VERTICAL) {
				newValue = (maximum - newValue);
			} else {
				newValue = (minimum + newValue);
			}
			doSetValue(newValue, interactionType, clickTarget, keyCode);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function doDrag(event:MouseEvent):void {
			var dist:Number = _width/snapInterval;
			var thumbPos:Number = track.mouseX;
			calculateValue(thumbPos, InteractionInputType.MOUSE, SliderEventClickTarget.THUMB);
			dispatchEvent(new SliderEvent(SliderEvent.THUMB_DRAG, value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function thumbPressHandler(event:MouseEvent):void {
			UIComponent.stageAlias.addEventListener(MouseEvent.MOUSE_MOVE,doDrag,false,0,true);
			UIComponent.stageAlias.addEventListener(MouseEvent.MOUSE_UP,thumbReleaseHandler,false,0,true);
			dispatchEvent(new SliderEvent(SliderEvent.THUMB_PRESS, value, InteractionInputType.MOUSE, SliderEventClickTarget.THUMB));
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function thumbReleaseHandler(event:MouseEvent):void {
			UIComponent.stageAlias.removeEventListener(MouseEvent.MOUSE_MOVE,doDrag);
			UIComponent.stageAlias.removeEventListener(MouseEvent.MOUSE_UP,thumbReleaseHandler);
			dispatchEvent(new SliderEvent(SliderEvent.THUMB_RELEASE, value, InteractionInputType.MOUSE, SliderEventClickTarget.THUMB));
			dispatchEvent(new SliderEvent(SliderEvent.CHANGE, value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function onTrackClick(event:MouseEvent):void {			
			calculateValue(track.mouseX, InteractionInputType.MOUSE, SliderEventClickTarget.TRACK);
			if (!liveDragging) {
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE, value, SliderEventClickTarget.TRACK, InteractionInputType.MOUSE));
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void {
			if (!enabled) { return; }
			var incrementBy:uint = (snapInterval > 0) ? snapInterval : 1;
			var newValue:Number;
			var isHorizontal:Boolean = (direction == SliderDirection.HORIZONTAL);

			if ((event.keyCode == Keyboard.DOWN && !isHorizontal) || (event.keyCode == Keyboard.LEFT && isHorizontal)) {
				newValue = value - incrementBy;
			} else if ((event.keyCode == Keyboard.UP && !isHorizontal) || (event.keyCode == Keyboard.RIGHT && isHorizontal)) {
				newValue = value + incrementBy;
			} else if ((event.keyCode == Keyboard.PAGE_DOWN && !isHorizontal) || (event.keyCode == Keyboard.HOME && isHorizontal)) {
				newValue = minimum;
			} else if ((event.keyCode == Keyboard.PAGE_UP && !isHorizontal) || (event.keyCode == Keyboard.END && isHorizontal)) {
				newValue = maximum;
			}
			
			if (!isNaN(newValue)) {
				event.stopPropagation();
				doSetValue(newValue, InteractionInputType.KEYBOARD, null, event.keyCode);
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function configUI():void {
			super.configUI();
			
			thumb = new BaseButton();
			thumb.setSize(13, 13);
			thumb.autoRepeat = false;
			addChild(thumb);
			
			thumb.addEventListener(MouseEvent.MOUSE_DOWN,thumbPressHandler,false,0,true);
			
			track = new BaseButton();
			track.move(0, 0);
			track.setSize(80, 4);
			track.autoRepeat = false;
			track.useHandCursor = false;
			track.addEventListener(MouseEvent.CLICK,onTrackClick,false,0,true);
			addChildAt(track,0);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function getPrecision(num:Number):Number {
			var s:String = num.toString();
			if (s.indexOf(".") == -1) { return 0; }
			return s.split(".").pop().length;
		}
	}
}
