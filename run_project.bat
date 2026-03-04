@echo off

start cmd /k "python C:\Users\Harley\Documents\GitHub\HandTrackingProject\hand_tracking_project\hand_tracking.py"
timeout /t 2 >nul
start "" "C:\Users\Harley\Documents\GitHub\HandTrackingProject\handtrackingproject\.godot"