// =============================================================================
// IaC Validator MCP Server
// =============================================================================
// A Model Context Protocol server that provides Terraform and Bicep validation
// tools for GitHub Copilot in VS Code.
//
// Usage:
//   go build -o iac-validator .
//   ./iac-validator
//
// The server communicates via stdio using JSON-RPC 2.0 protocol.
// =============================================================================

package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// =============================================================================
// MCP Protocol Types
// =============================================================================

// JSONRPCRequest represents an incoming JSON-RPC 2.0 request
type JSONRPCRequest struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      interface{}     `json:"id,omitempty"`
	Method  string          `json:"method"`
	Params  json.RawMessage `json:"params,omitempty"`
}

// JSONRPCResponse represents an outgoing JSON-RPC 2.0 response
type JSONRPCResponse struct {
	JSONRPC string        `json:"jsonrpc"`
	ID      interface{}   `json:"id,omitempty"`
	Result  interface{}   `json:"result,omitempty"`
	Error   *JSONRPCError `json:"error,omitempty"`
}

// JSONRPCError represents a JSON-RPC error
type JSONRPCError struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// MCPCapabilities defines what the server can do
type MCPCapabilities struct {
	Tools *ToolsCapability `json:"tools,omitempty"`
}

// ToolsCapability indicates tool support
type ToolsCapability struct {
	ListChanged bool `json:"listChanged,omitempty"`
}

// InitializeResult is returned on successful initialization
type InitializeResult struct {
	ProtocolVersion string          `json:"protocolVersion"`
	Capabilities    MCPCapabilities `json:"capabilities"`
	ServerInfo      ServerInfo      `json:"serverInfo"`
}

// ServerInfo provides metadata about the server
type ServerInfo struct {
	Name    string `json:"name"`
	Version string `json:"version"`
}

// Tool represents an MCP tool definition
type Tool struct {
	Name        string      `json:"name"`
	Description string      `json:"description"`
	InputSchema InputSchema `json:"inputSchema"`
}

// InputSchema defines the JSON Schema for tool inputs
type InputSchema struct {
	Type       string              `json:"type"`
	Properties map[string]Property `json:"properties,omitempty"`
	Required   []string            `json:"required,omitempty"`
}

// Property defines a single property in the input schema
type Property struct {
	Type        string   `json:"type"`
	Description string   `json:"description"`
	Enum        []string `json:"enum,omitempty"`
}

// ToolsListResult contains the list of available tools
type ToolsListResult struct {
	Tools []Tool `json:"tools"`
}

// ToolCallParams contains parameters for a tool invocation
type ToolCallParams struct {
	Name      string                 `json:"name"`
	Arguments map[string]interface{} `json:"arguments"`
}

// ToolCallResult contains the result of a tool invocation
type ToolCallResult struct {
	Content []ContentBlock `json:"content"`
	IsError bool           `json:"isError,omitempty"`
}

// ContentBlock represents a content block in tool results
type ContentBlock struct {
	Type string `json:"type"`
	Text string `json:"text"`
}

// =============================================================================
// MCP Server
// =============================================================================

// MCPServer handles MCP protocol communication
type MCPServer struct {
	reader *bufio.Reader
	writer io.Writer
	tools  map[string]ToolHandler
}

// ToolHandler is a function that handles a tool invocation
type ToolHandler func(args map[string]interface{}) (*ToolCallResult, error)

// NewMCPServer creates a new MCP server instance
func NewMCPServer() *MCPServer {
	server := &MCPServer{
		reader: bufio.NewReader(os.Stdin),
		writer: os.Stdout,
		tools:  make(map[string]ToolHandler),
	}

	// Register tools
	server.registerTools()

	return server
}

// registerTools sets up all available tools
func (s *MCPServer) registerTools() {
	s.tools["validate_terraform"] = s.handleValidateTerraform
	s.tools["validate_bicep"] = s.handleValidateBicep
	s.tools["check_iac_syntax"] = s.handleCheckSyntax
	s.tools["list_iac_files"] = s.handleListIaCFiles
}

