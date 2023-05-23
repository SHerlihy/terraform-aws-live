package tests_terraform_aws_live_plan

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
	"strings"
	"testing"
)

func TestProdPlan(t *testing.T) {
	httpListenerPort := float64(80)

	opts := &terraform.Options{
		TerraformDir:"../prod",
	}

	defer terraform.Destroy(t, opts)

	planStruct := terraform.InitAndPlanAndShowWithStructNoLogTempPlanFile(t, opts)

	keys := make([]string, 0, len(planStruct.ResourcePlannedValuesMap))

	for k := range planStruct.ResourcePlannedValuesMap {
		keys = append(keys, k)
	}

	t.Log(strings.Join(keys, " "))

	http_listener, exists := planStruct.ResourcePlannedValuesMap["module.initial_app.module.lb_http.aws_lb_listener.http"]
	require.True(t, exists, "no http listener")

	listen_port, exists := http_listener.AttributeValues["port"]
	require.True(t, exists, "no http listener port")
	require.Equal(t, httpListenerPort, listen_port)
}
