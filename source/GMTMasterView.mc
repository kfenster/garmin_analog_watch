import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Math;

//
// GMT Master watch face — inspired by the Rolex GMT-Master II blue dial.
//
// Hour marker layout (per reference photo):
//   12 o'clock  → downward-pointing triangle
//    3 o'clock  → date window (no marker)
//    6 o'clock  → rectangular bar
//    9 o'clock  → rectangular bar
//   all others  → large round applied circle
//

class GMTMasterView extends WatchUi.WatchFace {

    private var mCx as Number = 130;
    private var mCy as Number = 130;
    private var mR  as Number = 128;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        mCx = dc.getWidth()  / 2;
        mCy = dc.getHeight() / 2;
        mR  = (mCx < mCy ? mCx : mCy) - 2;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var clockTime = System.getClockTime();
        var info      = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        drawDial(dc);
        drawMinuteTicks(dc);
        drawHourMarkers(dc);
        drawDateWindow(dc, info.day);
        drawHands(dc, clockTime);
        drawCenterDot(dc);
    }

    // -------------------------------------------------------------------------
    // Dial background
    // -------------------------------------------------------------------------

    private function drawDial(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var dr = (mR * 0.92).toNumber();

        // Royal blue matched from reference photo: RGB(19, 53, 101)
        dc.setColor(0x133565, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(mCx, mCy, dr);

        dc.setColor(0x909090, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(mCx, mCy, dr);
        dc.drawCircle(mCx, mCy, dr + 1);
    }

    // -------------------------------------------------------------------------
    // Minute ticks
    // -------------------------------------------------------------------------

    private function drawMinuteTicks(dc as Graphics.Dc) as Void {
        var outerR  = mR * 0.905;
        var longIn  = mR * 0.852;
        var shortIn = mR * 0.880;

        for (var i = 0; i < 60; i++) {
            var angle  = i * (2.0 * Math.PI / 60.0);
            var sa     = Math.sin(angle);
            var ca     = Math.cos(angle);
            var isFive = (i % 5 == 0);
            var innerR = isFive ? longIn : shortIn;

            dc.setColor(0xF2F2F2, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(isFive ? 2 : 1);
            dc.drawLine(
                mCx + (outerR * sa).toNumber(),
                mCy - (outerR * ca).toNumber(),
                mCx + (innerR * sa).toNumber(),
                mCy - (innerR * ca).toNumber()
            );
        }
    }

    // -------------------------------------------------------------------------
    // Hour markers
    // -------------------------------------------------------------------------

    private function drawHourMarkers(dc as Graphics.Dc) as Void {
        for (var i = 0; i < 12; i++) {
            if (i == 3) { continue; }
            var angle = i * (2.0 * Math.PI / 12.0);
            if (i == 0) {
                drawTriangleMarker(dc, angle);
            } else if (i == 6 || i == 9) {
                drawRectMarker(dc, angle);
            } else {
                drawCircleMarker(dc, angle);
            }
        }
    }

    // 12 o'clock — downward-pointing triangle, base touches 59/1 minute marks
    private function drawTriangleMarker(dc as Graphics.Dc, angle as Float) as Void {
        var outerR = mR * 0.855;   // just touching 59/1 minute marks
        var innerR = mR * 0.560;   // apex
        var halfW  = mR * 0.100;   // wide base
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var pts = [
            [(mCx + outerR * sa + halfW * ca).toNumber(), (mCy - outerR * ca + halfW * sa).toNumber()],
            [(mCx + outerR * sa - halfW * ca).toNumber(), (mCy - outerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa).toNumber(),               (mCy - innerR * ca).toNumber()],
        ];

        dc.setColor(0xE8E8DC, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);
        dc.setColor(0x6A6A5A, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        drawOutline(dc, pts);
    }

    // 6 and 9 o'clock — rectangular bar (~50% more area)
    private function drawRectMarker(dc as Graphics.Dc, angle as Float) as Void {
        var outerR = mR * 0.822;   // ~4px gap from minute ticks
        var innerR = mR * 0.638;   // keep proportional length, shifted out
        var halfW  = mR * 0.050;   // wider for more area
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var pts = [
            [(mCx + outerR * sa + halfW * ca).toNumber(), (mCy - outerR * ca + halfW * sa).toNumber()],
            [(mCx + outerR * sa - halfW * ca).toNumber(), (mCy - outerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa - halfW * ca).toNumber(), (mCy - innerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa + halfW * ca).toNumber(), (mCy - innerR * ca + halfW * sa).toNumber()],
        ];

        dc.setColor(0xE8E8DC, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);
        dc.setColor(0x6A6A5A, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        drawOutline(dc, pts);
    }

    // All other hours — large applied circle with metallic ring
    private function drawCircleMarker(dc as Graphics.Dc, angle as Float) as Void {
        var dist = mR * 0.744;   // ~4px gap from minute ticks
        var r    = (mR * 0.075).toNumber();   // larger dots
        if (r < 5) { r = 5; }

        var x = (mCx + dist * Math.sin(angle)).toNumber();
        var y = (mCy - dist * Math.cos(angle)).toNumber();

        // Shadow
        dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x + 1, y + 1, r);
        // Metallic outer ring (steel)
        dc.setColor(0x686860, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r);
        // Lume fill inside
        dc.setColor(0xF0EEE8, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r - 2);
        // Small highlight
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 1, y - 1, r / 4);
    }

    // -------------------------------------------------------------------------
    // Date window at 3 o'clock
    // -------------------------------------------------------------------------

    private function drawDateWindow(dc as Graphics.Dc, day as Number) as Void {
        var dCx = (mCx + mR * 0.735).toNumber();
        var dCy = mCy;
        var dW  = (mR * 0.270).toNumber();  // fixed width — fits largest 2-digit date
        var dH  = (mR * 0.250).toNumber();  // taller so sides are clearly rectangular
        var dX  = dCx - dW / 2;
        var dY  = dCy - dH / 2;

        // Outer border
        dc.setColor(0x707070, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRoundedRectangle(dX, dY, dW, dH, 4);

        // White fill inset 1px so border stays visible
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(dX + 1, dY + 1, dW - 2, dH - 2, 3);

        // Inset shadow: dark edge at top and left (recessed window look)
        dc.setColor(0xB0B0B0, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(dX + 4, dY + 1, dX + dW - 5, dY + 1);
        dc.drawLine(dX + 1, dY + 4, dX + 1, dY + dH - 5);

        // Transparent background so text doesn't paint a white rectangle
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dCx, dCy, Graphics.FONT_SMALL, day.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // -------------------------------------------------------------------------
    // Hands
    // -------------------------------------------------------------------------

    private function drawHands(dc as Graphics.Dc, clockTime as System.ClockTime) as Void {
        var h = clockTime.hour % 12;
        var m = clockTime.min;
        var s = clockTime.sec;

        drawHourHand(dc,   (h + m / 60.0) * (2.0 * Math.PI / 12.0));
        drawMinuteHand(dc, (m + s / 60.0) * (2.0 * Math.PI / 60.0));
        drawSecondHand(dc,  s             * (2.0 * Math.PI / 60.0));
    }

    private function drawHourHand(dc as Graphics.Dc, angle as Float) as Void {
        // Rolex Mercedes hand: rectangular shaft + large circle (3 spokes) + triangular tip
        var ca = Math.cos(angle);
        var sa = Math.sin(angle);

        var shaftHW   = (mR * 0.042).toNumber();   // shaft half-width (wider for visible border)
        var circDist  = (mR * 0.355).toNumber();   // circle center from watch center
        var circR     = (mR * 0.068).toNumber();   // Mercedes circle radius
        var triTip    = (mR * 0.490).toNumber();   // arrowhead tip distance from center
        var triHW     = (mR * 0.026).toNumber();   // arrowhead half-width at base
        var shaftTopY = circDist - circR;           // shaft reaches bottom edge of circle

        // --- Shaft (starts at center, no tail) ---
        var shaft = [
            [-shaftHW,  0],
            [ shaftHW,  0],
            [ shaftHW, -shaftTopY],
            [-shaftHW, -shaftTopY],
        ];
        var shaftLume = [
            [-(shaftHW - 3),  0],
            [ (shaftHW - 3),  0],
            [ (shaftHW - 3), -shaftTopY],
            [-(shaftHW - 3), -shaftTopY],
        ];
        var shaftRot     = rotateTranslate(shaft,     angle);
        var shaftLumeRot = rotateTranslate(shaftLume, angle);

        dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(shiftPts(shaftRot, 1, 1));
        dc.setColor(0x686860, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(shaftRot);
        dc.setColor(0xF0EEE8, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(shaftLumeRot);

        // --- Mercedes circle ---
        var circX = (mCx + circDist * sa).toNumber();
        var circY = (mCy - circDist * ca).toNumber();

        dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(circX + 1, circY + 1, circR);
        dc.setColor(0x686860, Graphics.COLOR_TRANSPARENT);    // steel ring
        dc.fillCircle(circX, circY, circR);
        dc.setColor(0xF0EEE8, Graphics.COLOR_TRANSPARENT);   // lume fill
        dc.fillCircle(circX, circY, circR - 2);

        // Three spokes dividing the circle (Mercedes logo pattern)
        dc.setColor(0x686860, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        for (var j = 0; j < 3; j++) {
            var spokeAngle = angle + j * (2.0 * Math.PI / 3.0);
            var lx = (circX + (circR - 1) * Math.sin(spokeAngle)).toNumber();
            var ly = (circY - (circR - 1) * Math.cos(spokeAngle)).toNumber();
            dc.drawLine(circX, circY, lx, ly);
        }

        // --- Triangular arrowhead above circle ---
        var triBaseY = -(circDist + circR + 1);
        var tri = [
            [-triHW, triBaseY],
            [ triHW, triBaseY],
            [ 0,    -triTip],
        ];
        var triLume = [
            [-(triHW - 1), triBaseY + 1],
            [ (triHW - 1), triBaseY + 1],
            [ 0,           -(triTip - 2)],
        ];
        var triRot     = rotateTranslate(tri,     angle);
        var triLumeRot = rotateTranslate(triLume, angle);

        dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(shiftPts(triRot, 1, 1));
        dc.setColor(0x686860, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(triRot);
        dc.setColor(0xF0EEE8, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(triLumeRot);
    }

    private function drawMinuteHand(dc as Graphics.Dc, angle as Float) as Void {
        // Rolex Maxi minute hand: wide body, tapers to a pointed sword tip
        var tip  = (mR * 0.820).toNumber();
        var tail = (mR * 0.175).toNumber();
        var hw   = (mR * 0.046).toNumber();  // thickened for visible steel border
        var lw   = hw - 3;

        // Outer steel — starts at center, narrows into sword tip
        var steel = [
            [-hw,  0],
            [ hw,  0],
            [ hw, -(tip - 12)],
            [ 3,  -tip],
            [ 0,  -(tip + 2)],
            [-3,  -tip],
            [-hw, -(tip - 12)],
        ];
        // Inner lume shape
        var lume = [
            [-lw,  0],
            [ lw,  0],
            [ lw, -(tip - 13)],
            [ 2,  -(tip - 1)],
            [ 0,  -(tip + 1)],
            [-2,  -(tip - 1)],
            [-lw, -(tip - 13)],
        ];

        var steelRot = rotateTranslate(steel, angle);
        var lumeRot  = rotateTranslate(lume,  angle);

        dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(shiftPts(steelRot, 1, 1));
        dc.setColor(0x686860, Graphics.COLOR_TRANSPARENT);   // darker steel, clearly visible
        dc.fillPolygon(steelRot);
        dc.setColor(0xF0EEE8, Graphics.COLOR_TRANSPARENT);   // warm lume
        dc.fillPolygon(lumeRot);
    }

    private function drawSecondHand(dc as Graphics.Dc, angle as Float) as Void {
        // Structure: short tail ← [pivot circle] → line → [lollipop circle] → line → tip
        // Lollipop sits near the 6 o'clock rectangular marker radial distance
        var tailLen  = mR * 0.180;              // short counterbalance
        var lollDist = mR * 0.620;              // lollipop center (near inner edge of 6/9 markers)
        var lollR    = (mR * 0.048).toNumber(); // lollipop radius
        var tipLen   = mR * 0.900;              // tip extends almost to outer edge
        var pivotR   = (mR * 0.028).toNumber(); // small pivot circle at center
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var tipX  = (mCx + tipLen  * sa).toNumber();
        var tipY  = (mCy - tipLen  * ca).toNumber();
        var tailX = (mCx - tailLen * sa).toNumber();
        var tailY = (mCy + tailLen * ca).toNumber();
        var lollX = (mCx + lollDist * sa).toNumber();
        var lollY = (mCy - lollDist * ca).toNumber();

        var tailCircR = (mR * 0.038).toNumber();  // circle at tail end

        // Shadow
        dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(tailX + 1, tailY + 1, tipX + 1, tipY + 1);
        dc.fillCircle(lollX + 1, lollY + 1, lollR);
        dc.fillCircle(tailX + 1, tailY + 1, tailCircR);

        // White tail line
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(tailX, tailY, mCx, mCy);

        // Circle at tail end
        dc.fillCircle(tailX, tailY, tailCircR);

        // White line: center to lollipop
        dc.drawLine(mCx, mCy, lollX, lollY);

        // Lollipop circle
        dc.fillCircle(lollX, lollY, lollR);

        // White line: lollipop to tip (thin needle continues past the circle)
        dc.drawLine(lollX, lollY, tipX, tipY);

        // Small pivot circle at center (drawn last so it sits on top of lines)
        dc.fillCircle(mCx, mCy, pivotR);
    }

    // -------------------------------------------------------------------------
    // Center dot
    // -------------------------------------------------------------------------

    private function drawCenterDot(dc as Graphics.Dc) as Void {
        var r = (mR * 0.038).toNumber();
        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(mCx, mCy, r + 1);
        dc.setColor(0xB0B0A8, Graphics.COLOR_TRANSPARENT);   // polished steel cap
        dc.fillCircle(mCx, mCy, r);
        dc.setColor(0xE8E8E0, Graphics.COLOR_TRANSPARENT);   // highlight
        dc.fillCircle(mCx - 1, mCy - 1, r / 2);
    }

    // -------------------------------------------------------------------------
    // Helpers — untyped arrays so Monkey C infers the correct tuple types
    // -------------------------------------------------------------------------

    // Rotate local-coords points (tip toward -Y) by clock angle and
    // translate to screen center.
    private function rotateTranslate(pts, angle as Float) {
        var ca = Math.cos(angle);
        var sa = Math.sin(angle);
        var n  = pts.size();
        var result = new[n];
        for (var i = 0; i < n; i++) {
            var px = pts[i][0].toFloat();
            var py = pts[i][1].toFloat();
            result[i] = [
                (mCx + px * ca - py * sa).toNumber(),
                (mCy + px * sa + py * ca).toNumber(),
            ];
        }
        return result;
    }

    // Shift all points by (dx, dy) for drop shadow
    private function shiftPts(pts, dx as Number, dy as Number) {
        var n = pts.size();
        var result = new[n];
        for (var i = 0; i < n; i++) {
            result[i] = [pts[i][0] + dx, pts[i][1] + dy];
        }
        return result;
    }

    // Draw closed polygon outline
    private function drawOutline(dc as Graphics.Dc, pts) as Void {
        var n = pts.size();
        for (var i = 0; i < n; i++) {
            var j = (i + 1) % n;
            dc.drawLine(pts[i][0], pts[i][1], pts[j][0], pts[j][1]);
        }
    }

    function onShow()       as Void {}
    function onHide()       as Void {}
    function onExitSleep()  as Void {}
    function onEnterSleep() as Void {}

}
