using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Application;
using Toybox.Timer;
using Toybox.WatchUi;

class AppDelegate extends WatchUi.BehaviorDelegate
{
    var timerRefreshDisplay;

    function initialize()
    {
        BehaviorDelegate.initialize();
        timerRefreshDisplay = new Timer.Timer();
    }

    function onMenu()
    {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new SettingsMenu(), WatchUi.SLIDE_UP);
        return true;
    }

    function NotifyDisplay()
    {
        WatchUi.requestUpdate();
    }

    function onSelect()
    {
        g_thresholdState = g_thresholdState? THRESHOLD_LOW : THRESHOLD_HIGH;
        if(g_activitySession == null) {
            var recordName = WatchUi.loadResource(Rez.Strings.AppName);
            g_activitySession = ActivityRecording.createSession({ :name => recordName, :sport => ActivityRecording.SPORT_GENERIC, :subSport =>    ActivityRecording.SUB_SPORT_GENERIC });
            g_activitySession.start();
            timerRefreshDisplay.start(method(:NotifyDisplay), 1000, true);
            if(Attention has :playTone)
            {
                Attention.playTone(Attention.TONE_START);
            }
        } else {
            g_activitySession.stop();
            g_activitySession.save();
            timerRefreshDisplay.stop();
            if(Attention has :playTone)
            {
                Attention.playTone(Attention.TONE_STOP);
            }
            g_activitySession = null;
            NotifyDisplay();
        }
        return true;
    }

  function onBack()
  {
      if(g_activitySession != null) {
          if(Attention has :playTone)
          {
              Attention.playTone(Attention.TONE_LAP);
          }
          return true;
      }
      return false;
  }

}