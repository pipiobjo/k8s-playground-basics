package filter

import (
	"net/http"
	"strconv"
	"time"

	"github.com/rs/zerolog/log"
)

type Filter func(http.Handler) http.Handler

func FilterGroup(adapters ...Filter) []Filter {
	return adapters
}

func FilterChain(group []Filter, handler http.Handler) http.Handler {

	// Joining handlers
	for i := len(group); i > 0; i-- {
		handler = group[i-1](handler)
	}

	// return final handler chain
	return http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
		handler.ServeHTTP(res, req)
	})
}

func CheckContentLength(maxLength int) Filter {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
			clHeader := req.Header.Get("Content-Length")

			if clHeader == "" {
				log.Warn().Msg("no content length present in header")
				res.WriteHeader(http.StatusLengthRequired)
				return
			}

			cl, err := strconv.Atoi(clHeader)
			if err != nil {
				log.Warn().Msg("non integer content length provided")
				res.WriteHeader(http.StatusLengthRequired)
				return
			}

			if cl > maxLength {
				log.Warn().Int("max", maxLength).Int("actual", cl).Msg("content length exceeded")
				res.WriteHeader(http.StatusBadRequest)
				return
			}

			next.ServeHTTP(res, req)
		})
	}
}

func RequestLogger() Filter {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(res http.ResponseWriter, req *http.Request) {

			t1 := time.Now()
			next.ServeHTTP(res, req)
			// TODO use context to get the http status for logging
			log.Info().Str("method", req.Method).Str("path", req.URL.Path).Dur("duration", time.Now().Sub(t1)).Msg("handling")
		})
	}
}
