package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type Bird struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Image       string `json:"image"`
}

func main() {
	// Serve static HTML
	http.HandleFunc("/", serveHTML)
	
	// Proxy API requests to bird-api service
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
    <title>Bird API Viewer</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            width: 100%;
            padding: 40px;
            text-align: center;
        }

        h1 {
            color: #333;
            margin-bottom: 30px;
            font-size: 2.5em;
        }

        .card {
            display: none;
        }

        .card.active {
            display: block;
        }

        img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }

        h2 {
            color: #667eea;
            margin-bottom: 15px;
            font-size: 1.8em;
        }

        p {
            color: #666;
            font-size: 1.1em;
            line-height: 1.6;
            margin-bottom: 25px;
        }

        button {
            padding: 12px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }

        button:active {
            transform: translateY(0);
        }

        .loading {
            display: none;
            color: #667eea;
            font-size: 1.2em;
        }

        .error {
            display: none;
            color: #e74c3c;
            background: #fadbd8;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐦 Bird Viewer</h1>
        
        <div id="loading" class="loading">
            <p>Loading bird data...</p>
        </div>

        <div id="error" class="error"></div>

        <div id="card" class="card">
            <img id="birdImage" src="" alt="Bird">
            <h2 id="birdName"></h2>
            <p id="birdDescription"></p>
        </div>

        <button onclick="fetchBird()">Get Random Bird 🔄</button>
    </div>

    <script>
        function fetchBird() {
            const loadingEl = document.getElementById("loading");
            const errorEl = document.getElementById("error");
            const cardEl = document.getElementById("card");

            loadingEl.style.display = "block";
            errorEl.style.display = "none";
            cardEl.style.display = "none";

            fetch('/api/bird')
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }
                    return response.json();
                })
                .then(data => {
                    document.getElementById("birdImage").src = data.image;
                    document.getElementById("birdName").textContent = data.name;
                    document.getElementById("birdDescription").textContent = data.description;

                    loadingEl.style.display = "none";
                    cardEl.style.display = "block";
                })
                .catch(error => {
                    console.error("Error fetching bird:", error);
                    errorEl.textContent = `Error: ${error.message}`;
                    loadingEl.style.display = "none";
                    errorEl.style.display = "block";
                });
        }

        // Load a bird when page loads
        window.addEventListener("load", fetchBird);
    </script>
</body>
</html>`

	w.Header().Set("Content-Type", "text/html")
	fmt.Fprint(w, html)
}

func getBird(w http.ResponseWriter, r *http.Request) {
	// Call the bird-api service
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