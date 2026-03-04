import cv2
import mediapipe as mp
import socket
from mediapipe.tasks.python import vision
from mediapipe.tasks.python import BaseOptions

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
TARGET = ("127.0.0.1", 5555)

import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
model_path = os.path.join(BASE_DIR, "hand_landmarker.task")
cap = cv2.VideoCapture(0)

base_options = BaseOptions(model_asset_path=model_path)
options = vision.HandLandmarkerOptions(
    base_options=base_options,
    num_hands=1
)
detector = vision.HandLandmarker.create_from_options(options)

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Keep mirrored webcam view for comfort
    frame = cv2.flip(frame, 1)

    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)
    result = detector.detect(mp_image)

    if result.hand_landmarks:
        hand = result.hand_landmarks[0]

        values = []
        for lm in hand:
            # Mirror X to simulate opposite hand
            mirrored_x = 1.0 - lm.x

            values.append(str(mirrored_x))
            values.append(str(lm.y))
            values.append(str(lm.z))

        data = ",".join(values)
        sock.sendto(data.encode(), TARGET)

    cv2.imshow("Hand Tracking", frame)
    if cv2.waitKey(1) & 0xFF == 27:
        break

cap.release()
sock.close()
cv2.destroyAllWindows()