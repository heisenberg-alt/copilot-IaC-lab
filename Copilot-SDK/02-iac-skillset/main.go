// =============================================================================
// IaC Helper Skillset
// =============================================================================
// A Copilot Skillset providing IaC validation, generation, and explanation.
// Implements three skill endpoints that integrate with GitHub Copilot.
//
// Endpoints:
//   POST /validate  - Validate Terraform/Bicep code
//   POST /generate  - Generate IaC from descriptions
//   POST /explain   - Explain IaC resources
//
// Usage:
//   go run .
//   # Server starts on :8080
//   # Use ngrok to expose: ngrok http 8080
// =============================================================================

package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

// =============================================================================
// Configuration
// =============================================================================

type Config struct {
	Port          string
	WebhookSecret string
	Debug         bool
}

func loadConfig() *Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	return &Config{
		Port:          port,
		WebhookSecret: os.Getenv("GITHUB_WEBHOOK_SECRET"),
		Debug:         os.Getenv("DEBUG") != "",
	}
}

// =============================================================================
// Request/Response Types
// =============================================================================

// ValidateRequest is the request body for /validate
type ValidateRequest struct {
	Code string `json:"code"`
	Type string `json:"type"` // "terraform" or "bicep"
}

// ValidateResponse is the response for /validate
type ValidateResponse struct {
	Valid  bool              `json:"valid"`
	Errors []ValidationError `json:"errors,omitempty"`
}

// ValidationError represents a single validation error
type ValidationError struct {
	Line    int    `json:"line,omitempty"`
	Column  int    `json:"column,omitempty"`
	Message string `json:"message"`
	Code    string `json:"code,omitempty"`
}

// GenerateRequest is the request body for /generate
type GenerateRequest struct {
	Description string `json:"description"`
	Type        string `json:"type"` // "terraform" or "bicep"
}

// GenerateResponse is the response for /generate
type GenerateResponse struct {
	Code     string `json:"code"`
	Language string `json:"language"`
	Notes    string `json:"notes,omitempty"`
}

// ExplainRequest is the request body for /explain
type ExplainRequest struct {
	Resource string `json:"resource"`
	Property string `json:"property,omitempty"`
}

// ExplainResponse is the response for /explain
type ExplainResponse struct {
	Explanation      string   `json:"explanation"`
	Examples         []string `json:"examples,omitempty"`
	DocumentationURL string   `json:"documentation_url,omitempty"`
	RelatedResources []string `json:"related_resources,omitempty"`
}

// =============================================================================
// Server
// =============================================================================

type Server struct {
	config *Config
	mux    *http.ServeMux
}

func NewServer(config *Config) *Server {
	s := &Server{
		config: config,
		mux:    http.NewServeMux(),
	}
	s.setupRoutes()
	return s
}

func (s *Server) setupRoutes() {
	// Health check
	s.mux.HandleFunc("/health", s.handleHealth)

	// Skill endpoints
	s.mux.HandleFunc("/validate", s.withLogging(s.handleValidate))
	s.mux.HandleFunc("/generate", s.withLogging(s.handleGenerate))
	s.mux.HandleFunc("/explain", s.withLogging(s.handleExplain))

	// Manifest endpoint
	s.mux.HandleFunc("/manifest.json", s.handleManifest)
}

func (s *Server) withLogging(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		log.Printf("→ %s %s", r.Method, r.URL.Path)

		// Verify webhook signature if configured
		if s.config.WebhookSecret != "" && !s.verifySignature(r) {
			http.Error(w, "Invalid signature", http.StatusUnauthorized)
			return
		}

		next(w, r)
		log.Printf("← %s %s [%v]", r.Method, r.URL.Path, time.Since(start))
	}
}

func (s *Server) verifySignature(r *http.Request) bool {
	signature := r.Header.Get("X-Hub-Signature-256")
	if signature == "" {
		return true // No signature header, skip verification
	}

	body, err := io.ReadAll(r.Body)
	if err != nil {
		return false
	}
	// Reset body for handler
	r.Body = io.NopCloser(strings.NewReader(string(body)))

	mac := hmac.New(sha256.New, []byte(s.config.WebhookSecret))
	mac.Write(body)
	expectedSig := "sha256=" + hex.EncodeToString(mac.Sum(nil))

	return hmac.Equal([]byte(signature), []byte(expectedSig))
}

