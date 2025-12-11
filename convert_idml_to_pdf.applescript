-- macOS AppleScript: Convert IDML to PDF using InDesign
-- Automatically opens InDesign if not running
-- Usage: osascript convert_idml_to_pdf.applescript input.idml [output.pdf]

on run argv
    log "[AppleScript] Starting..."
    log "[AppleScript] Received " & (count of argv) & " argument(s)"
    
    -- Validate arguments
    if (count of argv) < 1 then
        set errorMsg to "ERROR: No input file provided. Usage: osascript convert_idml_to_pdf.applescript <input.idml> [output.pdf]"
        log errorMsg
        return errorMsg
    end if
    
    set inputFile to item 1 of argv
    set outputFile to ""
    if (count of argv) > 1 then
        set outputFile to item 2 of argv
    end if
    
    log "[AppleScript] Input file: " & inputFile
    if outputFile is not "" then
        log "[AppleScript] Output file: " & outputFile
    end if
    log ""
    
    -- Validate input file
    log "[AppleScript] Validating input file..."
    set inputFilePOSIX to POSIX file inputFile
    try
        set inputFileAlias to inputFilePOSIX as alias
        log "[AppleScript] ✓ Input file exists"
    on error errMsg
        set errorMsg to "ERROR: Input file not found: " & inputFile & " (" & errMsg & ")"
        log errorMsg
        return errorMsg
    end try
    
    -- Get JSX script path
    log "[AppleScript] Locating JSX script..."
    set scriptPath to POSIX path of (path to me)
    set scriptDir to do shell script "dirname " & quoted form of scriptPath
    set jsxScript to scriptDir & "/idml_to_pdf.jsx"
    set jsxScriptPOSIX to POSIX file jsxScript
    
    log "[AppleScript] JSX script path: " & jsxScript
    
    try
        set jsxScriptAlias to jsxScriptPOSIX as alias
        log "[AppleScript] ✓ JSX script found"
    on error errMsg
        set errorMsg to "ERROR: JSX script not found: " & jsxScript & " (" & errMsg & ")"
        log errorMsg
        return errorMsg
    end try
    log ""
    
    try
        -- Find InDesign
        log "[AppleScript] Looking for Adobe InDesign..."
        try
            set indesignApp to path to application "Adobe InDesign"
            log "[AppleScript] ✓ InDesign found"
        on error errMsg
            set errorMsg to "ERROR: Adobe InDesign not found. Please install InDesign. (" & errMsg & ")"
            log errorMsg
            return errorMsg
        end try
        
        -- Check if InDesign is running
        log "[AppleScript] Checking if InDesign is running..."
        tell application "System Events"
            set isRunning to (name of processes) contains "Adobe InDesign"
        end tell
        
        if isRunning then
            log "[AppleScript] ✓ InDesign is already running"
        else
            log "[AppleScript] InDesign is not running"
        end if
        
        -- Open InDesign if needed
        if not isRunning then
            log "[AppleScript] Opening InDesign..."
            tell application "Adobe InDesign"
                activate
                log "[AppleScript] Waiting for InDesign to be ready..."
                delay 3
                try
                    set indesignVersion to version as string
                    log "[AppleScript] ✓ InDesign " & indesignVersion & " is ready"
                on error errMsg
                    log "[AppleScript] WARNING: Could not get InDesign version: " & errMsg
                end try
            end tell
        end if
        log ""
        
        -- Execute conversion
        log "[AppleScript] Preparing to execute JSX script..."
        tell application "Adobe InDesign"
            -- Convert POSIX paths to strings for ExtendScript
            set inputFilePath to POSIX path of inputFilePOSIX
            log "[AppleScript] Input file path (for JSX): " & inputFilePath
            
            -- Use file reference (alias) for the JSX script
            set jsxScriptFile to jsxScriptPOSIX as alias
            
            if outputFile is "" then
                log "[AppleScript] Executing JSX script with 1 argument..."
                try
                    do script jsxScriptFile language javascript with arguments {inputFilePath}
                    log "[AppleScript] ✓ JSX script execution completed"
                on error errMsg number errNum
                    log "[AppleScript] ERROR executing script: " & errMsg & " (Error: " & errNum & ")"
                    error errMsg number errNum
                end try
            else
                set outputFilePOSIX to POSIX file outputFile
                set outputFilePath to POSIX path of outputFilePOSIX
                log "[AppleScript] Output file path (for JSX): " & outputFilePath
                log "[AppleScript] Executing JSX script with 2 arguments..."
                try
                    do script jsxScriptFile language javascript with arguments {inputFilePath, outputFilePath}
                    log "[AppleScript] ✓ JSX script execution completed"
                on error errMsg number errNum
                    log "[AppleScript] ERROR executing script: " & errMsg & " (Error: " & errNum & ")"
                    error errMsg number errNum
                end try
            end if
            log ""
            log "[AppleScript] SUCCESS: PDF conversion completed!"
            return "SUCCESS"
        end tell
        
    on error errorMessage number errorNumber
        set errorMsg to "ERROR: " & errorMessage
        if errorNumber is not 0 then
            set errorMsg to errorMsg & " (Error number: " & errorNumber & ")"
        end if
        log errorMsg
        log ""
        log "[AppleScript] Troubleshooting tips:"
        log "  1. Make sure Adobe InDesign is installed"
        log "  2. Grant Terminal permission in System Preferences > Security & Privacy > Accessibility"
        log "  3. Try opening InDesign manually first, then run this script again"
        log "  4. Check that the IDML file is not corrupted"
        return errorMsg
    end try
end run

