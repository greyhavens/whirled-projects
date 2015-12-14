// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {	

	import fl.controls.progressBarClasses.IndeterminateBar;
	import fl.controls.ProgressBarDirection;
	import fl.controls.ProgressBarMode;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;	

    //--------------------------------------
    //  Events
    //--------------------------------------
	/**
	 * Dispatched when the load operation completes. 
     *
     * @eventType flash.events.Event.COMPLETE
     *
     * @includeExample examples/ProgressBar.complete.1.as -noswf
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("complete", type="flash.events.Event")]


	/**
	 * Dispatched as content loads in event mode or polled mode. 
     *
     * @eventType flash.events.ProgressEvent.PROGRESS
     *
     * @includeExample examples/ProgressBar.complete.1.as -noswf
     *
     * @see ProgressBarMode#EVENT ProgressBarMode.EVENT
     * @see ProgressBarMode#POLLED ProgressBarMode.POLLED
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event("progress", type="flash.events.ProgressEvent")]
	

    //--------------------------------------
    //  Styles
    //--------------------------------------
    /**
     * Name of the class to use as the default icon. Setting any other icon  
     * style overrides this setting.
     *  
     * @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="icon", type="Class")]

    /**
     * Name of the class to use as the progress indicator track.
     * 
     * @default ProgressBar_trackSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="trackSkin", type="Class")]

    /**
     * Name of the class to use as the determinate progress bar.
     * 
     * @default ProgressBar_barSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="barSkin", type="Class")]

    /**
     * Name of the class to use as the indeterminate progress bar. This is passed to the  
     * indeterminate bar renderer, which is specified by the <code>indeterminateBar</code> 
     * style.
     *  
     * @default ProgressBar_indeterminateSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="indeterminateSkin", type="Class")]

    /**
     * The class to use as a renderer for the indeterminate bar animation.  
     * This is an advanced style.
     * 
     * @default fl.controls.progressBarClasses.IndeterminateBar
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="indeterminateBar", type="Class")]

    /**
     * The padding that separates the progress bar indicator from the track, in pixels.
     * 
     * @default 0
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="barPadding", type="Number", format="Length")]


    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The ProgressBar component displays the progress of content that is 
	 * being loaded. The ProgressBar is typically used to display the status of 
	 * images, as well as portions of applications, while they are loading. 
	 * The loading process can be determinate or indeterminate. A determinate 
	 * progress bar is a linear representation of the progress of a task over 
	 * time and is used when the amount of content to load is known. An indeterminate 
     * progress bar has a striped fill and a loading source of unknown size.
	 *
     * @includeExample examples/ProgressBarExample.as
     *
     * @see ProgressBarDirection
     * @see ProgressBarMode
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class ProgressBar extends UIComponent {
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var track:DisplayObject;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var determinateBar:DisplayObject;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var indeterminateBar:UIComponent;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _direction:String = ProgressBarDirection.RIGHT;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _indeterminate:Boolean = true;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _mode:String = ProgressBarMode.EVENT;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _minimum:Number=0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _maximum:Number=0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _value:Number=0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _source:Object;
		
		/**
		 * @private (protected)
		 */
		protected var _loaded:Number;
		
		
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var defaultStyles:Object = {trackSkin:"ProgressBar_trackSkin",
												  barSkin:"ProgressBar_barSkin",
												  indeterminateSkin:"ProgressBar_indeterminateSkin",
												  indeterminateBar:IndeterminateBar,
												  barPadding:0};
        /**
         * @copy fl.core.UIComponent#getStyleDefinition()
         *
		 * @includeExample ../core/examples/UIComponent.getStyleDefinition.1.as -noswf
		 *
         * @see fl.core.UIComponent#getStyle()
         * @see fl.core.UIComponent#setStyle()
         * @see fl.managers.StyleManager
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public static function getStyleDefinition():Object { return defaultStyles; }
		
		
		/**
         * Creates a new ProgressBar component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function ProgressBar() { 
			super();
		}		
		
		[Inspectable(defaultValue="right",type="list", enumeration="right,left")]
		/**
         * Indicates the fill direction for the progress bar. A value of 
         * <code>ProgressBarDirection.RIGHT</code> indicates that the progress 
         * bar is filled from left to right. A value of <code>ProgressBarDirection.LEFT</code>
         * indicates that the progress bar is filled from right to left.
         *
         * @default ProgressBarDirection.RIGHT
		 *
		 * @includeExample examples/ProgressBar.direction.1.as -noswf
		 *
         * @see ProgressBarDirection
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
			invalidate(InvalidationType.DATA);
		}
		
		/**
         * Gets or sets a value that indicates the type of fill that the progress 
		 * bar uses and whether the loading source is known or unknown. A value of 
		 * <code>true</code> indicates that the progress bar has a striped fill 
		 * and a loading source of unknown size. A value of <code>false</code> 
		 * indicates that the progress bar has a solid fill and a loading source 
		 * of known size. 
		 *
		 * <p>This property can only be set when the progress bar mode 
		 * is set to <code>ProgressBarMode.MANUAL</code>.</p>
         *
         * @default true
		 *
		 * @see #mode
		 * @see ProgressBarMode
         * @see fl.controls.progressBarClasses.IndeterminateBar IndeterminateBar
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get indeterminate():Boolean {
			return _indeterminate;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set indeterminate(value:Boolean):void {
			if (_mode != ProgressBarMode.MANUAL || _indeterminate == value) { return; }
			setIndeterminate(value);
		}
		/**
         * Gets or sets the minimum value for the progress bar when the 
		 * <code>ProgressBar.mode</code> property is set to <code>ProgressBarMode.MANUAL</code>.
         *
         * @default 0
         *
         * @see #maximum
         * @see #percentComplete
         * @see #value
         * @see ProgressBarMode#MANUAL
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get minimum():Number {
			return _minimum;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set minimum(value:Number):void {
			if (_mode != ProgressBarMode.MANUAL) { return; }
			_minimum = value;
			invalidate(InvalidationType.DATA);
		}
		/**
         * Gets or sets the maximum value for the progress bar when the 
		 * <code>ProgressBar.mode</code> property is set to <code>ProgressBarMode.MANUAL</code>.
         *
         * @default 0
         *
         * @see #minimum
         * @see #percentComplete
         * @see #value
         * @see ProgressBarMode#MANUAL
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
			setProgress(_value,value);
		}
		
		/**
         * Gets or sets a value that indicates the amount of progress that has 
		 * been made in the load operation. This value is a number between the 
		 * <code>minimum</code> and <code>maximum</code> values.
         *
         * @default 0
         *
         * @see #maximum
         * @see #minimum
         * @see #percentComplete
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
			setProgress(value,_maximum);
		}
		
		
		/**
         * Sets the state of the bar to reflect the amount of progress made when 
         * using manual mode. The <code>value</code> argument is assigned to the 
         * <code>value</code> property and the <code>maximum</code> argument is
         * assigned to the <code>maximum</code> property. The <code>minimum</code> 
         * property is not altered.
		 *
         * @param value A value describing the progress that has been made. 
		 *
         * @param maximum The maximum progress value of the progress bar.
		 *
         * @see #maximum
         * @see #value
         * @see ProgressBarMode#MANUAL ProgressBarMode.manual
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function setProgress(value:Number, maximum:Number):void {
			if (_mode != ProgressBarMode.MANUAL) { return; }
			_setProgress(value, maximum);
		}
		
		[Inspectable(name="source", type="String")]
		/**
		 * @private (internal)
		 */
		public function set sourceName(name:String):void {
			if (!componentInspectorSetting) { return; }
			if (name == "") { return; }
			var target:DisplayObject = parent.getChildByName(name) as DisplayObject;
			if (target == null) {
				throw new Error("Source clip '"+ name +"' not found on parent.");
			}
			source = target;
		}
		
		/**
         * Gets or sets a reference to the content that is being loaded and for
		 * which the ProgressBar is measuring the progress of the load operation. 
         * A typical usage of this property is to set it to a UILoader component.
		 *
		 * <p>Use this property only in event mode and polled mode.</p>
         *
         * @default null
		 *
         * @includeExample examples/ProgressBar.source.1.as -noswf
         * @includeExample examples/ProgressBar.source.2.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get source():Object {
			return _source;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set source(value:Object):void {
			if (_source == value) { return; }
			if (_mode != ProgressBarMode.MANUAL) { resetProgress(); }
			_source = value;
			
			if (_source == null) { return; } // Can not poll or add listeners to a null source!
			if (_mode == ProgressBarMode.EVENT) {
				setupSourceEvents();
			} else if (_mode == ProgressBarMode.POLLED) {
				addEventListener(Event.ENTER_FRAME,pollSource,false,0,true);
			}
		}
		
		
		/**
         * Gets a number between 0 and 100 that indicates the percentage 
		 * of the content has already loaded. 
		 *
		 * <p>To change the percentage value, use the <code>setProgress()</code> method.</p>
         *
         * @default 0
         *
         * @includeExample examples/ProgressBar.percentComplete.1.as -noswf
         * @includeExample examples/ProgressBar.percentComplete.2.as -noswf
         *
         * @see #maximum
         * @see #minimum
         * @see #setProgress()
         * @see #value
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get percentComplete():Number {
			return (_maximum <= _minimum || _value <= _minimum) ?  0 : Math.max(0,Math.min(100,(_value-_minimum)/(_maximum-_minimum)*100));
		}
		
		[Inspectable(defaultValue="event", type="list", enumeration="event,polled,manual")]		
		/**
         * Gets or sets the method to be used to update the progress bar. 
		 *
		 * <p>The following values are valid for this property:</p> 
		 * <ul>
		 *     <li><code>ProgressBarMode.EVENT</code></li>
		 *     <li><code>ProgressBarMode.POLLED</code></li>
		 *     <li><code>ProgressBarMode.MANUAL</code></li>
		 * </ul>
         *
         * <p>Event mode and polled mode are the most common modes. In event mode, 
		 * the <code>source</code> property specifies loading content that generates  
		 * <code>progress</code> and <code>complete</code> events; you should use 
		 * a UILoader object in this mode. In polled mode, the <code>source</code> 
		 * property specifies loading content, such as a custom class, that exposes 
		 * <code>bytesLoaded</code> and <code>bytesTotal</code> properties. Any object 
		 * that exposes these properties can be used as a source in polled mode.</p>
         *
         * <p>You can also use the ProgressBar component in manual mode by manually 
         * setting the <code>maximum</code> and <code>minimum</code> properties and 
         * making calls to the <code>ProgressBar.setProgress()</code> method.</p>
         *
         * @default ProgressBarMode.EVENT
		 * 
         * @see ProgressBarMode
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		 
		public function get mode():String {
			return _mode;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set mode(value:String):void {
			if (_mode == value) { return; }
			resetProgress();
			
			_mode = value;
			if (value == ProgressBarMode.EVENT && _source != null) {
				setupSourceEvents();
			} else if (value == ProgressBarMode.POLLED) {
				addEventListener(Event.ENTER_FRAME,pollSource,false,0,true);
			}
			
			setIndeterminate(_mode != ProgressBarMode.MANUAL);
		}
		
		/**
         * Resets the progress bar for a new load operation.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function reset():void {
			_setProgress(0,0);
			var tmp:Object = _source;
			_source = null;
			source = tmp;
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function _setProgress(value:Number,maximum:Number,fireEvent:Boolean=false):void {
			if (value == _value && maximum == _maximum) { return; }
			_value = value;
			_maximum = maximum;
			if (_value != _loaded && fireEvent) {
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,false,false,_value,_maximum));
				_loaded = _value;
			}
			if (_mode != ProgressBarMode.MANUAL) {
				setIndeterminate(maximum == 0);
			}
			invalidate(InvalidationType.DATA);
		}		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setIndeterminate(value:Boolean):void {
			if (_indeterminate == value) { return; }
			_indeterminate = value;
			invalidate(InvalidationType.STATE);
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function resetProgress():void {
			if (_mode == ProgressBarMode.EVENT && _source != null) {
				cleanupSourceEvents();
			} else if (_mode == ProgressBarMode.POLLED) {
				removeEventListener(Event.ENTER_FRAME,pollSource);
			} else if (_source != null) {
				_source = null;
			}
			_minimum = _maximum = _value = 0;
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setupSourceEvents():void {
			_source.addEventListener(ProgressEvent.PROGRESS,handleProgress,false,0,true);
			_source.addEventListener(Event.COMPLETE,handleComplete,false,0,true);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function cleanupSourceEvents():void {
			_source.removeEventListener(ProgressEvent.PROGRESS,handleProgress);
			_source.removeEventListener(Event.COMPLETE,handleComplete);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function pollSource(event:Event):void {
			if (_source == null) { return; }
			_setProgress(_source.bytesLoaded,_source.bytesTotal,true);
			if (_maximum > 0 && _maximum == _value) {
				removeEventListener(Event.ENTER_FRAME,pollSource);
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleProgress(event:ProgressEvent):void {
			_setProgress(event.bytesLoaded, event.bytesTotal, true);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		protected function handleComplete(event:Event):void {
			_setProgress(_maximum, _maximum, true);
			dispatchEvent(event);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
				drawTrack();
				drawBars();
				invalidate(InvalidationType.STATE,false);
				invalidate(InvalidationType.SIZE,false);
			}
			if (isInvalid(InvalidationType.STATE)) {
				indeterminateBar.visible = _indeterminate;
				determinateBar.visible = !_indeterminate;
				invalidate(InvalidationType.DATA,false);
			}
			
			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
				invalidate(InvalidationType.DATA,false);
			}
			
			if (isInvalid(InvalidationType.DATA) && !_indeterminate) {
				drawDeterminateBar();
			}
			super.draw();
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawTrack():void {
			var oldTrack:DisplayObject = track;
			track = getDisplayObjectInstance(getStyleValue("trackSkin"));
			addChildAt(track,0);
			if (oldTrack != null && oldTrack != track) { 
				removeChild(oldTrack);
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawBars():void {
			var oldDeterminateBar:DisplayObject = determinateBar;
			var oldIndeterminateBar:DisplayObject = indeterminateBar;
						
			determinateBar = getDisplayObjectInstance(getStyleValue("barSkin"));
			addChild(determinateBar);
			
			indeterminateBar = getDisplayObjectInstance(getStyleValue("indeterminateBar")) as UIComponent;
			indeterminateBar.setStyle("indeterminateSkin", getStyleValue("indeterminateSkin"));
			addChild(indeterminateBar);
			
			if (oldDeterminateBar != null && oldDeterminateBar != determinateBar) {
				removeChild(oldDeterminateBar);
			}
			if (oldIndeterminateBar != null && oldIndeterminateBar != determinateBar) {
				removeChild(oldIndeterminateBar);
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawDeterminateBar():void {
			var p:Number = percentComplete/100;
			var barPad:Number = Number(getStyleValue("barPadding"));
			determinateBar.width = Math.round((width-barPad*2)*p);
			determinateBar.x = (_direction == ProgressBarDirection.LEFT) ? width-barPad-determinateBar.width : barPad;
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawLayout():void {
			var barPadding:Number = Number(getStyleValue("barPadding"));
			track.width = width;
			track.height = height;
			indeterminateBar.setSize(width - barPadding * 2, height - barPadding * 2);
			indeterminateBar.move(barPadding, barPadding);
			indeterminateBar.drawNow();
			determinateBar.height = height-barPadding*2;
			determinateBar.y = barPadding;
		}
		


		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function configUI():void {
			super.configUI();
		}
	}
}