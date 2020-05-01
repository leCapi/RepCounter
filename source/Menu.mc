using Toybox.Graphics as Gfx;
using Toybox.WatchUi;
using Toybox.System;

class EditThresholdView extends WatchUi.View
{
    var m_thresholdType;

    function initialize(thresholdType)
    {
        View.initialize();
        self.m_thresholdType = thresholdType;
        g_threshodCurrentSetting = loadThreshold();
    }

    function loadThreshold()
    {
        var value = 0;
        switch(self.m_thresholdType)
        {
            case THRESHOLD_LOW:
                value = g_lowThresholdValue;
                break;
            default:
            case THRESHOLD_HIGH:
                value = g_highThresholdValue;
        }
        return value;
    }

    function onUpdate(dc)
    {
        View.onUpdate(dc);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        var xMid = dc.getWidth() / 2;
        var yMid = dc.getHeight() / 2;

        dc.drawText(xMid, yMid, Gfx.FONT_NUMBER_THAI_HOT, g_threshodCurrentSetting, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
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
    var m_thresholdType;

    function initialize(thresholdType)
    {
        InputDelegate.initialize();
        self.m_thresholdType = thresholdType;
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
                g_lowThresholdValue = newValue;
                break;
            case THRESHOLD_HIGH:
                g_highThresholdValue = newValue;
        }
    }

    function incrementThreshold(inc)
    {
        g_threshodCurrentSetting += inc;
    }

    function decrementThreshold(inc)
    {
        g_threshodCurrentSetting -= inc;
    }

    function onKey(evt)
    {
        var key = evt.getKey();
        switch (key)
        {
            case KEY_ENTER:
                saveThreshold(g_threshodCurrentSetting);
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                return true;
            case KEY_ESC:
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                return true;
            case KEY_UP:
                self.incrementThreshold(50);
                WatchUi.requestUpdate();
                return true;
            case KEY_DOWN:
                self.decrementThreshold(50);
                WatchUi.requestUpdate();
                return true;
        }
        return false;
    }

    function onKeyPressed(evt)
    {
        return false;
    }

    function onKeyReleased(evt) {
        return false;
    }


}

class SettingsMenu extends WatchUi.MenuInputDelegate
{
    function initialize()
    {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item)
    {
        if (item == :menu_high_threshold){
            WatchUi.pushView(new EditThresholdView(THRESHOLD_HIGH),
                new EditThresholdInputDelegate(THRESHOLD_HIGH), WatchUi.SLIDE_LEFT);
        }else if (item == :menu_low_threshold){
            WatchUi.pushView(new EditThresholdView(THRESHOLD_LOW),
                new EditThresholdInputDelegate(THRESHOLD_LOW), WatchUi.SLIDE_LEFT);
        }
    }
}
