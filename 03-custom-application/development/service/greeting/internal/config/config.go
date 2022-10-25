package config

import (
	"github.com/rs/zerolog/log"
	"pipiobjo.com/library/configuration"
)

type Config struct {
	Service configuration.ServiceConfig `yaml:"service"`
}

func LoadConfig() Config {
	c := Config{}
	err := configuration.NewConfigLoader().LoadConfig(&c)
	if err != nil {
		log.Err(err).Msg("cannot load config")
	}
	return c
}
