package naming

import "strings"

var Strategies = map[string]string{
	"none":        "{{ .name }}",
	"default":     "{{ .service.kind | upper }}_{{ .name | upper }}",
	"bindAsFiles": "{{ .name | lower }}",
}

var tplFuncs = map[string]interface{}{
	"upper": strings.ToUpper,
	"title": strings.Title,
	"lower": strings.ToLower,
}
