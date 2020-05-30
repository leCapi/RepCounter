using Toybox.Application;
using Toybox.Math;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class Settings
{
    var m_highThresholdValue;
    var m_lowThresholdValue;
    var m_soundCounterSize;

    function initialize()
    {
        m_lowThresholdValue = Application.Properties.getValue("low_threshold");
        m_highThresholdValue = Application.Properties.getValue("high_threshold");
        m_soundCounterSize = Application.Properties.getValue("sound_counter");
    }

    function save()
    {
        var app = Application.getApp();
        app.setProperty("high_threshold", m_highThresholdValue);
        app.setProperty("low_threshold", m_lowThresholdValue);
        app.setProperty("sound_counter", m_soundCounterSize);
    }
}

class TestSettings extends Settings
{
    var m_hQuantile;
    var m_lQuantile;
    var m_score;
    var m_selected;

    function initialize(lQ, hQ, lV, hV)
    {
        Settings.initialize();
        self.m_lowThresholdValue = lV;
        self.m_highThresholdValue = hV;
        self.m_lQuantile= lQ;
        self.m_hQuantile= hQ;
        self.m_score= -1;
        self.m_selected = false;
    }

    function isBetter(otherTestSettings)
    {
        if(m_score < otherTestSettings.m_score) {
            return true;
        }
        else if(m_score > otherTestSettings.m_score) {
            return false;
        }
        // score are equals below this line
        var spread = m_hQuantile - m_lQuantile;
        var spreadOther = otherTestSettings.m_hQuantile - otherTestSettings.m_lQuantile;
        if(spread > spreadOther) {
            return true;
        }
        else if(spread < spreadOther) {
            return false;
        }
        // both score and spread below this line
        if(m_highThresholdValue >= otherTestSettings.m_highThresholdValue) {
            return true;
        } else {
            return false;
        }
    }

    function toString()
    {
        var strValue = m_hQuantile.toString() + "-" + m_lQuantile.toString() + "/" +
            m_highThresholdValue.toString() + "-" + m_lowThresholdValue.toString() + "/" +
            m_score;
        if(m_selected) {
            strValue += " *";
        }
        return strValue;
    }
}