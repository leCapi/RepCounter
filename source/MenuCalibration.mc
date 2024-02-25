using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.WatchUi;

import Toybox.Lang;

class MenuCalibrationView extends WatchUi.View
{
    var m_textInstruction1 as WatchUi.TextArea;
    var m_textNbCalRepConfigured as WatchUi.TextArea;
    var m_textInstruction2 as WatchUi.TextArea;
    var m_instructionRules1 as WatchUi.Resource;
    var m_instructionRules2 as WatchUi.Resource;

    var m_unitRepetition as WatchUi.Resource;;

    var m_hyst as Hystersis;

    function initialize()
    {
        View.initialize();
        m_hyst = Application.getApp().m_hysteresis;

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

    function display_calibration_not_running(dc as Gfx.Dc) as Void
    {
        m_textNbCalRepConfigured.setText(m_hyst.m_cal.m_nbRepToCalibrate.format("%02d") +
            " " + m_unitRepetition);
        m_textNbCalRepConfigured.draw(dc);
        m_textInstruction1.draw(dc);
    }

    function display_calibration_running(dc as Gfx.Dc) as Void
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

    function onUpdate(dc as Gfx.Dc) as Void
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
        }
    }

    function onLayout(dc as Gfx.Dc) as Void{}
    function onShow() as Void {}
}

class MenuCalibrationInputDelegate extends WatchUi.InputDelegate
{
    var m_hyst as Hystersis;

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

    function start_calibration() as Void
    {
        Application.getApp().m_hysteresis.calibrate();
        WatchUi.requestUpdate();
    }

    function stop_calibration() as Void
    {
        Application.getApp().m_hysteresis.stopRecording();
        WatchUi.requestUpdate();
    }

    function handleKeyCalibrationNotRunning(key as Number) as Boolean
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

    function handleKeyCalibrationRunning(key as Number) as Boolean
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

    function onKey(evt)
    {
        var key = evt.getKey();

        switch (m_hyst.m_cal.m_state)
        {
            case CALIBRATION_NOT_RUNNING:
                return handleKeyCalibrationNotRunning(key);
            case CALIBRATION_RUNNING:
                return handleKeyCalibrationRunning(key);
        }

        return false;
    }
}

class ProgressBarBehaviorDelegate extends WatchUi.BehaviorDelegate
{
    var m_hyst as Hystersis;

    function initialize()
    {
        BehaviorDelegate.initialize();
        m_hyst = Application.getApp().m_hysteresis;
    }

    function onBack() as Boolean
    {
        if (m_hyst.m_cal.m_state == CALIBRATION_DONE){
            m_hyst.m_cal.reset();
        } else {
            m_hyst.abortCalibration();
        }
        return true;
    }
}
