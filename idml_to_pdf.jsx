// InDesign ExtendScript: Convert IDML to PDF
// Arguments: [0] = input IDML file, [1] = output PDF file (optional)

$.writeln("[JSX] =========================================");
$.writeln("[JSX] Starting IDML to PDF conversion");
$.writeln("[JSX] =========================================");
$.writeln("");

var inputFile, outputFile, doc;

// Validate arguments
$.writeln("[JSX] Checking arguments...");
$.writeln("[JSX] Number of arguments: " + arguments.length);

if (arguments.length < 1) {
    $.writeln("[JSX] ERROR: No input file specified.");
    $.writeln("[JSX] Expected at least 1 argument (input file path)");
    exit();
}

// Get input file (convert string path to File object)
$.writeln("[JSX] Processing input file argument...");
var inputPath = (typeof arguments[0] === 'string') ? arguments[0] : arguments[0].fsName;
$.writeln("[JSX] Input path: " + inputPath);

inputFile = new File(inputPath);
if (!inputFile) {
    $.writeln("[JSX] ERROR: Could not create File object from path: " + inputPath);
    exit();
}

if (!inputFile.exists) {
    $.writeln("[JSX] ERROR: IDML file not found: " + inputPath);
    $.writeln("[JSX] File object: " + inputFile.fsName);
    exit();
}

$.writeln("[JSX] ✓ Input file found: " + inputFile.name);
$.writeln("[JSX] Input file full path: " + inputFile.fsName);
$.writeln("");

// Get output file (default: same location, .pdf extension)
$.writeln("[JSX] Processing output file...");
if (arguments.length > 1) {
    var outputPath = (typeof arguments[1] === 'string') ? arguments[1] : arguments[1].fsName;
    $.writeln("[JSX] Output path provided: " + outputPath);
    outputFile = new File(outputPath);
} else {
    var outputPath = inputFile.parent.fsName + "/" + inputFile.name.replace(/\.idml$/i, ".pdf");
    $.writeln("[JSX] Output path auto-generated: " + outputPath);
    outputFile = new File(outputPath);
}

$.writeln("[JSX] Output file: " + outputFile.name);
$.writeln("[JSX] Output file full path: " + outputFile.fsName);
$.writeln("");

// Create output directory if needed
$.writeln("[JSX] Checking output directory...");
var outputFolder = outputFile.parent;
if (!outputFolder.exists) {
    $.writeln("[JSX] Output directory does not exist, creating: " + outputFolder.fsName);
    try {
        outputFolder.create();
        $.writeln("[JSX] ✓ Output directory created");
    } catch (e) {
        $.writeln("[JSX] ERROR: Could not create output directory: " + e.message);
        exit();
    }
} else {
    $.writeln("[JSX] ✓ Output directory exists: " + outputFolder.fsName);
}
$.writeln("");

// Convert IDML to PDF
try {
    $.writeln("[JSX] =========================================");
    $.writeln("[JSX] Opening IDML file: " + inputFile.name);
    $.writeln("[JSX] =========================================");
    
    doc = app.open(inputFile);
    if (!doc || !doc.isValid) {
        $.writeln("[JSX] ERROR: Could not open document");
        exit();
    }
    
    $.writeln("[JSX] ✓ Document opened successfully");
    $.writeln("[JSX] Document name: " + doc.name);
    $.writeln("");
    
    // Find best available PDF preset
    $.writeln("[JSX] Looking for PDF export preset...");
    var presetNames = ["[High Quality Print]", "[Press Quality]", "[Smallest File Size]", "[PDF/X-1a:2001]"];
    var pdfPreset = null;
    
    for (var i = 0; i < presetNames.length; i++) {
        try {
            var testPreset = app.pdfExportPresets.item(presetNames[i]);
            if (testPreset.isValid) {
                pdfPreset = testPreset;
                $.writeln("[JSX] ✓ Found preset: " + presetNames[i]);
                break;
            }
        } catch (e) {
            $.writeln("[JSX] Preset not available: " + presetNames[i]);
        }
    }
    
    if (!pdfPreset) {
        $.writeln("[JSX] No preset found, will use default PDF settings");
    }
    $.writeln("");
    
    // Export to PDF
    $.writeln("[JSX] =========================================");
    $.writeln("[JSX] Exporting to PDF: " + outputFile.name);
    $.writeln("[JSX] =========================================");
    
    if (pdfPreset && pdfPreset.isValid) {
        $.writeln("[JSX] Using preset: " + pdfPreset.name);
        doc.exportFile(ExportFormat.PDF_TYPE, outputFile, false, pdfPreset);
    } else {
        $.writeln("[JSX] Using default PDF export options");
        doc.exportFile(ExportFormat.PDF_TYPE, outputFile, false, new PDFExportOptions());
    }
    
    // Verify PDF was created
    if (outputFile.exists) {
        $.writeln("[JSX] ✓ PDF file created successfully");
        $.writeln("[JSX] PDF location: " + outputFile.fsName);
    } else {
        $.writeln("[JSX] WARNING: PDF file not found after export");
    }
    $.writeln("");
    
    // Close document
    $.writeln("[JSX] Closing document (without saving)...");
    doc.close(SaveOptions.NO);
    $.writeln("[JSX] ✓ Document closed");
    $.writeln("");
    
    $.writeln("[JSX] =========================================");
    $.writeln("[JSX] SUCCESS: " + inputFile.name + " → " + outputFile.name);
    $.writeln("[JSX] =========================================");
    
} catch (e) {
    $.writeln("");
    $.writeln("[JSX] =========================================");
    $.writeln("[JSX] ERROR during conversion");
    $.writeln("[JSX] =========================================");
    $.writeln("[JSX] Error message: " + e.message);
    $.writeln("[JSX] Error line: " + e.line);
    if (e.fileName) {
        $.writeln("[JSX] Error file: " + e.fileName);
    }
    $.writeln("");
    
    try {
        if (doc && doc.isValid) {
            $.writeln("[JSX] Attempting to close document...");
            doc.close(SaveOptions.NO);
            $.writeln("[JSX] Document closed");
        }
    } catch (closeError) {
        $.writeln("[JSX] WARNING: Could not close document: " + closeError.message);
    }
    
    exit();
}

