package buildinfo

import (
	"github.com/gorilla/mux"
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"net/http/httptest"
	"testing"
)

func TestVersionEndpoint(t *testing.T) {

	r := httptest.NewRequest("GET", "/v1/version", nil)
	Version = "1.2.3"
	m := mux.NewRouter()
	VersionEndpoint(m)
	w := httptest.NewRecorder()
	m.ServeHTTP(w, r)

	assert.Equal(t, 200, w.Result().StatusCode)
	b, err := ioutil.ReadAll(w.Result().Body)
	assert.NoError(t, err)
	assert.Equal(t, "{\"version\": \"1.2.3\"}\n", string(b))
}
