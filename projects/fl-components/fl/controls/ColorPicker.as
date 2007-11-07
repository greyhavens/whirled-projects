// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {

	import fl.core.UIComponent;
	import fl.core.InvalidationType;
	import fl.controls.BaseButton;
	import fl.controls.TextInput;
	import fl.controls.TextArea;
	import fl.events.ComponentEvent;
	import fl.events.ColorPickerEvent;
	import fl.managers.IFocusManager;
	import fl.managers.IFocusManagerComponent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.system.IME;

	//--------------------------------------
	//  Events
	//--------------------------------------

    /**
     * Dispatched when the user opens the color palette.
     *
     * @eventType flash.events.Event.OPEN
     *
     * @includeExample examples/ColorPicker.open.2.as -noswf
     *
     * @see #event:close
     * @see #open()
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Event(name="open", type="flash.events.Event")]

    /**
     * Dispatched when the user closes the color palette.
     *
     * @eventType flash.events.Event.CLOSE
     *
     * @see #event:open
     * @see #close()
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Event(name="close", type="flash.events.Event")]

    /**
     * Dispatched when the user clicks a color in the palette.
     *
     * @includeExample examples/ColorPicker.hexValue.1.as -noswf
     *
     * @eventType fl.events.ColorPickerEvent.CHANGE
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Event(name="change", type="fl.events.ColorPickerEvent")]

    /**
     * Dispatched when the user rolls over a swatch in the color palette.
     *
     * @eventType fl.events.ColorPickerEvent.ITEM_ROLL_OVER
     *
     * @see #event:itemRollOut
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Event(name="itemRollOver", type="fl.events.ColorPickerEvent")]

    /**
     * Dispatched when the user rolls out of a swatch in the color palette.
     *
     * @eventType fl.events.ColorPickerEvent.ITEM_ROLL_OUT
     *
     * @see #event:itemRollOver
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Event(name="itemRollOut", type="fl.events.ColorPickerEvent")]

    /**
     * Dispatched when the user presses the Enter key after editing the internal text field of the ColorPicker component.
     *
     * @eventType fl.events.ColorPickerEvent.ENTER
     *
     * @includeExample examples/ColorPicker.enter.1.as -noswf
     *
     * @see #editable
     * @see #textField
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Event(name="enter", type="fl.events.ColorPickerEvent")]


	//--------------------------------------
	//  Styles
	//--------------------------------------
    /**
     * Defines the padding that appears around each swatch in the color palette, in pixels.
     *
     * @default 1
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="swatchPadding", type="Number", format="Length")]

    /**
     * The class that provides the skin for a disabled button in the ColorPicker.
     *
     * @default ColorPicker_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     *
     * @internal [kenos] Changed description from "Disabled skin for the ColorPicker button" to the current.
     * Is this correct?
     */
	[Style(name="disabledSkin", type="Class")]

    /**
     * The padding that appears around the color TextField, in pixels.
     *
     * @default 3
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="textPadding", type="Number", format="Length")]

    /**
     * The class that provides the skin for the color well when the pointing device rolls over it.
     *
     * @default ColorPicker_overSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="overSkin", type="Class")]

    /**
     * The padding that appears around the group of color swatches, in pixels.
     *
     * @default 5
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="backgroundPadding", type="Number", format="Length")]

    /**
     * The class that provides the skin for the color well when it is filled with a color.
     *
     * @default ColorPicker_colorWell
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     *
     */
	[Style(name="colorWell", type="Class")]

    /**
     * The class that provides the skin for the ColorPicker button when it is in the down position.
     *
     * @default ColorPicker_downSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     *
     * @internal [kenos] Description was "Down skin for the ColorPicker button." Is the revised description correct?
     */
	[Style(name="downSkin", type="Class")]

    /**
     * The class that provides the background for the text field of the ColorPicker component.
     *
     * @default ColorPicker_textFieldSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="textFieldSkin", type="Class")]

    /**
     * The class that provides the background of the palette that appears in the ColorPicker component. 
     *
     * @default ColorPicker_backgroundSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="background", type="Class")]

    /**
     * The class that provides the skin which is used to draw the swatches contained in the ColorPicker component.
     *
     * @default ColorPicker_swatchSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="swatchSkin", type="Class")]

    /**
     * The class that provides the skin which is used to highlight the currently selected color.
     *
     * @default ColorPicker_swatchSelectedSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="swatchSelectedSkin", type="Class")]

    /**
     * The width of each swatch, in pixels.
     *
     * @default 10
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="swatchWidth", type="Number", format="Length")]

    /**
     * The height of each swatch, in pixels.
     *
     * @default 10
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="swatchHeight", type="Number", format="Length")]

    /**
     * The number of columns to be drawn in the ColorPicker color palette.
     *
     * @default 18
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="columnCount", type="Number", format="Length")]

    /**
     * The class that provides the skin for the ColorPicker button when it is in the up position.
     *
     * @default ColorPicker_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     *
     * @internal [kenos] The previous description was "Up skin for the ColorPicker button." Is the revised description
     *                   correct?
     */
	[Style(name="upSkin", type="Class")]

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
	//  Class description
	//--------------------------------------	
    /**
     * The ColorPicker component displays a list of one or more swatches 
     * from which the user can select a color. 
     *
     * <p>By default, the component displays a single swatch of color on a 
     * square button. When the user clicks this button, a panel opens to  
     * display the complete list of swatches.</p>
     *
     * @includeExample examples/ColorPickerExample.as
     *
     * @see fl.events.ColorPickerEvent ColorPickerEvent
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	public class ColorPicker extends UIComponent implements IFocusManagerComponent {

        /**
         * A reference to the internal text field of the ColorPicker component.
         *
         * @see #showTextField
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
		protected var customColors:Array;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public static  var defaultColors:Array;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var colorHash:Object;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var paletteBG:DisplayObject;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var selectedSwatch:Sprite;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var _selectedColor:uint;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var rollOverColor:int = -1;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _editable:Boolean = true;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var _showTextField:Boolean = true;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var isOpen:Boolean = false;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var doOpen:Boolean = false;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var swatchButton:BaseButton;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var colorWell:DisplayObject;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var swatchSelectedSkin:DisplayObject;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var palette:Sprite;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var textFieldBG:DisplayObject;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var swatches:Sprite;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var swatchMap:Array;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var currRowIndex:int;

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var currColIndex:int;


        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static  var defaultStyles:Object = {upSkin:"ColorPicker_upSkin", disabledSkin:"ColorPicker_disabledSkin",
														  overSkin:"ColorPicker_overSkin", downSkin:"ColorPicker_downSkin", colorWell:"ColorPicker_colorWell",
														  swatchSkin:"ColorPicker_swatchSkin", swatchSelectedSkin:"ColorPicker_swatchSelectedSkin",
														  swatchWidth:10, swatchHeight:10,
														  columnCount:18, swatchPadding:1,
														  textFieldSkin:"ColorPicker_textFieldSkin",
														  textFieldWidth:null, textFieldHeight:null, textPadding:3,
														  background:"ColorPicker_backgroundSkin", backgroundPadding:5,
														  textFormat:null, focusRectSkin:null, focusRectPadding:null,
														  embedFonts:false
														  };

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
		public static function getStyleDefinition():Object {
			return defaultStyles;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected static  const POPUP_BUTTON_STYLES:Object = {
														disabledSkin:"disabledSkin",
														downSkin:"downSkin",
														overSkin:"overSkin",
														upSkin:"upSkin"
														};

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected static  const SWATCH_STYLES:Object = {
														disabledSkin:"swatchSkin",
														downSkin:"swatchSkin",
														overSkin:"swatchSkin",
														upSkin:"swatchSkin"
														};

        /**
         * Creates an instance of the ColorPicker class.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function ColorPicker() {
			super();
		}

		[Inspectable(type="Color",defaultValue="#000000")]
        /**
         * Gets or sets the swatch that is currently highlighted in the palette of the ColorPicker component.
         *
         * @default 0x000000
         *
         * @includeExample examples/ColorPicker.selectedColor.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get selectedColor():uint {
			if (colorWell == null) {
				return 0;
			}
			return colorWell.transform.colorTransform.color;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set selectedColor(value:uint):void {
			if (!_enabled) {
				return;
			}
			_selectedColor = value;
			rollOverColor = -1;
			currColIndex = currRowIndex = 0;

			// Set the color value immediately to avoid invalidation.
			var ct:ColorTransform = new ColorTransform();
			ct.color = value;
			setColorWellColor(ct);

			invalidate(InvalidationType.DATA);
		}

        /**
         * Gets the string value of the current color selection.
         *
         * @includeExample examples/ColorPicker.hexValue.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get hexValue():String {
			if (colorWell == null) {
				return colorToString(0);
			}
			return colorToString(colorWell.transform.colorTransform.color);
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
			super.enabled = value;
			if (!value) {
				close();
			}
			swatchButton.enabled = value;
		}

        /**
         * Gets or sets a Boolean value that indicates whether the internal text field of the
         * ColorPicker component is editable. A value of <code>true</code> indicates that 
         * the internal text field is editable; a value of <code>false</code> indicates 
         * that it is not.
         *
         * @default true
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get editable():Boolean {
			return _editable;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set editable(value:Boolean):void {
			_editable = value;
			invalidate(InvalidationType.STATE);
		}

		[Inspectable(defaultValue=true)]
        /**
         * Gets or sets a Boolean value that indicates whether the internal text field 
         * of the ColorPicker component is displayed. A value of <code>true</code> indicates
         * that the internal text field is displayed; a value of <code>false</code> indicates
         * that it is not.
         *
         * @default true
         *
         * @includeExample examples/ColorPicker.showTextField.1.as -noswf
         *
         * @see #textField
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get showTextField():Boolean {
			return _showTextField;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set showTextField(value:Boolean):void {
			invalidate(InvalidationType.STYLES);
			_showTextField = value;
		}

        /**
         * Gets or sets the array of custom colors that the ColorPicker component
         * provides. The ColorPicker component draws and displays the colors that are 
         * described in this array.
         *
         * <p><strong>Note:</strong> The maximum number of colors that the ColorPicker 
         * component can display is 1024.</p>
         *
         * <p>By default, this array contains 216 autogenerated colors.</p>
         *
         * @includeExample examples/ColorPicker.colors.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         *
         */
		public function get colors():Array {
			return (customColors != null)?customColors:ColorPicker.defaultColors;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set colors(value:Array):void {
			customColors = value;
			invalidate(InvalidationType.DATA);
		}

        /**
         * @copy fl.controls.TextArea#imeMode
         *
         * @see flash.system.IMEConversionMode IMEConversionMode
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get imeMode():String {
			return _imeMode;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set imeMode(value:String):void {
			_imeMode = value;
		}

        /**
         * Shows the color palette. Calling this method causes the <code>open</code> 
         * event to be dispatched. If the color palette is already open or disabled, 
         * this method has no effect.
         *
         * @includeExample examples/ColorPicker.open.2.as -noswf
         *
         * @see #close()
         * @see #event:open
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function open():void {
			if (!_enabled) {
				return;
			}
			doOpen = true;
			
			var fm:IFocusManager = focusManager;
			if (fm) {
				fm.defaultButtonEnabled = false;
			}
			
			invalidate(InvalidationType.STATE);
		}

        /**
         * Hides the color palette. Calling this method causes the <code>close</code> 
         * event to be dispatched. If the color palette is already closed or disabled, 
         * this method has no effect.
         *
         * @see #event:close
         * @see #open()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function close():void {
			if (isOpen) {
                palette.parent.removeChild(palette);
				isOpen = false;
				dispatchEvent(new Event(Event.CLOSE));
			}
			
			var fm:IFocusManager = focusManager;
			if (fm) {
				fm.defaultButtonEnabled = true;
			}
			
			removeStageListener();
			cleanUpSelected();
		}

        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private function addCloseListener(event:Event) {
			removeEventListener(Event.ENTER_FRAME, addCloseListener);
			if (!isOpen) {
				return;
			}
			addStageListener();
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function onStageClick(event:MouseEvent):void {
			if (!contains(event.target as DisplayObject) && !palette.contains(event.target as DisplayObject)) {
				selectedColor = _selectedColor;
				close();
			}
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function setStyles():void {
			var bg:DisplayObject = colorWell;
			
			var colorWellStyle:Object = getStyleValue("colorWell");
			if (colorWellStyle != null) {
				colorWell = getDisplayObjectInstance(colorWellStyle) as DisplayObject;
			}
			addChildAt(colorWell, getChildIndex(swatchButton));
			copyStylesToChild(swatchButton, POPUP_BUTTON_STYLES);
			swatchButton.drawNow();
			
			if (bg != null && contains(bg) && bg != colorWell) { 
				removeChild(bg); 
			}
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function cleanUpSelected():void {
			if (swatchSelectedSkin && palette.contains(swatchSelectedSkin)) {
				palette.removeChild(swatchSelectedSkin);
			}
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function onPopupButtonClick(event:MouseEvent):void {
			if (isOpen) {
				close();
			} else {
				open();
			}
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {	
			if (isInvalid(InvalidationType.STYLES, InvalidationType.DATA)) {
				setStyles();
				drawPalette();
				setEmbedFonts();
				invalidate(InvalidationType.DATA, false);
				invalidate(InvalidationType.STYLES, false);
			}

			if (isInvalid(InvalidationType.DATA)) {
				drawSwatchHighlight();
				setColorDisplay();
			}

			if (isInvalid(InvalidationType.STATE)) {
				setTextEditable();
				if (doOpen) {
					doOpen = false;
					showPalette();
				}
				colorWell.visible = enabled;
			}
			if (isInvalid(InvalidationType.SIZE, InvalidationType.STYLES)) {
				swatchButton.setSize(width, height);
				swatchButton.drawNow();
				colorWell.width = width;
				colorWell.height = height;
			}
			super.draw();
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function showPalette():void {
			if (isOpen) {
				positionPalette();
				return;
			}
			addEventListener(Event.ENTER_FRAME, addCloseListener, false, 0, true);

			isOpen = true;
            var container :DisplayObjectContainer = positionPalette();
            container.addChild(palette);

			dispatchEvent(new Event(Event.OPEN));
			stage.focus = textField; // This is causing some issues.

			// Highlight the appropriate swatch.
			var swatch:Sprite = selectedSwatch;
			if (swatch == null) {
				swatch = findSwatch(_selectedColor);
			}
			setSwatchHighlight(swatch);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function setEmbedFonts():void {
			var embed:Object = getStyleValue('embedFonts');
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
		protected function drawSwatchHighlight():void {
			cleanUpSelected();
			var skin:Object = getStyleValue("swatchSelectedSkin");
			var swatchPadding:Number = getStyleValue("swatchPadding") as Number;
			if (skin != null) {
				swatchSelectedSkin = getDisplayObjectInstance(skin);
				swatchSelectedSkin.x = 0;
				swatchSelectedSkin.y = 0;
				swatchSelectedSkin.width = (getStyleValue("swatchWidth") as Number) + 2;
				swatchSelectedSkin.height = (getStyleValue("swatchHeight") as Number) + 2;
			}
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function drawPalette():void {
			if (isOpen) {
                palette.parent.removeChild(palette);
			}
			palette = new Sprite();
			drawTextField();
			drawSwatches();
			drawBG();
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function drawTextField():void {
			if (!showTextField) {
				return;
			}
			var padding:Number = getStyleValue("backgroundPadding") as Number;
			var textPadding:Number = getStyleValue("textPadding") as Number;

			// Add the TextField background
			textFieldBG = getDisplayObjectInstance(getStyleValue("textFieldSkin"));
			if (textFieldBG != null) {
				palette.addChild(textFieldBG);
				textFieldBG.x = textFieldBG.y = padding;
			}

			// Format the text field
			var uiStyles:Object = UIComponent.getStyleDefinition();
			var defaultTF:TextFormat = enabled ? uiStyles.defaultTextFormat as TextFormat : uiStyles.defaultDisabledTextFormat as TextFormat;
			textField.setTextFormat(defaultTF);

			var tf:TextFormat = getStyleValue("textFormat") as TextFormat;
			if (tf != null) {
				textField.setTextFormat(tf);
			} else {
				tf = defaultTF;
			}
			textField.defaultTextFormat = tf;
			setEmbedFonts();

			textField.restrict = "A-Fa-f0-9#";
			textField.maxChars = 6;
			palette.addChild(textField);

			textField.text = " #888888 ";
			textField.height = textField.textHeight + 3;
			textField.width = textField.textWidth + 3;
			textField.text = "";
			textField.x = textField.y = padding + textPadding;

			textFieldBG.width = textField.width + (textPadding*2);
			textFieldBG.height = textField.height + (textPadding*2);
			setTextEditable();
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function drawSwatches():void {
			var padding:Number = getStyleValue("backgroundPadding") as Number;
			var swatchY:Number = (showTextField ? textFieldBG.y + textFieldBG.height + padding : padding);

			swatches = new Sprite();
			palette.addChild(swatches);
			swatches.x = padding;
			swatches.y = swatchY;

			var cols:uint = getStyleValue("columnCount") as uint;
			var pad:uint = getStyleValue("swatchPadding") as uint;
			var w:Number = getStyleValue("swatchWidth") as Number;
			var h:Number = getStyleValue("swatchHeight") as Number;

			colorHash = {};
			swatchMap = [];

			var l:uint = Math.min(1024, colors.length);
			var rc:int = -1;
			for (var  i:uint=0; i<l; i++) {
				var s:Sprite = createSwatch(colors[i]);

				s.x = (w + pad) * (i%cols);
				if (s.x == 0) {
					swatchMap.push([s]);
					rc++;
				} else {
					swatchMap[rc].push(s);
				}
				colorHash[colors[i]] = {swatch:s, row:rc, col:swatchMap[rc].length-1};
				s.y = Math.floor(i/cols) * (h + pad);
				swatches.addChild(s);
			}
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function drawBG():void {
			var bg:Object = getStyleValue("background");
			if (bg != null) {
				paletteBG = getDisplayObjectInstance(bg) as Sprite;
			}
			if (paletteBG == null) {
				return;
			}
			var padding:Number = Number(getStyleValue("backgroundPadding"));
			paletteBG.width = Math.max(showTextField?textFieldBG.width:0, swatches.width) + padding*2;
			paletteBG.height = swatches.y + swatches.height + padding;
			palette.addChildAt(paletteBG, 0);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function positionPalette () :DisplayObjectContainer
        {
			var p :Point = swatchButton.localToGlobal(new Point(0,0));
            var container :DisplayObjectContainer;
            if (swatchButton.stage == UIComponent.stageAlias) {
                container = UIComponent.stageAlias;

            } else {
                // in case we're in a different component hierarchy than the stageAlias, walk
                // upwards to find the real parent that we should add to.
                container = swatchButtin.parent;
                try {
                    while (container != UIComponent.stageAlias && container.parent != null) {
                        container = container.parent;
                    }
                } catch (err :SecurityError) {
                    // stop when we can't access a parent
                }
                p = container.globalToLocal(p);
            }

			var padding:Number = getStyleValue("backgroundPadding") as Number;

            var doesntFit :Boolean;
            var heightFit :int;
            try {
                doesntFit = (p.x + palette.width > stage.stageWidth);
                heightFit = stageHeight - palette.height;
			} catch (err :SecurityError) {
                doesntFit = false; // well, who knows, but let's just roll with it
                heightFit = p.y;
            }
            if (doesntFit) {
                palette.x = (p.x - palette.width) <<0;
            } else {
                palette.x = (p.x + swatchButton.width + padding) <<0;
            }
			palette.y = Math.max(0, Math.min(p.y, heightFit)) <<0;

            return container;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function setTextEditable():void {
			if (!showTextField) {
				return;
			}
			textField.type = editable?TextFieldType.INPUT:TextFieldType.DYNAMIC;
			textField.selectable = editable;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function keyUpHandler(event:KeyboardEvent):void {
			if (!isOpen) { return; }
			
			var newColor:uint;
			var cTransform:ColorTransform = new ColorTransform();

			if (editable && showTextField) {
				// Get the color that is currently entered.
				var color:String = textField.text;
				
				// Works with or without the #
				if (color.indexOf("#") > -1) {
					color = color.replace(/^\s+|\s+$/g, "");
					color = color.replace(/#/g, "");
				} 
				
				// Convert to a color.
				newColor = parseInt(color, 16);
				
				// Try and select the swatch
				var swatch:Sprite = findSwatch(newColor);
				setSwatchHighlight(swatch);
				
				// Colorize the ColorWell
				cTransform.color = newColor;
				setColorWellColor(cTransform);
			} else {
				newColor = rollOverColor;
				cTransform.color = newColor;
			}
			// If the ENTER key, select the color
			if (event.keyCode != Keyboard.ENTER) {
				return;
			}

			// Verify the color, and close the palette.
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ENTER, newColor));
			
			_selectedColor = rollOverColor;
			setColorText(cTransform.color);
			rollOverColor = cTransform.color;	
			
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, selectedColor));
			close();
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function positionTextField():void {
			if (!showTextField) {
				return;
			}
			var padding:Number = getStyleValue("backgroundPadding") as Number;
			var textPadding:Number = getStyleValue("textPadding") as Number;


			textFieldBG.x = paletteBG.x + padding;
			textFieldBG.y = paletteBG.y + padding;
			textField.x = textFieldBG.x + textPadding;
			textField.y = textFieldBG.y + textPadding;
		}


        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function setColorDisplay():void {
			if (!swatchMap.length) {
				return;
			}
			var ct:ColorTransform = new ColorTransform(0,0,0,1,_selectedColor>>16,_selectedColor>>8&0xFF,_selectedColor&0xFF,0);
			setColorWellColor(ct);
			setColorText(_selectedColor);
			var swatch:Sprite = findSwatch(_selectedColor);
			setSwatchHighlight(swatch);

			if (swatchMap.length && colorHash[_selectedColor] == undefined) {
				cleanUpSelected();
			}
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function setSwatchHighlight(swatch:Sprite):void {
			if (swatch == null) {
				if (palette.contains(swatchSelectedSkin)) {
					palette.removeChild(swatchSelectedSkin);
				}
				return;
			} else if (!palette.contains(swatchSelectedSkin) && colors.length > 0) {
				palette.addChild(swatchSelectedSkin);
			} else if (!colors.length) {
				return;
			}

			var swatchPadding:Number = getStyleValue("swatchPadding") as Number;
			palette.setChildIndex(swatchSelectedSkin, palette.numChildren-1);
			swatchSelectedSkin.x = swatches.x + swatch.x - 1;
			swatchSelectedSkin.y = swatches.y + swatch.y - 1;

			var color = swatch.getChildByName('color').transform.colorTransform.color;
			currColIndex = colorHash[color].col;
			currRowIndex = colorHash[color].row;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function findSwatch(color:uint):Sprite {
			if (!swatchMap.length) {
				return null;
			}
			var so:Object = colorHash[color];
			if (so != null) {
				return so.swatch;
			}
			return null;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function onSwatchClick(event:MouseEvent):void {
			var cTransform:ColorTransform = event.target.getChildByName('color').transform.colorTransform;
			_selectedColor = cTransform.color;
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.CHANGE, selectedColor));
			close();
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function onSwatchOver(event:MouseEvent):void {
			var color:BaseButton = event.target.getChildByName("color") as BaseButton;
			var cTransform:ColorTransform = color.transform.colorTransform;
			setColorWellColor(cTransform);
			setSwatchHighlight(event.target as Sprite);
			setColorText(cTransform.color);
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OVER, cTransform.color));
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function onSwatchOut(event:MouseEvent):void {
			var cTransform:ColorTransform = event.target.transform.colorTransform;
			dispatchEvent(new ColorPickerEvent(ColorPickerEvent.ITEM_ROLL_OUT, cTransform.color));
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function setColorText(color:uint):void {
			if (textField == null) {
				return;
			}
			textField.text = "#"+colorToString(color);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function colorToString(color:uint):String {
			var colorText:String = color.toString(16);
			while (colorText.length < 6) {
				colorText = "0" + colorText;
			}
			return colorText;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function setColorWellColor(colorTransform:ColorTransform):void {
			if (!colorWell) {
				return;
			}
			colorWell.transform.colorTransform = colorTransform;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function createSwatch(color:uint):Sprite {
			var swatch:Sprite = new Sprite();

			// Draw the Color part of the swatch
			var swatchSkin:BaseButton = new BaseButton();
			swatchSkin.focusEnabled = false;
			var w:Number = getStyleValue("swatchWidth") as Number;
			var h:Number = getStyleValue("swatchHeight") as Number;
			swatchSkin.setSize(w, h);
			swatchSkin.transform.colorTransform = new ColorTransform(0,0,0,1,color>>16,color>>8&0xFF,color&0xFF,0);
			copyStylesToChild(swatchSkin, SWATCH_STYLES);
			swatchSkin.mouseEnabled = false;
			swatchSkin.drawNow();
			swatchSkin.name = "color";
			swatch.addChild(swatchSkin);

			// Draw the border/background
			var padding:Number = getStyleValue("swatchPadding") as Number;
			var g:Graphics = swatch.graphics;
			g.beginFill(0x000000);
			g.drawRect(-padding, -padding, w+padding*2, h+padding*2);
			g.endFill();

			swatch.addEventListener(MouseEvent.CLICK, onSwatchClick, false, 0, true);
			swatch.addEventListener(MouseEvent.MOUSE_OVER, onSwatchOver, false, 0, true);
			swatch.addEventListener(MouseEvent.MOUSE_OUT, onSwatchOut, false, 0, true);
			return swatch;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function addStageListener(event:Event = null):void {
			UIComponent.stageAlias.addEventListener(MouseEvent.MOUSE_DOWN, onStageClick, false, 0, true);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function removeStageListener(event:Event = null):void {
			UIComponent.stageAlias.removeEventListener(MouseEvent.MOUSE_DOWN, onStageClick, false);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function focusInHandler(event:FocusEvent):void {
			super.focusInHandler(event);
			setIMEMode(true);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function focusOutHandler(event:FocusEvent):void {
			if (event.relatedObject == textField) { 
				setFocus();
				return;	} // New focus is our textfield.
			
			if (isOpen) { close(); }
			super.focusOutHandler(event);
			setIMEMode(false);
		}
		
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function isOurFocus(target:DisplayObject):Boolean {
			return target == textField || super.isOurFocus(target);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function keyDownHandler(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.SHIFT :
				case Keyboard.CONTROL :
					return;
			}
			if (event.ctrlKey) {
				switch (event.keyCode) {
					case Keyboard.DOWN :
						open();
						break;
					case Keyboard.UP :
						close();
						break;
				}
				return;
			}
			// Palette is closed. Just open it.
			if (!isOpen) {
				switch(event.keyCode) {
					case Keyboard.UP:
					case Keyboard.DOWN:
					case Keyboard.LEFT:
					case Keyboard.RIGHT:
					case Keyboard.SPACE:
						open();
						return;
				}
			}
			// Change the number of allowed chatacters depending on input
			textField.maxChars = (event.keyCode == "#".charCodeAt(0) || textField.text.indexOf("#") > -1) ? 7 : 6;
			// Palette is open. Do appropriate action.
			switch (event.keyCode) {
				case Keyboard.TAB :
					var swatch:Sprite = findSwatch(_selectedColor);
					setSwatchHighlight(swatch);
					return;
					break;
				case Keyboard.HOME :
					currColIndex = currRowIndex = 0;// Set to first color
					break;
				case Keyboard.END :
					currColIndex = swatchMap[swatchMap.length-1].length-1;
					currRowIndex = swatchMap.length-1;// Set to last color
					break;
				case Keyboard.PAGE_DOWN :
					currRowIndex = swatchMap.length-1;// set to bottom of the column.
					break;
				case Keyboard.PAGE_UP :
					currRowIndex = 0;// Set to top of the column.
					break;
				case Keyboard.ESCAPE :
					if (isOpen) {
						selectedColor = _selectedColor;
					}
					close();
					return;
					break;
				case Keyboard.ENTER :
					// This is handled in the TextKeyUp method...
					return;
				case Keyboard.UP :
					currRowIndex = Math.max(-1, currRowIndex-1);
					if (currRowIndex == -1) {
						currRowIndex = swatchMap.length-1;
					}
					break;
				case Keyboard.DOWN :
					currRowIndex = Math.min(swatchMap.length, currRowIndex+1);
					if (currRowIndex == swatchMap.length) {
						currRowIndex = 0;
					}
					break;
				case Keyboard.RIGHT :
					currColIndex = Math.min(swatchMap[currRowIndex].length, currColIndex+1);
					if (currColIndex == swatchMap[currRowIndex].length) {
						currColIndex = 0;
						currRowIndex = Math.min(swatchMap.length, currRowIndex+1);
						if (currRowIndex == swatchMap.length) {
							currRowIndex = 0;
						}
					}
					break;
				case Keyboard.LEFT :
					currColIndex = Math.max(-1, currColIndex-1);
					if (currColIndex == -1) {
						currColIndex = swatchMap[currRowIndex].length-1;
						currRowIndex = Math.max(-1, currRowIndex-1);
						if (currRowIndex == -1) {
							currRowIndex = swatchMap.length-1;
						}
					}
					break;
				default :
					return;// Do Nothing.
			}
			
			var cTransform:ColorTransform = swatchMap[currRowIndex][currColIndex].getChildByName("color").transform.colorTransform;
			rollOverColor = cTransform.color;
			setColorWellColor(cTransform);

			setSwatchHighlight(swatchMap[currRowIndex][currColIndex]);
			setColorText(cTransform.color);

		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function configUI():void {
			super.configUI();
			
			tabChildren = false;

			// Only create the ColorPicker default colors once in an swf.
			if (ColorPicker.defaultColors == null) {
				ColorPicker.defaultColors = [];
				for (var i:uint=0; i<216; i++) {
					ColorPicker.defaultColors.push( ((i/6%3<<0)+((i/108)<<0)*3)*0x33<<16 | i%6*0x33<<8  | (i/18<<0)%6*0x33 );
				}
			}
			colorHash = {};
			swatchMap = [];

			textField = new TextField();
			textField.tabEnabled = false;
			//textField.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler,false,0,true);
 			//textField.addEventListener(KeyboardEvent.KEY_UP, onTextKeyUp, false,0,true);

			swatchButton = new BaseButton();
			swatchButton.focusEnabled = false;
			swatchButton.useHandCursor = false;
			swatchButton.autoRepeat = false;
			swatchButton.setSize(25, 25);
			swatchButton.addEventListener(MouseEvent.CLICK, onPopupButtonClick, false, 0, true);
			addChild(swatchButton);

			palette = new Sprite();
			palette.tabChildren = false;
			palette.cacheAsBitmap = true;
		}
		
	}
}
