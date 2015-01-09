﻿/*** MatrixPlugin by Grant Skinner and Sebastian DeRossi. Nov 3, 2009* Visit www.gskinner.external.com/blog for documentation, updates and more free code.*** Copyright (c) 2009 Grant Skinner* * Permission is hereby granted, free of charge, to any person* obtaining a copy of this software and associated documentation* files (the "Software"), to deal in the Software without* restriction, including without limitation the rights to use,* copy, modify, merge, publish, distribute, sublicense, and/or sell* copies of the Software, and to permit persons to whom the* Software is furnished to do so, subject to the following* conditions:* * The above copyright notice and this permission notice shall be* included in all copies or substantial portions of the Software.* * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR* OTHER DEALINGS IN THE SOFTWARE.**/package external.motion.plugins {		import external.motion.GTween;	import external.motion.plugins.IGTweenPlugin;	import flash.geom.Matrix;		/**	* Plugin for GTween. Tweens the a, b, c, d, tx, and ty properties of	* the target's <code>transform.matrix</code> object.	* <br/><br/>	* Supports the following <code>pluginData</code> properties:<UL>	* <LI> MatrixEnabled: overrides the enabled property for the plugin on a per tween basis.	* </UL>	**/	public class MatrixPlugin {			// Static interface:		/** Specifies whether this plugin is enabled for all tweens by default. **/		public static var enabled:Boolean=true;				/** @private **/		protected static var instance:MatrixPlugin;		/** @private **/		protected static var tweenProperties:Array = ['a', 'b', 'c', 'd', 'tx', 'ty'];				/**		* Installs this plugin for use with all GTween instances.		**/		public static function install():void {			if (instance) { return; }			instance = new MatrixPlugin();			GTween.installPlugin(instance, tweenProperties, true);		}			// Public methods:		/** @private **/		public function init(tween:GTween, name:String, value:Number):Number {			if (!((enabled && tween.pluginData.MatrixEnabled == null) || tween.pluginData.MatrixEnabled)) { return value; }						return tween.target.transform.matrix[name];		}				/** @private **/		public function tween(tween:GTween, name:String, value:Number, initValue:Number, rangeValue:Number, ratio:Number, end:Boolean):Number {			if (!((enabled && tween.pluginData.MatrixEnabled == null) || tween.pluginData.MatrixEnabled)) { return value; }						var matrix:Matrix = tween.target.transform.matrix;			matrix[name] =  value;			tween.target.transform.matrix = matrix;						// tell GTween not to use the default assignment behaviour:			return NaN;		}	}}