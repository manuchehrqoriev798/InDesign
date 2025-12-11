// InDesign ExtendScript: Convert IDML to PDF
// Arguments: [0] = input IDML file, [1] = output PDF file (optional)

var inputFile, outputFile, doc;

// Validate arguments
if (arguments.length < 1) {
    $.writeln("ERROR: No input file specified.");
    exit();
}

// Get input file (convert string path to File object)
var inputPath = (typeof arguments[0] === 'string') ? arguments[0] : arguments[0].fsName;
inputFile = new File(inputPath);
if (!inputFile || !inputFile.exists) {
    $.writeln("ERROR: IDML file not found: " + inputPath);
    exit();
}

// Get output file (default: same location, .pdf extension)
if (arguments.length > 1) {
    var outputPath = (typeof arguments[1] === 'string') ? arguments[1] : arguments[1].fsName;
    outputFile = new File(outputPath);
} else {
    var outputPath = inputFile.parent.fsName + "/" + inputFile.name.replace(/\.idml$/i, ".pdf");
    outputFile = new File(outputPath);
}

// Create output directory if needed
var outputFolder = outputFile.parent;
if (!outputFolder.exists) {
    outputFolder.create();
}

// Convert IDML to PDF
try {
    $.writeln("Opening: " + inputFile.name);
    doc = app.open(inputFile);
    
    // Find best available PDF preset
    var presetNames = ["[High Quality Print]", "[Press Quality]", "[Smallest File Size]", "[PDF/X-1a:2001]"];
    var pdfPreset = null;
    
    for (var i = 0; i < presetNames.length; i++) {
        try {
            var testPreset = app.pdfExportPresets.item(presetNames[i]);
            if (testPreset.isValid) {
                pdfPreset = testPreset;
                $.writeln("Using preset: " + presetNames[i]);
                break;
            }
        } catch (e) {
            // Continue to next preset
        }
    }
    
    // Export to PDF
    $.writeln("Exporting: " + outputFile.name);
    if (pdfPreset && pdfPreset.isValid) {
        doc.exportFile(ExportFormat.PDF_TYPE, outputFile, false, pdfPreset);
    } else {
        doc.exportFile(ExportFormat.PDF_TYPE, outputFile, false, new PDFExportOptions());
        $.writeln("Using default PDF settings");
    }
    
    // Close document
    doc.close(SaveOptions.NO);
    $.writeln("SUCCESS: " + inputFile.name + " → " + outputFile.name);
    
} catch (e) {
    $.writeln("ERROR: " + e.message);
    try {
        if (doc && doc.isValid) {
            doc.close(SaveOptions.NO);
        }
    } catch (closeError) {
        // Ignore
    }
    exit();
}

