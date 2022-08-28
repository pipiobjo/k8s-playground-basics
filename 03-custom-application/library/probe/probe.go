package probe

import (
	"github.com/gorilla/mux"
	"net/http"
)

type Probe func() (string, bool)

type ProbeService struct {
	Start []Probe
	Live  []Probe
	Ready []Probe
}

// NewProbeService creates a new probe service.
func NewProbeService() *ProbeService {
	p := &ProbeService{
		Start: make([]Probe, 0),
		Ready: make([]Probe, 0),
		Live:  make([]Probe, 0)}
	return p
}

// AddStart adds a start probe to the list of executed probes when the endpoint /start is called
func (p *ProbeService) AddStart(probe Probe) {
	p.Start = append(p.Start, probe)
}

// AddLive adds a liveness probe to the list of executed probes when the endpoint /live is called
func (p *ProbeService) AddLive(probe Probe) {
	p.Live = append(p.Live, probe)
}

// AddReady adds a readiness probe to the list of executed probes when the endpoint /ready is called
func (p *ProbeService) AddReady(probe Probe) {
	p.Ready = append(p.Ready, probe)
}

// HandleProbes configures the router for the three probes endpoints.
func (p *ProbeService) HandleProbes(router *mux.Router) {

	router.
		Methods("GET").
		Path("/start").
		HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			result := p.verifyStart()
			if result {
				writeOK(w)
			} else {
				writeFail(w)
			}
		})

	router.
		Methods("GET").
		Path("/live").
		HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			result := p.verifyLive()
			if result {
				writeOK(w)
			} else {
				writeFail(w)
			}
		})

	router.
		Methods("GET").
		Path("/ready").
		HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			result := p.verifyReady()
			if result {
				writeOK(w)
			} else {
				writeFail(w)
			}
		})
}

func writeOK(w http.ResponseWriter) {
	w.WriteHeader(200)
	w.Write([]byte("{ \"ok\": true }"))
}

func writeFail(w http.ResponseWriter) {
	w.WriteHeader(500)
	w.Write([]byte("{ \"ok\": false }"))
}

func (p ProbeService) verifyStart() bool {
	result := true
	for _, p := range p.Start {
		_, ok := p()
		result = result && ok
	}
	return result
}

func (p ProbeService) verifyReady() bool {
	result := true
	for _, p := range p.Ready {
		_, ok := p()
		result = result && ok
	}
	return result
}

func (p ProbeService) verifyLive() bool {
	result := true
	for _, p := range p.Live {
		_, ok := p()
		result = result && ok
	}
	return result
}
