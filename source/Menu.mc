using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi;
using Toybox.Timer;

public const INC_TICK_SETTING = 1;
public const INC_TICK_SETTING_FAST = 20;

var g_threshodCurrentSetting;

enum
{
    TOUCH_PLUS = 0,
    TOUCH_MINUS = 1
}

var g_soundCSIndex;
const g_soundCSPossibleValues = [0, 10, 20, 50, 100, 200];

class EditThresholdView extends WatchUi.View
{
    protected var m_thresholdType;
    protected var m_appSettings;
    protected var m_unit;

    function initialize(thresholdType, settings)
    {
        View.initialize();
        self.m_thresholdType = thresholdType;
        self.m_appSettings = settings;
        self.m_unit = WatchUi.loadResource(Rez.Strings.ciq_unit_acceleration);
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
        dc.drawText(g_XMid, dc.getHeight() - spaceNeeded, fontUnit, m_unit, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);

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
    const INC_UPDATE_INTERVAL_MS = 350;

    protected var m_thresholdType;
    protected var m_timer;
    protected var m_alreadyInc;
    protected var m_alreadyDec;
    protected var m_appSettings;
    protected var m_touchState;


    function initialize(thresholdType, settings)
    {
        InputDelegate.initialize();
        self.m_thresholdType = thresholdType;
        self.m_timer = new Timer.Timer();
        self.m_alreadyInc = false;
        self.m_alreadyDec = false;
        self.m_appSettings = settings;
        self.m_touchState = TOUCH_PLUS;
    }

    function onHide()
    {
        m_timer.stop();
        return true;
    }

    function onTap(evt)
    {
        if (m_touchState == TOUCH_PLUS)
        {
            m_touchState = TOUCH_MINUS;
        } else {
            m_touchState = TOUCH_PLUS;
        }
        return true;
    }

    function onHold(evt)
    {

        switch (m_touchState)
        {
            case TOUCH_PLUS:
                m_timer.stop();
                m_timer.start(method(:incrmentThresholdFast), INC_UPDATE_INTERVAL_MS, true);
                return true;
            case TOUCH_MINUS:
                m_timer.stop();
                m_timer.start(method(:decrmentThresholdFast), INC_UPDATE_INTERVAL_MS, true);
                return true;
        }
        return false;
    }

    function onRelease(evt)
    {
        m_timer.stop();
        return true;
    }

    function onSwipe(evt)
    {
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

        switch (key)
        {
            case KEY_UP:
                m_timer.stop();
                m_timer.start(method(:incrmentThresholdFast), INC_UPDATE_INTERVAL_MS, true);
                return true;
            case KEY_DOWN:
                m_timer.stop();
                m_timer.start(method(:decrmentThresholdFast), INC_UPDATE_INTERVAL_MS, true);
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

class EditSoundCounterView extends WatchUi.View
{
    protected var m_appSettings;
    protected var m_unit;

    function initialize(settings)
    {
        View.initialize();
        self.m_appSettings = settings;
        g_soundCSIndex = 0;
        for (var i = 0; i < g_soundCSPossibleValues.size(); i++)
        {
            if (settings.m_soundCounterSize == g_soundCSPossibleValues[i])
            {
                g_soundCSIndex = i;
                break;
            }
        }
        self.m_unit = WatchUi.loadResource(Rez.Strings.ciq_unit_rep);
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
        dc.drawText(g_XMid, g_YMid, fontThresholdValue, g_soundCSPossibleValues[g_soundCSIndex], Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(g_XMid, dc.getHeight() - spaceNeeded, fontUnit, m_unit, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);

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

class EditSoundCounterDelegate extends WatchUi.InputDelegate
{
    protected var m_appSettings;

    function initialize(settings)
    {
        InputDelegate.initialize();
        self.m_appSettings = settings;
    }

    function onTap(evt)
    {
        increaseSoundCounterSizeAndLoop();
        return true;
    }

    function onHold(evt)
    {
        return false;
    }

    function onHide()
    {
        return false;
    }

    function onRelease(evt)
    {
        return false;
    }

    function onSwipe(evt)
    {
        return false;
    }

    function saveSoundCounterSize(newSoundCounterSize)
    {
        m_appSettings.m_soundCounterSize = g_soundCSPossibleValues[newSoundCounterSize];
    }

    function decreaseSoundCounterSize()
    {
        g_soundCSIndex--;
        if(g_soundCSIndex < 0)
        {
            g_soundCSIndex = 0;
        }
        WatchUi.requestUpdate();
    }

    function increaseSoundCounterSize()
    {
        g_soundCSIndex++;
        if(g_soundCSIndex >= g_soundCSPossibleValues.size())
        {
            g_soundCSIndex = g_soundCSPossibleValues.size() - 1;
        }
        WatchUi.requestUpdate();
    }

    function increaseSoundCounterSizeAndLoop()
    {
        g_soundCSIndex++;
        if(g_soundCSIndex >= g_soundCSPossibleValues.size())
        {
            g_soundCSIndex = 0;
        }
        WatchUi.requestUpdate();
    }

    function onKey(evt)
    {
        var key = evt.getKey();
        switch (key)
        {
            case KEY_ENTER:
                saveSoundCounterSize(g_soundCSIndex);
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                return true;
            case KEY_ESC:
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                return true;
            case KEY_UP:
                increaseSoundCounterSize();
                return true;
            case KEY_DOWN:
                decreaseSoundCounterSize();
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
        } else if (item == :menu_sound_counter) {
            WatchUi.pushView(new EditSoundCounterView(settings),
                new EditSoundCounterDelegate(settings),
                WatchUi.SLIDE_LEFT);
        }
    }
}
