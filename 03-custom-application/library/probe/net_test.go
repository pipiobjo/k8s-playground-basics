package probe

import (
	"github.com/stretchr/testify/assert"
	"net/url"
	"testing"
)

func TestNewDnsProbeUrl(t *testing.T) {
	u, _ := url.Parse("https://httpbin.org/get")
	_, ok := NewDnsProbeUrl(u)()
	assert.True(t, ok)
}

func TestNewDnsProbeFail(t *testing.T) {
	_, ok := NewDnsProbe("none")()
	assert.False(t, ok)
}

func TestNewHttpGetProbeFail(t *testing.T) {
	u, _ := url.Parse("httpX://httpbin.org/get")
	_, ok := NewHttpGetProbe(*u)()
	assert.False(t, ok)
}

func TestNewHttpGetProbe(t *testing.T) {
	u, _ := url.Parse("https://httpbin.org/get")
	_, ok := NewHttpGetProbe(*u)()
	assert.True(t, ok)
}

func TestNewHttpGetProbeStatus(t *testing.T) {
	u, _ := url.Parse("https://httpbin.org/get")
	_, ok := NewHttpGetProbeStatus(*u, 200)()
	assert.True(t, ok)
}

func TestNewHttpGetProbeStatus400(t *testing.T) {
	u, _ := url.Parse("https://httpbin.org/status/400")
	_, ok := NewHttpGetProbeStatus(*u, 200)()
	assert.False(t, ok)
}
