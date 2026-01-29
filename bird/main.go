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

var birds = []Bird{
	{
		Name:        "American Robin",
		Description: "The American Robin is a migratory songbird of the thrush family. It is widely distributed across North America.",
	},
	{
		Name:        "Bald Eagle",
		Description: "The Bald Eagle is a large raptor found solely in North America. It is most recognizable by its white-headed and dark brown plumaged body.",
	},
	{
		Name:        "Blue Jay",
		Description: "The Blue Jay is a passerine bird in the family Corvidae, native to eastern North America. It is resident through most of the eastern and central United States east of the Rocky Mountains.",
	},
	{
		Name:        "Cardinal",
		Description: "Cardinals are songbirds with a distinctive crest on their heads. Males are bright red while females are tan or reddish colored.",
	},
	{
		Name:        "Roseate Spoonbill",
		Description: "The Roseate Spoonbill is a large wading bird known for its distinctive pink plumage and spoon-shaped bill used for feeding.",
	},
	{
		Name:        "Great Blue Heron",
		Description: "The Great Blue Heron is a large wading bird commonly found in freshwater and saltwater environments. It hunts by standing still and waiting for fish to come within striking distance.",
	},
	{
		Name:        "Mallard",
		Description: "The Mallard is a dabbling duck found throughout the Northern Hemisphere. Males have distinctive green heads and females are mottled brown.",
	},
	{
		Name:        "Red-tailed Hawk",
		Description: "The Red-tailed Hawk is one of the most common large raptors in North America. It is easily identified by its distinctive red tail feathers.",
	},
	{
		Name:        "Mourning Dove",
		Description: "The Mourning Dove is a member of the dove family. It is named for its mournful call and is the most hunted bird in North America.",
	},
	{
		Name:        "Pileated Woodpecker",
		Description: "The Pileated Woodpecker is a large woodpecker native to the Pacific coast, the Rocky Mountains, and the eastern half of North America.",
	},
	{
		Name:        "Steller's Jay",
		Description: "The Steller's Jay is a jay native to the western coast of North America. It is the most northerly jay in the Americas.",
	},
	{
		Name:        "American Goldfinch",
		Description: "The American Goldfinch is a small finch with bright yellow plumage in breeding males. It is found throughout most of North America.",
	},
}

func defaultBird(err error) Bird {
	return Bird{
		Name:        "Bird in disguise",
		Description: fmt.Sprintf("This bird is in disguise because: %s", err),
		Image:       "https://www.pokemonmillennium.net/wp-content/uploads/2015/11/missingno.png",
	}
}

func getBirdImage(birdName string) (string, error) {
	res, err := http.Get(fmt.Sprintf("http://bird-image-api-service:80/?birdName=%s", url.QueryEscape(birdName)))
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
	// Use local bird data instead of external API
	randomBird := birds[rand.Intn(len(birds))]
	
	birdImage, err := getBirdImage(randomBird.Name)
	if err != nil {
		fmt.Printf("Error in getting bird image: %s\n", err)
		return defaultBird(err)
	}

	randomBird.Image = birdImage
	return randomBird
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