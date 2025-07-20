// Default packages needed
package test

// Imports (In this case: SSH / Tf / Assertions)
import (
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestEC2Provisioning(t *testing.T) {
	// Run this test in parallel with other tests
	t.Parallel()

	// Define where your Terraform code lives
	terraformOptions := &terraform.Options{
		TerraformDir: "..", // assumes Terraform is one level above /test
	}

	// Deploy the infrastructure and ensure it is destroyed at the end of the test
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Get the public IP and output file path
	publicIP := terraform.Output(t, terraformOptions, "public_ip")
	assert.NotEmpty(t, publicIP, "Public IP must not be empty")

	// Define the path to your private key file
	privateKeyPath := "../my_key_pair.pem"

	// Secure the key file
	err := os.Chmod(privateKeyPath, 0400)
	if err != nil {
		t.Fatalf("Failed to chmod private key: %v", err)
	}

	// Read the private key file
	privateKeyBytes, err := os.ReadFile(privateKeyPath)
	if err != nil {
		t.Fatalf("Failed to read private key: %v", err)
	}

	// Setup SSH
	keyPair := ssh.KeyPair{
		PrivateKey: string(privateKeyBytes),
	}

	host := ssh.Host{
		Hostname:    publicIP,
		SshUserName: "ec2-user", // or "ubuntu" if using Ubuntu AMI
		SshKeyPair:  &keyPair,
	}

	// Wait for SSH to become available
	err = ssh.CheckSshConnectionE(t, host)
	if err != nil {
		t.Fatalf("Failed to establish SSH connection: %v", err)
	}

	// Check CloudWatch Agent status
	cwStatus := ssh.CheckSshCommand(t, host, "sudo systemctl is-active amazon-cloudwatch-agent")
	assert.Equal(t, "active", strings.TrimSpace(cwStatus), "CloudWatch Agent should be active")
}
