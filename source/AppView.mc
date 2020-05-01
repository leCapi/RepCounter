using Toybox.Activity;
using Toybox.Graphics as Gfx;
using Toybox.Sensor;
using Toybox.Time;
using Toybox.WatchUi as Ui;

class AppView extends Ui.View
{

    var timer_label;
    var counter_label;
    var set_label;

    function initialize()
    {
        View.initialize();
        timer_label = Ui.loadResource(Rez.Strings.timer_label);
        set_label = Ui.loadResource(Rez.Strings.set_label);
    }

    function onLayout(dc)
    {
        return false;
    }

    function onShow()
    {
      return false;
    }

    function onUpdate(dc)
    {
        View.onUpdate(dc);
        dc.clear();

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        var xTinyFH = dc.getFontHeight(Gfx.FONT_XTINY);
        var tinyFH = dc.getFontHeight(Gfx.FONT_SMALL);
        var xMid = dc.getWidth() / 2;
        var yMid = dc.getHeight() / 2;
        var topMargin = 20;

        // dispaly time
        var timeInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var timeNow = Lang.format("$1$:$2$", [timeInfo.hour.format("%02d"), timeInfo.min.format("%02d")]);
        dc.drawText(xMid, dc.getWidth()-2*xTinyFH, Gfx.FONT_XTINY, timeNow, Gfx.TEXT_JUSTIFY_CENTER);

        // display counter
        var repCounterHeight = dc.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT);
        dc.drawText(xMid, topMargin, Gfx.FONT_NUMBER_THAI_HOT, g_repCounter.format("%03d"), Gfx.TEXT_JUSTIFY_CENTER);

        // display threshold
        var thresholdX = 20;
        var distanceFromMid = 8;
        var thresholdIndicatorSize = 6;
        var thresholdY;
        switch(g_thresholdState)
        {
            case THRESHOLD_HIGH:
                thresholdY = yMid - distanceFromMid - thresholdIndicatorSize;
                break;
            case THRESHOLD_LOW:
                thresholdY = yMid + distanceFromMid;
                break;
        }
        dc.drawRectangle(thresholdX, thresholdY, 8, 8);

        dc.drawLine(0, yMid, dc.getWidth(), yMid);

        // display timer and set label
        var x = 55;
        var y = yMid + 8 ;
        dc.drawText(x, y, Gfx.FONT_XTINY, timer_label, Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(dc.getWidth() - x, y, Gfx.FONT_XTINY, set_label, Gfx.TEXT_JUSTIFY_RIGHT);
        y += xTinyFH;
        // display timer and set
        var elapsedTimeM = 0;
        var elapsedTimeS = 0;
        if (g_activitySession != null) {
            var info = Activity.getActivityInfo();
            var elapsedTime = info.timerTime/1000;
            elapsedTimeM = elapsedTime/60;
            elapsedTimeS = elapsedTime % 60;
        }
        var formatedDuration = elapsedTimeM.format("%02d") + ":" + elapsedTimeS.format("%02d");
        dc.drawText(x, y, Gfx.FONT_SMALL, formatedDuration, Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(dc.getWidth() - x, y, Gfx.FONT_SMALL, g_setCounter, Gfx.TEXT_JUSTIFY_RIGHT);
        return true;
    }

    function onHide()
    {
    }

}
