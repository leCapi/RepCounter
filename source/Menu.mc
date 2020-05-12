using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi;
using Toybox.Timer;

public const INC_TICK_SETTING = 1;
public const INC_TICK_SETTING_FAST = 20;

var g_threshodCurrentSetting;

class EditThresholdView extends WatchUi.View
{
    protected var m_thresholdType;
    protected var m_appSettings;

    function initialize(thresholdType, settings)
    {
        View.initialize();
        self.m_thresholdType = thresholdType;
        self.m_appSettings = settings;
        g_threshodCurrentSetting = loadThreshold();
    }

    function loadThreshold()
    {
        var value = 0;
        switch(self.m_thresholdType)
        {
            case THRESHOLD_LOW:
                value = m_appSettings.m_lowThresholdValue;
                break;
            default:
            case THRESHOLD_HIGH:
                value = m_appSettings.m_highThresholdValue;
        }
        return value;
    }

    function onUpdate(dc)
    {
        View.onUpdate(dc);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        var fontThresholdValue = Gfx.FONT_NUMBER_THAI_HOT;
        var fontUnit = Gfx.FONT_LARGE;
        var spaceNeeded = dc.getFontHeight(fontUnit);
        dc.drawText(g_XMid, g_YMid, fontThresholdValue, g_threshodCurrentSetting, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(g_XMid, dc.getHeight() - spaceNeeded, fontUnit, "mG", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);

        return true;
    }

    function onLayout(dc)
    {
        return false;
    }

    function onShow()
    {
      return false;
    }
}

class EditThresholdInputDelegate extends WatchUi.InputDelegate
{
    protected var m_thresholdType;
    protected var m_timer;
    protected var m_alreadyInc;
    protected var m_alreadyDec;
    protected var m_appSettings;

    function initialize(thresholdType, settings)
    {
        InputDelegate.initialize();
        self.m_thresholdType = thresholdType;
        self.m_timer = new Timer.Timer();
        self.m_alreadyInc = false;
        self.m_alreadyDec = false;
        self.m_appSettings = settings;
    }

    function onTap(evt) {
        return false;
    }

    function onHold(evt) {
        return false;
    }

    function onRelease(evt) {
        return false;
    }

    function onSwipe(evt) {
        return false;
    }

    function saveThreshold(newValue)
    {
        switch(self.m_thresholdType)
        {
            case THRESHOLD_LOW:
                m_appSettings.m_lowThresholdValue = newValue;
                break;
            case THRESHOLD_HIGH:
                m_appSettings.m_highThresholdValue = newValue;
        }
    }

    function incrementThreshold(inc)
    {
        g_threshodCurrentSetting += inc;
    }

    function decrementThreshold(inc)
    {
        g_threshodCurrentSetting -= inc;
        if (g_threshodCurrentSetting < 0) {
            g_threshodCurrentSetting = 0;
        }
    }

    function incrmentThresholdFast()
    {
        incrementThreshold(INC_TICK_SETTING_FAST);
        m_alreadyInc = true;
        WatchUi.requestUpdate();
    }

    function decrmentThresholdFast()
    {
        decrementThreshold(INC_TICK_SETTING_FAST);
        m_alreadyDec = true;
        WatchUi.requestUpdate();
    }

    function onKey(evt)
    {
        var key = evt.getKey();
        switch (key)
        {
            case KEY_ENTER:
                saveThreshold(g_threshodCurrentSetting);
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                return true;
            case KEY_ESC:
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                return true;
        }
        return false;
    }

    function onKeyPressed(evt)
    {
        var key = evt.getKey();
        var g_refreshTimeMain = 350;
        switch (key)
        {
            case KEY_UP:
                m_timer.stop();
                m_timer.start(method(:incrmentThresholdFast), g_refreshTimeMain, true);
                return true;
            case KEY_DOWN:
                m_timer.stop();
                m_timer.start(method(:decrmentThresholdFast), g_refreshTimeMain, true);
                return true;
        }
        return false;
    }

    function onKeyReleased(evt)
    {
        var key = evt.getKey();
        switch (key)
        {
            case KEY_UP:
                m_timer.stop();
                if (!m_alreadyInc) {
                    self.incrementThreshold(INC_TICK_SETTING);
                    WatchUi.requestUpdate();
                }
                m_alreadyInc = false;
                return true;
            case KEY_DOWN:
                m_timer.stop();
                if (!m_alreadyDec) {
                    self.decrementThreshold(INC_TICK_SETTING);
                    WatchUi.requestUpdate();
                }
                m_alreadyDec = false;
                return true;
        }
        return false;
    }
}

class MainMenuInputDelegate extends WatchUi.MenuInputDelegate
{
    function initialize()
    {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item)
    {
        var app = Application.getApp();
        var settings = app.m_hysteresis.m_settings;
        if (item == :menu_calibration){
            WatchUi.pushView(new MenuCalibrationView(),
                new MenuCalibrationInputDelegate(),
                WatchUi.SLIDE_IMMEDIATE);
        }
        else if (item == :menu_high_threshold){
            WatchUi.pushView(new EditThresholdView(THRESHOLD_HIGH, settings),
                new EditThresholdInputDelegate(THRESHOLD_HIGH, settings),
                WatchUi.SLIDE_LEFT);
        }else if (item == :menu_low_threshold){
            WatchUi.pushView(new EditThresholdView(THRESHOLD_LOW, settings),
                new EditThresholdInputDelegate(THRESHOLD_LOW, settings),
                WatchUi.SLIDE_LEFT);
        }
    }
}