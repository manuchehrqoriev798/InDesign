-- macOS AppleScript: Convert IDML to PDF using InDesign
-- Automatically opens InDesign if not running
-- Usage: osascript convert_idml_to_pdf.applescript input.idml [output.pdf]

on run argv
    -- Validate arguments
    if (count of argv) < 1 then
        return "ERROR: Usage: osascript convert_idml_to_pdf.applescript <input.idml> [output.pdf]"
    end if
    
    set inputFile to item 1 of argv
    set outputFile to ""
    if (count of argv) > 1 then
        set outputFile to item 2 of argv
    end if
    
    -- Validate input file
    set inputFilePOSIX to POSIX file inputFile
    try
        set inputFileAlias to inputFilePOSIX as alias
    on error
        return "ERROR: Input file not found: " & inputFile
    end try
    
    -- Get JSX script path
    set scriptPath to POSIX path of (path to me)
    set scriptDir to do shell script "dirname " & quoted form of scriptPath
    set jsxScript to scriptDir & "/idml_to_pdf.jsx"
    set jsxScriptPOSIX to POSIX file jsxScript
    
    try
        set jsxScriptAlias to jsxScriptPOSIX as alias
    on error
        return "ERROR: JSX script not found: " & jsxScript
    end try
    
    log "IDML to PDF Converter"
    log "Input:  " & inputFile
    if outputFile is not "" then
        log "Output: " & outputFile
    end if
    log ""
    
    try
        -- Find InDesign
        try
            set indesignApp to path to application "Adobe InDesign"
        on error
            return "ERROR: Adobe InDesign not found. Please install InDesign."
        end try
        
        -- Check if InDesign is running
        tell application "System Events"
            set isRunning to (name of processes) contains "Adobe InDesign"
        end tell
        
        -- Open InDesign if needed
        if not isRunning then
            log "Opening InDesign..."
            tell application "Adobe InDesign"
                activate
                -- Wait for InDesign to be ready
                delay 3
                -- Verify it's ready by checking version
                set indesignVersion to version as string
                log "InDesign " & indesignVersion & " is ready"
            end tell
        end if
        
        -- Execute conversion
        tell application "Adobe InDesign"
            log "Converting..."
            -- Convert POSIX paths to strings for ExtendScript
            set inputFilePath to POSIX path of inputFilePOSIX
            if outputFile is "" then
                do script jsxScriptPOSIX with arguments {inputFilePath}
            else
                set outputFilePOSIX to POSIX file outputFile
                set outputFilePath to POSIX path of outputFilePOSIX
                do script jsxScriptPOSIX with arguments {inputFilePath, outputFilePath}
            end if
            log "SUCCESS: PDF created!"
            return "SUCCESS"
        end tell
        
    on error errorMessage
        set errorMsg to "ERROR: " & errorMessage
        log errorMsg
        log ""
        log "Tip: Grant Terminal permission in System Preferences > Security & Privacy > Accessibility"
        return errorMsg
    end try
end run

