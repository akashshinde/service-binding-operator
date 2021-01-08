package naming

import "testing"

func TestName(t *testing.T) {
	data := map[string]interface{}{
		"service": map[string]interface{}{
			"name": "database",
		},
		"name": "db",
	}
	envVars := map[string]interface{}{
		"apikey": "abcdef",
	}

	strategy := "{{.service.name | upper }}_{{.name | title}}"

	vars, err := Build(data, envVars, strategy)
	if err != nil {
		t.Fatalf(err.Error())
	}
	if len(vars) != 1 {
		t.Fail()
	}
	t.Log(vars)
}
