import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Math;

//
// GMT Master Night — always-on sleep face.
// Black AMOLED dial, cyan-green lume. No mode switching.
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
        drawDayBox(dc, info.day_of_week);
        drawHands(dc, clockTime);
        drawCenterDot(dc);
    }

    function onPartialUpdate(dc as Graphics.Dc) as Void {
        onUpdate(dc);
    }

    // -------------------------------------------------------------------------
    // Dial background — true black
    // -------------------------------------------------------------------------

    private function drawDial(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var dr = (mR * 0.92).toNumber();
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(mCx, mCy, dr);
    }

    // -------------------------------------------------------------------------
    // Minute ticks — very dim so the dial isn't cluttered
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

            dc.setColor(0x0A2828, Graphics.COLOR_TRANSPARENT);
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

    private function drawTriangleMarker(dc as Graphics.Dc, angle as Float) as Void {
        var outerR = mR * 0.855;
        var innerR = mR * 0.619;
        var halfW  = mR * 0.100;
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var pts = [
            [(mCx + outerR * sa + halfW * ca).toNumber(), (mCy - outerR * ca + halfW * sa).toNumber()],
            [(mCx + outerR * sa - halfW * ca).toNumber(), (mCy - outerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa).toNumber(),               (mCy - innerR * ca).toNumber()],
        ];

        dc.setColor(0x00E5CC, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);
        dc.setColor(0x003830, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        drawOutline(dc, pts);
    }

    private function drawRectMarker(dc as Graphics.Dc, angle as Float) as Void {
        var outerR = mR * 0.800;
        var innerR = mR * 0.616;
        var halfW  = mR * 0.050;
        var sa = Math.sin(angle);
        var ca = Math.cos(angle);

        var pts = [
            [(mCx + outerR * sa + halfW * ca).toNumber(), (mCy - outerR * ca + halfW * sa).toNumber()],
            [(mCx + outerR * sa - halfW * ca).toNumber(), (mCy - outerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa - halfW * ca).toNumber(), (mCy - innerR * ca - halfW * sa).toNumber()],
            [(mCx + innerR * sa + halfW * ca).toNumber(), (mCy - innerR * ca + halfW * sa).toNumber()],
        ];

        dc.setColor(0x00E5CC, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);
        dc.setColor(0x003830, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        drawOutline(dc, pts);
    }

    private function drawCircleMarker(dc as Graphics.Dc, angle as Float) as Void {
        var dist = mR * 0.744;
        var r    = (mR * 0.075).toNumber();
        if (r < 5) { r = 5; }

        var x = (mCx + dist * Math.sin(angle)).toNumber();
        var y = (mCy - dist * Math.cos(angle)).toNumber();

        dc.setColor(0x003830, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r);
        dc.setColor(0x00E5CC, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, r - 2);
    }

    // -------------------------------------------------------------------------
    // Date window — dark gray, muted
    // -------------------------------------------------------------------------

    private function drawDateWindow(dc as Graphics.Dc, day as Number) as Void {
        var dCx   = mCx;
        var dCy   = (mCy + mR * 0.500).toNumber() - 30;
        var dW    = (mR * 0.215).toNumber();
        var dH    = (mR * 0.200).toNumber();
        var dX    = dCx - dW / 2;
        var dY    = dCy - dH / 2;

        var halfH  = dH.toFloat() / 2.0;
        var bulge  = (mR * 0.038).toFloat();
        var offset = (halfH * halfH - bulge * bulge) / (2.0 * bulge);
        var arcR   = Math.sqrt(offset * offset + halfH * halfH);
        var aStart = Math.atan2(-halfH, offset);
        var aEnd   = Math.atan2( halfH, offset);

        var nArc = 10;
        var pts  = new[nArc * 2];
        var cxR  = (dX + dW).toFloat() - offset;
        var cxL  = dX.toFloat() + offset;
        var cy   = dCy.toFloat();

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

        dc.setColor(0x585858, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);
        dc.setColor(0x404040, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(dX, dY + 1, dX + dW, dY + 1);
        dc.setColor(0x404040, Graphics.COLOR_TRANSPARENT);
        drawOutline(dc, pts);

        dc.setColor(0x00E5CC, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dCx, dCy, Graphics.FONT_TINY, day.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // -------------------------------------------------------------------------
    // Day-of-week arc — subtle dark gray
    // -------------------------------------------------------------------------

    private function drawDayBox(dc as Graphics.Dc, dayOfWeek as Number) as Void {
        var days = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY",
                    "THURSDAY", "FRIDAY", "SATURDAY"];

        var idx = dayOfWeek - 1;
        if (idx < 0 || idx > 6) { idx = 0; }

        var label    = days[idx];
        var n        = label.length();
        var arcR     = mR * 0.780;
        var arcCy    = mCy + mR * 0.390 - 8;
        var spacing  = 3.0;
        var fontBig  = Graphics.FONT_TINY;
        var fontSm   = Graphics.FONT_XTINY;
        var hBig     = dc.getFontHeight(fontBig).toFloat();
        var hSm      = dc.getFontHeight(fontSm).toFloat();
        var deltaR   = (hBig - hSm) / 2.0;

        var charWidths = new[n];
        var totalW = 0.0;
        for (var i = 0; i < n; i++) {
            var fnt = (i == 0) ? fontBig : fontSm;
            var w = dc.getTextWidthInPixels(label.substring(i, i + 1), fnt);
            charWidths[i] = w;
            if (i > 0) { totalW += spacing; }
            totalW += w.toFloat();
        }

        var totalAngle  = totalW / arcR;
        var startAngle  = -(totalAngle / 2.0);
        var ruleExtra   = 10.0 / arcR;
        var ruleStart   = startAngle - ruleExtra;
        var ruleSpan    = totalAngle + ruleExtra * 2.0;

        var rOuter      = arcR + hBig / 2.0 + 2.0;
        var rInner      = arcR - hBig / 2.0 - 2.0;
        var ruleSpanOut  = ruleSpan * 0.88;
        var ruleStartOut = ruleStart + (ruleSpan - ruleSpanOut) / 2.0;
        var steps       = 24;
        dc.setColor(0x303030, Graphics.COLOR_TRANSPARENT);
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

        dc.setColor(0x505050, Graphics.COLOR_TRANSPARENT);
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
    // Hands — cyan-green lume, dark steel borders
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
        var tipDist  = (mR * 0.820).toNumber() - 45;
        var triH     = (mR * 0.153).toNumber();         // arrowhead height (-10%)
        var triHW    = (mR * 0.083).toNumber();         // arrowhead half-width (+15%)
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

        dc.setColor(0x003830, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(steelRot);
        dc.setColor(0x00E5CC, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(lumeRot);
    }

    private function drawMinuteHand(dc as Graphics.Dc, angle as Float) as Void {
        // Minute hand with proportional arrowhead at tip
        var tip       = (mR * 0.775).toNumber();
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
            [-lw,            0],
            [ lw,            0],
            [ lw,           -arrowBase],
            [ (arrowHW - 1), -arrowBase],
            [ 0,             -(tip - 2)],
            [-(arrowHW - 1), -arrowBase],
            [-lw,           -arrowBase],
        ];

        var steelRot = rotateTranslate(steel, angle);
        var lumeRot  = rotateTranslate(lume,  angle);

        dc.setColor(0x003830, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(steelRot);
        dc.setColor(0x00E5CC, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(lumeRot);
    }

    private function drawSecondHand(dc as Graphics.Dc, angle as Float) as Void {
        var tailLen  = mR * 0.171;
        var lollDist = mR * 0.620;
        var lollR    = (mR * 0.030).toNumber();
        var tipLen   = mR * 0.855;
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

        dc.setColor(0x00E5CC, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(tailX, tailY, mCx, mCy);
        dc.fillCircle(tailX, tailY, tailCircR);
        dc.drawLine(mCx, mCy, lollX, lollY);
        dc.fillCircle(lollX, lollY, lollR);
        dc.drawLine(lollX, lollY, tipX, tipY);
        dc.fillCircle(mCx, mCy, pivotR);
    }

    // -------------------------------------------------------------------------
    // Center dot — muted steel
    // -------------------------------------------------------------------------

    private function drawCenterDot(dc as Graphics.Dc) as Void {
        var r = (mR * 0.038).toNumber();
        dc.setColor(0x003830, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(mCx, mCy, r + 1);
        dc.setColor(0x006050, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(mCx, mCy, r);
    }

    // -------------------------------------------------------------------------
    // Helpers
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

    private function drawOutline(dc as Graphics.Dc, pts) as Void {
        var n = pts.size();
        for (var i = 0; i < n; i++) {
            var j = (i + 1) % n;
            dc.drawLine(pts[i][0], pts[i][1], pts[j][0], pts[j][1]);
        }
    }

    function onShow() as Void {}
    function onHide() as Void {}

}
