package filter

import (
	"github.com/stretchr/testify/assert"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestFilterGroup(t *testing.T) {

	f := func(next http.Handler) http.Handler {
		return next
	}

	fg := FilterGroup(f)

	assert.True(t, len(fg) == 1)

}

func TestFilterChain(t *testing.T) {

	f := func(next http.Handler) http.Handler {
		return next
	}

	fg := FilterGroup(f, RequestLogger())

	fc := FilterChain(fg, http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {}))

	r := httptest.NewRequest("GET", "/test", strings.NewReader(""))
	fc.ServeHTTP(httptest.NewRecorder(), r)

}
