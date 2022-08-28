package internal

import (
	"github.com/stretchr/testify/assert"
	"pipiobjo.com/service/greeting/internal/config"
	"testing"
)

func TestHello(t *testing.T) {
	var cfg = config.Config{}
	cfg.Service.Name = "test"

	greeting, err := Hello("userName", cfg)

	assert.Nil(t, err)
	assert.NotNilf(t, greeting, "expecting greetings")
	//assert.Nilf(t, greeting, "fail for testing reports")

}
