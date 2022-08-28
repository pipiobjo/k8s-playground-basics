package shutdown

import (
	"github.com/rs/zerolog/log"
	"os"
	"os/signal"
	"syscall"
)

// WaitForTermination waits for the TERM or INT signal to stop the service.
func WaitForTermination() {
	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGTERM, syscall.SIGINT)
	rec := <-sig
	log.Info().Str("signal", rec.String()).Msg("terminating service")
}
