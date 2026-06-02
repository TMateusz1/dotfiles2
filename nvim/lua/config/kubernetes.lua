local M = {}
local generation_running = false
local dynamic_schema_file_patterns = {}

local static_kubernetes_file_patterns = {
	"k8s/**/*.yaml",
	"k8s/**/*.yml",
	"k8s/*.yaml",
	"k8s/*.yml",
	"kubernetes/**/*.yaml",
	"kubernetes/**/*.yml",
	"kubernetes/*.yaml",
	"kubernetes/*.yml",
	"**/k8s/*.yaml",
	"**/k8s/*.yml",
	"**/k8s/**/*.yaml",
	"**/k8s/**/*.yml",
	"**/kubernetes/*.yaml",
	"**/kubernetes/*.yml",
	"**/kubernetes/**/*.yaml",
	"**/kubernetes/**/*.yml",
	"**/deploy/*.yaml",
	"**/deploy/*.yml",
	"**/deploy/**/*.yaml",
	"**/deploy/**/*.yml",
	"**/deploy/k8s/*.yaml",
	"**/deploy/k8s/*.yml",
	"**/deploy/k8s/**/*.yaml",
	"**/deploy/k8s/**/*.yml",
	"**/deployment/*.yaml",
	"**/deployment/*.yml",
	"**/deployment/**/*.yaml",
	"**/deployment/**/*.yml",
	"**/deployments/*.yaml",
	"**/deployments/*.yml",
	"**/deployments/**/*.yaml",
	"**/deployments/**/*.yml",
	"**/manifest/*.yaml",
	"**/manifest/*.yml",
	"**/manifest/**/*.yaml",
	"**/manifest/**/*.yml",
	"**/manifests/*.yaml",
	"**/manifests/*.yml",
	"**/manifests/**/*.yaml",
	"**/manifests/**/*.yml",
	"**/base/*.yaml",
	"**/base/*.yml",
	"**/base/**/*.yaml",
	"**/base/**/*.yml",
	"**/overlays/*.yaml",
	"**/overlays/*.yml",
	"**/overlays/**/*.yaml",
	"**/overlays/**/*.yml",
	"**/clusters/*.yaml",
	"**/clusters/*.yml",
	"**/clusters/**/*.yaml",
	"**/clusters/**/*.yml",
	"**/argocd/*.yaml",
	"**/argocd/*.yml",
	"**/argocd/**/*.yaml",
	"**/argocd/**/*.yml",
	"*.k8s.yaml",
	"*.k8s.yml",
}

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, {
		title = "Kubernetes",
	})
end

local function ensure_dir(path)
	vim.fn.mkdir(path, "p")
end

local function is_non_empty_dir(path)
	local stat = vim.uv.fs_stat(path)

	if not stat or stat.type ~= "directory" then
		return false
	end

	local handle = vim.uv.fs_scandir(path)

	return handle ~= nil and vim.uv.fs_scandir_next(handle) ~= nil
end

local function is_yaml_buffer(bufnr)
	local filetype = vim.bo[bufnr].filetype

	return filetype == "yaml" or filetype == "yaml.helm-values"
end

local function has_kubernetes_markers(bufnr)
	local line_count = math.min(vim.api.nvim_buf_line_count(bufnr), 120)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, line_count, false)
	local has_api_version = false
	local has_kind = false

	for _, line in ipairs(lines) do
		if line:find("{{", 1, true) then
			return false
		end

		if line:match("^%s*apiVersion%s*:") then
			has_api_version = true
		elseif line:match("^%s*kind%s*:") then
			has_kind = true
		end

		if has_api_version and has_kind then
			return true
		end
	end

	return false
end

local function merge_required(schema, fields)
	local seen = {}
	local required = {}

	for _, field in ipairs(schema.required or {}) do
		if not seen[field] then
			seen[field] = true
			table.insert(required, field)
		end
	end

	for _, field in ipairs(fields) do
		if not seen[field] then
			seen[field] = true
			table.insert(required, field)
		end
	end

	schema.required = required
end

