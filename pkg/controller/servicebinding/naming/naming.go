package naming

import (
	"bytes"
	"html/template"
)

func GetOutputStringName(data map[string]interface{}, strategy string, val string) (string, string, error) {
	t, err := template.New("naming").Funcs(tplFuncs).Parse(strategy)
	if err != nil {
		return "", "", err
	}
	var tpl bytes.Buffer
	err = t.Execute(&tpl, data)
	if err != nil {
		return "", "", err
	}
	return tpl.String(), val, nil
}

func Build(svc map[string]interface{}, envVars map[string]string, strategy string) (map[string]string, error) {
	variables := make(map[string]string)
	for k, v := range envVars {
		d := map[string]interface{}{
			"service": svc,
			"name":    k,
		}

		envKey, envValue, err := GetOutputStringName(d, strategy, v)
		if err != nil {
			return nil, err
		}
		variables[envKey] = envValue
	}
	return variables, nil
}
