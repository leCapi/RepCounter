using Toybox.Application;
using Toybox.Math;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

import Toybox.Lang;

class Hystersis
{
    var m_hysteresisState as Number = THRESHOLD_LOW;
    var m_lastPoint as Number = -1;
    var m_hysteresisCycles as Number = 0;
    var m_soundCounter as Number = 0;

    var m_cal as Calibration;

    var m_settings as Settings;

    function initialize()
    {
        self.m_settings = new Settings();
        self.m_cal = new Calibration();

        self.resetContext();
    }

    function abortCalibration() as Void
    {
        m_cal.abortCalibration();
        self.resetSettings();
    }

    function resetSettings() as Void
    {
        m_settings = new Settings();
    }

    function calibrationTimerCallback() as Void
    {
        m_cal.m_clockCount -= 1;
        if(m_cal.m_clockCount == 0){
            self.stopRecording();
        }
        WatchUi.requestUpdate();
    }

    function calibrate() as Boolean
    {
        m_cal.m_clockCount = maxCalibrationClockCount;
        m_cal.m_state = CALIBRATION_RUNNING;
        if(Attention has :playTone) {
            Attention.playTone(Attention.TONE_START);
        }
        m_cal.m_timerTimeout.start(method(:calibrationTimerCallback), 1000, true);
        return true;
    }

    function stopRecording() as Void
    {
        if (m_cal.m_state != CALIBRATION_RUNNING) {
            return;
        }
        if(Attention has :playTone) {
            Attention.playTone(Attention.TONE_STOP);
        }
        m_cal.m_timerTimeout.stop();
        m_cal.m_lastChunkNeeded = true;
        m_cal.nextCalibrationStep();
    }

    function isRecordingForCalibration() as Boolean
    {
        if (m_cal.m_state == CALIBRATION_RUNNING ||
            m_cal.m_lastChunkNeeded){
            return true;
        }
        return false;
    }

    function startCalibrationProcess() as Void
    {
        if (m_cal.m_dataRecorded == null)
        {
            return;
        }
        m_cal.nextCalibrationStep();
        m_cal.m_timerComputation.start(method(:calibrationProcess), TIMER_COMPUTATION_INTERVAL, true);
    }

    function calibrationProcess() as Void
    {
        switch(m_cal.m_state)
        {
            case CALIBRATION_COMPUTING_QUANTILE:
                self.stepComputeQauntile();
                break;
            case CALIBRATION_COMPUTING_FREE_MEMORY:
                self.stepFreeMemory();
                break;
            case CALIBRATION_COMPUTING_PREPARE_EVALUATIONS:
                self.stepPrepareEvaluations();
                break;
            case CALIBRATION_COMPUTING_EVALUATIONS:
                self.stepComputeEvaluations();
                break;
            case CALIBRATION_COMPUTING_CHOOSE_SETTINGS:
                self.stepComputeChooseSettings();
                break;
            case CALIBRATION_DONE:
                self.stepCalibrationDone();
                break;
        }
    }

    function stepComputeQauntile() as Void
    {
        m_cal.computeQuantiles();
        m_cal.nextCalibrationStep();
    }

    function stepFreeMemory() as Void
    {
        m_cal.m_dataRecordedSorted.free();
        m_cal.nextCalibrationStep();
    }

    function stepPrepareEvaluations() as Void
    {
        m_cal.prepareSettings();
        m_cal.nextCalibrationStep();
    }

    function evaluateSetting() as Boolean
    {
        if (!m_cal.settingLeftToTest()){
            return true;
        }
        m_settings = m_cal.m_settingsList[m_cal.m_settingToTest];
        self.resetContext();
        self.compute(m_cal.m_dataRecorded);
        m_cal.m_settingToTest += 1;
        m_settings.m_score = (m_cal.m_nbRepToCalibrate - m_hysteresisCycles).abs();
        if(!m_cal.settingLeftToTest()) {
            return true;
        }
        return false;
    }

    function stepComputeEvaluations() as Void
    {
        evaluateSetting();
        var res = evaluateSetting();
        if(res) {
            m_cal.nextCalibrationStep();
        }
    }

    function stepComputeChooseSettings() as Void
    {
        var settingsListSize = m_cal.m_settingsList.size();
        if(settingsListSize == 0) {
            return;
        }
        var chosenSettings = m_cal.m_settingsList[0];
        for(var i = 1; i < settingsListSize; i++) {
            var settingCandidate = m_cal.m_settingsList[i];
            if(settingCandidate.isBetter(chosenSettings)){
                chosenSettings = settingCandidate;
            }
        }
        m_settings = chosenSettings;
        chosenSettings.m_selected = true;
        m_cal.dumpSettings();
        m_cal.nextCalibrationStep();
    }

    function stepCalibrationDone() as Void
    {
        m_cal.m_timerComputation.stop();
        self.resetContext();
        m_cal.updateProgressBar();
        m_settings.save();
    }

    function appendCalibrationData(data as Array<Number>) as Void
    {
        m_cal.m_dataRecorded.addAll(data);
        mergesort(data);
        m_cal.m_dataRecordedSorted.insertSortedArray(data);
        if(m_cal.m_lastChunkNeeded){
            m_cal.m_lastChunkNeeded = false;
            self.startCalibrationProcess();
        }
    }

    function resetContext() as Void
    {
        m_hysteresisState = THRESHOLD_LOW;
        m_lastPoint = -1;
        m_hysteresisCycles = 0;
        m_soundCounter = 0;
    }

    function compute(array as Array<Number>) as Void
    {
        var highValue = m_settings.m_highThresholdValue;
        var lowValue = m_settings.m_lowThresholdValue;

        for (var i = 0; i < array.size(); i++ ) {
            var newPoint = array[i];
            if(newPoint == null) {
                continue;
            }
            switch (m_hysteresisState)
            {
                case THRESHOLD_LOW:
                    if(m_lastPoint < highValue &&
                        newPoint >= highValue) {
                        m_hysteresisState = THRESHOLD_HIGH;
                    }
                    break;
                case THRESHOLD_HIGH:
                    if(m_lastPoint > lowValue &&
                        newPoint <= lowValue) {
                        m_hysteresisState = THRESHOLD_LOW;
                        m_hysteresisCycles++;
                    }
                    break;
            }
            m_lastPoint = newPoint;
        }
        if(m_settings.m_soundCounterSize!=0)
        {
            m_soundCounter = m_hysteresisCycles / m_settings.m_soundCounterSize;
        }
    }
}
