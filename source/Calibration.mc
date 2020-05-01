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
    CALIBRATION_COMPUTING_HIGH = 3,
    CALIBRATION_COMPUTING_PREPARE_BOT = 4,
    CALIBRATION_COMPUTING_BOT = 5,
    CALIBRATION_COMPUTING_STATS = 6,
    CALIBRATION_COMPUTING_EVALUATIONS = 7,
    CALIBRATION_COMPUTING_CHOOSE_SETTINGS = 8,
    CALIBRATION_DONE = 9,
    CALIBRATION_ABORT = 10
}

const maxCalibrationClockCount = 20;

const TIMER_COMPUTATION_INTERVAL = 300;
const SORT_INTERVAL_SIZE = 5;
const INCREMENT_PROGRESS_BAR = Math.ceil(100.0/(CALIBRATION_DONE - CALIBRATION_COMPUTING)).toNumber();

class Calibration
{
    var m_state;
    var m_dataRecorded;
    var m_lastChunkNeeded;
    var m_timerTimeout;
    var m_timerComputation;
    var m_clockCount;
    var m_nbRepToCalibrate;
    // computation
    var m_computationProgressBar;
    var m_progression;
    var m_sortIntervalSize;
    var m_nbSortedLow;
    var m_nbSortedHigh;
    var m_sortedHighValues;
    var m_sortedLowValues;
    var m_startSelection;
    var m_settingsList;
    var m_settingToTest;

    function initialize()
    {
        self.m_timerTimeout = new Timer.Timer();
        self.m_timerComputation = new Timer.Timer();
        var processingLabel = WatchUi.loadResource(Rez.Strings.menu_calibration_computing);
        self.m_progression = 0;
        self.m_computationProgressBar = new WatchUi.ProgressBar(processingLabel, 0);
        self.m_sortIntervalSize = SORT_INTERVAL_SIZE;
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
            case CALIBRATION_COMPUTING_HIGH:
            case CALIBRATION_COMPUTING_PREPARE_BOT:
            case CALIBRATION_COMPUTING_BOT:
            case CALIBRATION_COMPUTING_STATS:
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
        m_dataRecorded = null;
        m_lastChunkNeeded = false;
        m_clockCount = 0;
        m_nbRepToCalibrate = DEFAULT_CALIBRATION_NUMBER_REPS;
        m_nbSortedLow = 0;
        m_nbSortedHigh = 0;
        m_sortedHighValues = null;
        m_sortedLowValues = null;
        m_startSelection = 0;
        m_settingsList = new [0];
        m_settingToTest = 0;
        m_progression = 0;
        m_computationProgressBar.setProgress(m_progression);
    }

    function quantileIndex(iq)
    {
        var index = Math.round(iq.toFloat()/100 * m_dataRecorded.size()) - 1;
        return index.toNumber();
    }

    function prepareTopValues(nbElt)
    {
        m_nbSortedHigh = nbElt;
        m_sortedHighValues = new [m_nbSortedHigh+1];
        m_sortedHighValues[0] = MAX_INT32;
        m_startSelection = 1;
    }

    function selectTopValues()
    {
        var nbValues = m_dataRecorded.size();
        var max = m_startSelection + m_sortIntervalSize;
        max = max > m_nbSortedHigh ? m_nbSortedHigh : max;
        var i = 0;
        for(i = m_startSelection; i <= max; i++){
            var previousTopVal = m_sortedHighValues[i - 1];
            m_sortedHighValues[i] = -1;
            var nbRepetitions = 0;
            for (var j = 0; j < nbValues; j++) {
                var currentVal = m_dataRecorded[j];
                if (currentVal < previousTopVal) {
                    if(m_sortedHighValues[i] < currentVal){
                        m_sortedHighValues[i] = currentVal;
                        nbRepetitions = 1;
                    } else if(m_sortedHighValues[i] == currentVal) {
                        nbRepetitions++;
                    }
                }
            }
            for (var k = 1; k < nbRepetitions; k++) {
                var prevValMult = m_sortedHighValues[i];
                i++;
                if (i > m_nbSortedHigh) {
                    return true;
                }
                m_sortedHighValues[i] = prevValMult;
            }
        }
        if((i - 1) > max) {
            m_startSelection += (i - 1 - max);
        }
        m_startSelection += m_sortIntervalSize + 1;
        if (i > m_nbSortedHigh) {
            return true;
        }
        return false;
    }

    function prepareBotValues(nbElt)
    {
        m_nbSortedLow = nbElt;
        m_sortedLowValues = new [m_nbSortedLow + 1];
        m_sortedLowValues[0] = -1;
        m_startSelection = 1;
    }

    function selectBotValues()
    {
        var nbValues = m_dataRecorded.size();
        var max = m_startSelection + m_sortIntervalSize;
        max = max > m_nbSortedLow ? m_nbSortedLow : max;
        var i = 0;
        for(i = m_startSelection; i <= max; i++){
            var previousLowVal = m_sortedLowValues[i - 1];
            m_sortedLowValues[i] = MAX_INT32;
            var nbRepetitions = 0;
            for (var j = 0; j < nbValues; j++) {
                var currentVal = m_dataRecorded[j];
                if (currentVal > previousLowVal) {
                    if(m_sortedLowValues[i] > currentVal){
                        m_sortedLowValues[i] = currentVal;
                        nbRepetitions = 1;
                    } else if(m_sortedLowValues[i] == currentVal) {
                        nbRepetitions++;
                    }
                }
            }
            for (var k = 1; k < nbRepetitions; k++) {
                var prevValMult = m_sortedLowValues[i];
                i++;
                if (i > m_nbSortedLow) {
                    return true;
                }
                m_sortedLowValues[i] = prevValMult;
            }
        }
        if((i - 1) > max) {
            m_startSelection += (i - 1 - max);
        }
        m_startSelection += m_sortIntervalSize + 1;
        if (i > m_nbSortedLow) {
            return true;
        }
        return false;
    }

    function prepareSettings()
    {
        var m_sortedHighValues;
        var m_sortedLowValues;
        var listLQ = [20, 22, 25];
        var listHQ = [75, 80, 85, 90];
        var indexQ75 = self.quantileIndex(75);
        for(var i = 0; i < listLQ.size(); i++) {
            for(var j = 0; j < listHQ.size(); j++) {
                var lQ = listLQ[i];
                var hQ = listHQ[j];
                var lQIndex = self.quantileIndex(lQ);
                var hQIndex = self.quantileIndex(hQ);
                var lV = self.m_sortedLowValues[lQIndex + 1];
                var hV = self.m_sortedHighValues[hQIndex - indexQ75 + 1];
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
