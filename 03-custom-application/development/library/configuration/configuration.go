package configuration

import (
	"gopkg.in/yaml.v3"
	"io/ioutil"
	"os"
	"reflect"
	"regexp"
	"strings"
)

const envRegexp = `\${[Ee][Nn][Vv]:([A-Z\-\_]*)}`

var defaultPaths = []string{"", "k8s/dev/", "config/", "./config/", "/config/"}
var defaultFileName = "config.yaml"

type ConfigLoader interface {
	LoadConfig(cfg interface{}) error
	LoadConfigData([]byte, interface{}) error
	Paths(p ...string) ConfigLoader
	File(f string) ConfigLoader
}

type ConfigLoaderImpl struct {
	paths []string
	file  string
}

func NewConfigLoader() ConfigLoader {
	return ConfigLoaderImpl{
		paths: defaultPaths,
		file:  defaultFileName,
	}
}

func (c ConfigLoaderImpl) Paths(p ...string) ConfigLoader {
	c.paths = p
	return c
}

func (c ConfigLoaderImpl) File(f string) ConfigLoader {
	c.file = f
	return c
}

func (c ConfigLoaderImpl) LoadConfigData(data []byte, cfg interface{}) error {
	err := yaml.Unmarshal(data, cfg)
	if err != nil {
		return err
	}

	reg, err := regexp.Compile(envRegexp)
	if err != nil {
		return err
	}
	resolvePasswords(cfg, reg)
	return nil
}

func (c ConfigLoaderImpl) LoadConfig(cfg interface{}) error {

	file := c.getFileName()

	data, err := ioutil.ReadFile(file)
	if err != nil {
		return err
	}

	err = yaml.Unmarshal(data, cfg)
	if err != nil {
		return err
	}

	reg, err := regexp.Compile(envRegexp)
	if err != nil {
		return err
	}

	resolvePasswords(cfg, reg)
	return nil
}

func (c ConfigLoaderImpl) getFileName() string {
	for _, p := range c.paths {
		fn := p + c.file
		file, err := os.Stat(fn)
		if err == nil && !file.IsDir() {
			return fn
		}
	}
	return c.file
}

func resolvePasswords(cfg interface{}, regexp *regexp.Regexp) {
	v := reflect.ValueOf(cfg)
	resolveEnvironment(v, regexp)
}

func resolveEnvironment(v reflect.Value, regexp *regexp.Regexp) {

	if v.Kind() == reflect.Ptr && !v.IsNil() {
		v = v.Elem()
	}

	for i := 0; i < v.NumField(); i++ {
		value := v.Field(i)
		if value.Kind() == reflect.String {
			cv := value.String()
			if strings.HasPrefix(strings.ToLower(cv), "${env:") && strings.HasSuffix(cv, "}") {
				env := extractVariable(cv, regexp)
				value.SetString(os.Getenv(env))
			}

		} else if value.Kind() == reflect.Struct {
			resolveEnvironment(value, regexp)
		}
	}
}

func extractVariable(s string, regexp *regexp.Regexp) string {
	return regexp.ReplaceAllString(s, "$1")
}
