/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

// Constants for configuration file names.
const FEATURE_SETTINGS_FILE = "feature_settings.json";
const GCT_CONFIG_FILE = "config.json";

/**
 * A utility object for managing configuration settings stored in JSON files.
 * Provides methods to get and set feature-specific and general GCTV settings.
 */
const configUtils = {
    /**
     * Internal helper to read JSON data from a file using the global `fs` module.
     * @param {string} filePath - The path to the JSON configuration file.
     * @returns {object} The parsed JSON data, or an empty object if the file
     * does not exist, is empty, or contains invalid JSON.
     */
    _readJsonFile(filePath) {
        if (!fs.fileExists(filePath)) {
            return {};
        }
        try {
            const data = fs.readFile(filePath);
            if (data === null || data === undefined || data === "") {
                return {}; // Return empty object if file is empty
            }
            return JSON.parse(data);
        } catch (e) {
            console.error(`Error: Could not read or decode JSON from ${filePath}. Returning empty config.`, e);
            return {};
        }
    },

    /**
     * Internal helper to save data to a JSON file using the global `fs` module.
     * @param {string} filePath - The path to the JSON configuration file.
     * @param {object} data - The JavaScript object to save as JSON.
     */
    _saveJsonFile(filePath, data) {
        try {
            // Convert the JavaScript object to a JSON string, pretty-printed with 4 spaces.
            const jsonString = JSON.stringify(data, null, 4);
            fs.writeFile(filePath, jsonString);
        } catch (e) {
            console.error(`Error: Could not save JSON to ${filePath}:`, e);
        }
    },

    /**
     * Retrieves a specific feature setting from the feature_settings.json file.
     * @param {string} section - The main section name (e.g., "Hotkeys").
     * @param {string} setting - The specific setting name within the section (e.g., "VehicleBoostKey").
     * @returns {any} The value of the setting, or undefined if not found.
     */
    getFeatureSetting(section, setting) {
        const featuresSettings = this._readJsonFile(FEATURE_SETTINGS_FILE);
        // Use optional chaining (?.) for safe access to nested properties.
        return featuresSettings[section]?.[setting];
    },

    /**
     * Sets a specific feature setting and saves it to the feature_settings.json file.
     * Creates the section or file if they do not exist.
     * @param {string} section - The main section name.
     * @param {string} setting - The specific setting name.
     * @param {any} value - The value to set.
     */
    setFeatureSetting(section, setting, value) {
        const featuresSettings = this._readJsonFile(FEATURE_SETTINGS_FILE);
        if (!featuresSettings[section]) {
            featuresSettings[section] = {}; // Create section if it doesn't exist
        }
        featuresSettings[section][setting] = value;
        this._saveJsonFile(FEATURE_SETTINGS_FILE, featuresSettings);
        console.log(`Feature setting '${section}.${setting}' set to '${value}'.`);
    },

    /**
     * Retrieves a general GCTV setting from the config.json file.
     * @param {string} setting - The specific setting name.
     * @returns {any} The value of the setting, or undefined if not found.
     */
    getGctSetting(setting) {
        const gctSettings = this._readJsonFile(GCT_CONFIG_FILE);
        return gctSettings[setting];
    },

    /**
     * Sets a general GCTV setting and saves it to the config.json file.
     * Creates the file if it does not exist.
     * @param {string} setting - The specific setting name.
     * @param {any} value - The value to set.
     */
    setGctSetting(setting, value) {
        const gctSettings = this._readJsonFile(GCT_CONFIG_FILE);
        gctSettings[setting] = value;
        this._saveJsonFile(GCT_CONFIG_FILE, gctSettings);
        console.log(`GCT setting '${setting}' set to '${value}'.`);
    }
};

/*
// Example Usage (commented out for production, uncomment for testing in your Duktape environment)
// This example assumes `fs` is globally available.
if (typeof fs !== 'undefined' && typeof console !== 'undefined') {
    console.log("--- Testing configUtils JavaScript (Duktape with fs) ---");

    // To ensure a clean test, you might need to manually delete the .json files
    // before running this example, as there's no `fs.clear()` equivalent.
    // Example: fs.deleteFile(FEATURE_SETTINGS_FILE); fs.deleteFile(GCT_CONFIG_FILE);

    // Set and get feature settings
    configUtils.setFeatureSetting("Hotkeys", "VehicleBoostKey", "F5");
    configUtils.setFeatureSetting("VehicleOptions", "AutoFixVehicle", true);
    const boostKey = configUtils.getFeatureSetting("Hotkeys", "VehicleBoostKey");
    const autoFix = configUtils.getFeatureSetting("VehicleOptions", "AutoFixVehicle");
    console.log(`Retrieved VehicleBoostKey: ${boostKey}`);
    console.log(`Retrieved AutoFixVehicle: ${autoFix}`);
    console.log(`Non-existent setting: ${configUtils.getFeatureSetting('NonExistent', 'Key')}`);

    // Set and get GCT settings
    configUtils.setGctSetting("GameVolume", 0.75);
    configUtils.setGctSetting("PlayerName", "TestPlayerJS");
    const volume = configUtils.getGctSetting("GameVolume");
    const playerName = configUtils.getGctSetting("PlayerName");
    console.log(`Retrieved GameVolume: ${volume}`);
    console.log(`Retrieved PlayerName: ${playerName}`);
    console.log(`Non-existent GCT setting: ${configUtils.getGctSetting('DebugMode')}`);

    console.log("Configuration files should now be updated on disk.");
} else {
    console.warn("`fs` module or `console` not available. Example usage will not run.");
}
*/
