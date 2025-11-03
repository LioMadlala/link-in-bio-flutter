@echo off

REM Build Flutter web app
echo Building Flutter web app...
call flutter build web --release

REM Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo Build successful! Deploying to Firebase...
    call firebase deploy --only hosting
) else (
    echo Build failed! Please fix errors and try again.
    exit /b 1
)

