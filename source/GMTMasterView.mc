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

    private var mCx       as Number  = 130;
    private var mCy       as Number  = 130;
    private var mR        as Number  = 128;
    private var mSleepMode as Boolean = false;

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
        drawDayBox(dc, info.day_of_week);
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

        var dialColor = mSleepMode ? 0x000000 : 0x133565;
        dc.setColor(dialColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(mCx, mCy, dr);

        if (!mSleepMode) {
            dc.setColor(0x909090, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            dc.drawCircle(mCx, mCy, dr);
            dc.drawCircle(mCx, mCy, dr + 1);
        }
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

            var tickColor = mSleepMode ? 0x0A2828 : 0xF2F2F2;
            dc.setColor(tickColor, Graphics.COLOR_TRANSPARENT);
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
            var angle = i * (2.0 * Math.PI / 12.0);
            if (i == 0) {
                drawTriangleMarker(dc, angle);
            } else if (i == 3 || i == 6 || i == 9) {
                drawRectMarker(dc, angle);
            } else {
                drawCircleMarker(dc, angle);
            }
        }
    }

    // 12 o'clock — downward-pointing triangle, base touches 59/1 minute marks
    private function drawTriangleMarker(dc as Graphics.Dc, angle as Float) as Void {
        var outerR = mR * 0.855;   // just touching 59/1 minute marks
        var innerR = mR * 0.619;   // apex — 2/3 height + 20% restored
        var halfW  = mR * 0.100;   // wide base
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var pts = [
            [(mCx + outerR * sa + halfW * ca).toNumber(), (mCy - outerR * ca + halfW * sa).toNumber()],
            [(mCx + outerR * sa - halfW * ca).toNumber(), (mCy - outerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa).toNumber(),               (mCy - innerR * ca).toNumber()],
        ];

        var lumeColor   = mSleepMode ? 0x00E5CC : 0xE8E8DC;
        var borderColor = mSleepMode ? 0x003830 : 0x6A6A5A;
        dc.setColor(lumeColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);
        dc.setColor(borderColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        drawOutline(dc, pts);
    }

    // 6 and 9 o'clock — rectangular bar (~50% more area)
    private function drawRectMarker(dc as Graphics.Dc, angle as Float) as Void {
        var outerR = mR * 0.800;   // pulled inward to avoid dial edge
        var innerR = mR * 0.616;   // proportional
        var halfW  = mR * 0.050;   // wider for more area
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var pts = [
            [(mCx + outerR * sa + halfW * ca).toNumber(), (mCy - outerR * ca + halfW * sa).toNumber()],
            [(mCx + outerR * sa - halfW * ca).toNumber(), (mCy - outerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa - halfW * ca).toNumber(), (mCy - innerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa + halfW * ca).toNumber(), (mCy - innerR * ca + halfW * sa).toNumber()],
        ];

        var lumeColor   = mSleepMode ? 0x00E5CC : 0xE8E8DC;
        var borderColor = mSleepMode ? 0x003830 : 0x6A6A5A;
        dc.setColor(lumeColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);
        dc.setColor(borderColor, Graphics.COLOR_TRANSPARENT);
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

        var steelColor = mSleepMode ? 0x003830 : 0x686860;
        var lumeColor  = mSleepMode ? 0x00E5CC : 0xF0EEE8;
        // Shadow (skip in sleep — nothing to shadow against black)
        if (!mSleepMode) {
            dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x + 1, y + 1, r);
        }
        // Metallic outer ring
        dc.setColor(steelColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r);
        // Lume fill inside
        dc.setColor(lumeColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r - 2);
        // Small highlight (skip in sleep — lume glows uniformly)
        if (!mSleepMode) {
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x - 1, y - 1, r / 4);
        }
    }

    // -------------------------------------------------------------------------
    // Date window at 3 o'clock
    // -------------------------------------------------------------------------

    private function drawDateWindow(dc as Graphics.Dc, day as Number) as Void {
        var dCx   = mCx;
        var dCy   = (mCy + mR * 0.500).toNumber() - 30;
        var dW    = (mR * 0.215).toNumber();
        var dH    = (mR * 0.200).toNumber();
        var dX    = dCx - dW / 2;
        var dY    = dCy - dH / 2;

        // Bulged-side shape: straight top/bottom, convex arc on left and right.
        // Arc geometry: circle passing through both corners of a side, bulging outward.
        var halfH  = dH.toFloat() / 2.0;
        var bulge  = (mR * 0.038).toFloat();   // outward bulge in pixels
        var offset = (halfH * halfH - bulge * bulge) / (2.0 * bulge);
        var arcR   = Math.sqrt(offset * offset + halfH * halfH);
        var aStart = Math.atan2(-halfH, offset);   // angle to top corner from arc center
        var aEnd   = Math.atan2( halfH, offset);   // angle to bottom corner

        var nArc   = 10;
        var pts    = new[nArc * 2];
        var cxR    = (dX + dW).toFloat() - offset;
        var cxL    = dX.toFloat() + offset;
        var cy     = dCy.toFloat();

        for (var i = 0; i < nArc; i++) {
            var t  = i.toFloat() / (nArc - 1).toFloat();
            var a  = aStart + (aEnd - aStart) * t;
            // Right arc: top-right → bottom-right
            pts[i] = [
                (cxR + arcR * Math.cos(a)).toNumber(),
                (cy  + arcR * Math.sin(a)).toNumber()
            ];
            // Left arc: bottom-left → top-left (reverse angle order)
            var aL = aEnd - (aEnd - aStart) * t;
            pts[nArc + i] = [
                (cxL - arcR * Math.cos(aL)).toNumber(),
                (cy  + arcR * Math.sin(aL)).toNumber()
            ];
        }

        // Box fill
        var boxFill    = mSleepMode ? 0x585858 : 0xFFFFFF;
        var boxBorder  = mSleepMode ? 0x404040 : 0x707070;
        var boxShadow  = mSleepMode ? 0x404040 : 0xB0B0B0;
        var dateText   = mSleepMode ? 0x00E5CC : 0x000000;
        dc.setColor(boxFill, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);

        // Inset shadow along top edge
        dc.setColor(boxShadow, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(dX, dY + 1, dX + dW, dY + 1);

        // Border outline
        dc.setColor(boxBorder, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        drawOutline(dc, pts);

        // Date text
        dc.setColor(dateText, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dCx, dCy, Graphics.FONT_TINY, day.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // -------------------------------------------------------------------------
    // Day-of-week box — between triangle and center, upper dial
    // -------------------------------------------------------------------------

    private function drawDayBox(dc as Graphics.Dc, dayOfWeek as Number) as Void {
        var days = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY",
                    "THURSDAY", "FRIDAY", "SATURDAY"];

        var idx = dayOfWeek - 1;
        if (idx < 0 || idx > 6) { idx = 0; }

        var label    = days[idx];
        var n        = label.length();
        var arcR     = mR * 0.780;         // doubled radius = gentler curve
        var arcCy    = mCy + mR * 0.390 - 8;   // arc center below text so curve is gentle
        var spacing  = 3.0;                // px between characters
        var fontBig  = Graphics.FONT_TINY;
        var fontSm   = Graphics.FONT_XTINY;
        var hBig     = dc.getFontHeight(fontBig).toFloat();
        var hSm      = dc.getFontHeight(fontSm).toFloat();
        var deltaR   = (hBig - hSm) / 2.0;  // radial offset to bias big/small to their rules

        // Measure each character with its respective font
        var charWidths = new[n];
        var totalW = 0.0;
        for (var i = 0; i < n; i++) {
            var fnt = (i == 0) ? fontBig : fontSm;
            var w = dc.getTextWidthInPixels(label.substring(i, i + 1), fnt);
            charWidths[i] = w;
            if (i > 0) { totalW += spacing; }
            totalW += w.toFloat();
        }

        // Angular span of the text, rules extend 10px beyond each end
        var totalAngle  = totalW / arcR;
        var startAngle  = -(totalAngle / 2.0);
        var ruleExtra   = 10.0 / arcR;
        var ruleStart   = startAngle - ruleExtra;
        var ruleSpan    = totalAngle + ruleExtra * 2.0;

        // Stainless arc rules: outer (toward bezel) and inner (toward center)
        var rOuter      = arcR + hBig / 2.0 + 2.0;
        var rInner      = arcR - hBig / 2.0 - 2.0;
        var ruleSpanOut  = ruleSpan * 0.88;                      // outer rule = 88% of inner
        var ruleStartOut = ruleStart + (ruleSpan - ruleSpanOut) / 2.0;  // centered
        var steps       = 24;
        var ruleColor = mSleepMode ? 0x303030 : 0xA8A8A0;
        dc.setColor(ruleColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        for (var s = 0; s < steps; s++) {
            var a1o = ruleStartOut + ruleSpanOut * s.toFloat()       / steps.toFloat();
            var a2o = ruleStartOut + ruleSpanOut * (s + 1).toFloat() / steps.toFloat();
            dc.drawLine(
                (mCx + rOuter * Math.sin(a1o)).toNumber(),
                (arcCy - rOuter * Math.cos(a1o)).toNumber(),
                (mCx + rOuter * Math.sin(a2o)).toNumber(),
                (arcCy - rOuter * Math.cos(a2o)).toNumber()
            );
            var a1i = ruleStart + ruleSpan * s.toFloat()       / steps.toFloat();
            var a2i = ruleStart + ruleSpan * (s + 1).toFloat() / steps.toFloat();
            dc.drawLine(
                (mCx + rInner * Math.sin(a1i)).toNumber(),
                (arcCy - rInner * Math.cos(a1i)).toNumber(),
                (mCx + rInner * Math.sin(a2i)).toNumber(),
                (arcCy - rInner * Math.cos(a2i)).toNumber()
            );
        }

        // Draw characters: first letter biased toward outer rule, rest toward inner
        var dayColor = mSleepMode ? 0x505050 : 0xE8E8DC;
        dc.setColor(dayColor, Graphics.COLOR_TRANSPARENT);
        var curAngle = startAngle;
        for (var i = 0; i < n; i++) {
            var charW    = charWidths[i].toFloat();
            var midAngle = curAngle + charW / (2.0 * arcR);
            var r        = (i == 0) ? arcR : arcR - deltaR;
            var cx       = (mCx + r * Math.sin(midAngle)).toNumber();
            var cy       = (arcCy - r * Math.cos(midAngle)).toNumber();
            var fnt      = (i == 0) ? fontBig : fontSm;

            dc.drawText(cx, cy, fnt, label.substring(i, i + 1),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            curAngle += (charW + spacing) / arcR;
        }
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
        // Baton hand: rectangular shaft with flared triangular arrowhead at tip
        var shaftHW  = (mR * 0.055).toNumber();        // shaft half-width (+15%)
        var tipDist  = (mR * 0.820).toNumber() - 45;   // tip distance from center
        var triH     = (mR * 0.153).toNumber();         // height of triangular arrowhead (-10%)
        var triHW    = (mR * 0.083).toNumber();         // arrowhead half-width (+15%)
        var shaftTop = tipDist - triH;                  // distance from center to triangle base

        // One-piece shape: shaft sides + arrowhead flare + point
        var steel = [
            [-shaftHW,   0],
            [ shaftHW,   0],
            [ shaftHW,  -shaftTop],
            [ triHW,    -shaftTop],
            [ 0,        -tipDist],
            [-triHW,    -shaftTop],
            [-shaftHW,  -shaftTop],
        ];
        var lume = [
            [-(shaftHW - 2),  0],
            [ (shaftHW - 2),  0],
            [ (shaftHW - 2), -shaftTop],
            [ (triHW - 1),   -shaftTop],
            [ 0,             -(tipDist - 2)],
            [-(triHW - 1),   -shaftTop],
            [-(shaftHW - 2), -shaftTop],
        ];

        var steelRot = rotateTranslate(steel, angle);
        var lumeRot  = rotateTranslate(lume,  angle);

        var hSteelColor = mSleepMode ? 0x003830 : 0x686860;
        var hLumeColor  = mSleepMode ? 0x00E5CC : 0xF0EEE8;
        if (!mSleepMode) {
            dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(shiftPts(steelRot, 1, 1));
        }
        dc.setColor(hSteelColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(steelRot);
        dc.setColor(hLumeColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(lumeRot);
    }

    private function drawMinuteHand(dc as Graphics.Dc, angle as Float) as Void {
        // Minute hand with proportional arrowhead at tip
        var tip       = (mR * 0.775).toNumber();
        var hw        = (mR * 0.034).toNumber();
        var lw        = hw - 2;
        var arrowH    = (mR * 0.155).toNumber();   // arrowhead section height
        var arrowHW   = hw + 5;                    // arrowhead half-width (proportional flare)
        var arrowBase = tip - arrowH;              // where arrowhead starts from center

        // Shaft with parallel sides, flaring to arrowhead then to point
        var steel = [
            [-hw,       0],
            [ hw,       0],
            [ hw,      -arrowBase],
            [ arrowHW, -arrowBase],
            [ 0,       -tip],
            [-arrowHW, -arrowBase],
            [-hw,      -arrowBase],
        ];
        var lume = [
            [-lw,           0],
            [ lw,           0],
            [ lw,          -arrowBase],
            [ (arrowHW - 1), -arrowBase],
            [ 0,            -(tip - 2)],
            [-(arrowHW - 1), -arrowBase],
            [-lw,          -arrowBase],
        ];

        var steelRot = rotateTranslate(steel, angle);
        var lumeRot  = rotateTranslate(lume,  angle);

        var mSteelColor = mSleepMode ? 0x003830 : 0x686860;
        var mLumeColor  = mSleepMode ? 0x00E5CC : 0xF0EEE8;
        if (!mSleepMode) {
            dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(shiftPts(steelRot, 1, 1));
        }
        dc.setColor(mSteelColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(steelRot);
        dc.setColor(mLumeColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(lumeRot);
    }

    private function drawSecondHand(dc as Graphics.Dc, angle as Float) as Void {
        // Structure: short tail ← [pivot circle] → line → [lollipop circle] → line → tip
        // Lollipop sits near the 6 o'clock rectangular marker radial distance
        var tailLen  = mR * 0.171;              // short counterbalance (5% shorter)
        var lollDist = mR * 0.620;              // lollipop center (near inner edge of 6/9 markers)
        var lollR    = (mR * 0.030).toNumber(); // lollipop radius
        var tipLen   = mR * 0.855;              // tip (5% shorter)
        var pivotR   = (mR * 0.028).toNumber(); // small pivot circle at center
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var tipX  = (mCx + tipLen  * sa).toNumber();
        var tipY  = (mCy - tipLen  * ca).toNumber();
        var tailX = (mCx - tailLen * sa).toNumber();
        var tailY = (mCy + tailLen * ca).toNumber();
        var lollX = (mCx + lollDist * sa).toNumber();
        var lollY = (mCy - lollDist * ca).toNumber();

        var tailCircR = (mR * 0.027).toNumber();  // 80% area of lollipop circle

        var secColor = mSleepMode ? 0x00E5CC : 0xFFFFFF;

        // Shadow (skip in sleep — nothing to shadow against black)
        if (!mSleepMode) {
            dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawLine(tailX + 1, tailY + 1, tipX + 1, tipY + 1);
            dc.fillCircle(lollX + 1, lollY + 1, lollR);
            dc.fillCircle(tailX + 1, tailY + 1, tailCircR);
        }

        // Tail line
        dc.setColor(secColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(tailX, tailY, mCx, mCy);

        // Circle at tail end
        dc.fillCircle(tailX, tailY, tailCircR);

        // Line: center to lollipop
        dc.drawLine(mCx, mCy, lollX, lollY);

        // Lollipop circle
        dc.fillCircle(lollX, lollY, lollR);

        // Line: lollipop to tip
        dc.drawLine(lollX, lollY, tipX, tipY);

        // Small pivot circle at center
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

    function setSleepMode(sleep as Boolean) as Void {
        mSleepMode = sleep;
        WatchUi.requestUpdate();
    }

    function onShow()       as Void {}
    function onHide()       as Void {}
    function onExitSleep()  as Void { mSleepMode = false; WatchUi.requestUpdate(); }
    function onEnterSleep() as Void { mSleepMode = true;  WatchUi.requestUpdate(); }

    // In sleep mode Garmin dispatches partial updates instead of onUpdate.
    // Delegate to onUpdate so the sleep palette is rendered.
    function onPartialUpdate(dc as Graphics.Dc) as Void {
        onUpdate(dc);
    }

}
