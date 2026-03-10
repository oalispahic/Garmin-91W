import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Activity;

class G_91WView extends WatchUi.WatchFace {

    // Font resources
    var fontLarge = null;
    var fontSmall = null;
    var fontClean = null;

    // Colors
    const COLOR_BG = 0x000000;
    const COLOR_TEXT = 0xFFF5E1;
    const COLOR_RED = 0xCC0000;
    const COLOR_BLUE = 0x0055AA;
    const COLOR_GOLD = 0xCCAA55;
    const COLOR_GRID = 0x666666;

    // Track power mode
    var isAwake = true;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Load fonts with fallbacks
        try {
            fontLarge = WatchUi.loadResource(Rez.Fonts.bold_time);
        } catch (e) {
            fontLarge = Graphics.FONT_NUMBER_HOT;
        }
        try {
            fontSmall = WatchUi.loadResource(Rez.Fonts.bold_else);
        } catch (e) {
            fontSmall = Graphics.FONT_MEDIUM;
        }
   
        

        // Final fallback if still null
        if (fontLarge == null) { fontLarge = Graphics.FONT_NUMBER_HOT; }
        if (fontSmall == null) { fontSmall = Graphics.FONT_MEDIUM; }
        if (fontClean == null) { fontClean = Graphics.FONT_TINY; }
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Ensure fonts are loaded
        if (fontLarge == null) { fontLarge = Graphics.FONT_NUMBER_HOT; }
        if (fontSmall == null) { fontSmall = Graphics.FONT_MEDIUM; }
        if (fontClean == null) { fontClean = Graphics.FONT_TINY; }

        // Clear screen
        dc.setColor(COLOR_TEXT, COLOR_BG);
        dc.clear();

        // Get current time
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var seconds = clockTime.sec;

