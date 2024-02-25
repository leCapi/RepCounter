using Toybox.Graphics as Gfx;
using Toybox.WatchUi;
import Toybox.Lang;

class WorkoutDoneView extends WatchUi.View
{
    var m_message as WatchUi.Resource or Null;
    function initialize(ok as Boolean)
    {
        View.initialize();
        if(ok) {
            m_message = WatchUi.loadResource(Rez.Strings.workout_done_msg);
        } else {
            m_message = WatchUi.loadResource(Rez.Strings.workout_done_err);
        }
    }

    function onUpdate(dc as Gfx.Dc) as Void
    {
        View.onUpdate(dc);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(g_XMid, g_YMid, Gfx.FONT_MEDIUM, m_message, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {}
    function onLayout(dc as Gfx.Dc) as Void {}
    function onShow() as Void {}
}

class WorkoutDoneInputDelegate extends WatchUi.InputDelegate
{
    function initialize()
    {
        InputDelegate.initialize();
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

    function onKey(evt)
    {
        var key = evt.getKey();
        switch (key)
        {
            case KEY_ENTER:
            case KEY_ESC:
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                return true;
        }
        return false;
    }

    function onKeyPressed(evt)
    {
        return false;
    }

    function onKeyReleased(evt)
    {
        return false;
    }
}
