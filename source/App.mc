using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Sensor;

public const SAMPLERATE_ACCELERATION = 25;

var g_setCounter;
var g_repCounter;

var g_highThresholdValue;
var g_lowThresholdValue;
enum
{
    THRESHOLD_LOW = 0,
    THRESHOLD_HIGH = 1
}

var g_thresholdState;
var g_threshodCurrentSetting;

var g_activitySession;

class App extends Application.AppBase
{
    var accelerationPower;
    function onSensorData(data)
    {
        if(data has :accelerometerData and data.accelerometerData != null)
        {
            self.accelerationPower = data.accelerometerData.power;
        }
    }

    function initialize()
    {
        AppBase.initialize();

        Sensor.registerSensorDataListener(method(:onSensorData),
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

        g_lowThresholdValue = Application.Properties.getValue("low_threshold");
        g_highThresholdValue = Application.Properties.getValue("high_threshold");

        g_setCounter = 1;
        g_repCounter = 0;
        g_thresholdState = THRESHOLD_LOW;
    }

    function getInitialView()
    {
        return [ new AppView(), new AppDelegate() ];
    }


}
