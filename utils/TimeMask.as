package utils
{
	import flash.display.Shape;
	import flash.display.Sprite;

	/**
	 * Filled circle which may show circle part (pizza progress).
	 * May be filled to whatever desired degree
	 * @author Alexey Kuznetsov
	 */
	public final class TimeMask extends Sprite
	{
		private var circleR:Number; // Circle radius (in pixels)
		private var circle:Shape;

		public function TimeMask(xx:Number, yy:Number, circleRadius:int)
		{
			this.x = xx;
			this.y = yy;

			circleR = circleRadius;

			circle = new Shape();
			circle.graphics.moveTo(0, 0);
			circle.graphics.lineTo(circleR, 0);
			addChild(circle);

			updatePicture(0);
		}

		/**
		 * Coolest part. Draws piece of a circle.
		 * E.g. may be called as:    _timeMask.updatePicture(360 - 360 * ((now.time - _startDate.time) / _lifeTime), true);
		 * @param degree amount of degrees which will be filled in
		 * @param color with which to fill in
		 */
		public function updatePicture(degree:Number, color:uint = 0x000000):void
		{
			circle.graphics.clear();
			circle.graphics.moveTo(0, 0);
			circle.graphics.beginFill(color, 0.75);

			for (var i:int = 0; i <= Math.abs(degree); i++)
			{
				circle.graphics.lineTo(circleR * Math.cos(i * Math.PI / 180), -circleR * Math.sin(i * Math.PI / 180));
			}

			circle.graphics.lineTo(0, 0);
			circle.graphics.endFill();
		}
	}
}