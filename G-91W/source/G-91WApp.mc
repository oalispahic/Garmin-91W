import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class G_91WApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
    }

    function onStop(state as Lang.Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new G_91WView()];
    }
}