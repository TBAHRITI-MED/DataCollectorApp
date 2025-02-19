#!/usr/bin/env python3
import math
import csv
import json
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Autorise les requêtes cross-origin

# ---------------------------------------------------
# 1. Fonctions utilitaires : distance point-segment
# ---------------------------------------------------
def latlon_to_xy(lat, lon, lat0, lon0):
    R = 111320.0  # Nombre de mètres par degré approximativement
    x = (lon - lon0) * R * math.cos(math.radians(lat0))
    y = (lat - lat0) * R
    return (x, y)

def distance_point_to_segment(px, py, ax, ay, bx, by):
    ABx = bx - ax
    ABy = by - ay
    APx = px - ax
    APy = py - ay

    AB2 = ABx * ABx + ABy * ABy
    if AB2 == 0:
        return math.hypot(px - ax, py - ay)
    t = (APx * ABx + APy * ABy) / AB2
    if t < 0:
        return math.hypot(px - ax, py - ay)
    elif t > 1:
        return math.hypot(px - bx, py - by)
    else:
        projx = ax + t * ABx
        projy = ay + t * ABy
        return math.hypot(px - projx, py - projy)

def is_point_on_segment(latP, lonP, latA, lonA, latB, lonB, corridor_width=30):
    lat0, lon0 = latA, lonA
    px, py = latlon_to_xy(latP, lonP, lat0, lon0)
    ax, ay = latlon_to_xy(latA, lonA, lat0, lon0)
    bx, by = latlon_to_xy(latB, lonB, lat0, lon0)
    dist = distance_point_to_segment(px, py, ax, ay, bx, by)
    return dist <= corridor_width

# ---------------------------------------------------
# 2. Chargement des données initiales
# ---------------------------------------------------
CSV_FILE = "/Users/mohammedtbahriti/Documents/suivi_trajectoire_voie/sensor_data_1739009536.298178.csv"
all_points = []  # Liste de tuples (latitude, longitude, speed)

def load_points_csv(csv_file):
    data = []
    try:
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                lat_str = row.get('Latitude')
                lon_str = row.get('Longitude')
                speed_str = row.get('Speed')
                if lat_str and lon_str and speed_str:
                    lat = float(lat_str)
                    lon = float(lon_str)
                    speed = float(speed_str)
                    data.append((lat, lon, speed))
        print(f"{len(data)} points chargés depuis {csv_file}")
    except FileNotFoundError:
        print(f"Fichier CSV introuvable: {csv_file}")
    return data

all_points = load_points_csv(CSV_FILE)

# ---------------------------------------------------
# 3. Routes existantes
# ---------------------------------------------------
@app.route("/")
def index():
    return send_from_directory('.', 'index.html')

@app.route("/get_all_points", methods=["GET"])
def get_all_points():
    return jsonify({"points": all_points})

@app.route("/compute", methods=["POST"])
def compute():
    data = request.json
    latA = float(data["latA"])
    lonA = float(data["lonA"])
    latB = float(data["latB"])
    lonB = float(data["lonB"])
    corridor = 30.0

    onStreet = []
    offStreet = []
    speedSum = 0.0
    onCount = 0

    for (lat, lon, speed) in all_points:
        if is_point_on_segment(lat, lon, latA, lonA, latB, lonB, corridor):
            onStreet.append([lat, lon])
            speedSum += speed
            onCount += 1
        else:
            offStreet.append([lat, lon])

    avgSpeed = speedSum / onCount if onCount > 0 else 0.0

    return jsonify({
        "onStreet": onStreet,
        "offStreet": offStreet,
        "avgSpeed": avgSpeed
    })

@app.route("/compute_multiple", methods=["POST"])
def compute_multiple():
    data = request.json
    segments = data["segments"]
    
    results = []
    for idx, segment in enumerate(segments):
        latA, lonA = segment[0]
        latB, lonB = segment[1]
        onCount, offCount = compute_segment_points(latA, lonA, latB, lonB, 30.0)
        results.append({
            "segmentIndex": idx,
            "onCount": onCount,
            "offCount": offCount
        })
    
    if len(segments) > 1:
        latA, lonA = segments[0][0]
        latZ, lonZ = segments[-1][1]
        onCount, offCount = compute_segment_points(latA, lonA, latZ, lonZ, 30.0)
        results.append({
            "segmentIndex": "A->Z",
            "onCount": onCount,
            "offCount": offCount
        })
    
    return jsonify({"results": results})

def compute_segment_points(latA, lonA, latB, lonB, corridor=30.0):
    onCount = 0
    offCount = 0
    for (lat, lon, _) in all_points:
        if is_point_on_segment(lat, lon, latA, lonA, latB, lonB, corridor):
            onCount += 1
        else:
            offCount += 1
    return onCount, offCount

# ---------------------------------------------------
# 4. Route pour recevoir les données en temps réel
# ---------------------------------------------------
@app.route("/api/push_data", methods=["POST"])
def push_data():
    if not request.json:
        return jsonify({"error": "No JSON body"}), 400
    
    body = request.json
    
    # Si les données sont envoyées sous la clé "data", alors décoder la chaîne JSON.
    if "data" in body:
        try:
            parsed = json.loads(body["data"])
        except Exception as e:
            return jsonify({"error": "Invalid data JSON", "details": str(e)}), 400
        lat = float(parsed.get("latitude", 0))
        lon = float(parsed.get("longitude", 0))
        speed = float(parsed.get("speed", 0))
    else:
        try:
            lat = float(body.get("latitude", 0))v
            lon = float(body.get("longitude", 0))
            speed = float(body.get("speed", 0))
        except ValueError:
            return jsonify({"error": "Invalid numeric values"}), 400
    
    all_points.append((lat, lon, speed))
    print(f"📡 Nouveau point ajouté: lat={lat}, lon={lon}, speed={speed}")
    return jsonify({
        "status": "Point added",
        "count": len(all_points)
    }), 200

# ---------------------------------------------------
# 5. Lancement du serveur Flask
# ---------------------------------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