func (s *Server) Run() error {
	addr := ":" + s.config.Port
	log.Printf("🚀 IaC Helper Skillset starting on %s", addr)
	log.Printf("📍 Endpoints:")
	log.Printf("   POST /validate  - Validate IaC code")
	log.Printf("   POST /generate  - Generate IaC templates")
	log.Printf("   POST /explain   - Explain IaC resources")
	log.Printf("   GET  /health    - Health check")
	log.Printf("   GET  /manifest.json - Skillset manifest")
	return http.ListenAndServe(addr, s.mux)
}

// =============================================================================
// Health Check Handler
// =============================================================================

func (s *Server) handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"status":  "healthy",
		"service": "iac-helper-skillset",
	})
}

// =============================================================================
// Manifest Handler
// =============================================================================

func (s *Server) handleManifest(w http.ResponseWriter, r *http.Request) {
	manifest, err := os.ReadFile("manifest.json")
	if err != nil {
		http.Error(w, "Manifest not found", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(manifest)
}

// =============================================================================
// Validate Handler
// =============================================================================

func (s *Server) handleValidate(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req ValidateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
		return
	}

	if req.Code == "" {
		http.Error(w, "Code is required", http.StatusBadRequest)
		return
	}

	var response ValidateResponse

	switch strings.ToLower(req.Type) {
	case "terraform":
		response = s.validateTerraform(req.Code)
	case "bicep":
		response = s.validateBicep(req.Code)
	default:
		http.Error(w, "Type must be 'terraform' or 'bicep'", http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (s *Server) validateTerraform(code string) ValidateResponse {
	// Create temp directory
	tempDir, err := os.MkdirTemp("", "tf-validate-*")
	if err != nil {
		return ValidateResponse{
			Valid:  false,
			Errors: []ValidationError{{Message: "Failed to create temp directory"}},
		}
	}
	defer os.RemoveAll(tempDir)

	// Write code to file
	if err := os.WriteFile(filepath.Join(tempDir, "main.tf"), []byte(code), 0644); err != nil {
		return ValidateResponse{
			Valid:  false,
			Errors: []ValidationError{{Message: "Failed to write temp file"}},
		}
	}

	// Run terraform init
	initCmd := exec.Command("terraform", "init", "-backend=false", "-no-color")
	initCmd.Dir = tempDir
	initCmd.CombinedOutput()

	// Run terraform validate
	validateCmd := exec.Command("terraform", "validate", "-json", "-no-color")
	validateCmd.Dir = tempDir
	output, _ := validateCmd.CombinedOutput()

	// Parse JSON output
	var result struct {
		Valid       bool `json:"valid"`
		Diagnostics []struct {
			Severity string `json:"severity"`
			Summary  string `json:"summary"`
			Detail   string `json:"detail"`
			Range    *struct {
				Filename string `json:"filename"`
				Start    struct {
					Line   int `json:"line"`
					Column int `json:"column"`
				} `json:"start"`
			} `json:"range"`
		} `json:"diagnostics"`
	}

	if err := json.Unmarshal(output, &result); err != nil {
		// Return raw error if JSON parsing fails
		return ValidateResponse{
			Valid:  false,
			Errors: []ValidationError{{Message: string(output)}},
		}
	}

	response := ValidateResponse{Valid: result.Valid}
	for _, diag := range result.Diagnostics {
		if diag.Severity == "error" {
			verr := ValidationError{
				Message: diag.Summary,
			}
			if diag.Detail != "" {
				verr.Message += ": " + diag.Detail
			}
			if diag.Range != nil {
				verr.Line = diag.Range.Start.Line
				verr.Column = diag.Range.Start.Column
			}
			response.Errors = append(response.Errors, verr)
		}
	}

	return response
}

func (s *Server) validateBicep(code string) ValidateResponse {
	// Create temp directory
	tempDir, err := os.MkdirTemp("", "bicep-validate-*")
	if err != nil {
		return ValidateResponse{
			Valid:  false,
			Errors: []ValidationError{{Message: "Failed to create temp directory"}},
		}
	}
	defer os.RemoveAll(tempDir)

	// Write code to file
	tempFile := filepath.Join(tempDir, "main.bicep")
	if err := os.WriteFile(tempFile, []byte(code), 0644); err != nil {
		return ValidateResponse{
			Valid:  false,
			Errors: []ValidationError{{Message: "Failed to write temp file"}},
		}
	}

	// Run az bicep build
	cmd := exec.Command("az", "bicep", "build", "--file", tempFile, "--stdout")
	output, err := cmd.CombinedOutput()

	if err != nil {
		// Parse error output
		errors := []ValidationError{}
		lines := strings.Split(string(output), "\n")
		for _, line := range lines {
			line = strings.TrimSpace(line)
			if line == "" {
				continue
			}
			if strings.Contains(line, "Error") || strings.Contains(line, "BCP") {
				errors = append(errors, ValidationError{Message: line})
			}
		}
		if len(errors) == 0 {
			errors = append(errors, ValidationError{Message: string(output)})
		}
		return ValidateResponse{Valid: false, Errors: errors}
	}

	return ValidateResponse{Valid: true}
}

// =============================================================================
// Generate Handler
// =============================================================================

func (s *Server) handleGenerate(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req GenerateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
		return
	}

	if req.Description == "" {
		http.Error(w, "Description is required", http.StatusBadRequest)
		return
	}

	var response GenerateResponse

	switch strings.ToLower(req.Type) {
	case "terraform":
		response = s.generateTerraform(req.Description)
	case "bicep":
		response = s.generateBicep(req.Description)
	default:
		http.Error(w, "Type must be 'terraform' or 'bicep'", http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (s *Server) generateTerraform(description string) GenerateResponse {
	// Template library based on common patterns
	desc := strings.ToLower(description)

	var code string
	var notes string

	switch {
	case strings.Contains(desc, "storage") && strings.Contains(desc, "account"):
		code = generateTerraformStorageAccount()
		notes = "Generated Azure Storage Account with recommended settings. Customize the name, location, and SKU as needed."

	case strings.Contains(desc, "kubernetes") || strings.Contains(desc, "aks"):
		code = generateTerraformAKS()
		notes = "Generated AKS cluster with system node pool. Add user node pools as needed for workloads."

	case strings.Contains(desc, "virtual network") || strings.Contains(desc, "vnet"):
		code = generateTerraformVNet()
		notes = "Generated Virtual Network with a default subnet. Add more subnets as needed."

	case strings.Contains(desc, "resource group"):
		code = generateTerraformResourceGroup()
		notes = "Generated Resource Group. This is typically the foundation for other resources."

	case strings.Contains(desc, "key vault"):
		code = generateTerraformKeyVault()
		notes = "Generated Key Vault with RBAC authorization. Configure access policies based on your security requirements."

	default:
		code = generateTerraformGeneric(description)
		notes = "Generated a basic resource template. Please customize based on your specific requirements."
	}

	return GenerateResponse{
		Code:     code,
		Language: "terraform",
		Notes:    notes,
	}
}

func (s *Server) generateBicep(description string) GenerateResponse {
	desc := strings.ToLower(description)

	var code string
	var notes string

	switch {
	case strings.Contains(desc, "storage") && strings.Contains(desc, "account"):
		code = generateBicepStorageAccount()
		notes = "Generated Azure Storage Account with recommended settings. Customize parameters as needed."

	case strings.Contains(desc, "kubernetes") || strings.Contains(desc, "aks"):
		code = generateBicepAKS()
		notes = "Generated AKS cluster with system node pool. Modify node count and VM size based on workload."

	case strings.Contains(desc, "virtual network") || strings.Contains(desc, "vnet"):
		code = generateBicepVNet()
		notes = "Generated Virtual Network with a default subnet. Add more subnets as needed."

	case strings.Contains(desc, "key vault"):
		code = generateBicepKeyVault()
		notes = "Generated Key Vault with RBAC authorization enabled."

	default:
		code = generateBicepGeneric(description)
		notes = "Generated a basic resource template. Please customize based on your specific requirements."
	}

	return GenerateResponse{
		Code:     code,
		Language: "bicep",
		Notes:    notes,
	}
}

// =============================================================================
// Explain Handler
// =============================================================================

func (s *Server) handleExplain(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req ExplainRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
		return
	}

	if req.Resource == "" {
		http.Error(w, "Resource is required", http.StatusBadRequest)
		return
	}

	response := s.explainResource(req.Resource, req.Property)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (s *Server) explainResource(resource, property string) ExplainResponse {
	// Resource explanations database
	explanations := map[string]ExplainResponse{
		"azurerm_kubernetes_cluster": {
			Explanation: `The azurerm_kubernetes_cluster resource creates an Azure Kubernetes Service (AKS) cluster.

Key features:
• Managed Kubernetes control plane (free)
• Integration with Azure AD for authentication
• Support for multiple node pools
• Built-in monitoring with Azure Monitor
• Network policies with Azure CNI or Kubenet

Best practices:
• Use managed identities instead of service principals
• Enable Azure Policy add-on for governance
• Configure auto-scaling for node pools
• Use availability zones for high availability`,
			Examples: []string{
				`resource "azurerm_kubernetes_cluster" "example" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "aks"

  default_node_pool {
    name       = "system"
    node_count = 3
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }
}`,
			},
			DocumentationURL: "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster",
			RelatedResources: []string{
				"azurerm_kubernetes_cluster_node_pool",
				"azurerm_container_registry",
				"azurerm_log_analytics_workspace",
			},
		},
		"azurerm_storage_account": {
			Explanation: `The azurerm_storage_account resource creates an Azure Storage Account.

Supported services:
• Blob storage (object storage)
• File shares (SMB/NFS)
• Queues (messaging)
• Tables (NoSQL)

Key configurations:
• account_tier: Standard or Premium
• account_replication_type: LRS, GRS, ZRS, GZRS, RA-GRS, RA-GZRS
• account_kind: StorageV2 (recommended), BlobStorage, FileStorage

Best practices:
• Enable soft delete for blob and container recovery
• Use private endpoints for secure access
• Enable infrastructure encryption for sensitive data
• Configure lifecycle management for cost optimization`,
			Examples: []string{
				`resource "azurerm_storage_account" "example" {
  name                     = "storageaccountname"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}`,
			},
			DocumentationURL: "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account",
			RelatedResources: []string{
				"azurerm_storage_container",
				"azurerm_storage_blob",
				"azurerm_storage_share",
				"azurerm_private_endpoint",
			},
		},
		"azurerm_virtual_network": {
			Explanation: `The azurerm_virtual_network resource creates an Azure Virtual Network (VNet).

Purpose:
• Provides isolated network for Azure resources
• Enables secure communication between resources
• Supports hybrid connectivity (VPN, ExpressRoute)
• Foundation for subnet segmentation

Key features:
• Address space definition (CIDR blocks)
• DNS server configuration
• DDoS protection
• Service endpoints and private endpoints

Best practices:
• Plan address space for future growth
• Use subnets to segment workloads
• Implement NSGs for traffic filtering
• Use Azure Firewall or NVAs for advanced security`,
			Examples: []string{
				`resource "azurerm_virtual_network" "example" {
  name                = "vnet-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "default"
    address_prefix = "10.0.1.0/24"
  }
}`,
			},
			DocumentationURL: "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network",
			RelatedResources: []string{
				"azurerm_subnet",
				"azurerm_network_security_group",
				"azurerm_route_table",
				"azurerm_virtual_network_peering",
			},
		},
		"Microsoft.Storage/storageAccounts": {
			Explanation: `The Microsoft.Storage/storageAccounts Bicep resource creates an Azure Storage Account.

API Version: Use 2023-01-01 or later for latest features.

Key properties:
• sku.name: Standard_LRS, Standard_GRS, Standard_ZRS, Premium_LRS
• kind: StorageV2 (recommended), BlobStorage, FileStorage
• properties.supportsHttpsTrafficOnly: Always set to true
• properties.minimumTlsVersion: TLS1_2 recommended

Best practices:
• Use parameters for configurable values
• Enable blob soft delete
• Configure network rules for security
• Use managed identities for access`,
			Examples: []string{
				`resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}`,
			},
			DocumentationURL: "https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts",
			RelatedResources: []string{
				"Microsoft.Storage/storageAccounts/blobServices",
				"Microsoft.Storage/storageAccounts/fileServices",
				"Microsoft.Network/privateEndpoints",
			},
		},
	}

	// Look up the resource
	resource = strings.ToLower(resource)
	for key, explanation := range explanations {
		if strings.ToLower(key) == resource || strings.Contains(strings.ToLower(key), resource) {
			return explanation
		}
	}

	// Default response for unknown resources
	return ExplainResponse{
		Explanation: fmt.Sprintf(`Resource '%s' explanation not found in the local database.

To learn more about this resource:
1. Check the Terraform Registry: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
2. Check Azure Bicep docs: https://learn.microsoft.com/azure/templates/
3. Use 'az provider show' command for ARM resource types

Would you like me to search for documentation online?`, resource),
		DocumentationURL: "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs",
	}
}

// =============================================================================
// Template Generation Functions
// =============================================================================

func generateTerraformStorageAccount() string {
	return `# Azure Storage Account
# Generated by IaC Helper Skillset

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
}

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}`
}

func generateTerraformAKS() string {
	return `# Azure Kubernetes Service (AKS) Cluster
# Generated by IaC Helper Skillset

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = "1.28"

  default_node_pool {
    name                = "system"
    node_count          = var.node_count
    vm_size             = "Standard_D2s_v3"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "kube_config" {
  description = "Kubernetes config for kubectl"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}`
}

func generateTerraformVNet() string {
	return `# Azure Virtual Network
# Generated by IaC Helper Skillset

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "The ID of the default subnet"
  value       = azurerm_subnet.default.id
}`
}

func generateTerraformResourceGroup() string {
	return `# Azure Resource Group
# Generated by IaC Helper Skillset

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}`
}

func generateTerraformKeyVault() string {
	return `# Azure Key Vault
# Generated by IaC Helper Skillset

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "key_vault_name" {
  description = "Name of the Key Vault (must be globally unique)"
  type        = string
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization   = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 90

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}`
}

func generateTerraformGeneric(description string) string {
	return fmt.Sprintf(`# Terraform Template
# Generated by IaC Helper Skillset
# Description: %s

# TODO: Replace with specific resource configuration

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

# Add your resources here based on: %s

# Example resource:
# resource "azurerm_<resource_type>" "example" {
#   name                = "example"
#   resource_group_name = var.resource_group_name
#   location            = var.location
# }
`, description, description)
}

func generateBicepStorageAccount() string {
	return `// Azure Storage Account
// Generated by IaC Helper Skillset

@description('Name of the storage account (must be globally unique)')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Azure region for the storage account')
param location string = resourceGroup().location

@description('Storage account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param skuName string = 'Standard_LRS'

@description('Tags for the resource')
param tags object = {
  environment: 'production'
  managedBy: 'bicep'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
  tags: tags
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

@description('The resource ID of the storage account')
output storageAccountId string = storageAccount.id

@description('The primary blob endpoint')
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob`
}

func generateBicepAKS() string {
	return `// Azure Kubernetes Service (AKS) Cluster
// Generated by IaC Helper Skillset

@description('Name of the AKS cluster')
param clusterName string

@description('Azure region for the cluster')
param location string = resourceGroup().location

@description('DNS prefix for the cluster')
param dnsPrefix string

@description('Number of nodes in the default node pool')
@minValue(1)
@maxValue(100)
param nodeCount int = 3

@description('VM size for the nodes')
param nodeVmSize string = 'Standard_D2s_v3'

@description('Kubernetes version')
param kubernetesVersion string = '1.28'

@description('Tags for the resource')
param tags object = {
  environment: 'production'
  managedBy: 'bicep'
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-01-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    kubernetesVersion: kubernetesVersion
    agentPoolProfiles: [
      {
        name: 'system'
        count: nodeCount
        vmSize: nodeVmSize
        mode: 'System'
        enableAutoScaling: true
        minCount: 1
        maxCount: 5
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
    }
  }
  tags: tags
}

@description('The resource ID of the AKS cluster')
output clusterId string = aksCluster.id

@description('The FQDN of the AKS cluster')
output clusterFqdn string = aksCluster.properties.fqdn`
}

func generateBicepVNet() string {
	return `// Azure Virtual Network
// Generated by IaC Helper Skillset

@description('Name of the virtual network')
param vnetName string

@description('Azure region for the virtual network')
param location string = resourceGroup().location

@description('Address space for the VNet')
param addressPrefix string = '10.0.0.0/16'

@description('Address prefix for the default subnet')
param subnetPrefix string = '10.0.1.0/24'

@description('Tags for the resource')
param tags object = {
  environment: 'production'
  managedBy: 'bicep'
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
  tags: tags
}

@description('The resource ID of the virtual network')
output vnetId string = virtualNetwork.id

@description('The resource ID of the default subnet')
output subnetId string = virtualNetwork.properties.subnets[0].id`
}

func generateBicepKeyVault() string {
	return `// Azure Key Vault
// Generated by IaC Helper Skillset

@description('Name of the Key Vault (must be globally unique)')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('Azure region for the Key Vault')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {
  environment: 'production'
  managedBy: 'bicep'
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
  tags: tags
}

@description('The resource ID of the Key Vault')
output keyVaultId string = keyVault.id

@description('The URI of the Key Vault')
output keyVaultUri string = keyVault.properties.vaultUri`
}

func generateBicepGeneric(description string) string {
	return fmt.Sprintf(`// Bicep Template
// Generated by IaC Helper Skillset
// Description: %s

@description('Azure region for resources')
param location string = resourceGroup().location

@description('Tags for resources')
param tags object = {
  environment: 'production'
  managedBy: 'bicep'
}

// TODO: Add your resources here based on: %s

// Example resource:
// resource exampleResource 'Microsoft.<Provider>/<ResourceType>@<ApiVersion>' = {
//   name: 'example'
//   location: location
//   properties: {}
//   tags: tags
// }
`, description, description)
}

// =============================================================================
// Main Entry Point
// =============================================================================

func main() {
	config := loadConfig()
	server := NewServer(config)
	if err := server.Run(); err != nil {
		log.Fatalf("Server error: %v", err)
	}
}
