package naming

import "testing"

func TestName(t *testing.T) {
	data := map[string]interface{}{
		"service": map[string]interface{}{
			"name": "database",
			"kind": "Service",
		},
		"name": "db",
	}
	envVars := map[string]string{
		"apikey": "abcdef",
		"port":   "8888",
	}

	//strategy := "{{.service.name | upper }}_{{.name | title}}"

	vars, err := Build(data, envVars, "none")
	if err != nil {
		t.Fatalf(err.Error())
	}
	if len(vars) != 1 {
		t.Fail()
	}
	t.Log(vars)
}
