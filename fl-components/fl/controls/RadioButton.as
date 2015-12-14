// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {
	
	import fl.controls.ButtonLabelPlacement;
	import fl.controls.LabelButton;
	import fl.controls.RadioButtonGroup;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import fl.managers.IFocusManager;
	import fl.managers.IFocusManagerGroup;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;	

    //--------------------------------------
    //  Events
    //--------------------------------------
	/**
	 * Dispatched when the radio button instance's <code>selected</code> property changes.
	 *
     * @includeExample examples/RadioButton.change.1.as -noswf
     *
     * @eventType flash.events.Event.CHANGE
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="change" , type="flash.events.Event")]


	/**
	 * Dispatched when the user clicks the radio button with the mouse or spacebar.
     *
     * @includeExample examples/RadioButton.change.1.as -noswf
     *
     * @eventType flash.events.MouseEvent.CLICK
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="click" , type="flash.events.MouseEvent")]


    //--------------------------------------
    //  Styles
    //--------------------------------------
    /**
     * @copy fl.controls.LabelButton#style:icon
     *
     * @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="icon", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:upIcon
     *
     * @default RadioButton_upIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="upIcon", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:downIcon
     *
     * @default RadioButton_downIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="downIcon", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:overIcon
     *
     * @default RadioButton_overIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="overIcon", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:disabledIcon
     *
     * @default RadioButton_disabledIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="disabledIcon", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:selectedDisabledIcon
     *
     * @default RadioButton_selectedDisabledIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedDisabledIcon", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:selectedUpIcon
     *
     * @default RadioButton_selectedUpIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedUpIcon", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:selectedDownIcon
     *
     * @default RadioButton_selectedDownIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedDownIcon", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:selectedOverIcon
     *
     * @default RadioButton_selectedOverIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedOverIcon", type="Class")]
   
   	/**
     * @copy fl.controls.LabelButton#style:textPadding
     *
     * @default 5
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="textPadding", type="Number", format="Length")]


    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The RadioButton component lets you force a user to make a single
	 * selection from a set of choices. This component must be used in a
	 * group of at least two RadioButton instances. Only one member of
	 * the group can be selected at any given time. Selecting one radio
	 * button in a group deselects the currently selected radio button
     * in the group. You set the <code>groupName</code> parameter to indicate which
     * group a radio button belongs to. When the user clicks or tabs into a RadioButton
     * component group, only the selected radio button receives focus.
     *
     * <p>A radio button can be enabled or disabled. A disabled radio button does not receive mouse or
	 * keyboard input.</p>
     *
     * @see RadioButtonGroup
	 *
     * @includeExample examples/RadioButtonExample.as
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class RadioButton extends LabelButton implements IFocusManagerGroup {

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _value:Object;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 * The RadioButtonGroup object to which this RadioButton component instance belongs.
		 */
		protected var _group:RadioButtonGroup;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var defaultGroupName:String = "RadioButtonGroup";

		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static var defaultStyles:Object = {icon:null,
												  upIcon:"RadioButton_upIcon",downIcon:"RadioButton_downIcon",overIcon:"RadioButton_overIcon",
												  disabledIcon:"RadioButton_disabledIcon",
												  selectedDisabledIcon:"RadioButton_selectedDisabledIcon",
												  selectedUpIcon:"RadioButton_selectedUpIcon",selectedDownIcon:"RadioButton_selectedDownIcon",selectedOverIcon:"RadioButton_selectedOverIcon",
												  focusRectSkin:null,
												  focusRectPadding:null,
												  textFormat:null,
												  disabledTextFormat:null,
												  embedFonts:null,
												  textPadding:5};
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
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static var createAccessibilityImplementation:Function;
		

		/**
         * Creates a new RadioButton component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function RadioButton() {
			super();
			mode = "border";
			groupName = defaultGroupName;
		}
		
		/**
         * A radio button is a toggle button; its <code>toggle</code> property is set to
         * <code>true</code> in the constructor and cannot be changed.
		 * 
		 * @throws Error This property cannot be set on the RadioButton.
		 * 
         * @default true
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get toggle():Boolean {
			return true;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set toggle(value:Boolean):void {
			// can't turn toggle off in a radiobutton.
			throw new Error("Warning: You cannot change a RadioButtons toggle.");
		}
		
		/**
         * A radio button never auto-repeats by definition, so the <code>autoRepeat</code> property is set to
         * <code>false</code> in the constructor and cannot be changed.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get autoRepeat():Boolean {	
			return false;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set autoRepeat(value:Boolean):void {
			return;
		}
		
		[Inspectable(defaultValue=false)]
		/**
         * Indicates whether a radio button is currently selected (<code>true</code>) or deselected (<code>false</code>).
		 * 
         * @default false
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		override public function get selected():Boolean {
			return super.selected;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set selected(value:Boolean):void {
			// can only set to true in RadioButton:
			if (value == false || selected) { return; }
			if (_group != null) { _group.selection = this; }
			else { super.selected = value; }
		}
			
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */	
		override protected function configUI():void {
			super.configUI();
			super.toggle = true;
			
			var bg:Shape = new Shape();
			var g:Graphics = bg.graphics;
			g.beginFill(0,0);
			g.drawRect(0,0,100,100);
			g.endFill();
			background = bg as DisplayObject
			addChildAt(background,0);
			
			addEventListener(MouseEvent.CLICK, handleClick, false, 0, true);
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function drawLayout():void{
			super.drawLayout();	
			
			var textPadding:Number = Number(getStyleValue("textPadding"));
			switch(_labelPlacement){
				case ButtonLabelPlacement.RIGHT:
					icon.x = textPadding;
					textField.x = icon.x + (icon.width+textPadding);
					background.width = textField.x + textField.width + textPadding;
					background.height = Math.max(textField.height, icon.height)+textPadding*2;
					break;
				case ButtonLabelPlacement.LEFT:
					icon.x = width - icon.width - textPadding;
					textField.x = width - icon.width - textPadding*2 - textField.width;
					background.width = textField.width + icon.width + textPadding*3;
					background.height = Math.max(textField.height, icon.height)+textPadding*2;
					break;
				case ButtonLabelPlacement.TOP:
				case ButtonLabelPlacement.BOTTOM:
					background.width = Math.max(textField.width, icon.width) + textPadding*2;
					background.height = textField.height + icon.height + textPadding*3;
					break;
			}
			background.x = Math.min(icon.x-textPadding, textField.x-textPadding);
			background.y = Math.min(icon.y-textPadding, textField.y-textPadding);
		}
		
		[Inspectable(defaultValue="RadioButtonGroup")]
		/**
         * The group name for a radio button instance or group. You can use this property to get 
         * or set a group name for a radio button instance or for a radio button group.
         *
         * @default "RadioButtonGroup"
         *
		 * @includeExample examples/RadioButton.groupName.1.as -noswf
		 *
		 * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */        
		public function get groupName():String {
			return (_group == null) ? null : _group.name;
		}
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set groupName(group:String):void {
			if (_group != null) {
				_group.removeRadioButton(this);
				_group.removeEventListener(Event.CHANGE,handleChange);
			}
			_group = (group == null) ? null : RadioButtonGroup.getGroup(group);
			if (_group != null) {
                // Default to the easiest option, which is to select a newly added selected rb.
				_group.addRadioButton(this);
				_group.addEventListener(Event.CHANGE,handleChange,false,0,true);
			}
		}
		
		/**
         * The RadioButtonGroup object to which this RadioButton belongs.
         *
		 * @includeExample examples/RadioButton.group.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get group():RadioButtonGroup {
			return _group;
		}
		
        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set group(name:RadioButtonGroup):void {
			groupName = name.name;
		}
		
		[Inspectable(type="String")]
		/**
         * A user-defined value that is associated with a radio button.
		 * 
         * @default null
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get value():Object {
			return _value;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set value(val:Object):void {
			_value = val;
		}
		
		/**
		 * Shows or hides the focus indicator around this component instance.
		 *
         * @param focused Show or hide the focus indicator.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		override public function drawFocus(focused:Boolean):void {
			super.drawFocus(focused);
			
			// Size focusRect to fit hitArea, not actual width/height
			if (focused) {
				var focusPadding:Number = Number(getStyleValue('focusRectPadding'));
				uiFocusRect.x = background.x - focusPadding;
				uiFocusRect.y = background.y - focusPadding;
				
				uiFocusRect.width = background.width + (focusPadding*2);
				uiFocusRect.height = background.height + (focusPadding*2);
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleChange(event:Event):void {
			super.selected = (_group.selection == this);
			dispatchEvent(new Event(Event.CHANGE, true));
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleClick(event:MouseEvent):void {
			if (_group == null) { return; }
			_group.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true));
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			super.draw();
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function drawBackground():void {
			// Do nothing, handled in BaseButton.drawLayout();
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function initializeAccessibility():void {
			if (RadioButton.createAccessibilityImplementation != null) {
				RadioButton.createAccessibilityImplementation(this);
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.DOWN:
					setNext(!event.ctrlKey);
					event.stopPropagation();
					break;
				case Keyboard.UP:
					setPrev(!event.ctrlKey);
					event.stopPropagation();
					break;
				case Keyboard.LEFT:
					setPrev(!event.ctrlKey);
					event.stopPropagation();
					break;
				case Keyboard.RIGHT:
					setNext(!event.ctrlKey);
					event.stopPropagation();
					break;
				case Keyboard.SPACE:
					setThis();
					// disable toggling behavior for the RadioButton when
					// dealing with the spacebar since selection is maintained
					// by the group instead
					_toggle = false;
					// fall through, no break
				default:
					super.keyDownHandler(event);
					break;
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		 
		override protected function keyUpHandler(event:KeyboardEvent):void {
			super.keyUpHandler(event);
			if (event.keyCode == Keyboard.SPACE && !_toggle) {
				// we disabled _toggle for SPACE because we don't want to allow
				// de-selection, but now it needs to be re-enabled
				_toggle = true;
			}
		}
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function setPrev(moveSelection:Boolean = true):void {
			var g:RadioButtonGroup = _group;
			if(g == null){return;}
			var fm:IFocusManager = focusManager;
			if (fm) { fm.showFocusIndicator = true; }
			var indexNumber:int = g.getRadioButtonIndex(this);
			var counter:int = indexNumber;
			if(indexNumber != -1) {
				do {
					counter--;
					counter = (counter == -1) ? g.numRadioButtons-1 : counter;
					var radioButton:RadioButton = g.getRadioButtonAt(counter);
					if(radioButton && radioButton.enabled){
						if(moveSelection){
							g.selection = radioButton;
						}
						radioButton.setFocus();
						return;
					}
					if (moveSelection && g.getRadioButtonAt(counter) != g.selection) {
						g.selection = this;
					}
					this.drawFocus(true);
				} while(counter != indexNumber);
			}
		}
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function setNext(moveSelection:Boolean = true):void {
			var g:RadioButtonGroup = _group;
			if(g == null){return;}
			var fm:IFocusManager = focusManager;
			if (fm) { fm.showFocusIndicator = true; }
			var indexNumber:int = g.getRadioButtonIndex(this);
			var radioButtonCount:Number = g.numRadioButtons;
			var counter:int = indexNumber;
			if(indexNumber != -1) {
				do {
					counter++;
					counter = (counter > g.numRadioButtons-1) ? 0 : counter;
					var radioButton:RadioButton = g.getRadioButtonAt(counter);
					if(radioButton && radioButton.enabled){
						if(moveSelection){
							g.selection = radioButton;
						}
						radioButton.setFocus();
						return;
					}
					if (moveSelection && g.getRadioButtonAt(counter) != g.selection) {
						g.selection = this;
					}
					this.drawFocus(true);
				} while(counter != indexNumber);
			}
		}
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private function setThis():void {
			var g:RadioButtonGroup = _group;
			if(g != null) {
				if (g.selection != this) {
					g.selection = this;
				}
			} else {
				super.selected = true;
			}
		}
	}
}