        // 12h/24h format
        var deviceSettings = System.getDeviceSettings();
        if (!deviceSettings.is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            } else if (hours == 0) {
                hours = 12;
            }
        }

        // ===========================
        // ZONE 1: Top bar (Day - GARMIN - Date)
        // ===========================
        var topBarY = (h * 0.14).toNumber();

        dc.setColor(COLOR_TEXT, Graphics.COLOR_TRANSPARENT);

        // Day of week and month using FORMAT_SHORT (returns integers)
        var now = Time.now();
        var gregInfo = Gregorian.info(now, Time.FORMAT_SHORT);

        var dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];

        var dayStr = "---";
        var dow = gregInfo.day_of_week as Number;
        if (dow >= 1 && dow <= 7) {
            dayStr = dayNames[dow - 1] as String;
        }

        var monthStr = "---";
        var mon = gregInfo.month as Number;
        if (mon >= 1 && mon <= 12) {
            monthStr = monthNames[mon - 1] as String;
        }

        var dayNum = gregInfo.day as Number;
        var dateStr = dayNum.format("%d") + " " + monthStr;

        // Day of week (left)
        dc.drawText((w * 0.22).toNumber(), topBarY, fontClean, dayStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // GARMIN (center)
        dc.drawText((w * 0.50).toNumber(), topBarY, fontClean, "GARMIN",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Date (right)
        dc.drawText((w * 0.78).toNumber(), topBarY, fontClean, dateStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ===========================
        // ZONE 2: Top color bands
        // ===========================
        var bandsTopY = (h * 0.21).toNumber();
        var bandHeight = 3;
        var bandMargin = 1;
        var bandLeft = (w * 0.12).toNumber();
        var bandRight = (w * 0.88).toNumber();
        var bandWidth = bandRight - bandLeft;

        dc.setColor(COLOR_RED, COLOR_RED);
        dc.fillRectangle(bandLeft, bandsTopY, bandWidth, bandHeight);

        dc.setColor(COLOR_BLUE, COLOR_BLUE);
        dc.fillRectangle(bandLeft, bandsTopY + bandHeight + bandMargin, bandWidth, bandHeight);

        dc.setColor(COLOR_GOLD, COLOR_GOLD);
        dc.fillRectangle(bandLeft, bandsTopY + (bandHeight + bandMargin) * 2, bandWidth, bandHeight);

        // ===========================
        // ZONE 3: Main time (HH:MM + seconds)
        // ===========================
        var timeY = (h * 0.38).toNumber();

        var timeStr = hours.format("%02d") + ":" + minutes.format("%02d");

        dc.setColor(COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText((w * 0.45).toNumber(), timeY, fontLarge, timeStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Seconds (superscript right)
        if (isAwake) {
            var secStr = seconds.format("%02d");
            dc.drawText((w * 0.82).toNumber(), timeY - (h * 0.04).toNumber(), fontSmall, secStr,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // ===========================
        // ZONE 4: Bottom color bands (mirrored)
        // ===========================
        var bandsBottomY = (h * 0.53).toNumber();

        dc.setColor(COLOR_GOLD, COLOR_GOLD);
        dc.fillRectangle(bandLeft, bandsBottomY, bandWidth, bandHeight);

        dc.setColor(COLOR_BLUE, COLOR_BLUE);
        dc.fillRectangle(bandLeft, bandsBottomY + bandHeight + bandMargin, bandWidth, bandHeight);

        dc.setColor(COLOR_RED, COLOR_RED);
        dc.fillRectangle(bandLeft, bandsBottomY + (bandHeight + bandMargin) * 2, bandWidth, bandHeight);

        // ===========================
        // ZONE 5: Bottom data grid (2x2)
        // ===========================
        var gridTopY = (h * 0.61).toNumber();
        var gridBottomY = (h * 0.85).toNumber();
        var gridMidY = ((gridTopY + gridBottomY) / 2).toNumber();
        var gridMidX = (w / 2).toNumber();

        // Grid lines
        dc.setColor(COLOR_GRID, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(gridMidX, gridTopY, gridMidX, gridBottomY);
        dc.drawLine(bandLeft, gridMidY, bandRight, gridMidY);

        // Get activity data safely
        var distanceKm = 0.0;
        var steps = 0;
        var calories = 0;
        var heartRate = 0;

        var actInfo = ActivityMonitor.getInfo();
        if (actInfo != null) {
            if (actInfo.distance != null) {
                distanceKm = (actInfo.distance as Number).toFloat() / 100000.0;
            }
            if (actInfo.steps != null) {
                steps = actInfo.steps as Number;
            }
            if (actInfo.calories != null) {
                calories = actInfo.calories as Number;
            }
        }

        // Heart rate
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null) {
            if (activityInfo.currentHeartRate != null) {
                heartRate = activityInfo.currentHeartRate as Number;
            }
        }

        dc.setColor(COLOR_TEXT, Graphics.COLOR_TRANSPARENT);

        // Cell positions
        var leftCellX = ((bandLeft + gridMidX) / 2).toNumber();
        var rightCellX = ((gridMidX + bandRight) / 2).toNumber();
        var row1Y = ((gridTopY + gridMidY) / 2).toNumber();
        var row2Y = ((gridMidY + gridBottomY) / 2).toNumber();

        // Top-left: Distance
        dc.drawText(leftCellX, row1Y - 6, fontSmall, distanceKm.format("%.2f"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(leftCellX, row1Y + 14, fontClean, "KM",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Top-right: Steps
        dc.drawText(rightCellX, row1Y - 6, fontSmall, steps.format("%d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(rightCellX, row1Y + 14, fontClean, "STEPS",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Bottom-left: Heart Rate
        var hrDisplay = heartRate > 0 ? heartRate.format("%d") : "--";
        dc.drawText(leftCellX, row2Y - 6, fontSmall, hrDisplay,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(leftCellX, row2Y + 14, fontClean, "HR",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Bottom-right: Calories
        dc.drawText(rightCellX, row2Y - 6, fontSmall, calories.format("%d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(rightCellX, row2Y + 14, fontClean, "KCAL",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onPartialUpdate(dc as Dc) as Void {
        if (fontSmall == null) { return; }

        var w = dc.getWidth();
        var h = dc.getHeight();
        var clockTime = System.getClockTime();
        var secStr = clockTime.sec.format("%02d");

        var clipX = (w * 0.72).toNumber();
        var clipY = (h * 0.28).toNumber();
        var clipW = (w * 0.20).toNumber();
        var clipH = (h * 0.16).toNumber();

        dc.setClip(clipX, clipY, clipW, clipH);
        dc.setColor(COLOR_BG, COLOR_BG);
        dc.fillRectangle(clipX, clipY, clipW, clipH);

        dc.setColor(COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText((w * 0.82).toNumber(), (h * 0.34).toNumber(), fontSmall, secStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.clearClip();
    }

    function onEnterSleep() as Void {
        isAwake = false;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        isAwake = true;
        WatchUi.requestUpdate();
    }
}