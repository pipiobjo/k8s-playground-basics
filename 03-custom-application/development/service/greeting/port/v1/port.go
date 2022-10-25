package v1

import (
	"encoding/json"
	"github.com/gorilla/mux"
	"github.com/rs/zerolog/log"
	"net/http"
	"pipiobjo.com/library/buildinfo"
	"pipiobjo.com/service/greeting/internal"
	"pipiobjo.com/service/greeting/internal/config"
	"pipiobjo.com/service/greeting/port/v1/types"
	"strings"
)

func HandleRest(cfg config.Config, router *mux.Router) {
	// provide version endpoint
	buildinfo.VersionEndpoint(router)

	router.
		Methods("GET").
		Path("/v1/greeting/{name}").
		HandlerFunc((func(writer http.ResponseWriter, request *http.Request) {
			log.Info().Msg("GET /v1/greeting/{name}")

			vars := mux.Vars(request)
			name, ok := vars["name"]
			if !ok {
				writer.WriteHeader(http.StatusBadRequest)
			}
			greeting, err := internal.Hello(name, cfg)
			if err != nil {
				log.Error().Msg("greeting is empty")
			} else {
				log.Debug().Msg(greeting.Name)
			}
			writer.Header().Set("Content-Type", "application/json")
			writer.WriteHeader(http.StatusOK)

			json_err := json.NewEncoder(writer).Encode(greeting)
			if json_err != nil {
				http.Error(writer, json_err.Error(), 500)
				return
			}
		}))

	// Echo requests object, for testing waf behaviour
	router.
		Methods("POST").
		Path("/v1/greeting/echo").
		HandlerFunc((func(writer http.ResponseWriter, request *http.Request) {
			log.Info().Msg("POST /v1/greeting/echo")

			in := new(types.GreetingEchoRequest)
			err := parseBody(request, in)
			if err != nil {
				log.Error().Msg("greeting can not parse json")
			}

			writer.Header().Set("Content-Type", "application/json")
			writer.WriteHeader(http.StatusOK)

			json_err := json.NewEncoder(writer).Encode(in)
			if json_err != nil {
				http.Error(writer, json_err.Error(), 500)
				return
			}
		}))

	router.
		Methods("GET").
		Path("/v1/dumpRequest").
		HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {
			log.Info().Msg("GET /v1/dumpRequest")
			header := request.Header
			for key, element := range header {
				log.Info().Msg("Request Header name:" + key + " value:" + strings.Join(element, `','`))
			}
		})

}

func parseBody(request *http.Request, data *types.GreetingEchoRequest) error {
	decoder := json.NewDecoder(request.Body)
	err := decoder.Decode(data)
	if err != nil {
		return err
	}
	return nil
}
