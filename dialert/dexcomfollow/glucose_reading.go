package dexcomfollow

import (
	"errors"
	"regexp"
	"strconv"
	"time"
)

type GlucoseReading struct {
	Value          int       `json:"Value"`
	Trend          int       `json:"Trend"`
	TrendDirection string    `json:"TrendDirection"`
	DateTime       time.Time `json:"WT"`
}

func (gr *GlucoseReading) ValueInMgDl() int {
	return gr.Value
}

func (gr *GlucoseReading) ValueInMmolL() float64 {
	return float64(gr.Value) * MMOL_L_CONVERSION_FACTOR
}

func (gr *GlucoseReading) TrendDescription() string {
	return TREND_DESCRIPTIONS[gr.Trend]
}

func (gr *GlucoseReading) TrendArrow() string {
	return TREND_ARROWS[gr.Trend]
}

func ParseGlucoseReading(jsonGlucoseReading map[string]interface{}) (*GlucoseReading, error) {
	value, ok := jsonGlucoseReading["Value"].(float64)
	if !ok {
		return nil, errors.New("invalid glucose reading value")
	}

	trendDirection, ok := jsonGlucoseReading["Trend"].(string)
	if !ok {
		return nil, errors.New("invalid trend direction")
	}

	trend, ok := DEXCOM_TREND_DIRECTIONS[trendDirection]
	if !ok {
		return nil, errors.New("invalid trend")
	}

	timestampStr, ok := jsonGlucoseReading["WT"].(string)
	if !ok {
		return nil, errors.New("invalid timestamp")
	}

	re := regexp.MustCompile("[^0-9]")
	timestamp, err := strconv.ParseInt(re.ReplaceAllString(timestampStr, ""), 10, 64)
	if err != nil {
		return nil, err
	}

	return &GlucoseReading{
		Value:          int(value),
		Trend:          trend,
		TrendDirection: trendDirection,
		DateTime:       time.Unix(timestamp/1000, 0),
	}, nil
}
