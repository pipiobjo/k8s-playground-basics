package internal

import (
	"errors"
	"fmt"
	"github.com/rs/zerolog/log"
	"math/rand"
	"pipiobjo.com/service/greeting/internal/config"
	"sync/atomic"
)

type Greeting struct {
	Id      uint64 `json:"id"`
	Name    string `json:"name"`
	Message string `json:"message"`
}

var ops uint64 = 0

func Hello(name string, cfg config.Config) (Greeting, error) {
	var result Greeting
	if name == "" {
		log.Info().Str("name", cfg.Service.Name).Str("logger", "internal/GreetingService").Msg("name is not set")
		return result, errors.New("empty name")
	}

	// Create a message using a random format.
	message := fmt.Sprintf(randomFormat(), name)
	result.Name = name
	result.Message = message
	result.Id = atomic.AddUint64(&ops, 1)
	return result, nil
}

func randomFormat() string {
	formats := []string{
		"Hi, %v. Welcome!",
		"Great to see you, %v!",
		"Servus, %v! Well met!",
	}

	return formats[rand.Intn(len(formats))]
}
