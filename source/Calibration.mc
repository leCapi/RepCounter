using Toybox.Application;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi;

import Toybox.Lang;

const MAX_INT32 =  2147483647;

enum
{
    CALIBRATION_NOT_RUNNING = 0,
    CALIBRATION_RUNNING = 1,
    CALIBRATION_COMPUTING = 2,
    CALIBRATION_COMPUTING_QUANTILE = 3,
    CALIBRATION_COMPUTING_FREE_MEMORY = 4,
    CALIBRATION_COMPUTING_PREPARE_EVALUATIONS = 5,
    CALIBRATION_COMPUTING_EVALUATIONS = 6,
    CALIBRATION_COMPUTING_CHOOSE_SETTINGS = 7,
    CALIBRATION_DONE = 8,
    CALIBRATION_ABORT = 9
}

const maxCalibrationClockCount = 20;

const TIMER_COMPUTATION_INTERVAL = 300;
const INCREMENT_PROGRESS_BAR = Math.ceil(100.0/(CALIBRATION_DONE - CALIBRATION_COMPUTING)).toNumber();

class Calibration
{
    var m_state as Number = CALIBRATION_NOT_RUNNING;
    var m_dataRecorded as Array<Number> = new Array<Number>[0];
    var m_dataRecordedSorted as SortedList or Null;
    var m_quantiles as Array<Number> or Null;
    var m_lastChunkNeeded;
    var m_timerTimeout as Timer.Timer;
    var m_timerComputation as Timer.Timer;
    var m_clockCount as Number;
    var m_nbRepToCalibrate as Number;
    // computation
    var m_computationProgressBar as WatchUi.ProgressBar;
    var m_textCalibrationDone as WatchUi.Resource;
    var m_processingLabel as WatchUi.Resource;
    var m_progression as Number;
    var m_settingsList as Array<TestSettings>;
    var m_settingToTest as Number;

    function initialize()
    {
        self.m_timerTimeout = new Timer.Timer();
        self.m_timerComputation = new Timer.Timer();
        self.m_processingLabel = WatchUi.loadResource(Rez.Strings.menu_calibration_computing);
        self.m_progression = 0;
        self.m_computationProgressBar = new WatchUi.ProgressBar(m_processingLabel, 0);
        self.m_textCalibrationDone = WatchUi.loadResource(Rez.Strings.menu_calibration_ok);
        self.reset();
    }

    function incrementNbCalibrationRep() as Void
    {
        if(m_nbRepToCalibrate < 80) {
            m_nbRepToCalibrate++;
            WatchUi.requestUpdate();
        }
    }

    function decrementNbCalibrationRep() as Void
    {
        if(m_nbRepToCalibrate > 1) {
            m_nbRepToCalibrate--;
            WatchUi.requestUpdate();
        }
    }

    function abortCalibration() as Void
    {
        self.reset();
    }

    function settingLeftToTest() as Boolean
    {
        if (m_settingToTest < m_settingsList.size()){
            return true;
        }
        return false;
    }

    function updateProgressBar() as Void
    {
        if(m_state == CALIBRATION_DONE) {
            m_progression = 100;
            m_computationProgressBar.setDisplayString(m_textCalibrationDone);
        } else {
            m_progression += INCREMENT_PROGRESS_BAR;
        }
        m_computationProgressBar.setProgress(m_progression);
    }

    function nextCalibrationStep() as Void
    {
        m_state++;
        switch (m_state)
        {
            case CALIBRATION_COMPUTING:
                WatchUi.switchToView(m_computationProgressBar,
                    new ProgressBarBehaviorDelegate(),
                    WatchUi.SLIDE_IMMEDIATE);
                break;
            case CALIBRATION_COMPUTING_QUANTILE:
            case CALIBRATION_COMPUTING_PREPARE_EVALUATIONS:
            case CALIBRATION_COMPUTING_EVALUATIONS:
            case CALIBRATION_COMPUTING_CHOOSE_SETTINGS:
                self.updateProgressBar();
                break;
            case CALIBRATION_DONE:
            case CALIBRATION_ABORT:
                break;
        }

    }

    function reset() as Void
    {
        m_timerTimeout.stop();
        m_timerComputation.stop();
        m_state = CALIBRATION_NOT_RUNNING;
        m_dataRecorded = new[0];
        m_dataRecordedSorted = new SortedList();
        m_quantiles = new Array<Number>[100];
        m_lastChunkNeeded = false;
        m_clockCount = 0;
        m_nbRepToCalibrate = DEFAULT_CALIBRATION_NUMBER_REPS;
        m_settingsList = new Array<TestSettings>[0];
        m_settingToTest = 0;
        m_progression = 0;
        m_computationProgressBar.setProgress(m_progression);
        m_computationProgressBar.setDisplayString(m_processingLabel);
    }

    function quantileIndex(iq as Number) as Number
    {
        if(iq > 100)
        {
            return MAX_INT32;
        }
        var index = Math.ceil(iq.toFloat()/100 * m_dataRecorded.size()) - 1;
        return index.toNumber();
    }

    function quantileValue(quantile as Number) as Number
    {
        if (m_quantiles == null)
        {
            return -1;
        }
        else
        {
            return m_quantiles[quantile - 1];
        }
    }

    function computeQuantiles() as Void
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

    function prepareSettings() as Void
    {
        var listLQ = [14, 16, 18, 20, 22, 24, 26, 28, 30, 32];
        var listHQ = [78, 80, 82, 84, 86, 88, 90, 92, 94];
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

    function dumpSettings() as Void
    {
        var today = new Time.Moment(Time.today().value());
        var now = Time.Gregorian.info(today, Time.FORMAT_SHORT);
        var time = System.getClockTime();

        System.println(
            now.year + "." + now.month.format("%02d") + "." + now.day.format("%02d") + " " +
            time.hour.format("%02d") + ":" +
            time.min.format("%02d") + ":" +
            time.sec.format("%02d") +
            " : calibration results"
        );
        System.println("> quantiles of recorded data (mG) :");
        System.println(
            "q1:" + self.quantileValue(1) +
            " q10:" + self.quantileValue(10) +
            " q20:" + self.quantileValue(20) +
            " q30:" + self.quantileValue(30) +
            " q40:" + self.quantileValue(40) +
            " q50:" + self.quantileValue(50) +
            " q60:" + self.quantileValue(60) +
            " q70:" + self.quantileValue(70) +
            " q80:" + self.quantileValue(80) +
            " q90:" + self.quantileValue(90) +
            " q100:" + self.quantileValue(100)
        );

        System.println("> QuantileSpread/ValueSpread/Score (*best)");
        for(var i = 0; i<m_settingsList.size(); i++)
        {
            System.println(m_settingsList[i].toString());
        }
    }
}
