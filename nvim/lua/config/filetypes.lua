vim.filetype.add({
	filename = {
		["docker-compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["compose.yaml"] = "yaml.docker-compose",
	},

	pattern = {
		[".*/deploy/helm/.*%.yaml"] = "helm",
		[".*/deploy/helm/.*%.yml"] = "helm",
		[".*/helm/.*%.yml"] = "helm",
		[".*/helm/.*%.yaml"] = "helm",
		-- Useful for normal Helm chart layout too
		[".*/templates/.*%.yaml"] = "helm",
		[".*/templates/.*%.yml"] = "helm",
		[".*/templates/.*%.tpl"] = "helm",
	},
})
