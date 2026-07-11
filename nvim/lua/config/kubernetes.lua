local M = {}
local schema_cache_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "kubernetes", "crd-schemas")
local current_schema_path = vim.fs.joinpath(schema_cache_dir, "current.json")

local kubernetes_file_patterns = {
	"k8s/**/*.yaml",
	"k8s/**/*.yml",
	"kubernetes/**/*.yaml",
	"kubernetes/**/*.yml",
	"**/deploy/**/*.yaml",
	"**/deploy/**/*.yml",
	"**/deployment/**/*.yaml",
	"**/deployment/**/*.yml",
	"**/deployments/**/*.yaml",
	"**/deployments/**/*.yml",
	"**/manifests/**/*.yaml",
	"**/manifests/**/*.yml",
	"**/base/**/*.yaml",
	"**/base/**/*.yml",
	"**/overlays/**/*.yaml",
	"**/overlays/**/*.yml",
	"*.k8s.yaml",
	"*.k8s.yml",
}

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, {
		title = "Kubernetes",
	})
end

local function context_schema_path(context)
	local name = (context ~= "" and context or "default"):gsub("[^%w_.-]", "_")

	return vim.fs.joinpath(schema_cache_dir, name .. ".json")
end

local function schema_uri(path)
	return vim.uri_from_fname(path)
end

local function kubectl_context(callback)
	vim.system({ "kubectl", "config", "current-context" }, {
		text = true,
	}, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				callback("default")
				return
			end

			callback(vim.trim(result.stdout or ""))
		end)
	end)
end

local function crd_api_version(group, version)
	if group == "" then
		return version
	end

	return group .. "/" .. version
end

local function copy_schema(schema)
	if type(schema) == "table" then
		return vim.deepcopy(schema)
	end

	return {
		type = "object",
	}
end

local function ensure_array(value)
	if type(value) ~= "table" then
		return {}
	end

	return value
end

local function crd_version_schema(crd, version)
	local schema = copy_schema(version.schema and version.schema.openAPIV3Schema)

	schema.type = schema.type or "object"
	schema.properties = schema.properties or {}
	schema.properties.apiVersion = {
		enum = {
			crd_api_version(crd.spec.group or "", version.name or ""),
		},
	}
	schema.properties.kind = {
		enum = {
			crd.spec.names.kind,
		},
	}

	local required = ensure_array(schema.required)
	local seen = {}

	for _, item in ipairs(required) do
		seen[item] = true
	end

	for _, item in ipairs({ "apiVersion", "kind" }) do
		if not seen[item] then
			required[#required + 1] = item
		end
	end

	schema.required = required
	schema.title = ("%s %s"):format(crd.spec.names.kind, crd_api_version(crd.spec.group or "", version.name or ""))

	return schema
end

local function crd_schemas(payload)
	local schemas = {}

	for _, crd in ipairs(payload.items or {}) do
		if crd.spec and crd.spec.names and crd.spec.names.kind then
			for _, version in ipairs(crd.spec.versions or {}) do
				if version.served ~= false then
					schemas[#schemas + 1] = crd_version_schema(crd, version)
				end
			end
		end
	end

	table.sort(schemas, function(a, b)
		return (a.title or "") < (b.title or "")
	end)

	return {
		["$schema"] = "http://json-schema.org/draft-07/schema#",
		title = "Kubernetes CRDs",
		oneOf = schemas,
	}
end

local function write_schema_files(schema, context)
	vim.fn.mkdir(schema_cache_dir, "p")

	local encoded = vim.json.encode(schema)
	local context_path = context_schema_path(context)

	vim.fn.writefile({ encoded }, current_schema_path)
	vim.fn.writefile({ encoded }, context_path)

	return current_schema_path, context_path
end

local function restart_yamlls()
	local ok, lsp = pcall(require, "config.lsp")

	if ok and lsp.restart_server then
		lsp.restart_server("yamlls")
	end
end

function M.file_patterns()
	return vim.deepcopy(kubernetes_file_patterns)
end

function M.yaml_schemas()
	local extra = {
		{
			name = "Kubernetes",
			description = "Kubernetes resources",
			fileMatch = M.file_patterns(),
			url = "kubernetes",
		},
		{
			name = "Helm Chart",
			description = "Helm Chart.yaml",
			fileMatch = {
				"Chart.yaml",
				"**/Chart.yaml",
			},
			url = "https://json.schemastore.org/chart.json",
		},
	}

	if vim.uv.fs_stat(current_schema_path) then
		extra[#extra + 1] = {
			name = "Kubernetes CRDs",
			description = "CRDs fetched from the active kubectl context",
			fileMatch = M.file_patterns(),
			url = schema_uri(current_schema_path),
		}
	end

	return require("schemastore").yaml.schemas({
		extra = extra,
	})
end

function M.crd_schema_path()
	return current_schema_path
end

function M.fetch_crd_schemas()
	if vim.fn.executable("kubectl") ~= 1 then
		notify("kubectl is not executable", vim.log.levels.ERROR)
		return
	end

	notify("Fetching CRD schemas from current context...")

	vim.system({ "kubectl", "get", "crds", "-o", "json" }, {
		text = true,
	}, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				local output = vim.trim((result.stderr or "") .. "\n" .. (result.stdout or ""))

				notify(
					"kubectl get crds failed: " .. (output ~= "" and output or "unknown error"),
					vim.log.levels.ERROR
				)
				return
			end

			local ok, payload = pcall(vim.json.decode, result.stdout or "")

			if not ok or type(payload) ~= "table" then
				notify("kubectl returned invalid CRD JSON", vim.log.levels.ERROR)
				return
			end

			kubectl_context(function(context)
				local schema = crd_schemas(payload)
				local path = write_schema_files(schema, context)

				restart_yamlls()
				notify(("Fetched %d CRD schemas: %s"):format(#schema.oneOf, path))
			end)
		end)
	end)
end

function M.show_crd_schema_path()
	notify(M.crd_schema_path())
end

function M.setup()
	vim.api.nvim_create_user_command("KubeCrdSchemas", M.fetch_crd_schemas, {
		desc = "Fetch Kubernetes CRD schemas from the current kubectl context",
	})
	vim.api.nvim_create_user_command("KubeCrdSchemasPath", M.show_crd_schema_path, {
		desc = "Show Kubernetes CRD schema cache path",
	})

	vim.keymap.set("n", "<leader>ckf", M.fetch_crd_schemas, {
		desc = "Fetch Kubernetes CRD schemas",
	})
	vim.keymap.set("n", "<leader>ckp", M.show_crd_schema_path, {
		desc = "Show Kubernetes CRD schema path",
	})
end

return M
