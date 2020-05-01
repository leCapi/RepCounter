using Toybox.Activity;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.WatchUi as Ui;

const NO_HR_DETECTED = "-";

var g_XMid;
var g_YMid;
var g_refreshTimeMain = 1000;

class AppView extends Ui.View
{
    var m_refreshTimer;

    var m_timer_label;
    var m_set_label;
    var m_rest_msg;

    var m_topMargin;

    function initialize(timer)
    {
        View.initialize();
        m_refreshTimer = timer;
        m_timer_label = Ui.loadResource(Rez.Strings.timer_label);
        m_set_label = Ui.loadResource(Rez.Strings.set_label);
        m_rest_msg = Ui.loadResource(Rez.Strings.rest_msg);
        m_topMargin = 15;
    }

    function NotifyDisplay()
    {
        WatchUi.requestUpdate();
    }

    function onLayout(dc)
    {
        g_XMid = dc.getWidth() / 2;
        g_YMid = dc.getHeight() / 2;
        return true;
    }

    function onShow()
    {
        m_refreshTimer.start(method(:NotifyDisplay), g_refreshTimeMain, true);
        return true;
    }

    function onHide()
    {
        m_refreshTimer.stop();
        return false;
    }

    function displayTime(dc)
    {
        var timeInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var timeNow = Lang.format("$1$:$2$", [timeInfo.hour.format("%02d"), timeInfo.min.format("%02d")]);
        var font = Gfx.FONT_TINY;
        var margin = dc.getFontAscent(font);
        dc.drawText(g_XMid, dc.getHeight()- margin, font, timeNow, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function displayHR(dc)
    {
        var app = Application.getApp();
        var font = Gfx.FONT_TINY;
        var margin = dc.getFontAscent(font);
        var hr = app.m_lastHearthRate == null? NO_HR_DETECTED : app.m_lastHearthRate;
        dc.drawText(g_XMid, margin, font, hr, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function displayCounter(dc)
    {
        var app = Application.getApp();
        var repCounter = app.m_hysteresis.m_hysteresisCycles;
        var font = g_fancyFont;
        var margin = 48;

        dc.drawText(g_XMid, g_YMid/2 + margin, font, repCounter.format("%03d"), Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function displayRest(dc)
    {
        var app = Application.getApp();
        var fontValues = Gfx.FONT_NUMBER_MILD;
        var totRep  = app.m_session.m_totalNbRep;
        var timerTotal = app.m_session.computeDisplayTime(true);
        var margin = dc.getFontAscent(fontValues);
        var yPos = g_YMid/2 - 5;

        dc.drawText(g_XMid, yPos, fontValues, totRep.format("%04d"), Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(g_XMid, yPos + margin, fontValues, timerTotal, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);

        var fontRest = Gfx.FONT_XTINY;
        dc.drawText(g_XMid, g_YMid, fontRest, m_rest_msg, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function displayHysteresisThreshold(dc)
    {
        var app = Application.getApp();
        var thresholdState = app.m_hysteresis.m_hysteresisState;
        var thresholdX = 20;
        var distanceFromMid = 8;
        var thresholdIndicatorSize = 6;
        var thresholdY;
        switch(thresholdState)
        {
            case THRESHOLD_HIGH:
                thresholdY = g_YMid - distanceFromMid - thresholdIndicatorSize;
                break;
            case THRESHOLD_LOW:
                thresholdY = g_YMid + distanceFromMid;
                break;
        }
        dc.drawRectangle(thresholdX, thresholdY, 8, 8);
    }

    function displayTimerAndSet(dc)
    {
        var app = Application.getApp();
        var sportSession = app.m_session;
        var setCounter = sportSession.m_setCounter;
        var timer;
        if(app.m_session.m_state == STATE_RUN)
        {
            timer = sportSession.computeDisplayTime(false);
        }else{
            timer = sportSession.computeDisplayTime(false);
        }

        var horizontalMargin = 55;
        var fontLabel = Gfx.FONT_XTINY;
        var fontValues = Gfx.FONT_SMALL;
        var yLabel = g_YMid + dc.getFontAscent(fontLabel) + 12;
        var yValues = yLabel + dc.getFontAscent(fontValues);

        dc.drawText(horizontalMargin, yLabel, fontLabel, m_timer_label,
            Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(dc.getWidth() - horizontalMargin, yLabel, fontLabel, m_set_label,
            Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(horizontalMargin, yValues, Gfx.FONT_SMALL, timer,
            Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(dc.getWidth() - horizontalMargin, yValues, Gfx.FONT_SMALL, setCounter,
            Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function onUpdate(dc)
    {
        View.onUpdate(dc);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        var app = Application.getApp();
        var sportSession = app.m_session;

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        var xTinyFH = dc.getFontHeight(Gfx.FONT_XTINY);

        displayTime(dc);

        var sessionState = app.m_session.m_state;
        var repCounterHeight = dc.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT);
        if(sessionState == STATE_RUN) {
            displayCounter(dc);
            displayHysteresisThreshold(dc);
        } else {
            displayRest(dc);
        }

        var xEndLine = 35;
        dc.drawLine(0, g_YMid, xEndLine, g_YMid);
        dc.drawLine(dc.getWidth(), g_YMid, dc.getWidth()- xEndLine, g_YMid);

        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        displayHR(dc);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        displayTimerAndSet(dc);

        return true;
    }


}
