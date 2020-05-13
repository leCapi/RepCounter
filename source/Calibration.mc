using Toybox.Application;
using Toybox.Math;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

const MAX_INT32 =  2147483647;

enum
{
    CALIBRATION_NOT_RUNNING = 0,
    CALIBRATION_RUNNING = 1,
    CALIBRATION_COMPUTING = 2,
    CALIBRATION_COMPUTING_QUANTILE = 3,
    CALIBRATION_COMPUTING_PREPARE_EVALUATIONS = 4,
    CALIBRATION_COMPUTING_EVALUATIONS = 5,
    CALIBRATION_COMPUTING_CHOOSE_SETTINGS = 6,
    CALIBRATION_DONE = 7,
    CALIBRATION_ABORT = 8
}

const maxCalibrationClockCount = 20;

const TIMER_COMPUTATION_INTERVAL = 300;
const INCREMENT_PROGRESS_BAR = Math.ceil(100.0/(CALIBRATION_DONE - CALIBRATION_COMPUTING)).toNumber();

class Calibration
{
    var m_state;
    var m_dataRecorded;
    var m_dataRecordedSorted;
    var m_quantiles;
    var m_lastChunkNeeded;
    var m_timerTimeout;
    var m_timerComputation;
    var m_clockCount;
    var m_nbRepToCalibrate;
    // computation
    var m_computationProgressBar;
    var m_progression;
    var m_settingsList;
    var m_settingToTest;

    function initialize()
    {
        self.m_timerTimeout = new Timer.Timer();
        self.m_timerComputation = new Timer.Timer();
        var processingLabel = WatchUi.loadResource(Rez.Strings.menu_calibration_computing);
        self.m_progression = 0;
        self.m_computationProgressBar = new WatchUi.ProgressBar(processingLabel, 0);
        self.reset();
    }

    function incrementNbCalibrationRep()
    {
        if(m_nbRepToCalibrate < 80) {
            m_nbRepToCalibrate++;
            WatchUi.requestUpdate();
        }
    }

    function decrementNbCalibrationRep()
    {
        if(m_nbRepToCalibrate > 1) {
            m_nbRepToCalibrate--;
            WatchUi.requestUpdate();
        }
    }

    function abortCalibration()
    {
        m_state = CALIBRATION_ABORT;
    }

    function settingLeftToTest()
    {
        if (m_settingToTest < m_settingsList.size()){
            return true;
        }
        return false;
    }

    function updateProgressBar()
    {
        m_progression += INCREMENT_PROGRESS_BAR;
        m_computationProgressBar.setProgress(m_progression);
    }

    function nextCalibrationStep()
    {
        m_state++;
        switch (m_state)
        {
            case CALIBRATION_COMPUTING:
                WatchUi.pushView(m_computationProgressBar,
                    new ProgressBarBehaviorDelegate(),
                    WatchUi.SLIDE_IMMEDIATE);
                break;
            case CALIBRATION_COMPUTING_QUANTILE:
            case CALIBRATION_COMPUTING_PREPARE_EVALUATIONS:
            case CALIBRATION_COMPUTING_EVALUATIONS:
            case CALIBRATION_COMPUTING_CHOOSE_SETTINGS:
                self.updateProgressBar();
                WatchUi.requestUpdate();
                break;
            case CALIBRATION_DONE:
            case CALIBRATION_ABORT:
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }

    }

    function reset()
    {
        m_timerTimeout.stop();
        m_timerComputation.stop();
        m_state = CALIBRATION_NOT_RUNNING;
        m_dataRecorded = new[0];
        m_dataRecordedSorted = new SortedList();
        m_quantiles = new[100];
        m_lastChunkNeeded = false;
        m_clockCount = 0;
        m_nbRepToCalibrate = DEFAULT_CALIBRATION_NUMBER_REPS;
        m_settingsList = new [0];
        m_settingToTest = 0;
        m_progression = 0;
        m_computationProgressBar.setProgress(m_progression);
    }

    function quantileIndex(iq)
    {
        if(iq > 100)
        {
            return MAX_INT32;
        }
        var index = Math.ceil(iq.toFloat()/100 * m_dataRecorded.size()) - 1;
        return index.toNumber();
    }

    function quantileValue(quantile)
    {
        return m_quantiles[quantile - 1];
    }

    function computeQuantiles()
    {
        var quant = 1;
        var quantIndex = quantileIndex(quant);
        var it = m_dataRecordedSorted.m_first;
        var listIndex = 0;
        while(it != null) {
            if(listIndex < quantIndex) {
                it = it.m_next;
                listIndex++;
            } else {
                m_quantiles[quant - 1] = it.m_value;
                quant++;
                quantIndex = quantileIndex(quant);
            }
        }
    }

    function prepareSettings()
    {
        var listLQ = [20, 22, 25];
        var listHQ = [75, 80, 85, 90];
        for(var i = 0; i < listLQ.size(); i++) {
            for(var j = 0; j < listHQ.size(); j++) {
                var lQ = listLQ[i];
                var hQ = listHQ[j];
                var lV = self.quantileValue(lQ);
                var hV = self.quantileValue(hQ);
                var testSettings = new TestSettings(lQ, hQ, lV, hV);
                m_settingsList.add(testSettings);
            }
        }
    }

    function dumpSettings()
    {
        var time = System.getClockTime();
        System.println(
            time.hour.format("%02d") + ":" +
            time.min.format("%02d") + ":" +
            time.sec.format("%02d") +
            " : calibration results"
        );

        for(var i = 0; i<m_settingsList.size(); i++)
        {
            System.println(m_settingsList[i].toString());
        }
    }
}
