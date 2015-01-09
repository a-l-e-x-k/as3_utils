/**
 * Author: Alexey
 * Date: 10/13/12
 * Time: 4:38 PM
 */
package utils
{
	import external.caurina.transitions.Tweener;

	import starling.display.Image;
	import starling.textures.Texture;

	public class TweenableImage extends Image
	{
		private var _tweenStartTime:Number; //in UNIX milliseconds
		private var _lastUpdateTime:Number; //in UNIX milliseconds

		private var _tweenLength:Number; //in seconds
		private var _tweenFunc:Function;
		private var _startValue:Number;
		private var _targetValue:Number;
		private var _valueName:String;
		private var _onComplete:Function;

		/**
		 * Allows tweening without creating any tweens.
		 * Updates are manually called
		 * This removes heavy tweens creation (which is especially noticable at high amounts of items)
		 */
		public function TweenableImage(texture:Texture)
		{
			super(texture);
		}

		public function startTween(tweenLength:Number, tweenType:String, valueName:String, targetValue:Number, onComplete:Function = null):void
		{
			_tweenLength = tweenLength;
			_tweenStartTime = new Date().time;
			_lastUpdateTime = _tweenStartTime;
			/**
			 * When Equations.as were inited,
			 * in Tweener class property transitionList was filled in with transitionName - function associations
			 */
			_tweenFunc = Tweener.transitionList[tweenType.toLowerCase()];
			_startValue = this[valueName];
			_targetValue = targetValue;
			_valueName = valueName;
			_onComplete = onComplete;
		}

		public function update():void
		{
			_lastUpdateTime = new Date().time;
			this[_valueName] = _tweenFunc((_lastUpdateTime - _tweenStartTime) / 1000, _startValue, _targetValue - _startValue, _tweenLength);
			if (this[_valueName] == _targetValue && _onComplete != null)
				_onComplete(this);
		}
	}
}
