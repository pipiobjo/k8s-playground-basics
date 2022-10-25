module pipiobjo.com/service/greeting

go 1.18

require (
	github.com/gorilla/mux v1.8.0
	github.com/rs/zerolog v1.27.0
	github.com/stretchr/testify v1.7.2
	pipiobjo.com/library/buildinfo v0.0.0
	pipiobjo.com/library/configuration v0.0.0
	pipiobjo.com/library/filter v0.0.0
	pipiobjo.com/library/probe v0.0.0
	pipiobjo.com/library/shutdown v0.0.0

)

require (
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/kr/text v0.2.0 // indirect
	github.com/mattn/go-colorable v0.1.12 // indirect
	github.com/mattn/go-isatty v0.0.14 // indirect
	github.com/niemeyer/pretty v0.0.0-20200227124842-a10e7caefd8e // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	golang.org/x/sys v0.0.0-20220209214540-3681064d5158 // indirect
	gopkg.in/check.v1 v1.0.0-20200227125254-8fa46927fb4f // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)

replace (
	pipiobjo.com/library/buildinfo v0.0.0 => ../../library/buildinfo
	pipiobjo.com/library/configuration v0.0.0 => ../../library/configuration
	pipiobjo.com/library/filter v0.0.0 => ../../library/filter
	pipiobjo.com/library/probe v0.0.0 => ../../library/probe
	pipiobjo.com/library/shutdown v0.0.0 => ../../library/shutdown
)
