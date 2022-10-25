package buildinfo

import (
	"fmt"
	"io"
	"net/http"

	"github.com/gorilla/mux"
)

var Version string

func VersionEndpoint(router *mux.Router, v ...string) *mux.Route {
	var version string
	if len(v) > 0 {
		version = v[0]
	} else {
		version = "v1"
	}

	return router.
		Methods("GET").
		Path(fmt.Sprintf(`/%s/version`, version)).
		HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {
			requestedContentType := request.Header.Get("Content-Type")
			if requestedContentType == "text/plain" {
				writer.Header().Set("Content-Type", "text/plain")
				io.WriteString(writer, Version)
			} else {
				writer.Header().Set("Content-Type", "application/json")
				writer.WriteHeader(http.StatusOK)
				io.WriteString(writer, "{\"version\": \""+Version+"\"}\n")
			}
		})
}
