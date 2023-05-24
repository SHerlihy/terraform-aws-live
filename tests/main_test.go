package tests_terraform_aws_live

import (
	e2e "github.com/SHerlihy/terraform-aws-live/tests/tests_terraform_aws_live_e2e"
	pt "github.com/SHerlihy/terraform-aws-live/tests/tests_terraform_aws_live_plan"
	"os"
	"testing"
)

func TestPlan(t *testing.T) {
	stackEnv := os.Getenv("STACK_ENV")

	if stackEnv == "prod" {
		pt.TestProdPlan(t)
	} else {
		pt.TestStagePlan(t)
	}
}

func TestE2E(t *testing.T) {
	e2e.TestE2E(t)
}
