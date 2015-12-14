// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {
	
	import fl.controls.BaseButton;
	import fl.controls.TextInput; //Only for ASDocs
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import fl.events.ComponentEvent;
	import fl.managers.IFocusManagerComponent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.ui.Keyboard;

	//--------------------------------------
	//  Styles
	//--------------------------------------
	/**
	 * The class that provides the skin for the down arrow when it is disabled.
	 *
     * @default NumericStepperDownArrow_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="downArrowDisabledSkin", type="Class")]

	/**
	 * The class that provides the skin for the down arrow when it is in a down state.
	 *
     * @default NumericStepperDownArrow_downSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="downArrowDownSkin", type="Class")]

	/**
	 * The class that provides the skin for the down arrow when the mouse is over the component.
	 *
	 * @default NumericStepperDownArrow_overSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="downArrowOverSkin", type="Class")]

	/**
	 * The class that provides the skin for the down arrow when it is in its default state.
	 * 
	 * @default NumericStepperDownArrow_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="downArrowUpSkin", type="Class")]

	/**
	 * The class that provides the skin for the up arrow when it is disabled.
	 *
     * @default NumericStepperUpArrow_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="upArrowDisabledSkin", type="Class")]

	/**
	 * The class that provides the skin for the up arrow when it is in the down state.
	 *
     * @default NumericStepperUpArrow_downSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="upArrowDownSkin", type="Class")]

	/**
	 * The class that provides the skin for the down arrow during mouse over.
	 *
     * @default NumericStepperUpArrow_overSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="upArrowOverSkin", type="Class")]

	/**
	 * The class that provides the skin for the up arrow when it is in the up state.
	 *
     * @default NumericStepperUpArrow_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="upArrowUpSkin", type="Class")]

	/**
	 * The class that provides the skin for the text input box.
	 *
     * @default NumericStepper_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="TextInput_upskin", type="Class")]

	/**
	 * The skin used for the up arrow when it is in an up state.
	 *
	 * @default NumericStepper_disabledSkin
	 *
	 * @internal [kenos] Is this description correct? Most of the skins are provides by classes and this looks
	 *                   more like some of the width or height specifiers. The style name also doesn't seem to
     *                   match the description.
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="TextInput_disabledSkin", type="Number", format="Length")]

	/**
     * @copy fl.controls.BaseButton#style:repeatDelay
     * 
     * @default 500
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="repeatDelay", type="Number", format="Time")]

    /**
     * @copy fl.controls.BaseButton#style:repeatInterval
     *
     * @default 35
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="repeatInterval", type="Number", format="Time")]
	
	/**
     * @copy fl.controls.LabelButton#style:embedFonts
     * 
     * @default false
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="embedFonts", type="Boolean")]

    //--------------------------------------
    //  Events
    //--------------------------------------
	/**
	 *  Dispatched when the user changes the value of the NumericStepper component.
     *
	 *  <p><strong>Note:</strong> This event is not dispatched if ActionScript 
	 *  is used to change the value.</p>
	 *
     *  @eventType flash.events.Event.CHANGE
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="change", type="flash.events.Event")]

    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The NumericStepper component displays an ordered set of numbers from which
	 * the user can make a selection. This component includes a single-line field 
	 * for text input and a pair of arrow buttons that can be used to step through 
	 * the set of values. The Up and Down arrow keys can also be used to view the 
	 * set of values. The NumericStepper component dispatches a <code>change</code> 
	 * event after there is a change in its current value. This component also contains
	 * the <code>value</code> property; you can use this property to obtain the current 
	 * value of the component.
	 *
     * @includeExample examples/NumericStepperExample.as
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class NumericStepper extends UIComponent implements IFocusManagerComponent {

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var inputField:TextInput;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var upArrow:BaseButton;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var downArrow:BaseButton;
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
		protected var _minimum:Number = 0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _value:Number = 1;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _stepSize:Number = 1;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _precision:Number;
		
		/**
         * Creates a new NumericStepper component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function NumericStepper() {
			super();
			setStyles();
			stepSize = _stepSize;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static var defaultStyles:Object = {
											downArrowDisabledSkin:"NumericStepperDownArrow_disabledSkin",
											downArrowDownSkin:"NumericStepperDownArrow_downSkin",
											downArrowOverSkin:"NumericStepperDownArrow_overSkin",
											downArrowUpSkin:"NumericStepperDownArrow_upSkin",
											upArrowDisabledSkin:"NumericStepperUpArrow_disabledSkin",
											upArrowDownSkin:"NumericStepperUpArrow_downSkin",
											upArrowOverSkin:"NumericStepperUpArrow_overSkin",
											upArrowUpSkin:"NumericStepperUpArrow_upSkin",
											upSkin:"TextInput_upSkin", disabledSkin:"TextInput_disabledSkin",
											focusRect:null, focusRectSkin:null, focusRectPadding:null,
											repeatDelay:500,repeatInterval:35, embedFonts:false
											};
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
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected static const DOWN_ARROW_STYLES:Object = {
											disabledSkin:"downArrowDisabledSkin",
											downSkin:"downArrowDownSkin",
											overSkin:"downArrowOverSkin",
											upSkin:"downArrowUpSkin",
											repeatDelay:"repeatDelay",
											repeatInterval:"repeatInterval"
											};

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected static const UP_ARROW_STYLES:Object = {
											disabledSkin:"upArrowDisabledSkin",
											downSkin:"upArrowDownSkin",
											overSkin:"upArrowOverSkin",
											upSkin:"upArrowUpSkin",
											repeatDelay:"repeatDelay",
											repeatInterval:"repeatInterval"
											};

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected static const TEXT_INPUT_STYLES:Object = {
											upSkin:"upSkin",
											disabledSkin:"disabledSkin",
											textPadding:"textPadding",
											textFormat:"textFormat",
											disabledTextFormat:"disabledTextFormat",
											embedFonts:"embedFonts"
											};

		[Inspectable(defaultValue=true)]
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
			if (value == enabled) { return; }
			super.enabled = value;
			upArrow.enabled = downArrow.enabled = inputField.enabled = value;
		}
		
		[Inspectable(defaultValue=10)]
		/**
		 * Gets or sets the maximum value in the sequence of numeric values.
         *
         * @default 10
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
			if (_value > _maximum) { 
				setValue(_maximum, false);
			}
		}
		
		[Inspectable(defaultValue=0)]
		/**
		 * Gets or sets the minimum number in the sequence of numeric values.
         *
         * @default 0
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
			_minimum = value;
			if (_value < _minimum) {
				setValue(_minimum, false);
			}
		}

		/**
         * Gets the next value in the sequence of values.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get nextValue():Number {
			var val:Number = _value + _stepSize;
			return (inRange(val)) ? val : _value;
		}

		/**
         * Gets the previous value in the sequence of values.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get previousValue():Number {
			var val:Number = _value - _stepSize;
			return (inRange(val)) ? val : _value;
		}
		
		[Inspectable(defaultValue=1)]
		/**
         * Gets or sets a nonzero number that describes the unit of change between 
		 * values. The <code>value</code> property is a multiple of this number 
		 * less the minimum. The NumericStepper component rounds the resulting value to the 
		 * nearest step size.
         *
         * @default 1
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get stepSize():Number {
			return _stepSize;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set stepSize(value:Number):void {
			_stepSize = value;
			_precision = getPrecision();
			setValue(_value);
		}
		
		[Inspectable(defaultValue=1)]
		/**
		 * Gets or sets the current value of the NumericStepper component.
         *
         * @default 1
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
			setValue(value, false);
		}
		
		/**
		 * Gets a reference to the TextInput component that the NumericStepper
		 * component contains. Use this property to access and manipulate the 
		 * underlying TextInput component. For example, you can use this
		 * property to change the current selection in the text box or to
		 * restrict the characters that the text box accepts.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get textField():TextInput {
			return inputField;	
		}
		
		/**
         * @copy fl.controls.TextArea#imeMode
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		 public function get imeMode():String {
			return inputField.imeMode;
		}		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set imeMode(value:String):void {
			inputField.imeMode = value;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function configUI():void {
			super.configUI();

			upArrow = new BaseButton();
			copyStylesToChild(upArrow, UP_ARROW_STYLES);
			upArrow.autoRepeat = true;
			upArrow.setSize(21, 12);
			upArrow.focusEnabled = false;
			addChild(upArrow);

			downArrow = new BaseButton();
			copyStylesToChild(downArrow, DOWN_ARROW_STYLES);
			downArrow.autoRepeat = true;
			downArrow.setSize(21, 12);
			downArrow.focusEnabled = false;
			addChild(downArrow);

			inputField = new TextInput();
			copyStylesToChild(inputField, TEXT_INPUT_STYLES);
			inputField.restrict = "0-9\\-\\.\\,";
			inputField.text = _value.toString();
			inputField.setSize(21, 24);
			inputField.focusTarget = this as IFocusManagerComponent;
			inputField.focusEnabled = false;
			inputField.addEventListener(FocusEvent.FOCUS_IN, passEvent);
			inputField.addEventListener(FocusEvent.FOCUS_OUT, passEvent);
			addChild(inputField);

			inputField.addEventListener(Event.CHANGE, onTextChange, false, 0, true);
			upArrow.addEventListener(ComponentEvent.BUTTON_DOWN, stepperPressHandler, false, 0, true);
			downArrow.addEventListener(ComponentEvent.BUTTON_DOWN, stepperPressHandler, false, 0, true);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setValue(value:Number, fireEvent:Boolean=true):void {
			if (value == _value) {
				return;
			}
			var oldVal:Number = _value;
			_value = getValidValue(value);
			inputField.text = _value.toString();
			
			if (fireEvent) {
				dispatchEvent(new Event(Event.CHANGE, true));
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
			event.stopImmediatePropagation();

			var val:Number = Number(inputField.text);
			switch (event.keyCode) {
				case Keyboard.END:
					setValue(maximum);
					break;
				case Keyboard.HOME:
					setValue(minimum);
					break;
				case Keyboard.UP:
					setValue(nextValue);
					break;
				case Keyboard.DOWN:
					setValue(previousValue);
					break;
				case Keyboard.ENTER:
					setValue(val);
					break;
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function stepperPressHandler(event:ComponentEvent):void {
			setValue(Number(inputField.text), false);
			
			switch (event.currentTarget) {
				case upArrow:
					setValue(nextValue);
					break;
				case downArrow:
					setValue(previousValue);
			}
			inputField.setFocus();
			inputField.textField.setSelection(0,0);
		}

		/**
         * @copy fl.core.UIComponent#drawFocus()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function drawFocus(event:Boolean):void {
			super.drawFocus(event);
			if (event) {
				var focusPadding:Number = Number(getStyleValue('focusRectPadding'));
				uiFocusRect.width = width + (focusPadding*2);
				uiFocusRect.height = height + (focusPadding*2);
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function focusOutHandler(event:FocusEvent):void {
			if (event.eventPhase == 3) {
				setValue(Number(inputField.text));
			}
			super.focusOutHandler(event);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES,InvalidationType.STATE)) {
				setStyles();
				invalidate(InvalidationType.SIZE, false);
			}
			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}
			if (isFocused && focusManager.showFocusIndicator) { drawFocus(true); }
			validate();
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawLayout():void {
			var w:Number = width - upArrow.width;
			var h:Number = height / 2;
			inputField.setSize(w, height);
			upArrow.height = h;
			downArrow.height = Math.floor(h);
			downArrow.move(w, h);
			upArrow.move(w, 0);
			
			downArrow.drawNow();
			upArrow.drawNow();
			inputField.drawNow();
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function onTextChange(event:Event):void {
			event.stopImmediatePropagation();
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function passEvent(event:Event):void {
			dispatchEvent(event);
		}

		/**
         * Sets focus to the component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function setFocus():void {
			if(stage) { stage.focus = inputField.textField; }
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function isOurFocus(target:DisplayObject):Boolean {
			return target == inputField || super.isOurFocus(target);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setStyles():void {
			copyStylesToChild(downArrow, DOWN_ARROW_STYLES);
			copyStylesToChild(upArrow, UP_ARROW_STYLES);
			copyStylesToChild(inputField, TEXT_INPUT_STYLES);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function inRange(num:Number):Boolean {
			return (num >= _minimum && num <= _maximum);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function inStep(num:Number):Boolean {
			return (num - _minimum) % _stepSize == 0;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function getValidValue(num:Number):Number {
			if (isNaN(num)) { return _value; }
			var closest:Number = Number((_stepSize * Math.round(num / _stepSize)).toFixed(_precision));
			if (closest > maximum) { 
				return maximum; 
			} else if (closest < minimum) { 
				return minimum;
			} else { 
				return closest
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function getPrecision():Number {
			var s:String = _stepSize.toString();
			if (s.indexOf('.') == -1) { return 0; }
			return s.split('.').pop().length;
		}

	}
}