package filter

import (
	"github.com/rs/zerolog/log"
	"net/http"
	"time"
)

func LogTime(delegate http.HandlerFunc) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		t1 := time.Now()
		delegate.ServeHTTP(w, r)
		log.Info().Str("path", r.URL.Path).Dur("duration", time.Now().Sub(t1)).Msg("handling get")
	}
}
