// Package datetime parses XSD dateTime strings as defined by RFC 7643 Section 2.3.5.
package datetime

import (
	"fmt"
	"time"
)

// Parse parses an XSD dateTime string into a time.Time value.
// Accepts the format: YYYY-MM-DDThh:mm:ss[.fffffffff][Z|(+|-)hh:mm]
// When no timezone is present, UTC is assumed.
// Go's time.Parse automatically accepts fractional seconds even when the
// layout omits them, so a single layout covers all fractional-second variants.
func Parse(value string) (time.Time, error) {
	if t, err := time.Parse(time.RFC3339, value); err == nil {
		return t, nil
	}
	if t, err := time.Parse("2006-01-02T15:04:05", value); err == nil {
		return t, nil
	}
	return time.Time{}, fmt.Errorf("invalid xsd:dateTime value: %q", value)
}
