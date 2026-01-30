package main

import (
	"fmt"
	"io"
	"net/http"
)

func main() {
	http.HandleFunc("/", serveHTML)
	http.HandleFunc("/api/bird", getBird)

	fmt.Println("Frontend listening on :3000")
	http.ListenAndServe(":3000", nil)
}

func serveHTML(w http.ResponseWriter, r *http.Request) {
	html := `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bird Explorer</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #000;
            min-height: 100vh;
            overflow: hidden;
        }

        .container {
            width: 100%;
            height: 100vh;
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        #birdImage {
            width: 100%;
            height: 100%;
            object-fit: cover;
            position: absolute;
            top: 0;
            left: 0;
            z-index: 1;
        }

        .dark-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.2);
            z-index: 2;
        }

        .header {
            position: absolute;
            top: 30px;
            left: 30px;
            z-index: 10;
            color: white;
            text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.5);
        }

        .header h1 {
            font-size: 3em;
            margin: 0;
        }

        .header p {
            font-size: 1em;
            opacity: 0.9;
            margin: 5px 0 0 0;
        }

        .info-box {
            position: absolute;
            bottom: 30px;
            right: 30px;
            width: 350px;
            max-height: 50vh;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
            border: 1px solid rgba(255, 255, 255, 0.3);
            z-index: 10;
            display: flex;
            flex-direction: column;
            gap: 15px;
            overflow-y: auto;
        }

        .info-box h2 {
            color: #667eea;
            font-size: 1.8em;
            margin: 0;
            word-wrap: break-word;
        }

        .info-box p {
            color: #555;
            font-size: 0.9em;
            line-height: 1.5;
            flex-grow: 1;
        }

        .button-group {
            display: flex;
            gap: 10px;
            margin-top: auto;
        }

        button {
            flex: 1;
            padding: 10px 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 0.9em;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }

        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 25px rgba(102, 126, 234, 0.5);
        }

        button:active {
            transform: translateY(0);
        }

        .loading {
            position: absolute;
            bottom: 30px;
            right: 30px;
            width: 350px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
            text-align: center;
            color: #667eea;
            display: none;
            z-index: 10;
        }

        .loading-spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 15px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .error {
            position: absolute;
            bottom: 30px;
            right: 30px;
            width: 350px;
            background: #fadbd8;
            color: #c0392b;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
            border-left: 5px solid #c0392b;
            font-weight: 600;
            word-break: break-word;
            display: none;
            z-index: 10;
        }

        @media (max-width: 768px) {
            .info-box,
            .loading,
            .error {
                width: 90vw;
                bottom: 20px;
                right: 20px;
            }

            .info-box h2 {
                font-size: 1.5em;
            }

            .info-box p {
                font-size: 0.85em;
            }

            .header {
                top: 20px;
                left: 20px;
            }

            .header h1 {
                font-size: 2em;
            }

            .header p {
                font-size: 0.9em;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <img id="birdImage" src="" alt="Bird" style="display: none;">
        <div class="dark-overlay"></div>

        <div class="header">
            <h1>🐦 Bird Explorer</h1>
            <p>Discover beautiful birds</p>
        </div>

        <div id="loading" class="loading">
            <div class="loading-spinner"></div>
            <p>Loading bird...</p>
        </div>

        <div id="error" class="error"></div>

        <div id="info-box" class="info-box" style="display: none;">
            <h2 id="birdName"></h2>
            <p id="birdDescription"></p>
            <div class="button-group">
                <button onclick="fetchBird()">Get Next Bird →</button>
            </div>
        </div>
    </div>

    <script>
        function fetchBird() {
            const loading = document.getElementById("loading");
            const error = document.getElementById("error");
            const infoBox = document.getElementById("info-box");
            const image = document.getElementById("birdImage");

            loading.style.display = "block";
            error.style.display = "none";
            infoBox.style.display = "none";
            image.style.display = "none";

            fetch('/api/bird')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('HTTP error! status: ' + response.status);
                    }
                    return response.json();
                })
                .then(data => {
                    image.src = data.image;
                    document.getElementById("birdName").textContent = data.name;
                    document.getElementById("birdDescription").textContent = data.description;

                    image.onload = function() {
                        loading.style.display = "none";
                        infoBox.style.display = "flex";
                        image.style.display = "block";
                    };

                    image.onerror = function() {
                        error.textContent = "Failed to load bird image. Try another one!";
                        loading.style.display = "none";
                        error.style.display = "block";
                    };
                })
                .catch(error => {
                    console.error("Error:", error);
                    error = document.getElementById("error");
                    error.textContent = "Error: " + error.message;
                    loading.style.display = "none";
                    error.style.display = "block";
                });
        }

        window.addEventListener("load", fetchBird);
    </script>
</body>
</html>`

	w.Header().Set("Content-Type", "text/html")
	fmt.Fprint(w, html)
}

func getBird(w http.ResponseWriter, r *http.Request) {
	resp, err := http.Get("http://bird-api-service:80/")
	if err != nil {
		http.Error(w, "Failed to fetch bird data", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, "Failed to read bird data", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(body)
}