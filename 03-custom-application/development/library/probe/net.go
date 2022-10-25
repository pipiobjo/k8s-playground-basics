package probe

import (
	"net"
	"net/http"
	"net/url"
)

func NewDnsProbeUrl(url *url.URL) func() (string, bool) {
	return NewDnsProbe(url.Host)
}

func NewDnsProbe(url string) func() (string, bool) {
	return func() (string, bool) {
		adr, err := net.LookupHost(url)

		if err != nil {
			return err.Error(), false
		}

		if len(adr) > 0 {
			return "ok", true
		}
		return "fail, no addresses resolved", false
	}
}

func NewHttpGetProbe(url url.URL) func() (string, bool) {
	return NewHttpGetProbeStatus(url, 200)
}

func NewHttpGetProbeStatus(url url.URL, status int) func() (string, bool) {
	return func() (string, bool) {
		res, err := http.Get(url.String())
		if err != nil {
			return err.Error(), false
		}

		if res.StatusCode > status {
			return res.Status, false
		}

		return "ok", true
	}

}
