package configuration

import (
	"github.com/stretchr/testify/assert"
	"os"
	"testing"
)

type Configuration struct {
	Url      string `yaml:"url"`
	UserId   string `yaml:"userId"`
	Password string `yaml:"password"`
	Nested   Nested `yaml:"nested"`
}

type Nested struct {
	Pwd string `yaml:"pwd"`
}

var data = `
url: test
userId: userid
password: ${ENV:SECRET_PWD}
nested:
  pwd: ${env:NESTED_SECRET_PWD}
`

func Test_LoadConfig(t *testing.T) {

	os.Setenv("SECRET_PWD", "secure")
	os.Setenv("NESTED_SECRET_PWD", "moresecure")

	c := &Configuration{}
	err := NewConfigLoader().LoadConfigData([]byte(data), c)
	assert.Nil(t, err)
	assert.Equal(t, "secure", c.Password)
	assert.Equal(t, "moresecure", c.Nested.Pwd)

}

func Test_LoadConfigFail(t *testing.T) {
	os.Setenv("SECRET_PWD", "secure")
	os.Setenv("NESTED_SECRET_PWD-", "moresecure")

	c := &Configuration{}
	err := NewConfigLoader().File("unknown.yaml").LoadConfig(c)
	assert.NotNil(t, err)
}

func Test_LoadConfigFromFile(t *testing.T) {
	os.Setenv("SECRET_PWD", "secure")
	os.Setenv("NESTED_SECRET_PWD", "moresecure")

	c := &Configuration{}
	err := NewConfigLoader().Paths("config/").LoadConfig(c)
	assert.Nil(t, err)
	assert.Equal(t, "secure", c.Password)
	assert.Equal(t, "moresecure", c.Nested.Pwd)
}

func Test_LoadConfigFromFileDefault(t *testing.T) {
	os.Setenv("SECRET_PWD", "secure")
	os.Setenv("NESTED_SECRET_PWD", "moresecure")

	c := &Configuration{}
	err := NewConfigLoader().LoadConfig(c)
	assert.Nil(t, err)
	assert.Equal(t, "secure", c.Password)
	assert.Equal(t, "moresecure", c.Nested.Pwd)
}

func Test_LoadConfigFromFileName(t *testing.T) {
	os.Setenv("SECRET_PWD", "secure")
	os.Setenv("NESTED_SECRET_PWD", "moresecure")

	c := &Configuration{}
	err := NewConfigLoader().File("config.yml").LoadConfig(c)
	assert.Nil(t, err)
	assert.Equal(t, "secure", c.Password)
	assert.Equal(t, "moresecure", c.Nested.Pwd)
}
