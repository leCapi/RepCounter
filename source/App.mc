using Toybox.Application;
using Toybox.FitContributor;
using Toybox.Sensor;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;
using Toybox.Attention;
using Toybox.Graphics;
import Toybox.Lang;


function dumpStats(place as Lang.String) as Void
{
    var stats = System.getSystemStats();
    var clock = System.getTimer();
    System.println(">>> stats " + place + " " + clock);
    System.println("used / total memory : " +
        stats.usedMemory + " / " + stats.totalMemory);
}

public const SAMPLERATE_ACCELERATION = 25;
public const DEFAULT_CALIBRATION_NUMBER_REPS = 10;

var g_fancyFont as Graphics.FontType or Null;

enum
{
    THRESHOLD_LOW = 0,
    THRESHOLD_HIGH = 1
}

enum
{
    STATE_REST = 0,
    STATE_RUN = 1
}

public const FITFIELD_TOTAL_REPETITIONS = 0;
public const FITFIELD_HIGH_THRESHOLD = 10;
public const FITFIELD_LOW_THRESHOLD = 11;

public const FITFIELD_REPETITIONS = 1;
public const FITFIELD_SET_DURATION = 2;
public const FITFIELD_SET_REST = 3;

function convertTimeStampToSecond(timeStamp as Number) as Float
{
    return timeStamp/1000.0;
}

class SportSession
{
    var m_state as Number = STATE_RUN;
    var m_activitySession as FitContributor.ActivityRecording.Session or Null;
    var m_timeStampLastLap as Number = 0;
    var m_setCounter as Number = 0;
    var m_totalNbRep as Number = 0;

    private var m_totalRepField as FitContributor.Field or Null;
    private var m_highThresholdField as FitContributor.Field or Null;
    private var m_lowThresholdField as FitContributor.Field or Null;
    private var m_repField as FitContributor.Field or Null;
    private var m_durationField as FitContributor.Field or Null;
    private var m_restField as FitContributor.Field or Null;

    function initialize()
    {
        reset();
    }

    function reset() as Void
    {
        m_state = STATE_RUN;
        m_activitySession = null;
        m_timeStampLastLap = 0;
        m_setCounter = 1;
        m_totalNbRep = 0;
    }

    function pauseActivity() as Void
    {
        if (m_activitySession != null)
        {
            m_activitySession.stop();
        }
    }

    function resumeActivity() as Void
    {
        if (m_activitySession != null)
        {
            m_activitySession.start();
        }
    }

    function discardActivity() as Void
    {
        m_activitySession.discard();
        self.reset();
    }

    function isRunning() as Boolean
    {
        return m_activitySession != null && m_activitySession.isRecording() &&
            m_state == STATE_RUN;
    }

    function noActivity() as Boolean
    {
        return m_activitySession == null;
    }


    function endRunSet() as Void
    {
        if(m_state == STATE_RUN) {
            self.lap();
        }
    }

    function computeCurrentStepLapTime() as Number
    {
        var info = Activity.getActivityInfo();
        var elapsedTime = -1;
        if (info != null and info.timerTime != null)
        {
            var t = info.timerTime;
            if (t!=null)
            {
                elapsedTime = (t - m_timeStampLastLap);
            }
        }
        return elapsedTime;
    }

    function computeDisplayTime(total as Boolean) as String
    {
        if(m_activitySession == null) {
            return "00:00";
        }
        var elapsedTimeM = 0;
        var elapsedTimeS = 0;
        var elapsedTime;
        if(total) {
            elapsedTime = Activity.getActivityInfo().timerTime / 1000;
        } else {
            elapsedTime = self.computeCurrentStepLapTime() / 1000;
        }
        elapsedTimeM = elapsedTime / 60;
        elapsedTimeS = elapsedTime % 60;

        var formatedDuration = elapsedTimeM.format("%02d") + ":" + elapsedTimeS.format("%02d");

        return formatedDuration;
    }

    function lap() as Void
    {
        var elapsedTime = computeCurrentStepLapTime();
        var elapsedTimeInSecond = convertTimeStampToSecond(elapsedTime);
        var info = Activity.getActivityInfo();
        self.m_timeStampLastLap = info.timerTime;
        var nbRepetitions = Application.getApp().m_hysteresis.m_hysteresisCycles;

        if(m_state == STATE_REST){
            m_restField.setData(elapsedTimeInSecond);
            m_activitySession.addLap();
            m_setCounter++;
        } else if (m_state == STATE_RUN){
            m_durationField.setData(elapsedTimeInSecond);
            m_repField.setData(nbRepetitions);
            m_totalNbRep += nbRepetitions;
            Application.getApp().resetCounterContext();
        }

        m_state = m_state? STATE_REST:STATE_RUN;
    }

