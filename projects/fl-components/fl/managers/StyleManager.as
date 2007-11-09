// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.managers {
	
	import fl.core.UIComponent;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	/**
	 * The StyleManager class provides static methods that can be used to get and 
	 * set styles for a component instance, an entire component type, or all user 
	 * interface components in a Flash document. Styles are defined as values that 
     * affect the display of a component, including padding, text formats, and skins.
	 *
	 * @includeExample examples/StyleManagerExample.as
	 *
	 * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class StyleManager {
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var _instance:StyleManager;

		// Allows lookups of all classes that use a specific style:
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private var styleToClassesHash:Object;

		// Allows lookups of all instances of a specific class:
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private var classToInstancesDict:Dictionary;

        // Allows lookup of current styles for a specific class:
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private var classToStylesDict:Dictionary;

		// Allows lookup of default styles for a specific class:

        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
        private var classToDefaultStylesDict:Dictionary;

        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private var globalStyles:Object;
		
		/**
         * Creates a new StyleManager object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function StyleManager() {
			styleToClassesHash = {};
			classToInstancesDict = new Dictionary(true);
			classToStylesDict = new Dictionary(true);
			classToDefaultStylesDict = new Dictionary(true)
			globalStyles = UIComponent.getStyleDefinition();
		}
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static function getInstance() {
			if (_instance == null) { _instance = new StyleManager(); }
			return _instance;
		}
		
		/**
		 * Registers a component instance with the style manager. After a component instance is
		 * instantiated, it can register with the style manager to be notified of changes 
		 * in style. Component instances can register to receive notice of style changes that are
		 * component-based or global in nature.
         *
		 * @param instance The component instance to be registered for style
         * management.
         *
         * @internal Do you guys have a code snippet/test case/sample you could give us for this? (pdehaan(at)adobe.com)
         * @adobe [LM] Although this method is public, it is all handled internally by UIComponent.  Each component registers itself when it instantiates.
         * @internal Should this then be (at)private in the docs?
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function registerInstance(instance:UIComponent):void {
			var inst:StyleManager = getInstance();
			var classDef:Class = getClassDef(instance);
			
			if (classDef == null) {	return;	}
			
			// check if an instance of this class has been registered before:
			if (inst.classToInstancesDict[classDef] == null) {
				
				inst.classToInstancesDict[classDef] = new Dictionary(true);
				// set up the style to class hash. This lets us look up which classes use which styles quickly.
				var target:Class = classDef;				
				var defaultStyles:Object;
				// Walk the inheritance chain looking for a default styles object.
				while (defaultStyles == null) {
					// Trick the strict compiler.
					if (target["getStyleDefinition"] != null) {
						defaultStyles = target["getStyleDefinition"]();
						break;
					}
					try {
						target = instance.loaderInfo.applicationDomain.getDefinition(getQualifiedSuperclassName(target)) as Class;
					} catch(err:Error) {
						try {
							target = getDefinitionByName(getQualifiedSuperclassName(target)) as Class;
						} catch (e:Error) {
							defaultStyles = UIComponent.getStyleDefinition();
							break;
						}
					}
				}
				
				var styleToClasses:Object = inst.styleToClassesHash;
				for (var n:String in defaultStyles) {
					
					if (styleToClasses[n] == null) {
						styleToClasses[n] = new Dictionary(true);
					}
					// add this class as a subscriber to this style:
					styleToClasses[n][classDef] = true;
				}
				// add this class's default styles:
				inst.classToDefaultStylesDict[classDef] = defaultStyles;
				// set up the override styles table:
				inst.classToStylesDict[classDef] = {};
			}
			inst.classToInstancesDict[classDef][instance] = true;
			setSharedStyles(instance);
		}
		
		/**
		 * @private
		 * 
		 * Sets an inherited style on a component.
		 *
         * @param instance The component object on which to set the inherited style.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static function setSharedStyles(instance:UIComponent):void {
			var inst:StyleManager = getInstance();
			var classDef:Class = getClassDef(instance);
			var styles:Object = inst.classToDefaultStylesDict[classDef];
			for (var n:String in styles) {
				instance.setSharedStyle(n,getSharedStyle(instance,n));
			}
		}
		
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static function getSharedStyle(instance:UIComponent,name:String):Object {
			var classDef:Class = getClassDef(instance);
			var inst:StyleManager = getInstance();
			// first check component styles:
			var style:Object = inst.classToStylesDict[classDef][name];
			if (style != null) { return style; }
			// then check global styles:
			style = inst.globalStyles[name];
			
			if (style != null) { return style; }
			// finally return the default component style:
			return inst.classToDefaultStylesDict[classDef][name];
		}
		
		/**
		 * Gets a style that exists on a specific component.
		 *
		 * @param component The name of the component instance on which to find the
		 *        requested style.
		 *
		 * @param name The name of the style to be retrieved.
		 *
		 * @return The requested style from the specified component. This function returns <code>null</code> 
         * if the specified style is not found.
         *
         * @see #clearComponentStyle()
         * @see #getStyle()
         * @see #setComponentStyle()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function getComponentStyle(component:Object,name:String):Object {
			var classDef:Class = getClassDef(component);
			var styleHash:Object = getInstance().classToStylesDict[classDef];
			return (styleHash == null) ? null : styleHash[name];
		}
		
		/**
		 * Removes a style from the specified component.
		 *
		 * @param component The name of the component from which the style is to be removed.
		 *
         * @param name The name of the style to be removed.
         *
         * @see #clearStyle()
         * @see #getComponentStyle()
         * @see #setComponentStyle()
         * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function clearComponentStyle(component:Object,name:String):void {
			var classDef:Class = getClassDef(component);
			var styleHash:Object = getInstance().classToStylesDict[classDef];
			if (styleHash != null && styleHash[name] != null) {
				delete(styleHash[name]);
				invalidateComponentStyle(classDef,name);
			}
		}
		
		/**
		 * Sets a style on all instances of a component type, for example, on all instances of a 
		 * Button component, or on all instances of a ComboBox component. 
		 *
		 * @param component The type of component, for example, Button or ComboBox.  This parameter also accepts
		 * a component instance or class that can be used to identify all instances of a component type.
		 *
		 * @param name The name of the style to be set.
		 *
		 * @param style The style object that describes the style that is to be set.
         *
         * @see #clearComponentStyle()
         * @see #getComponentStyle()
         * @see #setStyle()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function setComponentStyle(component:Object,name:String,style:Object):void {
			var classDef:Class = getClassDef(component);
			var styleHash:Object = getInstance().classToStylesDict[classDef];
			if (styleHash == null) {
				styleHash = getInstance().classToStylesDict[classDef] = {};
			}
			if (styleHash == style) { return; }
			styleHash[name] = style;
			invalidateComponentStyle(classDef,name);
		}
		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static function getClassDef(component:Object):Class {
			if (component is Class) { 
				return (component as Class);
			}
			try {
				return getDefinitionByName(getQualifiedClassName(component)) as Class;
			} catch (e:Error) {
				if (component is UIComponent) {
					try {
						return component.loaderInfo.applicationDomain.getDefinition(getQualifiedClassName(component)) as Class;
					} catch (e:Error) {}
				}
			}
			return null;
		}
		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static function invalidateStyle(name:String):void {
			var classes:Dictionary = getInstance().styleToClassesHash[name];
			if (classes == null) { return; }
			for (var classRef:Object in classes) {
				invalidateComponentStyle(Class(classRef),name);
			}
		}
		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static function invalidateComponentStyle(componentClass:Class,name:String):void {
			var instances:Dictionary = getInstance().classToInstancesDict[componentClass];
			if (instances == null) { return; }
			
			for (var obj:Object in instances) {
				var instance:UIComponent = obj as UIComponent;
				if (instance == null) { continue; }
				instance.setSharedStyle(name,getSharedStyle(instance,name));
			}
		}
		
		/**
		 * Sets a global style for all user interface components in a document.
		 *
		 * @param name A String value that names the style to be set.
		 *
		 * @param style The style object to be set. The value of this property depends on the 
		 * style that the user sets. For example, if the style is set to "textFormat", the style 
		 * property should be set to a TextFormat object. A mismatch between the style name and
		 * the value of the style property may cause the component to behave incorrectly.
         *
         * @see #clearStyle()
         * @see #getStyle()
         * @see #setComponentStyle()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function setStyle(name:String, style:Object):void {
			var styles:Object = getInstance().globalStyles;
			if (styles[name] === style && !(style is TextFormat)) { return; }
			styles[name] = style;
			invalidateStyle(name);
		}
		
		/**
		 * Removes a global style from all user interface components in a document.
		 *
         * @param name The name of the global style to be removed.
         *
         * @see #clearComponentStyle()
         * @see #getStyle()
         * @see #setStyle()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function clearStyle(name:String):void {
			setStyle(name,null);
		}
		
		/**
		 * Gets a global style by name.
		 *
		 * @param name The name of the style to be retrieved.
		 *
		 * @return The value of the global style that was retrieved.
         *
		 * @internal "that was removed" - doesn't sound right. Do you guys have a code snippet/test 
		 *         case/sample you could give us for this? (rberry(at)adobe.com)
         * @adobe [LM] Correct - description was wrong.  Code sample would be simple: {var textFormat:TextFormat = StyleManager.getStyle("textFormat") as TextFormat;}
         *
         * @see #clearStyle()
         * @see #getComponentStyle()
         * @see #setStyle()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function getStyle(name:String):Object {
			return getInstance().globalStyles[name];
		}
		
	}
	
}
