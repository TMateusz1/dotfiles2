local source = {}

local function item_kind()
	return require("blink.cmp.types").CompletionItemKind.Property
end

local tag_specs = {
	{
		label = "json",
		key = "json",
		value = "${1:%s}",
		description = "JSON field name",
		sort = "01",
	},
	{
		label = "json,omitempty",
		key = "json",
		value = "${1:%s},omitempty",
		description = "JSON field name, skip zero values",
		sort = "02",
	},
	{
		label = "json,string",
		key = "json",
		value = "${1:%s},string",
		description = "JSON field name, encode as a JSON string",
		sort = "03",
	},
	{
		label = "json:-",
		key = "json",
		value = "-",
		description = "Ignore this field for JSON",
		sort = "04",
	},
	{
		label = "yaml",
		key = "yaml",
		value = "${1:%s}",
		description = "YAML field name",
		sort = "11",
	},
	{
		label = "yaml,omitempty",
		key = "yaml",
		value = "${1:%s},omitempty",
		description = "YAML field name, skip zero values",
		sort = "12",
	},
	{
		label = "yaml:inline",
		key = "yaml",
		value = "${1:%s},inline",
		description = "Inline this field in YAML",
		sort = "13",
	},
	{
		label = "bson",
		key = "bson",
		value = "${1:%s}",
		description = "BSON field name",
		sort = "21",
	},
	{
		label = "bson,omitempty",
		key = "bson",
		value = "${1:%s},omitempty",
		description = "BSON field name, skip zero values",
		sort = "22",
	},
	{
		label = "bson:-",
		key = "bson",
		value = "-",
		description = "Ignore this field for BSON",
		sort = "23",
	},
	{
		label = "xml",
		key = "xml",
		value = "${1:%s}",
		description = "XML field name",
		sort = "31",
	},
	{
		label = "xml,omitempty",
		key = "xml",
		value = "${1:%s},omitempty",
		description = "XML field name, skip zero values",
		sort = "32",
	},
	{
		label = "toml",
		key = "toml",
		value = "${1:%s}",
		description = "TOML field name",
		sort = "41",
	},
	{
		label = "toml,omitempty",
		key = "toml",
		value = "${1:%s},omitempty",
		description = "TOML field name, skip zero values",
		sort = "42",
	},
	{
		label = "mapstructure",
		key = "mapstructure",
		value = "${1:%s}",
		description = "mapstructure field name",
		sort = "51",
	},
	{
		label = "mapstructure,omitempty",
		key = "mapstructure",
		value = "${1:%s},omitempty",
		description = "mapstructure field name, skip zero values",
		sort = "52",
	},
	{
		label = "db",
		key = "db",
		value = "${1:%s}",
		description = "Database column name",
		sort = "61",
	},
	{
		label = "env",
		key = "env",
		value = "${1:%s}",
		description = "Environment variable name",
		sort = "71",
		transform = "screaming_snake",
	},
	{
		label = "validate",
		key = "validate",
		value = "${1:required}",
		description = "Validation rules",
		sort = "81",
	},
	{
		label = "validate,omitempty",
		key = "validate",
		value = "omitempty",
		description = "Validate only when present",
		sort = "82",
	},
	{
		label = "form",
		key = "form",
		value = "${1:%s}",
		description = "HTTP form field name",
		sort = "91",
	},
	{
		label = "query",
		key = "query",
		value = "${1:%s}",
		description = "HTTP query field name",
		sort = "92",
	},
	{
		label = "uri",
		key = "uri",
		value = "${1:%s}",
		description = "URI binding field name",
		sort = "93",
	},
}

local option_specs = {
	json = {
		{ label = "omitempty", description = "Skip this field when it has a zero value" },
		{ label = "string", description = "Encode or decode this value as a JSON string" },
	},
	yaml = {
		{ label = "omitempty", description = "Skip this field when it has a zero value" },
		{ label = "inline", description = "Inline this field into the surrounding YAML object" },
		{ label = "flow", description = "Use YAML flow style" },
	},
	bson = {
		{ label = "omitempty", description = "Skip this field when it has a zero value" },
		{ label = "inline", description = "Inline this field into the surrounding BSON object" },
		{ label = "minsize", description = "Marshal integers using the smallest BSON integer type" },
		{ label = "truncate", description = "Truncate BSON doubles when decoding into integer fields" },
	},
	xml = {
		{ label = "omitempty", description = "Skip this field when it has a zero value" },
		{ label = "attr", description = "Encode this field as an XML attribute" },
		{ label = "chardata", description = "Encode this field as XML character data" },
		{ label = "cdata", description = "Encode this field as an XML CDATA section" },
		{ label = "innerxml", description = "Encode this field as raw inner XML" },
		{ label = "comment", description = "Encode this field as an XML comment" },
	},
	validate = {
		{ label = "required", description = "Value must be present" },
		{ label = "omitempty", description = "Skip later validators when empty" },
		{ label = "dive", description = "Validate each element of a slice, array, or map" },
		{ label = "email", description = "Value must be an email address" },
		{ label = "url", description = "Value must be a URL" },
		{ label = "uri", description = "Value must be a URI" },
		{ label = "uuid", description = "Value must be a UUID" },
		{ label = "min", insert = "min=${1:1}", description = "Minimum length or value" },
		{ label = "max", insert = "max=${1:1}", description = "Maximum length or value" },
		{ label = "len", insert = "len=${1:1}", description = "Exact length" },
		{ label = "oneof", insert = "oneof=${1:value}", description = "One of a fixed set of values" },
	},
}

local function last_index(text, needle)
	local index = 1
	local last = nil

	while true do
		local position = text:find(needle, index, true)

		if not position then
			return last
		end

		last = position
		index = position + #needle
	end
