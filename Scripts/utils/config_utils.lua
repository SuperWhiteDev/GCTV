local configUtils = { }

function configUtils.GetFeatureSetting(section, setting)
    local featuresSettings = JsonRead("feature_settings.json")
    
    return featuresSettings[section][setting]
end

function configUtils.SetFeatureSetting(section, setting, value)
    local featuresSettings = JsonRead("feature_settings.json")
    
    featuresSettings[section][setting] = value

    JsonSave("feature_settings.json", featuresSettings)
end

function configUtils.GetGCTSetting()
    
end

function configUtils.SetGCTSetting()
    
end

return configUtils