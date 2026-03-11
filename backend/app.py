from flask import Flask, request, jsonify
import cv2
import numpy as np
from PIL import Image
import pytesseract

app = Flask(__name__)

face_model = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)

@app.route('/scan', methods=['POST'])
def scan():
    file = request.files['image']
    img = Image.open(file.stream)
    img_np = np.array(img)

    gray = cv2.cvtColor(img_np, cv2.COLOR_BGR2GRAY)
    faces = face_model.detectMultiScale(gray, 1.3, 5)

    text = pytesseract.image_to_string(img)

    score = 0
    if len(faces) > 0:
        score += 30
    if len(text.strip()) > 5:
        score += 40

    level = "SAFE"
    if score > 60:
        level = "HIGH RISK"
    elif score > 30:
        level = "MEDIUM RISK"

    return jsonify({
        "faces": len(faces),
        "text_found": bool(text.strip()),
        "score": score,
        "level": level
    })

app.run(debug=True)
