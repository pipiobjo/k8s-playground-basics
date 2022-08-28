package configuration

import (
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"strconv"
)

// ServiceConfig is a struct for the standard rest and health port declaration
type ServiceConfig struct {
	Name     string `yaml:"name"`
	Rest     int    `yaml:"rest"`
	Health   int    `yaml:"health"`
	LogLevel string `yaml:"logLevel"`
}

// RestAdr returns the address and the port for the rest endpoint in the format ":<PORT>"
func (s ServiceConfig) RestAdr() string {
	return ":" + strconv.Itoa(s.Rest)
}

// HealthAdr returns the address and the port for the health endpoint in the format ":<PORT>"
func (s ServiceConfig) HealthAdr() string {
	return ":" + strconv.Itoa(s.Health)
}

// Level returns the configured level or Info if the level is not parsable
func (s ServiceConfig) Level() (level zerolog.Level) {
	level, err := zerolog.ParseLevel(s.LogLevel)
	if err != nil {
		zerolog.SetGlobalLevel(zerolog.InfoLevel)
		log.Err(err).Str("level", s.LogLevel).Msg("unparsable log level")
	}
	log.Info().Str("level", level.String()).Msg("using loglevel")
	return
}
