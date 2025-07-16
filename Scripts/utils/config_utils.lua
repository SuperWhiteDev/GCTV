-- This utility script provides functions for managing configuration settings
-- stored in JSON files, specifically for feature-specific and general GCTV settings.

local config_utils = {} -- Create a table to hold our utility functions.

-- Constants for the names of the configuration files.
FEATURE_SETTINGS_FILE = "feature_settings.json" -- File for feature-specific settings.
GCT_CONFIG_FILE = "config.json"                 -- File for general GCTV configuration.

--- Retrieves a specific feature setting from the feature_settings.json file.
-- @param section string The main section name (e.g., "Hotkeys", "VehicleOptions").
-- @param setting string The specific setting name within the section (e.g., "VehicleBoostKey").
-- @returns any The value of the setting, or nil if the section or setting is not found.
function config_utils.get_feature_setting(section, setting)
    -- Attempt to read the entire feature settings file.
    local features_settings = JsonRead(FEATURE_SETTINGS_FILE)
    
    -- Check if the file was read successfully and contains the section and setting.
    if features_settings ~= nil and features_settings[section] ~= nil then
        return features_settings[section][setting]
    else
        return nil -- Return nil if file, section, or setting is not found.
    end
end

--- Sets a specific feature setting and saves it to the feature_settings.json file.
-- If the file or section does not exist, it will be created.
-- @param section string The main section name.
-- @param setting string The specific setting name.
-- @param value any The value to set for the setting.
function config_utils.set_feature_setting(section, setting, value)
    -- Attempt to read the existing feature settings.
    local features_settings = JsonRead(FEATURE_SETTINGS_FILE)
    
    -- If the file was read successfully, update the existing settings.
    if features_settings ~= nil then
        -- Ensure the section exists before attempting to set the setting.
        if features_settings[section] == nil then
            features_settings[section] = {}
        end
        features_settings[section][setting] = value
        JsonSave(FEATURE_SETTINGS_FILE, features_settings) -- Save the updated settings.
    else 
        -- If the file does not exist or is empty, create a new structure for it.
        -- Note: This creates a new table with only the specified section and setting.
        -- If other sections exist, they would be overwritten if JsonRead returns nil due to file absence.
        -- A more robust approach might involve initializing an empty table and then adding the section/setting.
        JsonSave(FEATURE_SETTINGS_FILE, { [section] = { [setting] = value } })
    end
end

--- Retrieves a general GCTV setting from the config.json file.
-- @param setting string The specific setting name.
-- @returns any The value of the setting, or nil if the setting is not found.
function config_utils.get_gct_setting(setting)
    -- Attempt to read the entire general configuration file.
    local gct_settings = JsonRead(GCT_CONFIG_FILE)
    
    -- Check if the file was read successfully and contains the setting.
    if gct_settings ~= nil then
        return gct_settings[setting]
    else
        return nil -- Return nil if file or setting is not found.
    end
end

--- Sets a general GCTV setting and saves it to the config.json file.
-- If the file does not exist, it will be created.
-- @param setting string The specific setting name.
-- @param value any The value to set for the setting.
function config_utils.set_gct_setting(setting, value)
    -- Attempt to read the existing general configuration.
    local gct_settings = JsonRead(GCT_CONFIG_FILE)
    
    -- If the file was read successfully, update the existing settings.
    if gct_settings ~= nil then
        gct_settings[setting] = value
        JsonSave(GCT_CONFIG_FILE, gct_settings) -- Save the updated settings.
    else 
        -- If the file does not exist or is empty, create a new structure for it.
        -- Note: This creates a new table with only the specified setting.
        JsonSave(GCT_CONFIG_FILE, { [setting] = value })
    end 
end

return config_utils -- Return the utility table for use in other scripts.
