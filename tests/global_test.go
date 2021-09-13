package main

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestGlobal(t *testing.T) {
	opts := &terraform.Options{
		TerraformDir: "../global",
		Vars: map[string]interface{}{
			"force_destroy": true,
		},
	}

	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)
}