end

local function count_char(text, char)
	local _, count = text:gsub(vim.pesc(char), "")

	return count
end

local function snippet_escape(text)
	return text:gsub("\\", "\\\\"):gsub("%$", "\\$")
end

local function snake_case(name)
	local text = name:gsub("(%u+)(%u%l)", "%1_%2")
	text = text:gsub("([%l%d])(%u)", "%1_%2")
	text = text:gsub("[^%w]+", "_")
	text = text:gsub("^_+", ""):gsub("_+$", "")

	return text:lower()
end

local function screaming_snake_case(name)
	return snake_case(name):upper()
end

local function tag_value(spec, field_name)
	local transformed = spec.transform == "screaming_snake" and screaming_snake_case(field_name)
		or snake_case(field_name)
	local value = spec.value

	if value:find("%s", 1, true) then
		return value:format(snippet_escape(transformed))
	end

	return value
end

local function parse_field_name(prefix)
	local text = vim.trim(prefix)

	if text == "" or text:find("^//") then
		return nil
	end

	local field_name = text:match("^([_%a][_%w]*)%s*,") or text:match("^([_%a][_%w]*)%s+")

	if field_name == "type" or field_name == "func" or field_name == "return" then
		return nil
	end

	return field_name
end

local function segment_start(tag_text)
	local start = 1
	local search = 1

	while true do
		local _, whitespace_end = tag_text:find("%s+", search)

		if not whitespace_end then
			return start
		end

		start = whitespace_end + 1
		search = whitespace_end + 1
	end
end

local function used_keys(tag_text)
	local keys = {}

	for key in tag_text:gmatch('([_%a][_%w%-]*):"') do
		keys[key] = true
	end

	return keys
end

local function completion_context(ctx)
	if vim.bo.filetype ~= "go" then
		return nil
	end

	local cursor = ctx and ctx.cursor or vim.api.nvim_win_get_cursor(0)
	local line = ctx and ctx.line or vim.api.nvim_get_current_line()
	local cursor_col = cursor[2]
	local before_cursor = line:sub(1, cursor_col)

	if count_char(before_cursor, "`") % 2 == 0 then
		return nil
	end

	local tag_start_col = last_index(before_cursor, "`")

	if not tag_start_col then
		return nil
	end

	local field_name = parse_field_name(line:sub(1, tag_start_col - 1))

	if not field_name then
		return nil
	end

	local tag_text_before = before_cursor:sub(tag_start_col + 1)
	local segment_start_col = segment_start(tag_text_before)
	local current_segment = tag_text_before:sub(segment_start_col)
	local replacement_start_col = tag_start_col + segment_start_col - 1

	local key, value = current_segment:match('^([_%a][_%w%-]*):"([^"]*)$')

	if key and option_specs[key] then
		local value_start_col = replacement_start_col + #key + 2
		local option_start_in_value = key == "validate" and 1 or nil
		local comma_position = last_index(value, ",")

		if comma_position then
			option_start_in_value = comma_position + 1
		end

		if option_start_in_value then
			return {
				mode = "option",
				key = key,
				line = cursor[1] - 1,
				start_col = value_start_col + option_start_in_value - 1,
				end_col = cursor_col,
			}
		end
	end

	if current_segment:find('[:"]') then
		return nil
	end

	return {
		mode = "tag",
		field_name = field_name,
		line = cursor[1] - 1,
		start_col = replacement_start_col,
		end_col = cursor_col,
		used_keys = used_keys(tag_text_before:sub(1, segment_start_col - 1)),
	}
end

local function text_edit(context, new_text)
	return {
		newText = new_text,
		range = {
			start = {
				line = context.line,
				character = context.start_col,
			},
			["end"] = {
				line = context.line,
				character = context.end_col,
			},
		},
	}
end

local function documentation(title, description)
	return {
		kind = "markdown",
		value = ("`%s`\n\n%s"):format(title, description),
	}
end

local function tag_item(context, spec)
	local value = tag_value(spec, context.field_name)
	local preview = ('%s:"%s"'):format(spec.key, value:gsub("%${1:([^}]+)}", "%1"):gsub("%$0", ""))

	return {
		label = spec.label,
		filterText = spec.key,
		sortText = spec.sort,
		kind = item_kind(),
		labelDetails = {
			description = preview,
		},
		textEdit = text_edit(context, ('%s:"%s"$0'):format(spec.key, value)),
		insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
		documentation = documentation(preview, spec.description),
	}
end

local function option_item(context, spec)
	local new_text = spec.insert or spec.label

	return {
		label = spec.label,
		filterText = spec.label,
		sortText = spec.label,
		kind = item_kind(),
		labelDetails = {
			description = context.key,
		},
		textEdit = text_edit(context, new_text),
		insertTextFormat = spec.insert and vim.lsp.protocol.InsertTextFormat.Snippet
			or vim.lsp.protocol.InsertTextFormat.PlainText,
		documentation = documentation(spec.label, spec.description),
	}
end

function source.new()
	return setmetatable({}, { __index = source })
end

function source:enabled()
	return vim.bo.filetype == "go"
end

function source:get_trigger_characters()
	return { "`", " ", "," }
end

function source:get_completions(ctx, callback)
	local context = completion_context(ctx)
	local items = {}

	if context and context.mode == "tag" then
		for _, spec in ipairs(tag_specs) do
			if not context.used_keys[spec.key] then
				table.insert(items, tag_item(context, spec))
			end
		end
	elseif context and context.mode == "option" then
		for _, spec in ipairs(option_specs[context.key] or {}) do
			table.insert(items, option_item(context, spec))
		end
	end

	callback({
		items = items,
		is_incomplete_backward = false,
		is_incomplete_forward = false,
	})
end

return source
