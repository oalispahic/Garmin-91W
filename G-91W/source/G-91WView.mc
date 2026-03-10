import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class G_91WView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Load fonts here
    }

    function onUpdate(dc as Dc) as Void {
        // TODO: Full drawing logic will go here
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_LARGE,
            "HELLO RETRO",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function onPartialUpdate(dc as Dc) as Void {
        // TODO: Seconds-only update
    }

    function onEnterSleep() as Void {
        // Low power mode entered
    }

    function onExitSleep() as Void {
        // Active mode — request full update
        WatchUi.requestUpdate();
    }

}
