using Toybox.Application;
using Toybox.Timer;
using Toybox.WatchUi;

class AppDelegate extends WatchUi.BehaviorDelegate
{
    var m_refreshTimer;

    function initialize(timer)
    {
        BehaviorDelegate.initialize();
        m_refreshTimer = timer;
        m_refreshTimer.start(method(:NotifyDisplay), g_refreshTimeMain, true);
    }

    function onMenu()
    {
        var app = Application.getApp();
        if(app.m_session.noActivity())
        {
            WatchUi.pushView(new Rez.Menus.MainMenu(), new MainMenuInputDelegate(), WatchUi.SLIDE_LEFT);
        }
        return true;
    }

    function NotifyDisplay()
    {
        WatchUi.requestUpdate();
    }

    function onSelect()
    {
        var app = Application.getApp();
        var sportSession = Application.getApp().m_session;
        if(!sportSession.activityOnGoing()) {
            app.startActivity();
            m_refreshTimer.stop();
            m_refreshTimer.start(method(:NotifyDisplay), g_refreshTimeMain, true);
            NotifyDisplay();
        } else {
            app.pauseActivity();
            callEndMenu();
        }
        return true;
    }

    function onBack()
    {
        var sportSession = Application.getApp().m_session;
        if(sportSession.activityOnGoing()) {
            if(Attention has :playTone) {
                Attention.playTone(Attention.TONE_LAP);
            }
            sportSession.lap();
            return true;
        }
        return false;
    }

    function callEndMenu()
    {
        var menuTitle = WatchUi.loadResource(Rez.Strings.menu_end);
        var resumeKey = WatchUi.loadResource(Rez.Strings.menu_end_resume);
        var saveKey = WatchUi.loadResource(Rez.Strings.menu_end_save);
        var discardKey = WatchUi.loadResource(Rez.Strings.menu_end_discard);
        var menu = new WatchUi.Menu2({:title=>menuTitle});
        var delegate;
        var item1 = new WatchUi.MenuItem(resumeKey, null, :menu_end_resume, null);
        var item2 = new WatchUi.MenuItem(saveKey, null, :menu_end_save, null);
        var item3 = new WatchUi.MenuItem(discardKey, null, :menu_end_discard, null);
        menu.addItem(item1);
        menu.addItem(item2);
        menu.addItem(item3);
        delegate = new EndMenuInputDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}


class EndMenuInputDelegate extends WatchUi.Menu2InputDelegate
{
    function initialize()
    {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item)
    {
        var app = Application.getApp();
        var id = item.getId();
        if(id == :menu_end_resume) {
            app.resumeActivity();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }else if(id == :menu_end_save) {
            var activitySaved = app.saveActivity();
            WatchUi.switchToView(new WorkoutDoneView(activitySaved),
                new WorkoutDoneInputDelegate(),
                WatchUi.SLIDE_IMMEDIATE);
        } else if (id == :menu_end_discard) {
            var message = WatchUi.loadResource(Rez.Strings.menu_end_confirm_discard);
            var dialog = new WatchUi.Confirmation(message);
            WatchUi.pushView(dialog,
                new DiscardConfirmationDelegate(),
                WatchUi.SLIDE_LEFT);
        }
    }

    function onBack()
    {
        var app = Application.getApp();
        app.resumeActivity();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

class DiscardConfirmationDelegate extends WatchUi.ConfirmationDelegate
{
    function initialize()
    {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response)
    {
        var app = Application.getApp();
        if(response == WatchUi.CONFIRM_YES) {
            app.discardActivity();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}