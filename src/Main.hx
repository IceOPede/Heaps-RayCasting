import h2d.Text;
import hxd.Key;
import h2d.col.Ray;
import h2d.col.Segment;
import h2d.col.Point;
import h2d.Graphics;

// https://github.com/hamaluik/LuxeSightLights/blob/master/src/SightLight.hx
class Main extends hxd.App {
	var origin:Graphics;
	//
	var box1:Graphics;
	var box2:Graphics;
	var box3:Graphics;
	//
	var segmentList:Array<Segment>;
	var interLineList:Array<Graphics>;
	// var lightPolygonList:Array<Graphics>;
	var lightPolygon:Graphics;
	var pointList:Array<Point>;

	var fpsCounter:Text;

	override function init() {
		this.box1 = new Graphics(s2d);
		this.box2 = new Graphics(s2d);
		this.box3 = new Graphics(s2d);

		this.lightPolygon = new Graphics(s2d);

		this.origin = new Graphics(s2d);
		this.origin.beginFill(0xFFFFFF);
		this.origin.moveTo(0, 0);
		this.origin.lineStyle(0.5, 0xFFFFFF);
		this.origin.drawCircle(0, 0, 5);
		this.origin.endFill();

		this.segmentList = [];
		this.interLineList = [];

		this.pointList = [];

		drawBoxes();

		this.fpsCounter = new Text(hxd.res.DefaultFont.get(), s2d);
		this.fpsCounter.x = 0;
		this.fpsCounter.y = 0;
	}

	override function update(dt:Float) {
		this.fpsCounter.text = Std.string(engine.fps);
		this.origin.x = s2d.mouseX;
		this.origin.y = s2d.mouseY;
		castRayToSegmentEnds();
	}

	function castRayToSegmentEnds() {
		for (line in this.interLineList) {
			line.clear();
		}
		this.interLineList = [];

		this.pointList = [];

		var originPoint = new Point(this.origin.x, this.origin.y);
		var rayList = [];
		for (segment in this.segmentList) {
			var ray = createRay(originPoint, new Point(segment.x, segment.y));

			var angle:Float = Math.atan2(ray.dy - ray.y, ray.dx - ray.x);

			var angleMinus = angle - 0.00001;
			var anglePlus = angle + 0.00001;

			var rayMinus = createRay(originPoint, new Point(Math.cos(angleMinus), Math.sin(angleMinus)).add(new Point(ray.x, ray.y)));
			var rayPlus = createRay(originPoint, new Point(Math.cos(anglePlus), Math.sin(anglePlus)).add(new Point(ray.x, ray.y)));

			// rayList.push(ray);
			rayList.push(rayMinus);
			rayList.push(rayPlus);
		}

		for (ray in rayList) {
			var closestPoint = null;
			var intersectedSegment = null;
			var recDst = Math.POSITIVE_INFINITY;
			for (segment in this.segmentList) {
				var point = getIntersection(ray, segment);
				if (point != null) {
					var dst = originPoint.distanceSq(point);
					if (dst < recDst) {
						intersectedSegment = segment;
						closestPoint = point;
						recDst = dst;
					}
				}
			}

			if (intersectedSegment != null) {
				if (closestPoint != null) {
					// var line = new Graphics(s2d);
					// line.beginFill(0x000000);
					// line.lineStyle(1, 0xFF0000);
					// line.moveTo(this.origin.x, this.origin.y);
					// line.lineTo(closestPoint.x, closestPoint.y);
					// line.endFill();
					// interLineList.push(line);

					this.pointList.push(closestPoint);
				}
			}
		}

		pointList.sort(function(a, b) {
			var radA = Math.atan2(a.y - originPoint.y, a.x - originPoint.x);
			var radB = Math.atan2(b.y - originPoint.y, b.x - originPoint.x);
			if (radA < radB) {
				return -1;
			} else if (radA > radB) {
				return 1;
			}
			return 0;
		});

		this.lightPolygon.clear();
		this.lightPolygon.beginFill(0xffb400, 0.3);
		this.lightPolygon.moveTo(originPoint.x, originPoint.y);
		for (point in pointList) {
			this.lightPolygon.lineTo(point.x, point.y);
		}
		this.lightPolygon.lineTo(pointList[0].x, pointList[0].y);
		this.lightPolygon.lineTo(originPoint.x, originPoint.y);
		this.lightPolygon.endFill();
	}

