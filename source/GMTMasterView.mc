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
//    3 o'clock  → rectangular bar
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
        drawGMTGhostRing(dc);
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

        var dialColor = mSleepMode ? 0x0B0D10 : 0x1F4E8C;
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

            var tickColor = mSleepMode ? 0x0F1F1F : 0xF0F0F0;
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
                drawCircleMarker(dc, angle, mR * 0.063);
            }
        }
    }

    // 12 o'clock — downward-pointing triangle
    private function drawTriangleMarker(dc as Graphics.Dc, angle as Float) as Void {
        var outerR = mR * 0.855;
        var innerR = mR * 0.664;   // height -15% then -10%
        var halfW  = mR * 0.085;   // base -10% then -10%
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var pts = [
            [(mCx + outerR * sa + halfW * ca).toNumber(), (mCy - outerR * ca + halfW * sa).toNumber()],
            [(mCx + outerR * sa - halfW * ca).toNumber(), (mCy - outerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa).toNumber(),               (mCy - innerR * ca).toNumber()],
        ];

        dc.setColor(mSleepMode ? 0xC8E6C9 : 0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);
    }

    // 3, 6, 9 o'clock — rectangular bar
    private function drawRectMarker(dc as Graphics.Dc, angle as Float) as Void {
        var outerR = mR * 0.800 + 5;
        var innerR = mR * 0.630 + 5;
        var halfW  = mR * 0.046;
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var pts = [
            [(mCx + outerR * sa + halfW * ca).toNumber(), (mCy - outerR * ca + halfW * sa).toNumber()],
            [(mCx + outerR * sa - halfW * ca).toNumber(), (mCy - outerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa - halfW * ca).toNumber(), (mCy - innerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa + halfW * ca).toNumber(), (mCy - innerR * ca + halfW * sa).toNumber()],
        ];

        dc.setColor(mSleepMode ? 0xC8E6C9 : 0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);
    }

    // Applied circle marker; caller supplies radius
    private function drawCircleMarker(dc as Graphics.Dc, angle as Float, rF as Float) as Void {
        var dist = mR * 0.744 + 5;
        var r    = rF.toNumber();
        if (r < 5) { r = 5; }

        var x = (mCx + dist * Math.sin(angle)).toNumber();
        var y = (mCy - dist * Math.cos(angle)).toNumber();

        dc.setColor(mSleepMode ? 0xC8E6C9 : 0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r);
    }

    // -------------------------------------------------------------------------
    // Date window — lower center (6 o'clock region)
    // -------------------------------------------------------------------------

    private function drawDateWindow(dc as Graphics.Dc, day as Number) as Void {
        var dCx   = mCx;
        var dCy   = (mCy + mR * 0.500).toNumber() - 22;
        var dW    = (mR * 0.215).toNumber();
        var dH    = (mR * 0.200).toNumber();
        var dX    = dCx - dW / 2;
        var dY    = dCy - dH / 2;

        // Bulged-side shape: straight top/bottom, convex arc on left and right.
        var halfH  = dH.toFloat() / 2.0;
        var bulge  = (mR * 0.038).toFloat();
        var offset = (halfH * halfH - bulge * bulge) / (2.0 * bulge);
        var arcR   = Math.sqrt(offset * offset + halfH * halfH);
        var aStart = Math.atan2(-halfH, offset);
        var aEnd   = Math.atan2( halfH, offset);

        var nArc   = 10;
        var pts    = new[nArc * 2];
        var cxR    = (dX + dW).toFloat() - offset;
        var cxL    = dX.toFloat() + offset;
        var cy     = dCy.toFloat();

        for (var i = 0; i < nArc; i++) {
            var t  = i.toFloat() / (nArc - 1).toFloat();
            var a  = aStart + (aEnd - aStart) * t;
            pts[i] = [
                (cxR + arcR * Math.cos(a)).toNumber(),
                (cy  + arcR * Math.sin(a)).toNumber()
            ];
            var aL = aEnd - (aEnd - aStart) * t;
            pts[nArc + i] = [
                (cxL - arcR * Math.cos(aL)).toNumber(),
                (cy  + arcR * Math.sin(aL)).toNumber()
            ];
        }

        var boxFill    = mSleepMode ? 0x585858 : 0xFFFFFF;
        var boxBorder  = mSleepMode ? 0x404040 : 0xCCCCCC;
        var boxShadow  = mSleepMode ? 0x404040 : 0xB0B0B0;
        var dateText   = mSleepMode ? 0xC8E6C9 : 0x000000;
        dc.setColor(boxFill, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);

        dc.setColor(boxShadow, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(dX, dY + 1, dX + dW, dY + 1);

        dc.setColor(boxBorder, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        drawOutline(dc, pts);

        dc.setColor(dateText, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dCx, dCy, Graphics.FONT_TINY, day.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // -------------------------------------------------------------------------
    // Day-of-week arc text — upper dial, ~65% radius from center
    // -------------------------------------------------------------------------

    private function drawDayBox(dc as Graphics.Dc, dayOfWeek as Number) as Void {
        var days = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY",
                    "THURSDAY", "FRIDAY", "SATURDAY"];

        var idx = dayOfWeek - 1;
        if (idx < 0 || idx > 6) { idx = 0; }

        var label    = days[idx];
        var n        = label.length();
        var spacing  = 5.0;
        var font     = Graphics.FONT_XTINY;
        var hFont    = dc.getFontHeight(font).toFloat();
        // Position: outer rule top sits 4px below triangle apex (mCy - mR*0.619)
        var arcR     = mR * 0.680;
        var rOuter   = arcR + hFont / 2.0 + 2.0;
        var arcCy    = (mCy - mR * 0.664 + 12.0 + rOuter).toNumber();

        var charWidths = new[n];
        var totalW = 0.0;
        for (var i = 0; i < n; i++) {
            var w = dc.getTextWidthInPixels(label.substring(i, i + 1), font);
            charWidths[i] = w;
            if (i > 0) { totalW += spacing; }
            totalW += w.toFloat();
        }

        var totalAngle  = totalW / arcR;
        var startAngle  = -(totalAngle / 2.0);
        var ruleExtra   = 8.0 / arcR;
        var ruleStart   = startAngle - ruleExtra;
        var ruleSpan    = totalAngle + ruleExtra * 2.0;

        var rInner      = arcR - hFont / 2.0 - 2.0;
        var ruleSpanOut  = ruleSpan * 0.88;
        var ruleStartOut = ruleStart + (ruleSpan - ruleSpanOut) / 2.0;
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

        var dayColor = mSleepMode ? 0xAAAAAA : 0xE6E6E6;
        dc.setColor(dayColor, Graphics.COLOR_TRANSPARENT);
        var curAngle = startAngle;
        for (var i = 0; i < n; i++) {
            var charW    = charWidths[i].toFloat();
            var midAngle = curAngle + charW / (2.0 * arcR);
            var cx       = (mCx + arcR * Math.sin(midAngle)).toNumber();
            var cy       = (arcCy - arcR * Math.cos(midAngle)).toNumber();

            dc.drawText(cx, cy, font, label.substring(i, i + 1),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            curAngle += (charW + spacing) / arcR;
        }
    }

    // -------------------------------------------------------------------------
    // GMT ghost ring — 12 subtle ticks at 2-hour intervals (no numerals)
    // Visible but not attention-grabbing; fades further in night mode.
    // -------------------------------------------------------------------------

    private function drawGMTGhostRing(dc as Graphics.Dc) as Void {
        var ringR     = mR * 0.740;
        // Day: muted gray; Night: very dim (30–40% of day brightness)
        var tickColor = mSleepMode ? 0x1E2620 : 0x888880;

        dc.setColor(tickColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        for (var h = 0; h < 24; h += 2) {
            var angle   = h * (2.0 * Math.PI / 24.0);
            var sa      = Math.sin(angle);
            var ca      = Math.cos(angle);
            var isMajor = (h % 6 == 0);
            var outerR  = ringR + (isMajor ? 5.0 : 3.0);
            var innerR  = ringR - (isMajor ? 5.0 : 3.0);

            dc.drawLine(
                (mCx + outerR * sa).toNumber(),
                (mCy - outerR * ca).toNumber(),
                (mCx + innerR * sa).toNumber(),
                (mCy - innerR * ca).toNumber()
            );
        }
    }

    // -------------------------------------------------------------------------
    // Hands
    // -------------------------------------------------------------------------

    private function drawHands(dc as Graphics.Dc, clockTime as System.ClockTime) as Void {
        var h = clockTime.hour % 12;
        var m = clockTime.min;
        var s = clockTime.sec;

        // UTC time from absolute epoch seconds (Time.now() is always UTC)
        var utcSecs  = Time.now().value() % 86400;
        var utcH24   = (utcSecs / 3600) % 24;
        var utcM     = (utcSecs % 3600) / 60;

        drawHourHand(dc,   (h + m / 60.0)                    * (2.0 * Math.PI / 12.0));
        drawGMTHand(dc,    (utcH24 % 12 + utcM / 60.0)       * (2.0 * Math.PI / 12.0));
        drawMinuteHand(dc, (m + s / 60.0)                     * (2.0 * Math.PI / 60.0));
        drawSecondHand(dc,  s                                  * (2.0 * Math.PI / 60.0));
    }

    private function drawHourHand(dc as Graphics.Dc, angle as Float) as Void {
        var shaftHW  = (mR * 0.055).toNumber();
        var tipDist  = (mR * 0.600).toNumber();
        var triH     = (mR * 0.153).toNumber();
        var triHW    = (mR * 0.083).toNumber();
        var shaftTop = tipDist - triH;

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

        var hSteelColor = mSleepMode ? 0x1A3828 : 0x686860;
        var hLumeColor  = mSleepMode ? 0xC8E6C9 : 0xFFFFFF;
        if (!mSleepMode) {
            dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(shiftPts(steelRot, 1, 1));
        }
        dc.setColor(hSteelColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(steelRot);
        dc.setColor(hLumeColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(lumeRot);
    }

    private function drawGMTHand(dc as Graphics.Dc, angle as Float) as Void {
        // Burnt orange arrow hand showing UTC time
        var tip      = (mR * 0.750).toNumber() + 8;
        var hw       = (mR * 0.014).toNumber();
        var arrowH   = (mR * 0.138).toNumber();                    // +15%
        var arrowHW  = ((hw.toFloat() + 5.0) * 1.15).toNumber();   // +15%
        var arrowBase = tip - arrowH;

        var pts = [
            [-hw,       0],
            [ hw,       0],
            [ hw,      -arrowBase],
            [ arrowHW, -arrowBase],
            [ 0,       -tip],
            [-arrowHW, -arrowBase],
            [-hw,      -arrowBase],
        ];
        var ptsRot = rotateTranslate(pts, angle);

        var gmtColor = mSleepMode ? 0xC46A2D : 0xE06A2B;
        if (!mSleepMode) {
            dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(shiftPts(ptsRot, 1, 1));
        }
        dc.setColor(gmtColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(ptsRot);
    }

    private function drawMinuteHand(dc as Graphics.Dc, angle as Float) as Void {
        var tip       = (mR * 0.900).toNumber();
        var hw        = (mR * 0.034).toNumber();
        var lw        = hw - 2;
        var arrowH    = (mR * 0.155).toNumber();
        var arrowHW   = hw + 5;
        var arrowBase = tip - arrowH;

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

        var mSteelColor = mSleepMode ? 0x1A3828 : 0x686860;
        var mLumeColor  = mSleepMode ? 0xC8E6C9 : 0xFFFFFF;
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
        var tailLen  = mR * 0.171;
        var lollDist = mR * 0.620;
        var lollR    = (mR * 0.020).toNumber();   // slightly smaller lollipop
        var tipLen   = mR * 0.920;                // longer tip (92% radius)
        var pivotR   = (mR * 0.028).toNumber();
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var tipX  = (mCx + tipLen  * sa).toNumber();
        var tipY  = (mCy - tipLen  * ca).toNumber();
        var tailX = (mCx - tailLen * sa).toNumber();
        var tailY = (mCy + tailLen * ca).toNumber();
        var lollX = (mCx + lollDist * sa).toNumber();
        var lollY = (mCy - lollDist * ca).toNumber();

        var tailCircR = (mR * 0.027).toNumber();

        var secColor = mSleepMode ? 0x888888 : 0xB8C2D0;  // cool blue-gray

        if (!mSleepMode) {
            dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawLine(tailX + 1, tailY + 1, tipX + 1, tipY + 1);
            dc.fillCircle(lollX + 1, lollY + 1, lollR);
            dc.fillCircle(tailX + 1, tailY + 1, tailCircR);
        }

        dc.setColor(secColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(tailX, tailY, mCx, mCy);
        dc.fillCircle(tailX, tailY, tailCircR);
        dc.drawLine(mCx, mCy, lollX, lollY);

        // Hollow lollipop circle
        dc.setPenWidth(1);
        dc.drawCircle(lollX, lollY, lollR);

        dc.setPenWidth(2);
        dc.drawLine(lollX, lollY, tipX, tipY);
        dc.fillCircle(mCx, mCy, pivotR);
    }

    // -------------------------------------------------------------------------
    // Center dot
    // -------------------------------------------------------------------------

    private function drawCenterDot(dc as Graphics.Dc) as Void {
        var r = (mR * 0.038).toNumber();
        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(mCx, mCy, r + 1);
        dc.setColor(0xB0B0A8, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(mCx, mCy, r);
        dc.setColor(0xE8E8E0, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(mCx - 1, mCy - 1, r / 2);
    }

    // -------------------------------------------------------------------------
    // Helpers — untyped arrays so Monkey C infers the correct tuple types
    // -------------------------------------------------------------------------

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

    private function shiftPts(pts, dx as Number, dy as Number) {
        var n = pts.size();
        var result = new[n];
        for (var i = 0; i < n; i++) {
            result[i] = [pts[i][0] + dx, pts[i][1] + dy];
        }
        return result;
    }

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

    function onPartialUpdate(dc as Graphics.Dc) as Void {
        onUpdate(dc);
    }

}
