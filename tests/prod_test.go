package main

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestProd(t *testing.T) {
	opts := &terraform.Options{
		TerraformDir: "../prod",
	}

	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)
}
