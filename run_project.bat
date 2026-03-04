@echo off

start cmd /k "python C:\Users\Harley\Documents\GitHub\HandTrackingProject\hand_tracking_project\hand_tracking.py"
timeout /t 4 >nul
start "" "C:\Users\Harley\scoop\apps\godot\current\godot.exe" --path "C:\Users\Harley\Documents\GitHub\HandTrackingProject\handtrackingproject"