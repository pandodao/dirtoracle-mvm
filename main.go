package main

import (
	"fmt"

	"github.com/pandodao/dirtoracle-mvm/cmd"
)

var (
	version string
	commit  string
)

func main() {
	ver := fmt.Sprintf("%s (%s)", version, commit)
	cmd.Execute(ver)
}
