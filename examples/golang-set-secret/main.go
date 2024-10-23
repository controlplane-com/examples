package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

// SecretPayload represents the request body structure
type SecretPayload struct {
	Name        string     `json:"name"`
	Description string     `json:"description"`
	Type        string     `json:"type"`
	Data        SecretData `json:"data"`
}

// SecretData represents the nested data structure
type SecretData struct {
	Payload  string `json:"payload"`
	Encoding string `json:"encoding"`
}

// WebServiceRequest represents the incoming request for the web service
type WebServiceRequest struct {
	Name  string `json:"name"`
	Value string `json:"value"`
}

func main() {
	http.HandleFunc("/set-secret", handleSetSecret)
	http.HandleFunc("/", handleHealthCheck)
	fmt.Println("Server is running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleSetSecret(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req WebServiceRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	cpln_token := os.Getenv("CPLN_TOKEN")
	if cpln_token == "" {
		http.Error(w, "CPLN_TOKEN environment variable is not set", http.StatusInternalServerError)
		return
	}

	cpln_endpoint := os.Getenv("CPLN_ENDPOINT")
	if cpln_endpoint == "" {
		http.Error(w, "CPLN_ENPOINT environment variable is not set", http.StatusInternalServerError)
		return
	}

	cpln_org := os.Getenv("CPLN_ORG")
	if cpln_org == "" {
		http.Error(w, "CPLN_ORG environment variable is not set", http.StatusInternalServerError)
		return
	}

	// API endpoint
	url := fmt.Sprintf("%s/org/%s/secret", cpln_endpoint, cpln_org)
	println("URL: ", url)

	// Create the request payload
	payload := SecretPayload{
		Name:        req.Name,
		Description: "Set via web service",
		Type:        "opaque",
		Data: SecretData{
			Payload:  req.Value,
			Encoding: "plain",
		},
	}

	// Convert payload to JSON
	jsonData, err := json.Marshal(payload)
	if err != nil {
		http.Error(w, "Failed to marshal JSON", http.StatusInternalServerError)
		return
	}

	// Create new request
	httpReq, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}

	// Set headers
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", cpln_token)

	// Create HTTP client
	client := &http.Client{}

	// Send request
	resp, err := client.Do(httpReq)
	if err != nil {
		http.Error(w, "Failed to send request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// Read response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, "Failed to read response", http.StatusInternalServerError)
		return
	}

	// Print response status and body
	fmt.Printf("Response Status: %s\n", resp.Status)
	fmt.Printf("Response Body: %s\n", string(body))
}

func handleHealthCheck(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}
