package types

type GreetingEchoRequest struct {
	Entries []struct {
		Name string   `json:"name"`
		Urls []string `json:"urls"`
	} `json:"entries"`
}