local function metadata_schema()
	return {
		type = "object",
		additionalProperties = true,
		properties = {
			name = {
				type = "string",
			},
			namespace = {
				type = "string",
			},
			labels = {
				type = "object",
				additionalProperties = {
					type = "string",
				},
			},
			annotations = {
				type = "object",
				additionalProperties = {
					type = "string",
				},
			},
		},
	}
end

local function schema_for_crd(crd, version)
	local group = vim.tbl_get(crd, "spec", "group")
	local kind = vim.tbl_get(crd, "spec", "names", "kind")
	local version_name = version.name

	if not group or not kind or not version_name then
		return nil
	end

	local schema = vim.deepcopy(vim.tbl_get(version, "schema", "openAPIV3Schema") or {})

	if vim.tbl_isempty(schema) then
		schema = {
			type = "object",
			additionalProperties = true,
		}
	end

	schema["$schema"] = schema["$schema"] or "http://json-schema.org/draft-07/schema#"
	schema.type = schema.type or "object"
	schema.additionalProperties = schema.additionalProperties
	schema.properties = schema.properties or {}
	schema.properties.apiVersion = {
		type = "string",
		const = group .. "/" .. version_name,
	}
	schema.properties.kind = {
		type = "string",
		const = kind,
	}
	schema.properties.metadata = schema.properties.metadata or metadata_schema()

	merge_required(schema, {
		"apiVersion",
		"kind",
		"metadata",
	})

	return schema
end

local function crd_schema_path(group, kind, version)
	local group_dir = vim.fs.joinpath(M.crd_catalog_dir(), group:lower())
	ensure_dir(group_dir)

	return vim.fs.joinpath(group_dir, ("%s_%s.json"):format(kind:lower(), version:lower()))
end

local function openshift_schema_path(group, kind, version)
	local group_dir = vim.fs.joinpath(M.crd_catalog_dir(), "openshift", "v4.15-strict")
	ensure_dir(group_dir)

	return vim.fs.joinpath(group_dir, ("%s_%s_%s.json"):format(kind:lower(), group:lower(), version:lower()))
end

function M.crd_catalog_dir()
	return vim.fs.joinpath(vim.fn.stdpath("state"), "kubernetes", "crd-catalog")
end

function M.crd_store_url()
	return vim.uri_from_fname(M.crd_catalog_dir())
end

function M.crd_store_settings()
	return {
		enable = is_non_empty_dir(M.crd_catalog_dir()),
		url = M.crd_store_url(),
	}
end

function M.file_patterns()
	local patterns = vim.deepcopy(static_kubernetes_file_patterns)

	for pattern in pairs(dynamic_schema_file_patterns) do
		table.insert(patterns, pattern)
	end

	return patterns
end

function M.yaml_schemas()
	return require("schemastore").yaml.schemas({
		extra = {
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
		},
	})
end

function M.update_yamlls()
	local yaml_settings = {
		kubernetesCRDStore = M.crd_store_settings(),
		schemas = M.yaml_schemas(),
	}

	vim.lsp.config("yamlls", {
		settings = {
			yaml = yaml_settings,
		},
	})

	for _, client in ipairs(vim.lsp.get_clients({ name = "yamlls" })) do
		client.config.settings = client.config.settings or {}
		client.config.settings.yaml = vim.tbl_deep_extend("force", client.config.settings.yaml or {}, yaml_settings)
	end
end

