local function has_helm_chart(path)
	local dir = vim.fs.dirname(path)

	return vim.fs.find("Chart.yaml", {
		path = dir,
		upward = true,
		limit = 1,
	})[1] ~= nil
end

vim.filetype.add({
	filename = {
		["docker-compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["compose.yaml"] = "yaml.docker-compose",
	},

	pattern = {
		[".*/templates/.*%.ya?ml"] = function(path)
			if has_helm_chart(path) then
				return "helm"
			end
		end,
		[".*/templates/.*%.tpl"] = function(path)
			if has_helm_chart(path) then
				return "helm"
			end
		end,
		[".*/templates/NOTES%.txt"] = function(path)
			if has_helm_chart(path) then
				return "helm"
			end
		end,
		[".*/deploy/helm/.*%.ya?ml"] = "helm",
		[".*/helm/.*%.ya?ml"] = "helm",
		["helmfile.*%.ya?ml"] = "helm",
		["helmfile.*%.ya?ml.gotmpl"] = "helm",
		[".*/values.*%.ya?ml"] = function(path)
			if has_helm_chart(path) then
				return "yaml.helm-values"
			end
		end,
	},
})
