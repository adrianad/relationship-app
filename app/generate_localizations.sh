#!/bin/bash
# Script to generate localization files for the app using the non-deprecated approach

echo "Generating localization files using the non-deprecated approach..."

# Ensure the generated directory exists 
mkdir -p lib/generated

# Remove the temporary AppLocalizations file if it exists
if [ -f "lib/l10n/app_localizations.dart" ]; then
  echo "Removing temporary app_localizations.dart file..."
  rm lib/l10n/app_localizations.dart
fi

# Run the gen-l10n command
flutter gen-l10n

echo "Localization files generated successfully!"
echo "The app now uses Flutter's official non-synthetic package localization system."
echo "Generated files are in lib/generated/ and imported using package:app/generated/app_localizations.dart"
echo "Any changes to ARB files will require running this script again."