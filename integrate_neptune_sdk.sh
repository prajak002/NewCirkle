#!/bin/bash
# Neptune SDK Integration Script for Linux/Mac

echo "=== Neptune SDK Integration Script ==="
echo ""

# Check if Neptune SDK zip exists
if [ ! -f "NeptuneLiteApi_V4.15.00_20250606.zip" ]; then
    echo "❌ NeptuneLiteApi_V4.15.00_20250606.zip not found in current directory"
    echo "Please place the Neptune SDK zip file in the project root directory"
    exit 1
fi

echo "✅ Found Neptune SDK zip file"
echo ""

# Create extraction directory
echo "📁 Creating extraction directory..."
mkdir -p temp_neptune_extract
cd temp_neptune_extract

# Extract the zip file
echo "📦 Extracting Neptune SDK..."
unzip -q ../NeptuneLiteApi_V4.15.00_20250606.zip

# Create libs directory
echo "📁 Creating android/app/libs directory..."
mkdir -p ../android/app/libs

# Find and copy AAR/JAR files
echo "🔍 Looking for AAR and JAR files..."
find . -name "*.aar" -exec echo "Found AAR: {}" \;
find . -name "*.jar" -exec echo "Found JAR: {}" \;

echo ""
echo "📋 Copying files to android/app/libs/..."
find . -name "*.aar" -exec cp {} ../android/app/libs/ \;
find . -name "*.jar" -exec cp {} ../android/app/libs/ \;

# List copied files
echo "✅ Files copied to android/app/libs/:"
ls -la ../android/app/libs/

# Cleanup
cd ..
rm -rf temp_neptune_extract

echo ""
echo "=== Next Steps ==="
echo "1. Open android/app/src/main/kotlin/com/example/cirmle_rfid_pos/NeptuneCardHandler.kt"
echo "2. Update the import statements based on your Neptune SDK documentation"
echo "3. Uncomment the TODO sections with real Neptune SDK calls"
echo "4. Run: flutter clean && flutter pub get && flutter build android"
echo ""
echo "📖 For detailed instructions, see: NEPTUNE_INTEGRATION_STEPS.md"
echo ""
echo "🎉 Neptune SDK files integration complete!"
