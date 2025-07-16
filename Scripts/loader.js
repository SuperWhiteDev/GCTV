const scripts = fs.readdir(GetGCTFolder() + "\\Scripts\\features")

if (scripts) {
    for (var i = 0; i < scripts.length; i++) {
        if (fs.getFileExtension(scripts[i]) === ".js") {
            RunScript("features\\" + scripts[i])
        }
    }
}
