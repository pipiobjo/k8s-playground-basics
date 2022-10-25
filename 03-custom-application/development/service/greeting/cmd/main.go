package main

import (
	"github.com/gorilla/mux"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"net/http"
	"pipiobjo.com/library/buildinfo"
	"pipiobjo.com/library/probe"
	"pipiobjo.com/library/shutdown"
	"pipiobjo.com/service/greeting/internal/config"
	v1 "pipiobjo.com/service/greeting/port/v1"
)

type server struct {
	Config config.Config
}

func main() {
	cfg := config.LoadConfig()

	server := NewServer(cfg)

	go func() {
		server.initProbes()
	}()

	go func() {
		server.initRest()
	}()
	shutdown.WaitForTermination()
}

func NewServer(cfg config.Config) *server {
	level, err := zerolog.ParseLevel(cfg.Service.LogLevel)
	log.Info().Str("name", cfg.Service.Name).Str("version", buildinfo.Version).Msg("starting service blueprint")
	if err == nil {
		zerolog.SetGlobalLevel(level)
	} else {
		zerolog.SetGlobalLevel(zerolog.InfoLevel)
	}

	return &server{
		Config: cfg,
	}
}

func (s server) initProbes() {

	router := mux.NewRouter()
	probes := probe.NewProbeService()
	probes.HandleProbes(router)

	probes.AddLive(func() (string, bool) {
		return "server", true
	})

	log.Info().Int("port", s.Config.Service.Health).Msg("starting health probes")
	http.ListenAndServe(s.Config.Service.HealthAdr(), router)
}

func (s server) initRest() {

	router := mux.NewRouter()
	v1.HandleRest(s.Config, router)

	log.Info().Int("port", s.Config.Service.Rest).Msg("starting rest endpoint")
	err := http.ListenAndServe(s.Config.Service.RestAdr(), router)
	if err != nil {
		log.Fatal().Str("error", err.Error()).Msg("Error while starting rest endpoint")
	}
}
