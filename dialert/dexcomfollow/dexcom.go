package dexcomfollow

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"strconv"

	"github.com/google/uuid"
)

type DexcomError struct {
	Code    string `json:"Code"`
	Message string `json:"Message"`
}

type Dexcom struct {
	Username  string
	AccountID string
	Password  string
	BaseURL   string
	SessionID string
	Client    *http.Client
}

func NewDexcom(username, accountID, password string, ous bool) *Dexcom {
	baseURL := DEXCOM_BASE_URL
	if ous {
		baseURL = DEXCOM_BASE_URL_OUS
	}

	return &Dexcom{
		Username:  username,
		AccountID: accountID,
		Password:  password,
		BaseURL:   baseURL,
		Client:    &http.Client{},
	}
}

func (d *Dexcom) authenticate() error {
	// Implement authentication logic
	return nil
}

func (d *Dexcom) post(endpoint string, params map[string]string, jsonBody map[string]interface{}) (map[string]interface{}, error) {
	url := fmt.Sprintf("%s/%s", d.BaseURL, endpoint)
	reqBody, err := json.Marshal(jsonBody)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(reqBody))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Accept-Encoding", "application/json")
	q := req.URL.Query()
	for key, value := range params {
		q.Add(key, value)
	}
	req.URL.RawQuery = q.Encode()

	resp, err := d.Client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("request failed with status code: %d", resp.StatusCode)
	}

	var result map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		return nil, err
	}

	return result, nil
}

func (d *Dexcom) handleResponse(resp *http.Response) error {
	// Handle response logic
	return nil
}

func (d *Dexcom) validateSessionID() error {
	if d.SessionID == "" || d.SessionID == DEFAULT_UUID {
		return errors.New("invalid session ID")
	}
	_, err := uuid.Parse(d.SessionID)
	if err != nil {
		return errors.New("invalid session ID")
	}
	return nil
}

func (d *Dexcom) getGlucoseReadings(minutes, maxCount int) ([]*GlucoseReading, error) {
	if minutes <= 0 || minutes > MAX_MINUTES {
		return nil, errors.New("invalid minutes parameter")
	}

	if maxCount <= 0 || maxCount > MAX_MAX_COUNT {
		return nil, errors.New("invalid maxCount parameter")
	}

	params := map[string]string{
		"sessionId": d.SessionID,
		"minutes":   strconv.Itoa(minutes),
		"maxCount":  strconv.Itoa(maxCount),
	}

	resp, err := d.post(DEXCOM_GLUCOSE_READINGS_ENDPOINT, params, nil)
	if err != nil {
		return nil, err
	}

	jsonReadings, ok := resp["Readings"].([]interface{})
	if !ok {
		return nil, errors.New("failed to parse glucose readings")
	}

	var readings []*GlucoseReading
	for _, jr := range jsonReadings {
		readingMap, ok := jr.(map[string]interface{})
		if !ok {
			continue
		}

		reading, err := ParseGlucoseReading(readingMap)
		if err != nil {
			log.Printf("failed to parse reading: %v", err)
			continue
		}

		readings = append(readings, reading)
	}

	return readings, nil
}

func (d *Dexcom) GetLatestGlucoseReading() (*GlucoseReading, error) {
	readings, err := d.getGlucoseReadings(MAX_MINUTES, 1)
	if err != nil {
		return nil, err
	}

	if len(readings) == 0 {
		return nil, nil
	}

	return readings[0], nil
}

func (d *Dexcom) GetCurrentGlucoseReading() (*GlucoseReading, error) {
	readings, err := d.getGlucoseReadings(10, 1)
	if err != nil {
		return nil, err
	}

	if len(readings) == 0 {
		return nil, nil
	}

	return readings[0], nil
}
