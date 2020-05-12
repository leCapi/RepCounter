using Toybox.Application;
using Toybox.Math;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class Hystersis
{
    var m_hysteresisState;
    var m_lastPoint;
    var m_hysteresisCycles;

    var m_cal;

    var m_settings;

    function initialize()
    {
        self.m_settings = new Settings();
        self.m_cal = new Calibration();

        self.resetContext();
    }

    function abortCalibration()
    {
        m_cal.abortCalibration();
        self.resetSettings();
    }

    function resetSettings()
    {
        m_settings = new Settings();
    }

    function calibrationTimerCallback()
    {
        m_cal.m_clockCount -= 1;
        if(m_cal.m_clockCount == 0){
            self.stopRecording();
        }
        WatchUi.requestUpdate();
    }

    function calibrate()
    {
        m_cal.m_clockCount = maxCalibrationClockCount;
        m_cal.m_state = CALIBRATION_RUNNING;
        m_cal.m_dataRecorded = new [0];
        if(Attention has :playTone) {
            Attention.playTone(Attention.TONE_START);
        }
        m_cal.m_timerTimeout.start(method(:calibrationTimerCallback), 1000, true);
        return true;
    }

    function stopRecording()
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

    function isRecordingForCalibration()
    {
        if (m_cal.m_state == CALIBRATION_RUNNING ||
            m_cal.m_lastChunkNeeded){
            return true;
        }
        return false;
    }

    function startCalibrationProcess()
    {
        if (m_cal.m_dataRecorded == null)
        {
            return;
        }
        var indexQ75 = m_cal.quantileIndex(75);
        var indexQ25 = m_cal.quantileIndex(25);
        var nbHighEltNeeded = m_cal.m_dataRecorded.size() - indexQ75;
        m_cal.prepareTopValues(nbHighEltNeeded);
        m_cal.nextCalibrationStep();
        m_cal.m_timerComputation.start(method(:calibrationProcess), TIMER_COMPUTATION_INTERVAL, true);
    }

    function calibrationProcess()
    {
        switch(m_cal.m_state)
        {
            case CALIBRATION_COMPUTING_HIGH:
                self.stepSortHighData();
                break;
            case CALIBRATION_COMPUTING_PREPARE_BOT:
                self.stepPrepareSortLowData();
                break;
            case CALIBRATION_COMPUTING_BOT:
                self.stepSortLowData();
                break;
            case CALIBRATION_COMPUTING_STATS:
                self.stepComputeStats();
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

    function stepSortHighData()
    {
        var res = m_cal.selectTopValues();
        if(res) {
            m_cal.nextCalibrationStep();
        }
    }

    function stepPrepareSortLowData()
    {
        var indexQ25 = m_cal.quantileIndex(25);
        m_cal.prepareBotValues(indexQ25 + 1);
        m_cal.nextCalibrationStep();
    }

    function stepSortLowData()
    {
        var res = m_cal.selectBotValues();
        if(res) {
            m_cal.nextCalibrationStep();
        }
    }

    function stepComputeStats()
    {
        m_cal.prepareSettings();
        m_cal.nextCalibrationStep();
    }

    function evaluateSetting()
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

    function stepComputeEvaluations()
    {
        evaluateSetting();
        var res = evaluateSetting();
        if(res) {
            m_cal.nextCalibrationStep();
        }
    }

    function stepComputeChooseSettings()
    {
        var settingsListSize = m_cal.m_settingsList.size();
        if(settingsListSize == 0){
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

    function stepCalibrationDone()
    {
        self.resetContext();
        m_cal.m_timerComputation.stop();
    }

    function appendCalibrationData(data)
    {
        m_cal.m_dataRecorded.addAll(data);
        if(m_cal.m_lastChunkNeeded){
            m_cal.m_lastChunkNeeded = false;
            self.startCalibrationProcess();
        }
    }

    function resetContext()
    {
        m_hysteresisState = THRESHOLD_LOW;
        m_lastPoint = -1;
        m_hysteresisCycles = 0;
    }

    function compute(array)
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
    }
}