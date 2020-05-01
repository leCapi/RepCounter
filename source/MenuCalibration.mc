using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.WatchUi;

class MenuCalibrationView extends WatchUi.View
{
    var m_textInstruction1;
    var m_textNbCalRepConfigured;
    var m_textInstruction2;
    var m_instructionRules1;
    var m_instructionRules2;
    var m_textComputing;
    var m_textCalibrationDone;
    var m_textCalibrationAbort;

    var m_unitRepetition;

    var m_hyst;

    function initialize()
    {
        View.initialize();
        m_hyst = Application.getApp().m_hysteresis;

        m_textCalibrationDone = WatchUi.loadResource(Rez.Strings.menu_calibration_ok);
        m_textCalibrationAbort = WatchUi.loadResource(Rez.Strings.menu_calibration_abort);

        var instructions1 = WatchUi.loadResource(Rez.Strings.menu_calibration_instructions_1);
        m_textInstruction1 = new WatchUi.TextArea({
            :text=>instructions1,
            :color=>Graphics.COLOR_WHITE,
            :font=>[Graphics.FONT_SMALL, Graphics.FONT_XTINY],
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER,
            :width=>180,
            :height=>200,
            :justification=>Gfx.TEXT_JUSTIFY_VCENTER|Gfx.TEXT_JUSTIFY_CENTER
        });
        m_textNbCalRepConfigured = new WatchUi.TextArea({
            :text=>"",
            :color=>Graphics.COLOR_WHITE,
            :font=>[Graphics.FONT_SMALL, Graphics.FONT_XTINY],
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM,
            :width=>60,
            :height=>40,
            :justification=>Gfx.TEXT_JUSTIFY_VCENTER|Gfx.TEXT_JUSTIFY_CENTER
        });
        m_unitRepetition = WatchUi.loadResource(Rez.Strings.ciq_unit_rep);
        var instructions2 = WatchUi.loadResource(Rez.Strings.menu_calibration_instructions_2);
        m_textInstruction2 = new WatchUi.TextArea({
            :text=>instructions2,
            :color=>Graphics.COLOR_WHITE,
            :font=>[Graphics.FONT_XTINY],
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM,
            :width=>200,
            :height=>100,
            :justification=>Gfx.TEXT_JUSTIFY_VCENTER|Gfx.TEXT_JUSTIFY_CENTER
        });
        m_instructionRules1 = WatchUi.loadResource(Rez.Strings.menu_calibration_instructions_3);
        m_instructionRules2 = WatchUi.loadResource(Rez.Strings.menu_calibration_instructions_4);
    }

    function display_calibration_not_running(dc)
    {
        m_textNbCalRepConfigured.setText(m_hyst.m_cal.m_nbRepToCalibrate.format("%02d") +
            " " + m_unitRepetition);
        m_textNbCalRepConfigured.draw(dc);
        m_textInstruction1.draw(dc);
    }

    function display_calibration_running(dc)
    {
        var instructionRules = m_instructionRules1 +
            m_hyst.m_cal.m_nbRepToCalibrate + m_instructionRules2;
        var textInstructionRules = new WatchUi.TextArea({
            :text=>instructionRules,
            :color=>Graphics.COLOR_WHITE,
            :font=>[Graphics.FONT_XTINY],
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_TOP,
            :width=>200,
            :height=>100,
            :justification=>Gfx.TEXT_JUSTIFY_VCENTER|Gfx.TEXT_JUSTIFY_CENTER
        });
        textInstructionRules.draw(dc);
        m_textInstruction2.draw(dc);
        var time = m_hyst.m_cal.m_clockCount;
        dc.drawText(g_XMid,
            g_YMid,
            Gfx.FONT_NUMBER_THAI_HOT,
            time,
            Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function display_calibration_done(dc)
    {
        dc.drawText(g_XMid,
            g_YMid,
            Gfx.FONT_LARGE,
            m_textCalibrationDone,
            Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function display_calibration_abort(dc)
    {
        dc.drawText(g_XMid,
            g_YMid,
            Gfx.FONT_LARGE,
            m_textCalibrationAbort,
            Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function onUpdate(dc)
    {
        View.onUpdate(dc);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        switch (m_hyst.m_cal.m_state)
        {
            case CALIBRATION_NOT_RUNNING:
                display_calibration_not_running(dc);
                break;
            case CALIBRATION_RUNNING:
                display_calibration_running(dc);
                break;
            case CALIBRATION_COMPUTING:
            case CALIBRATION_COMPUTING_HIGH:
            case CALIBRATION_COMPUTING_BOT:
            case CALIBRATION_COMPUTING_STATS:
            case CALIBRATION_COMPUTING_EVALUATIONS:
                // handled by a progressBar view
                break;
            case CALIBRATION_DONE:
                display_calibration_done(dc);
                break;
            case CALIBRATION_ABORT:
                display_calibration_abort(dc);
                break;
        }

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

class MenuCalibrationInputDelegate extends WatchUi.InputDelegate
{
    var m_hyst;

    function initialize()
    {
        InputDelegate.initialize();
        m_hyst = Application.getApp().m_hysteresis;
    }

    function onTap(evt)
    {
        return false;
    }

    function onHold(evt)
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

    function start_calibration()
    {
        Application.getApp().m_hysteresis.calibrate();
        WatchUi.requestUpdate();
    }

    function stop_calibration()
    {
        Application.getApp().m_hysteresis.stopRecording();
        WatchUi.requestUpdate();
    }

    function handleKeyCalibrationNotRunning(key)
    {
        switch (key)
        {
            case KEY_ENTER:
                self.start_calibration();
                return true;
            case KEY_ESC:
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                return true;
            case KEY_UP:
                m_hyst.m_cal.incrementNbCalibrationRep();
                return true;
            case KEY_DOWN:
                m_hyst.m_cal.decrementNbCalibrationRep();
                return true;
        }
        return false;
    }

    function handleKeyCalibrationRunning(key)
    {
        switch (key)
        {
            case KEY_ENTER:
                self.stop_calibration();
            case KEY_ESC:
                return true;
        }
        return false;
    }

    function handleKeyCalibrationComputing(key)
    {
        return true;
    }

    function handleKeyCalibrationDone(key)
    {
        switch (key)
        {
            case KEY_ENTER:
            case KEY_ESC:
                m_hyst.m_cal.reset();
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                return true;
        }
        return false;
    }

    function onKey(evt)
    {
        var key = evt.getKey();

        switch (m_hyst.m_cal.m_state)
        {
            case CALIBRATION_NOT_RUNNING:
                return handleKeyCalibrationNotRunning(key);
            case CALIBRATION_RUNNING:
                return handleKeyCalibrationRunning(key);
            case CALIBRATION_COMPUTING:
            case CALIBRATION_COMPUTING_HIGH:
            case CALIBRATION_COMPUTING_PREPARE_BOT:
            case CALIBRATION_COMPUTING_BOT:
            case CALIBRATION_COMPUTING_STATS:
            case CALIBRATION_COMPUTING_EVALUATIONS:
                return handleKeyCalibrationComputing(key);
            case CALIBRATION_DONE:
            case CALIBRATION_ABORT:
                return handleKeyCalibrationDone(key);
        }

        return false;
    }
}

class ProgressBarBehaviorDelegate extends WatchUi.BehaviorDelegate
{
    var m_hyst;

    function initialize()
    {
        BehaviorDelegate.initialize();
        m_hyst = Application.getApp().m_hysteresis;
    }

    function onBack()
    {
        m_hyst.abortCalibration();
        return true;
    }
}
