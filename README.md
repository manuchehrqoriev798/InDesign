# IDML to PDF Converter for macOS

Convert IDML files to PDF using Adobe InDesign via automation. This script automatically opens InDesign if it's not running and converts your IDML files to PDF.

## Quick Start

```bash
./convert_idml_to_pdf_mac.sh document.idml
```

## Requirements

- **macOS** (any recent version)
- **Adobe InDesign** installed (2022, 2023, 2024, or CC 2019)
- **Terminal** access

## Setup (One-Time)

### Step 1: Make Script Executable

```bash
chmod +x convert_idml_to_pdf_mac.sh
```

### Step 2: Grant Terminal Permission

The first time you run the script, macOS will ask for permission to control InDesign:

1. Open **System Preferences** (or **System Settings** on newer macOS)
2. Go to **Security & Privacy** (or **Privacy & Security**)
3. Click on **Accessibility**
4. Find **Terminal** (or **iTerm** if you use that) in the list
5. Make sure it's **checked/enabled**
6. If Terminal is not in the list, run the script once and macOS will prompt you - click "Allow"

## Usage

### Basic Usage

```bash
./convert_idml_to_pdf_mac.sh document.idml
```

This creates `document.pdf` in the same folder as the IDML file.

### Specify Output File

```bash
./convert_idml_to_pdf_mac.sh document.idml output.pdf
```

### Using Full Paths

```bash
./convert_idml_to_pdf_mac.sh ~/Documents/file.idml ~/Desktop/file.pdf
```

### Batch Conversion

Convert multiple files at once:

```bash
cd ~/Documents/idml_files
for file in *.idml; do
    ~/path/to/convert_idml_to_pdf_mac.sh "$file"
done
```

## How It Works

1. **Checks InDesign**: Verifies InDesign is installed
2. **Opens InDesign**: Automatically opens InDesign if it's not running
3. **Converts File**: Opens the IDML file and exports it to PDF
4. **Closes Document**: Closes the document without saving changes to the IDML

The script uses the "High Quality Print" preset by default, or the best available preset if that's not found.

## Files

- `idml_to_pdf.jsx` - Core conversion script (runs inside InDesign)
- `convert_idml_to_pdf.applescript` - AppleScript wrapper (handles InDesign automation)
- `convert_idml_to_pdf_mac.sh` - Shell script wrapper (easy to use)

All files must be in the same directory.

## Troubleshooting

### "Adobe InDesign not found"

**Solution**: Make sure InDesign is installed in `/Applications/`. The script looks for:
- `/Applications/Adobe InDesign 2024/`
- `/Applications/Adobe InDesign 2023/`
- `/Applications/Adobe InDesign 2022/`
- `/Applications/Adobe InDesign CC 2019/`

### "Permission denied" or Script won't run

**Solution**: 
1. Make the script executable: `chmod +x convert_idml_to_pdf_mac.sh`
2. Grant Terminal permission in System Preferences > Security & Privacy > Accessibility

### "Could not connect to InDesign"

**Solution**:
1. Open InDesign manually first
2. Grant Terminal permission to control InDesign (see Setup Step 2)
3. Try running the script again

### "Input file not found"

**Solution**: 
- Use full paths: `/Users/yourname/Documents/file.idml`
- Or navigate to the folder first: `cd ~/Documents` then run the script

### Script runs but PDF is not created

**Solution**:
- Check that you have write permission to the output folder
- Check Terminal output for error messages
- Try opening the IDML file manually in InDesign to verify it's not corrupted

### InDesign opens but nothing happens

**Solution**:
- Make sure `idml_to_pdf.jsx` is in the same folder as the other scripts
- Check Terminal for error messages
- Try opening the IDML file manually in InDesign first

## Notes

- The script closes the document without saving, so your original IDML file is never modified
- Large files may take a minute or two to convert
- InDesign must be installed and licensed for this to work
- The first time you run it, InDesign may take longer to open

## License

Free to use. Ensure you have proper licensing for Adobe InDesign.