function M.attach_buffer_schema(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	if not vim.api.nvim_buf_is_valid(bufnr) or not is_yaml_buffer(bufnr) or not has_kubernetes_markers(bufnr) then
		return false
	end

	local filename = vim.api.nvim_buf_get_name(bufnr)

	if filename == "" then
		return false
	end

	local pattern = vim.uri_from_fname(filename)

	if dynamic_schema_file_patterns[pattern] then
		return false
	end

	dynamic_schema_file_patterns[pattern] = true
	M.update_yamlls()

	vim.schedule(function()
		pcall(vim.cmd, "LspRestart yamlls")
		notify("Attached Kubernetes schema to " .. vim.fn.fnamemodify(filename, ":t"))
	end)

	return true
end

function M.generate_crd_schemas(opts)
	opts = opts or {}

	if generation_running then
		return
	end

	if vim.fn.executable("kubectl") ~= 1 then
		if not opts.quiet then
			notify("kubectl is not executable, cannot generate CRD schemas", vim.log.levels.ERROR)
		end
		return
	end

	generation_running = true

	if not opts.quiet then
		notify("Generating CRD schemas from current kubectl context...")
	end

	vim.system({
		"kubectl",
		"get",
		"crd",
		"-o",
		"json",
	}, {
		text = true,
	}, function(result)
		vim.schedule(function()
			generation_running = false

			if result.code ~= 0 then
				if not opts.quiet then
					notify(
						result.stderr and result.stderr ~= "" and result.stderr or "kubectl get crd failed",
						vim.log.levels.ERROR
					)
				end
				return
			end

			local ok, crds = pcall(vim.json.decode, result.stdout)

			if not ok or type(crds) ~= "table" then
				if not opts.quiet then
					notify("kubectl returned invalid CRD JSON", vim.log.levels.ERROR)
				end
				return
			end

			local count = 0

			for _, crd in ipairs(crds.items or {}) do
				local group = vim.tbl_get(crd, "spec", "group")
				local kind = vim.tbl_get(crd, "spec", "names", "kind")

				for _, version in ipairs(vim.tbl_get(crd, "spec", "versions") or {}) do
					if version.served ~= false then
						local schema = schema_for_crd(crd, version)

						if schema and group and kind and version.name then
							local encoded = vim.json.encode(schema)
							local path = crd_schema_path(group, kind, version.name)
							vim.fn.writefile({ encoded }, path)

							if group:lower():find("openshift.io", 1, true) then
								vim.fn.writefile({ encoded }, openshift_schema_path(group, kind, version.name))
							end

							count = count + 1
						end
					end
				end
			end

			if count == 0 then
				if not opts.quiet then
					notify("No CRDs found in the current kubectl context", vim.log.levels.WARN)
				end
				return
			end

			notify(("Generated %d CRD schema files in %s"):format(count, M.crd_catalog_dir()))
			M.update_yamlls()

			pcall(vim.cmd, "LspRestart yamlls")
		end)
	end)
end

function M.setup()
	-- Keep CRD cache generation quiet on file open; explicit commands notify.
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("user_kubernetes_crds", { clear = true }),
		pattern = {
			"yaml",
			"helm",
			"yaml.helm-values",
		},
		callback = function()
			if not is_non_empty_dir(M.crd_catalog_dir()) then
				M.generate_crd_schemas({
					quiet = true,
				})
			end
		end,
		desc = "Generate local CRD schemas for yamlls when needed",
	})

	vim.api.nvim_create_autocmd({
		"BufReadPost",
		"BufWritePost",
		"TextChanged",
		"TextChangedI",
	}, {
		group = vim.api.nvim_create_augroup("user_kubernetes_schema_attach", { clear = true }),
		pattern = {
			"*.yaml",
			"*.yml",
		},
		callback = function(event)
			vim.defer_fn(function()
				M.attach_buffer_schema(event.buf)
			end, 200)
		end,
		desc = "Attach Kubernetes schema to YAML files with apiVersion and kind",
	})

	vim.api.nvim_create_user_command("KubeCrdSchemas", function()
		M.generate_crd_schemas()
	end, {
		desc = "Generate yamlls CRD schemas from the current kubectl context",
	})

	vim.api.nvim_create_user_command("KubeCrdSchemasPath", function()
		print(M.crd_catalog_dir())
	end, {
		desc = "Print the local yamlls CRD schema cache directory",
	})

	vim.api.nvim_create_user_command("KubeSchemaAttach", function()
		if not M.attach_buffer_schema(0) then
			notify("Current buffer does not look like a Kubernetes manifest", vim.log.levels.WARN)
		end
	end, {
		desc = "Attach Kubernetes schema to the current YAML buffer",
	})
end

return M
