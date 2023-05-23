package tests_terraform_aws_live

import (
	"os"
	"testing"
pt "github.com/SHerlihy/terraform-aws-live/tests/tests_terraform_aws_live_plan"
)

func TestPlan(t *testing.T) {
	stackEnv := os.Getenv("STACK_ENV")

	if stackEnv == "prod" {
        pt.TestProdPlan(t)
	} else {
        pt.TestStagePlan(t)
	}
}