// Run starts the server and processes requests
func (s *MCPServer) Run() error {
	debugLog("IaC Validator MCP Server starting...")

	for {
		// Read a line (JSON-RPC message)
		line, err := s.reader.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				debugLog("EOF received, shutting down")
				return nil
			}
			return fmt.Errorf("read error: %w", err)
		}

		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		debugLog("Received: %s", line)

		// Parse the request
		var request JSONRPCRequest
		if err := json.Unmarshal([]byte(line), &request); err != nil {
			s.sendError(nil, -32700, "Parse error", err.Error())
			continue
		}

		// Handle the request
		s.handleRequest(&request)
	}
}

// handleRequest routes requests to appropriate handlers
func (s *MCPServer) handleRequest(req *JSONRPCRequest) {
	debugLog("Handling method: %s", req.Method)

	switch req.Method {
	case "initialize":
		s.handleInitialize(req)
	case "initialized":
		// Notification, no response needed
		debugLog("Client initialized")
	case "tools/list":
		s.handleToolsList(req)
	case "tools/call":
		s.handleToolsCall(req)
	case "ping":
		s.sendResult(req.ID, map[string]string{})
	default:
		s.sendError(req.ID, -32601, "Method not found", req.Method)
	}
}

// handleInitialize processes the initialize request
func (s *MCPServer) handleInitialize(req *JSONRPCRequest) {
	result := InitializeResult{
		ProtocolVersion: "2024-11-05",
		Capabilities: MCPCapabilities{
			Tools: &ToolsCapability{
				ListChanged: false,
			},
		},
		ServerInfo: ServerInfo{
			Name:    "iac-validator-mcp",
			Version: "1.0.0",
		},
	}
	s.sendResult(req.ID, result)
}

// handleToolsList returns the list of available tools
func (s *MCPServer) handleToolsList(req *JSONRPCRequest) {
	tools := []Tool{
		{
			Name:        "validate_terraform",
			Description: "Validate Terraform configuration files in a directory. Runs 'terraform init' (if needed) and 'terraform validate' to check for syntax and configuration errors.",
			InputSchema: InputSchema{
				Type: "object",
				Properties: map[string]Property{
					"path": {
						Type:        "string",
						Description: "Path to the Terraform directory or file to validate. Can be absolute or relative to the workspace.",
					},
				},
				Required: []string{"path"},
			},
		},
		{
			Name:        "validate_bicep",
			Description: "Validate a Bicep file by running 'az bicep build'. Returns any syntax or semantic errors found in the Bicep code.",
			InputSchema: InputSchema{
				Type: "object",
				Properties: map[string]Property{
					"path": {
						Type:        "string",
						Description: "Path to the Bicep file to validate. Must be a .bicep file.",
					},
				},
				Required: []string{"path"},
			},
		},
		{
			Name:        "check_iac_syntax",
			Description: "Quick syntax check for IaC code snippets. Validates Terraform HCL or Bicep syntax without requiring a full project structure.",
			InputSchema: InputSchema{
				Type: "object",
				Properties: map[string]Property{
					"code": {
						Type:        "string",
						Description: "The IaC code to validate.",
					},
					"type": {
						Type:        "string",
						Description: "The type of IaC code.",
						Enum:        []string{"terraform", "bicep"},
					},
				},
				Required: []string{"code", "type"},
			},
		},
		{
			Name:        "list_iac_files",
			Description: "List all Terraform (.tf) and Bicep (.bicep) files in a directory. Useful for understanding the structure of an IaC project.",
			InputSchema: InputSchema{
				Type: "object",
				Properties: map[string]Property{
					"path": {
						Type:        "string",
						Description: "Path to the directory to scan for IaC files.",
					},
					"recursive": {
						Type:        "string",
						Description: "Whether to scan subdirectories (true/false). Defaults to true.",
					},
				},
				Required: []string{"path"},
			},
		},
	}

	s.sendResult(req.ID, ToolsListResult{Tools: tools})
}

