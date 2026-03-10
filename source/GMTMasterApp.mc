import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GMTMasterApp extends Application.AppBase {

    private var mView as GMTMasterView?;

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        mView = new GMTMasterView();
        return [mView];
    }

    function onSleep() as Void {
        if (mView != null) { (mView as GMTMasterView).setSleepMode(true); }
    }

    function onWake() as Void {
        if (mView != null) { (mView as GMTMasterView).setSleepMode(false); }
    }

}

function getApp() as GMTMasterApp {
    return Application.getApp() as GMTMasterApp;
}
