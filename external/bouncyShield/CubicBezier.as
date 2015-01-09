/**
 * Created with IntelliJ IDEA.
 * User: aleksejkuznecov
 * Date: 1/7/13
 * Time: 12:09 AM
 * To change this template use File | Settings | File Templates.
 */
package external.bouncyShield
{

    import fl.motion.BezierSegment;

    import flash.display.Graphics;
    import flash.geom.Point;

    public class CubicBezier
    {

        /* pubic static function drawCurve
         *      Draws a single cubic Bézier curve
         *      @param:画笔、四个点（两个控制点）
         *              g:Graphics                      -Graphics on which to draw the curve
         *              p1:Point                        -First point in the curve
         *              p2:Point                        -Second point (control point) in the curve
         *              p3:Point                        -Third point (control point) in the curve
         *              p4:Point                        -Fourth point in the curve
         *      @return:
         */
        public static function drawCurve(g:Graphics, p1:Point, p2:Point, p3:Point, p4:Point):void
        {
            var bezier = new BezierSegment(p1, p2, p3, p4);    // BezierSegment using the four points(使用4个点)
            g.moveTo(p1.x, p1.y);
            // Construct the curve out of 100 segments (adjust number for less/more detail)
            //构建曲线的100段（调整数字或多或少细点）
            for (var t = .01; t < 1.01; t += .01)
            {
                //计算二维三次贝塞尔曲线在特定时间的位置。 t:Number — 沿曲线的 time 或进度，为 0 到 1 之间的十进制值。
                var val = bezier.getValue(t);   // x,y on the curve for a given t
                //注意： t 参数不一定以统一的速度沿曲线移动。 例如，t 值为 0.5 不一定是曲线中间的值。
                g.lineTo(val.x, val.y);
            }
        }

        /* public static function curveThroughPoints
         *      Draws a smooth curve through a series of points. For a closed curve, make the first and last points the same.
         *      @param:
         *              g:Graphics                      -Graphics on which to draw the curve
         *              p:Array                         -Array of Point instances
         *              z:Number                        -A factor (between 0 and 1) to reduce the size of curves by limiting the distance of control points from anchor points.
         *                                                       For example, z=.5 limits control points to half the distance of the closer adjacent anchor point.
         *                                                       I put the option here, but I recommend sticking with .5
         （一个因素（介于0和1 ） ，以减少曲线大小通过限制控制点到定位点的距离。
         例如， ž =. 5限制控制点，一半的距离更接近邻近锚点。
         我放在这里作为选项，但我建议坚持0.5）
         *              angleFactor:Number      -Adjusts the size of curves depending on how acute the angle between points is. Curves are reduced as acuteness
         *                                                       increases, and this factor controls by how much.
         *                                                       1 = curves are reduced in direct proportion to acuteness
         *                                                       0 = curves are not reduced at all based on acuteness
         *                                                       in between = the reduction is basically a percentage of the full reduction
         （调整曲线的大小取决于点之间的夹角有多急。曲度减少因为
         尖锐性增加，及这一因素的控制为多少。
         1 =曲线减少成正比尖锐
         0 =曲线不减少的基础上在所有尖锐性
         之间=减少基本上是一个百分比的全面减少）

         *      @return:
         */
        public static function curveThroughPoints(g:Graphics, points:Array/*of Points*/, z:Number = .5, angleFactor:Number = .75):void
        {
            try
            {
                var p:Array = points.slice();   // Local copy of points array （点数组的一个拷贝）
                var duplicates:Array = new Array();     // Array to hold indices of duplicate points（数组用来保存重复的点的下标）
                // Check to make sure array contains only Points（检查保证p数组中只包含点对象）
                for (var i = 0; i < p.length; i++)
                {
                    if (!(p[i] is Point))
                    {
                        throw new Error("Array must contain Point objects");
                    }
                    // Check for the same point twice in a row（检查一行中是否有同一个点出现两次）
                    if (i > 0)
                    {
                        if (p[i].x == p[i - 1].x && p[i].y == p[i - 1].y)
                        {
                            duplicates.push(i);     // add index of duplicate to duplicates array（把重复点【前面一个：i】的下标加入duplicates数组）
                        }
                    }
                }
                // Loop through duplicates array and remove points from the points array
                for (i = duplicates.length - 1; i >= 0; i--)
                {
                    p.splice(duplicates[i], 1);//删除一个元素
                }
                // Make sure z is between 0 and 1 (too messy otherwise)
                if (z <= 0)
                {
                    z = .5;
                }
                else if (z > 1)
                {
                    z = 1;
                }
                // Make sure angleFactor is between 0 and 1
                if (angleFactor < 0)
                {
                    angleFactor = 0;
                }
                else if (angleFactor > 1)
                {
                    angleFactor = 1;
                }

                //
                // First calculate all the curve control points（首先计算出所有的曲线控制点）
                //

                // None of this junk will do any good if there are only two points（如果只有两个点，不进行这个"垃圾处理",将不会带来任何好处）
                if (p.length > 2)
                {
                    // Ordinarily, curve calculations will start with the second point and go through the second-to-last point
                    //一般来说，曲线计算将开始第二点，然后进行直到倒数第2个点
                    var firstPt = 1;
                    var lastPt = p.length - 1;
                    // Check if this is a closed line (the first and last points are the same)
                    //检查是否这是一个闭环（第一个和最后一个点是同一个）
                    if (p[0].x == p[p.length - 1].x && p[0].y == p[p.length - 1].y)
                    {
                        // Include first and last points in curve calculations（包括第一个和最后一个点，曲线的计算）
                        firstPt = 0;
                        lastPt = p.length;
                    }

                    var controlPts:Array = new Array();     // An array to store the two control points (of a cubic Bézier curve) for each point(为每个点存储两个控制点（一个三次Bézier曲线）的数组)

                    // Loop through all the points (except the first and last if not a closed line) to get curve control points for each.
                    //循环遍历所有各点（除第一点和最后一点，如果不是封闭线）为每个点获得曲线控制点。
                    for (i = firstPt; i < lastPt; i++)
                    {

                        // The previous, current, and next points
                        var p0 = (i - 1 < 0) ? p[p.length - 2] : p[i - 1];    // If the first point (of a closed line), use the second-to-last point as the previous point
                        var p1 = p[i];
                        var p2 = (i + 1 == p.length) ? p[1] : p[i + 1];             // If the last point (of a closed line), use the second point as the next point
                        var a = Point.distance(p0, p1);  // Distance from previous point to current point
                        if (a < 0.001) a = .001;                // Correct for near-zero distances, which screw up the angles or something
                        var b = Point.distance(p1, p2);  // Distance from current point to next point
                        if (b < 0.001) b = .001;
                        var c = Point.distance(p0, p2);  // Distance from previous point to next point
                        if (c < 0.001) c = .001;
                        var C = Math.acos((b * b + a * a - c * c) / (2 * b * a));       // Angle formed by the two sides of the triangle (described by the three points above) adjacent to the current point
                        // Duplicate set of points. Start by giving previous and next points values RELATIVE to the current point.
                        var aPt = new Point(p0.x - p1.x, p0.y - p1.y);
                        var bPt = new Point(p1.x, p1.y);
                        var cPt = new Point(p2.x - p1.x, p2.y - p1.y);
                        /*
                         We'll be adding adding the vectors from the previous and next points to the current point,
                         but we don't want differing magnitudes (i.e. line segment lengths) to affect the direction
                         of the new vector. Therefore we make sure the segments we use, based on the duplicate points
                         created above, are of equal length. The angle of the new vector will thus bisect angle C
                         (defined above) and the perpendicular to this is nice for the line tangent to the curve.
                         The curve control points will be along that tangent line.
                         */
                        if (a > b)
                        {
                            aPt.normalize(b);       // Scale the segment to aPt (bPt to aPt) to the size of b (bPt to cPt) if b is shorter.
                        }
                        else if (b > a)
                        {
                            cPt.normalize(a);       // Scale the segment to cPt (bPt to cPt) to the size of a (aPt to bPt) if a is shorter.
                        }
                        // Offset aPt and cPt by the current point to get them back to their absolute position.
                        aPt.offset(p1.x, p1.y);
                        cPt.offset(p1.x, p1.y);
                        // Get the sum of the two vectors, which is perpendicular to the line along which our curve control points will lie.
                        var ax = bPt.x - aPt.x;   // x component of the segment from previous to current point
                        var ay = bPt.y - aPt.y;
                        var bx = bPt.x - cPt.x;   // x component of the segment from next to current point
                        var by = bPt.y - cPt.y;
                        var rx = ax + bx;       // sum of x components
                        var ry = ay + by;
                        var r = Math.sqrt(rx * rx + ry * ry); // length of the summed vector - not being used, but there it is anyway
                        var theta = Math.atan(ry / rx);   // angle of the new vector

                        var controlDist = Math.min(a, b) * .5;     // Distance of curve control points from current point: a fraction the length of the shorter adjacent triangle side
                        var controlScaleFactor = C / Math.PI;     // Scale the distance based on the acuteness of the angle. Prevents big loops around long, sharp-angled triangles.
                        controlDist *= ((1 - angleFactor) + angleFactor * controlScaleFactor);      // Mess with this for some fine-tuning
                        var controlAngle = theta + Math.PI / 2;     // The angle from the current point to control points: the new vector angle plus 90 degrees (tangent to the curve).
                        var controlPoint2 = Point.polar(controlDist, controlAngle);      // Control point 2, curving to the next point.
                        var controlPoint1 = Point.polar(controlDist, controlAngle + Math.PI);      // Control point 1, curving from the previous point (180 degrees away from control point 2).
                        // Offset control points to put them in the correct absolute position
                        controlPoint1.offset(p1.x, p1.y);
                        controlPoint2.offset(p1.x, p1.y);
                        /*
                         Haven't quite worked out how this happens, but some control points will be reversed.
                         In this case controlPoint2 will be farther from the next point than controlPoint1 is.
                         Check for that and switch them if it's true.
                         */
                        if (Point.distance(controlPoint2, p2) > Point.distance(controlPoint1, p2))
                        {
                            controlPts[i] = new Array(controlPoint2, controlPoint1); // Add the two control points to the array in reverse order
                        }
                        else
                        {
                            controlPts[i] = new Array(controlPoint1, controlPoint2); // Otherwise add the two control points to the array in normal order
                        }
                        // Uncomment to draw lines showing where the control points are.
                        /*
                         g.moveTo(p1.x,p1.y);
                         g.lineTo(controlPoint2.x,controlPoint2.y);
                         g.moveTo(p1.x,p1.y);
                         g.lineTo(controlPoint1.x,controlPoint1.y);
                         */
                    }

                    //
                    // Now draw the curve
                    //
                    g.moveTo(p[0].x, p[0].y);
                    // If this isn't a closed line
                    if (firstPt == 1)
                    {
                        // Draw a regular quadratic Bézier curve from the first to second points, using the first control point of the second point
                        g.curveTo(controlPts[1][0].x, controlPts[1][0].y, p[1].x, p[1].y);
                    }
                    // Loop through points to draw cubic Bézier curves through the penultimate point, or through the last point if the line is closed.
                    for (i = firstPt; i < lastPt - 1; i++)
                    {
                        // BezierSegment instance using the current point, its second control point, the next point's first control point, and the next point
                        var bezier:BezierSegment = new BezierSegment(p[i], controlPts[i][1], controlPts[i + 1][0], p[i + 1]);
                        // Construct the curve out of 100 segments (adjust number for less/more detail)
                        for (var t = .01; t < 1.01; t += .01)
                        {
                            var val = bezier.getValue(t);   // x,y on the curve for a given t
                            g.lineTo(val.x, val.y);
                        }
                    }
                    // If this isn't a closed line
                    if (lastPt == p.length - 1)
                    {
                        // Curve to the last point using the second control point of the penultimate point.
                        g.curveTo(controlPts[i][1].x, controlPts[i][1].y, p[i + 1].x, p[i + 1].y);
                    }
                    // just draw a line if only two points
                }
                else if (p.length == 2)
                {
                    g.moveTo(p[0].x, p[0].y);
                    g.lineTo(p[1].x, p[1].y);
                }
            }
                // Catch error
            catch (e)
            {
                trace(e.getStackTrace());
            }
        }

    }

}