// handleToolsCall processes a tool invocation
func (s *MCPServer) handleToolsCall(req *JSONRPCRequest) {
	var params ToolCallParams
	if err := json.Unmarshal(req.Params, &params); err != nil {
		s.sendError(req.ID, -32602, "Invalid params", err.Error())
		return
	}

	debugLog("Tool call: %s with args: %v", params.Name, params.Arguments)

	handler, ok := s.tools[params.Name]
	if !ok {
		s.sendError(req.ID, -32602, "Unknown tool", params.Name)
		return
	}

	result, err := handler(params.Arguments)
	if err != nil {
		result = &ToolCallResult{
			Content: []ContentBlock{{Type: "text", Text: fmt.Sprintf("Error: %s", err.Error())}},
			IsError: true,
		}
	}

	s.sendResult(req.ID, result)
}

// =============================================================================
// Tool Handlers
// =============================================================================

// handleValidateTerraform validates Terraform files
func (s *MCPServer) handleValidateTerraform(args map[string]interface{}) (*ToolCallResult, error) {
	path, ok := args["path"].(string)
	if !ok {
		return nil, fmt.Errorf("path parameter is required")
	}

	// Resolve path
	absPath, err := filepath.Abs(path)
	if err != nil {
		return nil, fmt.Errorf("invalid path: %w", err)
	}

	// Check if path exists
	info, err := os.Stat(absPath)
	if err != nil {
		return nil, fmt.Errorf("path not found: %s", absPath)
	}

	// If it's a file, use its directory
	dir := absPath
	if !info.IsDir() {
		dir = filepath.Dir(absPath)
	}

	var output strings.Builder
	output.WriteString(fmt.Sprintf("🔍 Validating Terraform in: %s\n\n", dir))

	// Check if terraform is installed
	if _, err := exec.LookPath("terraform"); err != nil {
		return &ToolCallResult{
			Content: []ContentBlock{{
				Type: "text",
				Text: "❌ Terraform CLI not found. Please install Terraform: https://www.terraform.io/downloads",
			}},
			IsError: true,
		}, nil
	}

	// Check if already initialized
	terraformDir := filepath.Join(dir, ".terraform")
	needsInit := true
	if _, err := os.Stat(terraformDir); err == nil {
		needsInit = false
	}

	// Run terraform init if needed
	if needsInit {
		output.WriteString("📦 Running terraform init...\n")
		cmd := exec.Command("terraform", "init", "-backend=false", "-no-color")
		cmd.Dir = dir
		initOutput, err := cmd.CombinedOutput()
		if err != nil {
			output.WriteString(fmt.Sprintf("⚠️ Init warning: %s\n", string(initOutput)))
		} else {
			output.WriteString("✅ Terraform initialized\n\n")
		}
	}

	// Run terraform validate
	output.WriteString("🔎 Running terraform validate...\n\n")
	cmd := exec.Command("terraform", "validate", "-json", "-no-color")
	cmd.Dir = dir
	validateOutput, err := cmd.CombinedOutput()

	// Parse JSON output
	var validateResult struct {
		Valid        bool `json:"valid"`
		ErrorCount   int  `json:"error_count"`
		WarningCount int  `json:"warning_count"`
		Diagnostics  []struct {
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

	if jsonErr := json.Unmarshal(validateOutput, &validateResult); jsonErr != nil {
		// If JSON parsing fails, return raw output
		if err != nil {
			output.WriteString(fmt.Sprintf("❌ Validation failed:\n%s", string(validateOutput)))
			return &ToolCallResult{
				Content: []ContentBlock{{Type: "text", Text: output.String()}},
				IsError: true,
			}, nil
		}
	}

	if validateResult.Valid {
		output.WriteString("✅ **Terraform configuration is valid!**\n\n")
		output.WriteString(fmt.Sprintf("📊 Summary:\n"))
		output.WriteString(fmt.Sprintf("   - Errors: %d\n", validateResult.ErrorCount))
		output.WriteString(fmt.Sprintf("   - Warnings: %d\n", validateResult.WarningCount))
	} else {
		output.WriteString("❌ **Terraform validation failed**\n\n")
		output.WriteString(fmt.Sprintf("📊 Found %d error(s) and %d warning(s):\n\n",
			validateResult.ErrorCount, validateResult.WarningCount))

		for i, diag := range validateResult.Diagnostics {
			icon := "⚠️"
			if diag.Severity == "error" {
				icon = "❌"
			}
			output.WriteString(fmt.Sprintf("%d. %s **%s**\n", i+1, icon, diag.Summary))
			if diag.Range != nil {
				output.WriteString(fmt.Sprintf("   📍 File: %s, Line: %d, Column: %d\n",
					diag.Range.Filename, diag.Range.Start.Line, diag.Range.Start.Column))
			}
			if diag.Detail != "" {
				output.WriteString(fmt.Sprintf("   💡 %s\n", diag.Detail))
			}
			output.WriteString("\n")
		}
	}

	return &ToolCallResult{
		Content: []ContentBlock{{Type: "text", Text: output.String()}},
		IsError: !validateResult.Valid,
	}, nil
}

// handleValidateBicep validates Bicep files
func (s *MCPServer) handleValidateBicep(args map[string]interface{}) (*ToolCallResult, error) {
	path, ok := args["path"].(string)
	if !ok {
		return nil, fmt.Errorf("path parameter is required")
	}

	// Resolve path
	absPath, err := filepath.Abs(path)
	if err != nil {
		return nil, fmt.Errorf("invalid path: %w", err)
	}

	// Verify it's a .bicep file
	if !strings.HasSuffix(strings.ToLower(absPath), ".bicep") {
		return nil, fmt.Errorf("file must have .bicep extension: %s", absPath)
	}

	// Check if file exists
	if _, err := os.Stat(absPath); err != nil {
		return nil, fmt.Errorf("file not found: %s", absPath)
	}

	var output strings.Builder
	output.WriteString(fmt.Sprintf("🔍 Validating Bicep file: %s\n\n", filepath.Base(absPath)))

	// Check if az CLI is installed
	if _, err := exec.LookPath("az"); err != nil {
		return &ToolCallResult{
			Content: []ContentBlock{{
				Type: "text",
				Text: "❌ Azure CLI not found. Please install Azure CLI: https://docs.microsoft.com/cli/azure/install-azure-cli",
			}},
			IsError: true,
		}, nil
	}

	// Run az bicep build
	output.WriteString("🔎 Running az bicep build...\n\n")
	cmd := exec.Command("az", "bicep", "build", "--file", absPath, "--stdout")
	buildOutput, err := cmd.CombinedOutput()

	if err != nil {
		// Parse error output for user-friendly display
		output.WriteString("❌ **Bicep validation failed**\n\n")

		errorLines := strings.Split(string(buildOutput), "\n")
		for _, line := range errorLines {
			line = strings.TrimSpace(line)
			if line == "" {
				continue
			}

			// Look for error patterns
			if strings.Contains(line, "Error") || strings.Contains(line, "error") {
				output.WriteString(fmt.Sprintf("❌ %s\n", line))
			} else if strings.Contains(line, "Warning") || strings.Contains(line, "warning") {
				output.WriteString(fmt.Sprintf("⚠️ %s\n", line))
			} else if strings.Contains(line, "BCP") {
				// Bicep error codes
				output.WriteString(fmt.Sprintf("   🔹 %s\n", line))
			} else {
				output.WriteString(fmt.Sprintf("   %s\n", line))
			}
		}

		return &ToolCallResult{
			Content: []ContentBlock{{Type: "text", Text: output.String()}},
			IsError: true,
		}, nil
	}

	output.WriteString("✅ **Bicep file is valid!**\n\n")
	output.WriteString("📊 The file compiled successfully to ARM template.\n")

	// Show a preview of the ARM output size
	armSize := len(buildOutput)
	output.WriteString(fmt.Sprintf("   - Generated ARM template size: %d bytes\n", armSize))

	return &ToolCallResult{
		Content: []ContentBlock{{Type: "text", Text: output.String()}},
		IsError: false,
	}, nil
}

// handleCheckSyntax performs quick syntax checks on code snippets
func (s *MCPServer) handleCheckSyntax(args map[string]interface{}) (*ToolCallResult, error) {
	code, ok := args["code"].(string)
	if !ok {
		return nil, fmt.Errorf("code parameter is required")
	}

	codeType, ok := args["type"].(string)
	if !ok {
		return nil, fmt.Errorf("type parameter is required (terraform or bicep)")
	}

	var output strings.Builder
	output.WriteString(fmt.Sprintf("🔍 Checking %s syntax...\n\n", codeType))

	// Create temp directory
	tempDir, err := os.MkdirTemp("", "iac-syntax-check-*")
	if err != nil {
		return nil, fmt.Errorf("failed to create temp directory: %w", err)
	}
	defer os.RemoveAll(tempDir)

	switch strings.ToLower(codeType) {
	case "terraform":
		// Write code to temp file
		tempFile := filepath.Join(tempDir, "main.tf")
		if err := os.WriteFile(tempFile, []byte(code), 0644); err != nil {
			return nil, fmt.Errorf("failed to write temp file: %w", err)
		}

		// Run terraform fmt to check syntax
		cmd := exec.Command("terraform", "fmt", "-check", "-no-color", tempFile)
		fmtOutput, fmtErr := cmd.CombinedOutput()

		// Run terraform validate
		initCmd := exec.Command("terraform", "init", "-backend=false", "-no-color")
		initCmd.Dir = tempDir
		initCmd.CombinedOutput()

		validateCmd := exec.Command("terraform", "validate", "-no-color")
		validateCmd.Dir = tempDir
		validateOutput, validateErr := validateCmd.CombinedOutput()

		if fmtErr != nil {
			output.WriteString("⚠️ **Formatting issues detected**\n")
			output.WriteString(fmt.Sprintf("   %s\n", string(fmtOutput)))
		}

		if validateErr != nil {
			output.WriteString("❌ **Syntax errors found:**\n")
			output.WriteString(fmt.Sprintf("```\n%s\n```\n", string(validateOutput)))
			return &ToolCallResult{
				Content: []ContentBlock{{Type: "text", Text: output.String()}},
				IsError: true,
			}, nil
		}

		output.WriteString("✅ **Terraform syntax is valid!**\n")

	case "bicep":
		// Write code to temp file
		tempFile := filepath.Join(tempDir, "main.bicep")
		if err := os.WriteFile(tempFile, []byte(code), 0644); err != nil {
			return nil, fmt.Errorf("failed to write temp file: %w", err)
		}

		// Run az bicep build
		cmd := exec.Command("az", "bicep", "build", "--file", tempFile, "--stdout")
		buildOutput, err := cmd.CombinedOutput()

		if err != nil {
			output.WriteString("❌ **Bicep syntax errors found:**\n")
			output.WriteString(fmt.Sprintf("```\n%s\n```\n", string(buildOutput)))
			return &ToolCallResult{
				Content: []ContentBlock{{Type: "text", Text: output.String()}},
				IsError: true,
			}, nil
		}

		output.WriteString("✅ **Bicep syntax is valid!**\n")

	default:
		return nil, fmt.Errorf("unsupported type: %s (use 'terraform' or 'bicep')", codeType)
	}

	return &ToolCallResult{
		Content: []ContentBlock{{Type: "text", Text: output.String()}},
		IsError: false,
	}, nil
}

// handleListIaCFiles lists IaC files in a directory
func (s *MCPServer) handleListIaCFiles(args map[string]interface{}) (*ToolCallResult, error) {
	path, ok := args["path"].(string)
	if !ok {
		return nil, fmt.Errorf("path parameter is required")
	}

	recursive := true
	if r, ok := args["recursive"].(string); ok {
		recursive = strings.ToLower(r) != "false"
	}

	absPath, err := filepath.Abs(path)
	if err != nil {
		return nil, fmt.Errorf("invalid path: %w", err)
	}

	var output strings.Builder
	output.WriteString(fmt.Sprintf("📂 Scanning for IaC files in: %s\n\n", absPath))

	var tfFiles, bicepFiles []string

	walkFn := func(p string, info os.FileInfo, err error) error {
		if err != nil {
			return nil // Skip errors
		}
		if info.IsDir() {
			// Skip hidden and common non-IaC directories
			name := info.Name()
			if strings.HasPrefix(name, ".") || name == "node_modules" || name == ".terraform" {
				return filepath.SkipDir
			}
			if !recursive && p != absPath {
				return filepath.SkipDir
			}
			return nil
		}

		ext := strings.ToLower(filepath.Ext(p))
		relPath, _ := filepath.Rel(absPath, p)

		if ext == ".tf" {
			tfFiles = append(tfFiles, relPath)
		} else if ext == ".bicep" {
			bicepFiles = append(bicepFiles, relPath)
		}

		return nil
	}

	if err := filepath.Walk(absPath, walkFn); err != nil {
		return nil, fmt.Errorf("failed to scan directory: %w", err)
	}

	if len(tfFiles) > 0 {
		output.WriteString(fmt.Sprintf("🟣 **Terraform files** (%d):\n", len(tfFiles)))
		for _, f := range tfFiles {
			output.WriteString(fmt.Sprintf("   - %s\n", f))
		}
		output.WriteString("\n")
	}

	if len(bicepFiles) > 0 {
		output.WriteString(fmt.Sprintf("🔵 **Bicep files** (%d):\n", len(bicepFiles)))
		for _, f := range bicepFiles {
			output.WriteString(fmt.Sprintf("   - %s\n", f))
		}
		output.WriteString("\n")
	}

	if len(tfFiles) == 0 && len(bicepFiles) == 0 {
		output.WriteString("ℹ️ No Terraform (.tf) or Bicep (.bicep) files found.\n")
	}

	output.WriteString(fmt.Sprintf("\n📊 **Summary:** %d Terraform, %d Bicep files\n",
		len(tfFiles), len(bicepFiles)))

	return &ToolCallResult{
		Content: []ContentBlock{{Type: "text", Text: output.String()}},
		IsError: false,
	}, nil
}

// =============================================================================
// Response Helpers
// =============================================================================

// sendResult sends a successful response
func (s *MCPServer) sendResult(id interface{}, result interface{}) {
	response := JSONRPCResponse{
		JSONRPC: "2.0",
		ID:      id,
		Result:  result,
	}
	s.send(response)
}

// sendError sends an error response
func (s *MCPServer) sendError(id interface{}, code int, message, data string) {
	response := JSONRPCResponse{
		JSONRPC: "2.0",
		ID:      id,
		Error: &JSONRPCError{
			Code:    code,
			Message: message,
			Data:    data,
		},
	}
	s.send(response)
}

// send writes a response to stdout
func (s *MCPServer) send(response JSONRPCResponse) {
	data, err := json.Marshal(response)
	if err != nil {
		debugLog("Failed to marshal response: %v", err)
		return
	}
	fmt.Fprintln(s.writer, string(data))
	debugLog("Sent: %s", string(data))
}

// debugLog writes debug output to stderr
func debugLog(format string, args ...interface{}) {
	if os.Getenv("DEBUG") != "" {
		fmt.Fprintf(os.Stderr, "[DEBUG] "+format+"\n", args...)
	}
}

// =============================================================================
// Main Entry Point
// =============================================================================

func main() {
	server := NewMCPServer()
	if err := server.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Server error: %v\n", err)
		os.Exit(1)
	}
}
