package naming

import (
	"bytes"
	"html/template"
	"strings"
)

var tplFuncs = map[string]interface{}{
	"upper": strings.ToUpper,
	"title": strings.Title,
	"lower": strings.ToLower,
}

func GetOutputStringName(data map[string]interface{}, strategy string, val string) (map[string]string, error) {
	t, err := template.New("test").Funcs(tplFuncs).Parse(strategy)
	if err != nil {
		return nil, err
	}
	var tpl bytes.Buffer
	err = t.Execute(&tpl, data)
	if err != nil {
		return nil, err
	}
	return map[string]string{
		tpl.String(): val,
	}, nil
}

func Build(svc map[string]interface{}, envVars map[string]interface{}, strategy string) (map[string]string, error) {
	for k, v := range envVars {
		d := map[string]interface{}{
			"service": svc,
			"name":    k,
		}
		vars, err := GetOutputStringName(d, strategy, v.(string))
		if err != nil {
			return nil, err
		}
		return vars, nil
	}
	return nil, nil
}
