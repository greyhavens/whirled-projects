// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls { 
	
	import fl.controls.BaseButton;	
	import fl.controls.ButtonLabelPlacement;
	import fl.controls.TextInput; //Only for ASDocs
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import fl.events.ComponentEvent;
	import fl.managers.IFocusManagerComponent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
    //--------------------------------------
    //  Events
    //--------------------------------------	
	/**
	 * Dispatched after the toggle button receives input from
	 * a mouse device or from the spacebar.
	 *
     * @eventType flash.events.MouseEvent.CLICK
     *
     * @includeExample examples/LabelButton.click.1.as -noswf
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="click", type="flash.events.MouseEvent")]	
	
	/**
	 * Dispatched after the label value changes.
	 *
     * @eventType fl.events.ComponentEvent.LABEL_CHANGE
     *
     * @includeExample examples/LabelButton.labelChange.1.as -noswf
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="labelChange", type="fl.events.ComponentEvent")]
	
	
	//--------------------------------------
	//  Styles
	//--------------------------------------	
	/**
     *  Name of the class to use as the skin for the background and border 
     *  when the button is not selected and is disabled.
     *
     *  @default Button_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="disabledSkin", type="Class")]
	
	/**
	 *  Name of the class to use as the skin for the background and border
	 *  when the button is not selected and the mouse is not over the component.
	 *  
     *  @default Button_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="upSkin", type="Class")]
	
	/**
	 *  Name of the class to use as the skin for the background and border
	 *  when the button is not selected and the mouse button is down.
	 *  
     *  @default Button_downSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="downSkin", type="Class")]
	
	/**
	 *  Name of the class to use as the skin for the background and border
	 *  when the button is not selected and the mouse is over the component.
	 *  
     *  @default Button_overSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */	
 	[Style(name="overSkin", type="Class")]
	
	/**
	 *  Name of the class to use as the skin for the background and border
	 *  when a toggle button is selected and disabled.
	 * 
     *  @default Button_selectedDisabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="selectedDisabledSkin", type="Class")]
	
	/**
	 *  Name of the class to use as the skin for the background and border
	 *  when a toggle button is selected and the mouse is not over the component.
	 * 
     *  @default Button_selectedUpSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="selectedUpSkin", type="Class")]
	
	/**
	 *  Name of the class to use as the skin for the background and border
	 *  when a toggle button is selected and the mouse button is down.
	 *  
     *  @default Button_selectedDownSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="selectedDownSkin", type="Class")]
	
	/**
	 *  Name of the class to use as the skin for the background and border
	 *  when a toggle button is selected and the mouse is over the component.
	 *  
     *  @default Button_selectedOverSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="selectedOverSkin", type="Class")]
	
	/**
     *  The spacing between the text and the edges of the component, and the 
     *  spacing between the text and the icon, in pixels.
	 *	
     *  @default 5
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="textPadding", type="Number", format="Length")]

    /**
     *  @copy fl.controls.BaseButton#style:repeatDelay
     *
     *  @default 500
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="repeatDelay", type="Number", format="Time")]

    /**
     *  @copy fl.controls.BaseButton#style:repeatInterval
     *
     *  @default 35
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="repeatInterval", type="Number", format="Time")]

    /**
     *  Name of the class to use as the icon when a toggle button is not selected 
     *  and the mouse is not over the button.
     *
     *  @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="icon", type="Class")]

    /**
     *  Name of the class to use as the icon when a toggle button is not selected and the mouse is not over the button.
     *
     *  @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="upIcon", type="Class")]

    /**
     *  Name of the class to use as the icon when the button is not selected and the mouse button is down.
     *
     *  @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="downIcon", type="Class")]

    /**
     *  Name of the class to use as the icon when the button is not selected and the mouse is over the component.
     *
     *  @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="overIcon", type="Class")]

    /**
     *  Name of the class to use as the icon when the button is not disabled.
	 *		
     *  @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */	
    [Style(name="disabledIcon", type="Class")]
	
	/**
     *  Name of the class to use as the icon when the button is selected and disabled.
     *
     *  @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
    [Style(name="selectedDisabledIcon", type="Class")]

    /**
     *  Name of the class to use as the icon when the button is selected and the mouse button is up.
     *
     *  @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedUpIcon", type="Class")]

    /**
     *  Name of the class to use as the icon when the button is selected and the mouse button is down.
     *
     *  @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedDownIcon", type="Class")]

    /**
     *  Name of the class to use as the icon when the button is selected and the mouse is over the component.
     *
     *  @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedOverIcon", type="Class")]
	
	/**
     * Indicates whether embedded font outlines are used to render the text field.  
     * If this value is <code>true</code>, Flash Player renders the text field
	 * by using embedded font outlines. If this value is <code>false</code>, 
	 * Flash Player renders the text field by using device fonts. 
	 *
	 * <p>If you set the <code>embedFonts</code> property to <code>true</code> 
	 * for a text field, you must specify a font for that text by using the 
	 * <code>font</code> property of a TextFormat object that is applied to the text field. 
	 * If the specified font is not embedded in the SWF file, the text is not displayed.</p>
	 * 
     * @default false
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="embedFonts", type="Boolean")]
	
	//--------------------------------------
	//  Class description
	//--------------------------------------	
 	/**
	 * The LabelButton class is an abstract class that extends the 
	 * BaseButton class by adding a label, an icon, and toggle functionality. 
	 * The LabelButton class is subclassed by the Button, CheckBox, RadioButton, and 
	 * CellRenderer classes. 
	 *
	 * <p>The LabelButton component is used as a simple button class that can be
	 * combined with custom skin states that support ScrollBar buttons, NumericStepper 
	 * buttons, ColorPicker swatches, and so on.</p>
	 * 
	 * @includeExample examples/LabelButtonExample.as -noswf
	 * @includeExample examples/IconWithToolTip.as
	 *
	 * @see fl.controls.BaseButton
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class LabelButton extends BaseButton implements IFocusManagerComponent {

		/**
		 * A reference to the component's internal text field.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var textField:TextField;
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _labelPlacement:String = ButtonLabelPlacement.RIGHT;		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _toggle:Boolean = false;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var icon:DisplayObject;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var oldMouseState:String;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _label:String = "Label";		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var mode:String = "center"; // other option is "border".  Not currently used, but is reference in subclasses.
		

        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var defaultStyles:Object = {
												  icon:null,
												  upIcon:null,downIcon:null,overIcon:null,disabledIcon:null,
												  selectedDisabledIcon:null,selectedUpIcon:null,selectedDownIcon:null,selectedOverIcon:null,
												  textFormat:null, disabledTextFormat:null,
												  textPadding:5, embedFonts:false
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
		public static function getStyleDefinition():Object { 
			return mergeStyles(defaultStyles, BaseButton.getStyleDefinition());
		}

		/**
		 *  @private
		 *  Method for creating the Accessibility class.
         *  This method is called from UIComponent.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static var createAccessibilityImplementation:Function;
		
		
		/**
         * Creates a new LabelButton component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function LabelButton() {
			super();
		}
		
		[Inspectable(defaultValue="Label")]
		/**
		 * Gets or sets the text label for the component. By default, the label
		 * text appears centered on the button.
         *
         * <p><strong>Note:</strong> Setting this property triggers the <code>labelChange</code> 
		 * event object to be dispatched.</p>
         *
         * @default "Label"
         *
         * @see #event:labelChange
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */        
		public function get label():String {
			return _label;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set label(value:String):void {
			_label = value;
			if (textField.text != _label) {
				textField.text = _label;
				dispatchEvent(new ComponentEvent(ComponentEvent.LABEL_CHANGE));
			}
			invalidate(InvalidationType.SIZE);
			invalidate(InvalidationType.STYLES);
		}	
		
		[Inspectable(enumeration="left,right,top,bottom", defaultValue="right", name="labelPlacement")]
		/**
		 *  Position of the label in relation to a specified icon.
		 *
		 *  <p>In ActionScript, you can use the following constants to set this property:</p>
		 * 
		 *  <ul>
		 *  <li><code>ButtonLabelPlacement.RIGHT</code></li>
		 *  <li><code>ButtonLabelPlacement.LEFT</code></li>
		 *  <li><code>ButtonLabelPlacement.BOTTOM</code></li>
		 *  <li><code>ButtonLabelPlacement.TOP</code></li>
		 *  </ul>
		 *
		 *  @default ButtonLabelPlacement.RIGHT
         *
         * @includeExample examples/LabelButton.labelPlacement.1.as -noswf
		 *
         *  @see ButtonLabelPlacement
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */        
		public function get labelPlacement():String {
			return _labelPlacement;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set labelPlacement(value:String):void {
			_labelPlacement = value;
			invalidate(InvalidationType.SIZE);
		}	
		
		[Inspectable(defaultValue=false)]
		/**
         *  Gets or sets a Boolean value that indicates whether a button 
		 *  can be toggled. A value of <code>true</code> indicates that it 
		 *  can; a value of <code>false</code> indicates that it cannot.
		 * 
		 *  <p>If this value is <code>true</code>, clicking the button 
		 *  toggles it between selected and unselected states. You can get 
		 *  or set this state programmatically by using the <code>selected</code> 
		 *  property.</p>
		 *
		 *  <p>If this value is <code>false</code>, the button does not 
		 *  stay pressed after the user releases it. In this case, its 
		 *  <code>selected</code> property is always <code>false</code>.</p>
		 *
		 *  <p><strong>Note:</strong> When the <code>toggle</code> is set to <code>false</code>,
		 *  <code>selected</code> is forced to <code>false</code> because only 
         *  toggle buttons can be selected.</p>
		 *
         *  @default false
         *
         * @includeExample examples/LabelButton.toggle.2.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get toggle():Boolean {
			return _toggle;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set toggle(value:Boolean):void {
			if (!value && super.selected) { selected = false; }
			_toggle = value;
			if (_toggle) { addEventListener(MouseEvent.CLICK,toggleSelected,false,0,true); }
			else { removeEventListener(MouseEvent.CLICK,toggleSelected); }
			invalidate(InvalidationType.STATE);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function toggleSelected(event:MouseEvent):void {
			selected = !selected;
			dispatchEvent(new Event(Event.CHANGE, true));
		}	
		
		[Inspectable(defaultValue=false)]
		/**
		 *  Gets or sets a Boolean value that indicates whether 
		 *  a toggle button is toggled in the on or off position.
		 *  A value of <code>true</code> indicates that it is 
		 *  toggled in the on position; a value of <code>false</code> indicates
		 *  that it is toggled in the off position. This property can be 
		 *  set only if the <code>toggle</code> property is set to <code>true</code>.
		 *
		 *  <p>For a CheckBox component, this value indicates whether the box
		 *  displays a check mark. For a RadioButton component, this value 
		 *  indicates whether the component is selected.</p>
		 *
		 *  <p>The user can change this property by clicking the component,
		 *  but you can also set this property programmatically.</p>
		 *
		 *  <p>If the <code>toggle</code> property is set to <code>true</code>, 
		 *  changing this property also dispatches a <code>change</code> event.</p>
		 *
         *  @default false
         *
         * @includeExample examples/LabelButton.toggle.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		override public function get selected():Boolean {
			return (_toggle) ? _selected : false;
		}		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		override public function set selected(value:Boolean):void {
			_selected = value;
			if (_toggle) {
				invalidate(InvalidationType.STATE);
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
			
			textField = new TextField();
			textField.type = TextFieldType.DYNAMIC;
			textField.selectable = false;
			addChild(textField);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		override protected function draw():void {
			if (textField.text != _label) { 
				label = _label;
			}
			
			if (isInvalid(InvalidationType.STYLES,InvalidationType.STATE)) {
				drawBackground();
				drawIcon();
				drawTextFormat();
				
				invalidate(InvalidationType.SIZE,false);
			}
			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}
			if (isInvalid(InvalidationType.SIZE,InvalidationType.STYLES)) {
				if (isFocused && focusManager.showFocusIndicator) { drawFocus(true); }
			}
			validate(); // because we're not calling super.draw
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawIcon():void {			
			var oldIcon:DisplayObject = icon;
			
			var styleName:String = (enabled) ? mouseState : "disabled";
			if (selected) { 
				styleName = "selected"+styleName.substr(0,1).toUpperCase()+styleName.substr(1);
			}
			styleName += "Icon";
			
			var iconStyle:Object = getStyleValue(styleName);
			if (iconStyle == null) {
				// try the default icon:
				iconStyle = getStyleValue("icon");
			}			
			if (iconStyle != null) { 
				icon = getDisplayObjectInstance(iconStyle);
			}
			if (icon != null) {
				addChildAt(icon,1);
			}
			
			if (oldIcon != null && oldIcon != icon) { 
				removeChild(oldIcon);
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawTextFormat():void {
			// Apply a default textformat
			var uiStyles:Object = UIComponent.getStyleDefinition();
			var defaultTF:TextFormat = enabled ? uiStyles.defaultTextFormat as TextFormat : uiStyles.defaultDisabledTextFormat as TextFormat;
			textField.setTextFormat(defaultTF);
			
			var tf:TextFormat = getStyleValue(enabled?"textFormat":"disabledTextFormat") as TextFormat;
			if (tf != null) {
				textField.setTextFormat(tf);
			} else {
				tf = defaultTF;
			}
			textField.defaultTextFormat = tf;
			
			setEmbedFont();
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setEmbedFont() {
			var embed:Object = getStyleValue("embedFonts");
			if (embed != null) {
				textField.embedFonts = embed;
			}	
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function drawLayout():void {
			var txtPad:Number = Number(getStyleValue("textPadding"));
			var placement:String = (icon == null && mode == "center") ? ButtonLabelPlacement.TOP : _labelPlacement;
			textField.height =  textField.textHeight+4;
			
			var txtW:Number = textField.textWidth+4;
			var txtH:Number = textField.textHeight+4;
			
			var paddedIconW:Number = (icon == null) ? 0 : icon.width+txtPad;
			var paddedIconH:Number = (icon == null) ? 0 : icon.height+txtPad;
			textField.visible = (label.length > 0);
			
			if (icon != null) {
				icon.x = Math.round((width-icon.width)/2);
				icon.y = Math.round((height-icon.height)/2);
			}
			
			var tmpWidth:Number;
			var tmpHeight:Number;
			
			if (textField.visible == false) {
				textField.width = 0;
				textField.height = 0;
			} else if (placement == ButtonLabelPlacement.BOTTOM || placement == ButtonLabelPlacement.TOP) {
				tmpWidth = Math.max(0,Math.min(txtW,width-2*txtPad));
				if (height-2 > txtH) {
					tmpHeight = txtH;
				} else {
					tmpHeight = height-2;
				}
				
				textField.width = txtW = tmpWidth;
				textField.height = txtH = tmpHeight;
				
				textField.x = Math.round((width-txtW)/2);
				textField.y = Math.round((height-textField.height-paddedIconH)/2+((placement == ButtonLabelPlacement.BOTTOM) ? paddedIconH : 0));
				if (icon != null) {
					icon.y = Math.round((placement == ButtonLabelPlacement.BOTTOM) ? textField.y-paddedIconH : textField.y+textField.height+txtPad);
				}
			} else {
				tmpWidth =  Math.max(0,Math.min(txtW,width-paddedIconW-2*txtPad));	
				textField.width = txtW = tmpWidth;	
				
				textField.x = Math.round((width-txtW-paddedIconW)/2+((placement != ButtonLabelPlacement.LEFT) ? paddedIconW : 0));
				textField.y = Math.round((height-textField.height)/2);
				if (icon != null) {
					icon.x = Math.round((placement != ButtonLabelPlacement.LEFT) ? textField.x-paddedIconW : textField.x+txtW+txtPad);
				}
			}
			super.drawLayout();			
		}
	
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		override protected function keyDownHandler(event:KeyboardEvent):void {
			if (!enabled) { return; }
			if (event.keyCode == Keyboard.SPACE) {
				if(oldMouseState == null) {
					oldMouseState = mouseState;
				}
				setMouseState("down");
				startPress();
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		override protected function keyUpHandler(event:KeyboardEvent):void {
			if (!enabled) { return; }
			if (event.keyCode == Keyboard.SPACE) {
				setMouseState(oldMouseState);
				oldMouseState = null;
				endPress();
				dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function initializeAccessibility():void {
			if (LabelButton.createAccessibilityImplementation != null)
				LabelButton.createAccessibilityImplementation(this);
		}
	}
}