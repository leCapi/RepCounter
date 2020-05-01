using Toybox.Graphics as Gfx;
using Toybox.WatchUi;

const TIMEOUT_AUTO_RETURN = 3000;

class WorkoutDoneView extends WatchUi.View
{
    var m_message;
    function initialize(ok)
    {
        View.initialize();
        if(ok) {
            m_message = WatchUi.loadResource(Rez.Strings.workout_done_msg);
        } else {
            m_message = WatchUi.loadResource(Rez.Strings.workout_done_err);
        }
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
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(g_XMid, g_YMid, Gfx.FONT_MEDIUM, m_message, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);

        return true;
    }

    function onHide()
    {
        return false;
    }
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
