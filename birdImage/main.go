package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
)

type Urls struct {
	Thumb   string `json:"thumb"`
	Small   string `json:"small"`
	Regular string `json:"regular"`
	Full    string `json:"full"`
}

type Links struct {
	Urls Urls `json:"urls"`
}

type ImageResponse struct {
	Results []Links `json:"results"`
}

type Bird struct {
	Image string
}

func defaultImage() string {
	return "https://www.pokemonmillennium.net/wp-content/uploads/2015/11/missingno.png"
}

func getBirdImage(birdName string) string {
	var query = fmt.Sprintf(
		"https://api.unsplash.com/search/photos?page=1&query=%s&client_id=P1p3WPuRfpi7BdnG8xOrGKrRSvU1Puxc1aueUWeQVAI&per_page=1",
		url.QueryEscape(birdName),
	)
	res, err := http.Get(query)
	if err != nil {
		fmt.Printf("Error reading image API: %s\n", err)
		return defaultImage()
	}
	defer res.Body.Close()
	
	body, err := io.ReadAll(res.Body)
	if err != nil {
		fmt.Printf("Error parsing image API response: %s\n", err)
		return defaultImage()
	}
	var response ImageResponse
	err = json.Unmarshal(body, &response)
	if err != nil {
		fmt.Printf("Error unmarshalling bird image: %s", err)
		return defaultImage()
	}
	
	if len(response.Results) == 0 {
		return defaultImage()
	}
	
	// Get the full URL
	baseImage := response.Results[0].Urls.Full
	if baseImage == "" {
		baseImage = response.Results[0].Urls.Regular
	}
	
	// Replace low quality params with high quality params
	// Replace w=200 with w=2000 and q=80 with q=100
	highQualityImage := strings.ReplaceAll(baseImage, "w=200", "w=2000")
	highQualityImage = strings.ReplaceAll(highQualityImage, "q=80", "q=100")
	
	return highQualityImage
}

func bird(w http.ResponseWriter, r *http.Request) {
	var buffer bytes.Buffer
	birdName := r.URL.Query().Get("birdName")
	if birdName == "" {
		json.NewEncoder(&buffer).Encode(defaultImage())
	} else {
		json.NewEncoder(&buffer).Encode(getBirdImage(birdName))
	}
	io.WriteString(w, buffer.String())
}

func main() {
	http.HandleFunc("/", bird)
	http.ListenAndServe(":4200", nil)
}