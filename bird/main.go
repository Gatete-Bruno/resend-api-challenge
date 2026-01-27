package main

import (
	"encoding/json"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"net/url"
)

type Bird struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Image       string `json:"image"`
}

func defaultBird(err error) Bird {
	return Bird{
		Name:        "Bird in disguise",
		Description: fmt.Sprintf("This bird is in disguise because: %s", err),
		Image:       "https://www.pokemonmillennium.net/wp-content/uploads/2015/11/missingno.png",
	}
}

func getBirdImage(birdName string) (string, error) {
	res, err := http.Get(fmt.Sprintf("http://bird-api-release-bird-image-api-service:80/?birdName=%s", url.QueryEscape(birdName)))
	if err != nil {
		return "", err
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return "", err
	}

	// Unmarshal and check if the response is valid
	var imageURL string
	if err := json.Unmarshal(body, &imageURL); err != nil {
		return "", err
	}

	return imageURL, nil
}

func getBirdFactoid() Bird {
	res, err := http.Get(fmt.Sprintf("https://freetestapi.com/api/v1/birds/%d", rand.Intn(50)))
	if err != nil {
		fmt.Printf("Error reading bird API: %s\n", err)
		return defaultBird(err)
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		fmt.Printf("Error parsing bird API response: %s\n", err)
		return defaultBird(err)
	}

	var bird Bird
	if err := json.Unmarshal(body, &bird); err != nil {
		fmt.Printf("Error unmarshalling bird: %s\n", err)
		return defaultBird(err)
	}

	birdImage, err := getBirdImage(bird.Name)
	if err != nil {
		fmt.Printf("Error in getting bird image: %s\n", err)
		return defaultBird(err)
	}

	bird.Image = birdImage
	return bird
}

func bird(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	birdFactoid := getBirdFactoid()
	if err := json.NewEncoder(w).Encode(birdFactoid); err != nil {
		http.Error(w, "Error encoding response", http.StatusInternalServerError)
	}
}

func main() {
	http.HandleFunc("/", bird)
	http.ListenAndServe(":4201", nil)
}