	function drawBoxes() {
		var fillColor = 0x0000FF;
		var fillAlpha = 0.3;

		this.box1.beginFill(fillColor, fillAlpha);
		this.box1.lineStyle(1, 0xFFFFFF);
		this.box1.moveTo(0, 0);
		this.box1.lineTo(120, 20);
		this.box1.lineTo(170, 150);
		this.box1.lineTo(10, 200);
		this.box1.lineTo(0, 0);
		this.box1.endFill();
		this.box1.x = 250;
		this.box1.y = 100;

		this.segmentList.push(createSegment(box1.localToGlobal(new Point(0, 0)), box1.localToGlobal(new Point(120, 20))));
		this.segmentList.push(createSegment(box1.localToGlobal(new Point(120, 20)), box1.localToGlobal(new Point(170, 150))));
		this.segmentList.push(createSegment(box1.localToGlobal(new Point(170, 150)), box1.localToGlobal(new Point(10, 200))));
		this.segmentList.push(createSegment(box1.localToGlobal(new Point(10, 200)), box1.localToGlobal(new Point(0, 0))));

		this.box2.beginFill(fillColor, fillAlpha);
		this.box2.lineStyle(1, 0xFFFFFF);
		this.box2.moveTo(0, 0);
		this.box2.lineTo(100, -50);
		this.box2.lineTo(100, 200);
		this.box2.lineTo(80, 200);
		this.box2.lineTo(0, 0);
		this.box2.endFill();
		this.box2.x = 700;
		this.box2.y = 200;

		this.segmentList.push(createSegment(box2.localToGlobal(new Point(0, 0)), box2.localToGlobal(new Point(100, -50))));
		this.segmentList.push(createSegment(box2.localToGlobal(new Point(100, -50)), box2.localToGlobal(new Point(100, 200))));
		this.segmentList.push(createSegment(box2.localToGlobal(new Point(100, 200)), box2.localToGlobal(new Point(80, 200))));
		this.segmentList.push(createSegment(box2.localToGlobal(new Point(80, 200)), box2.localToGlobal(new Point(0, 0))));

		this.box3.beginFill(fillColor, fillAlpha);
		this.box3.lineStyle(1, 0xFFFFFF);
		this.box3.moveTo(0, 0);
		this.box3.lineTo(200, 0);
		this.box3.lineTo(0, 100);
		this.box3.lineTo(-200, 100);
		this.box3.lineTo(0, 0);
		this.box3.endFill();
		this.box3.x = 400;
		this.box3.y = 500;

		this.segmentList.push(createSegment(box3.localToGlobal(new Point(0, 0)), box3.localToGlobal(new Point(200, 0))));
		this.segmentList.push(createSegment(box3.localToGlobal(new Point(200, 0)), box3.localToGlobal(new Point(0, 100))));
		this.segmentList.push(createSegment(box3.localToGlobal(new Point(0, 100)), box3.localToGlobal(new Point(-200, 100))));
		this.segmentList.push(createSegment(box3.localToGlobal(new Point(-200, 100)), box3.localToGlobal(new Point(0, 0))));

		// Walls

		// left
		this.segmentList.push(createSegment(new Point(0, 0), new Point(s2d.width, 0)));
		// Top
		this.segmentList.push(createSegment(new Point(s2d.width, 0), new Point(s2d.width, s2d.height)));
		// Right
		this.segmentList.push(createSegment(new Point(s2d.width, s2d.height), new Point(0, s2d.height)));
		// bottom
		this.segmentList.push(createSegment(new Point(0, s2d.height), new Point(0, 0)));
	}

	function createSegment(p1:Point, p2:Point):Segment {
		return new Segment(new Point(p1.x, p1.y), new Point((p2.x + p1.x), (p2.y + p1.y)));
	}

	function createRay(p1:Point, p2:Point):Ray {
		return new Ray(new Point(p1.x, p1.y), new Point((p2.x + p1.x), (p2.y + p1.y)));
	}

	function getIntersection(ray:Ray, segment:Segment):Point {
		var x1 = segment.x;
		var y1 = segment.y;
		var x2 = segment.dx;
		var y2 = segment.dy;

		var x3 = ray.x;
		var y3 = ray.y;
		var x4 = ray.dx;
		var y4 = ray.dy;

		var den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
		if (den == 0) {
			return null;
		}
		var t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den;
		var u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den;
		if (t > 0 && t < 1 && u > 0) {
			var x = x1 + t * (x2 - x1);
			var y = y1 + t * (y2 - y1);
			return new Point(x, y);
		} else {
			return null;
		}
	}

	static function main() {
		new Main();
	}
}