    function start() as Void
    {
        var recordName = WatchUi.loadResource(Rez.Strings.AppName);

        m_activitySession = ActivityRecording.createSession(
            {
            :name => recordName,
            :sport => ActivityRecording.SPORT_GENERIC,
            :subSport => ActivityRecording.SUB_SPORT_STRENGTH_TRAINING
            });
        m_totalRepField = m_activitySession.createField("total_repetitions",
            FITFIELD_TOTAL_REPETITIONS,
            FitContributor.DATA_TYPE_UINT16,
            {
                :mesgType => FitContributor.MESG_TYPE_SESSION,
                :units => WatchUi.loadResource(Rez.Strings.ciq_unit_rep)
            });
        m_highThresholdField = m_activitySession.createField("high_threshold",
            FITFIELD_HIGH_THRESHOLD,
            FitContributor.DATA_TYPE_UINT16,
            {
                :mesgType => FitContributor.MESG_TYPE_SESSION,
                :units => WatchUi.loadResource(Rez.Strings.ciq_unit_acceleration)
            });
        m_lowThresholdField = m_activitySession.createField("low_threshold",
            FITFIELD_LOW_THRESHOLD,
            FitContributor.DATA_TYPE_UINT16,
            {
                :mesgType => FitContributor.MESG_TYPE_SESSION,
                :units => WatchUi.loadResource(Rez.Strings.ciq_unit_acceleration)
            });
        m_repField = m_activitySession.createField("repetitions",
            FITFIELD_REPETITIONS,
            FitContributor.DATA_TYPE_UINT16,
            {
                :mesgType => FitContributor.MESG_TYPE_LAP,
                :units => WatchUi.loadResource(Rez.Strings.ciq_unit_rep)
            });
        m_durationField = m_activitySession.createField("duration",
            FITFIELD_SET_DURATION,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType => FitContributor.MESG_TYPE_LAP,
                :units => WatchUi.loadResource(Rez.Strings.ciq_unit_time)
            });
        m_restField = m_activitySession.createField("rest",
            FITFIELD_SET_REST,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType => FitContributor.MESG_TYPE_LAP,
                :units => WatchUi.loadResource(Rez.Strings.ciq_unit_time)
            });

        var settings = Application.getApp().m_hysteresis.m_settings;
        m_highThresholdField.setData(settings.m_highThresholdValue);
        m_lowThresholdField.setData(settings.m_lowThresholdValue);

        m_activitySession.start();
    }

    function save() as Boolean
    {
        self.endRunSet();
        var activitySaved = false;
        self.m_totalRepField.setData(self.m_totalNbRep);

        if (m_activitySession)
        {
            var elapsedTime = computeCurrentStepLapTime();
            var elapsedTimeInSecond = convertTimeStampToSecond(elapsedTime);
            m_restField.setData(elapsedTimeInSecond);
            m_activitySession.stop();
            activitySaved = m_activitySession.save();
            self.reset();
            Application.getApp().resetCounterContext();
        }

        return activitySaved;
    }

    function activityOnGoing() as Boolean
    {
        return m_activitySession != null;
    }
}

class App extends Application.AppBase
{
    var m_hysteresis as Hystersis;
    var m_session as SportSession;
    var m_lastHearthRate as Number or Null;
    var m_vibeLap as Array<Attention.VibeProfile>;

    function initialize()
    {
        AppBase.initialize();
        g_fancyFont = WatchUi.loadResource(Rez.Fonts.fancyFont);

        Sensor.registerSensorDataListener(method(:onAccelerometerData),
            {
            :period => 1,
            :accelerometer =>
                {
                :enabled => true,
                    :sampleRate => SAMPLERATE_ACCELERATION,
                    :includePower => true
                }
            }
        );
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensorEvent));

        m_hysteresis = new Hystersis();
        m_session = new SportSession();
        m_lastHearthRate = null;
        m_vibeLap = [new Attention.VibeProfile(100, 2000)];
    }

    function pauseActivity() as Void
    {
        if(Attention has :playTone){
            Attention.playTone(Attention.TONE_STOP);
        }
        m_session.pauseActivity();
    }

    function resumeActivity() as Void
    {
        if(Attention has :playTone){
            Attention.playTone(Attention.TONE_START);
        }
        m_session.resumeActivity();
    }

    function saveActivity() as Boolean
    {
        var activitySaved = m_session.save();
        if(Attention has :playTone && !activitySaved){
            Attention.playTone(Attention.TONE_ERROR);
        }
        return activitySaved;
    }

    function discardActivity() as Void
    {
        if(Attention has :playTone){
            Attention.playTone(Attention.TONE_RESET);
        }
        m_hysteresis.resetContext();
        m_session.discardActivity();
    }

    function startActivity() as Void
    {
        if(Attention has :playTone){
            Attention.playTone(Attention.TONE_START);
        }
        m_session.start();
    }

    function resetCounterContext() as Void
    {
        m_hysteresis.resetContext();
    }

    function onAccelerometerData(data) as Void
    {
        if(data has :accelerometerData and data.accelerometerData != null) {
            if(m_session.m_activitySession != null && m_session.isRunning()) {
                var soundCounter = m_hysteresis.m_soundCounter;
                m_hysteresis.compute(data.accelerometerData.power);
                if (soundCounter < m_hysteresis.m_soundCounter)
                {
                    if(Attention has :playTone) {
                      Attention.playTone(Attention.TONE_LOUD_BEEP);
                  } else if (Attention has :vibrate) {
                      Attention.vibrate(m_vibeLap);
                  }
                }
            } else if(m_hysteresis.isRecordingForCalibration()){
                m_hysteresis.appendCalibrationData(data.accelerometerData.power);
            }
        }
    }

    function onSensorEvent(data) as Void
    {
        if(data has :heartRate and data.heartRate != null) {
            m_lastHearthRate = data.heartRate;
        }
        else {
            m_lastHearthRate = null;
        }
    }

    function getInitialView()
    {
        var timerMainView = new Timer.Timer();
        return [ new AppView(timerMainView), new AppDelegate(timerMainView) ];
    }

    function onStop(state) as Void
    {
        m_hysteresis.m_settings.save();
    }
}
