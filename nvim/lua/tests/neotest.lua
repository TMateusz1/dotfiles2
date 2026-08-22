local M = {}

local function assert_equal(actual, expected, label)
	assert(
		vim.deep_equal(actual, expected),
		("%s: expected %s, got %s"):format(label, vim.inspect(expected), vim.inspect(actual))
	)
end

function M.run()
	local neotest = require("config.neotest")
	local root = vim.fn.tempname()
	vim.fn.mkdir(root, "p")
	root = assert(vim.uv.fs_realpath(root))
	local package_dir = vim.fs.joinpath(root, "pkg")
	local new_file = vim.fs.joinpath(package_dir, "new.go")
	local test_file = vim.fs.joinpath(package_dir, "new_test.go")

	vim.fn.mkdir(package_dir)
	vim.fn.writefile({ "module example.com/test" }, vim.fs.joinpath(root, "go.mod"))
	vim.fn.writefile({ "package pkg" }, test_file)
	vim.cmd.edit(vim.fn.fnameescape(new_file))

	assert_equal(neotest.current_file(), new_file, "current test file")
	assert_equal(neotest.current_package_dir(), package_dir, "current test package")
	assert_equal(neotest.project_root(), root, "test project root")
	assert_equal(neotest.integrated_run_args(), { strategy = "integrated" }, "cursor test arguments")
	assert_equal(
		neotest.integrated_run_args(test_file),
		{ test_file, strategy = "integrated" },
		"target test arguments"
	)

	local node = {}
	function node:data()
		return {
			type = "test",
			path = test_file,
			name = "TestExample",
		}
	end
	function node:closest_value_for()
		return { 4, 2, 4, 10 }
	end

	local tree = {}
	function tree:get_key(position_id)
		return position_id == "test-id" and node or nil
	end

	local client = { listeners = {} }
	function client:get_position(_, opts)
		assert_equal(opts, { adapter = "neotest-golang" }, "quickfix adapter")
		return tree
	end

	local consumer = neotest.quickfix_consumer(client)
	client.listeners.results("neotest-golang", {
		["test-id"] = {
			status = "failed",
			errors = {
				{ line = 6, message = "expected failure" },
				{ line = 6, message = "expected failure" },
			},
		},
	}, false)

	assert(
		vim.wait(500, function()
			return vim.fn.getqflist({ title = 0 }).title == "Neotest failures"
		end, 10),
		"Neotest failures were not written to quickfix"
	)

	local quickfix = vim.fn.getqflist({ items = 0, title = 0 })
	assert_equal(quickfix.title, "Neotest failures", "quickfix title")
	assert_equal(#quickfix.items, 1, "deduplicated quickfix item count")
	assert_equal(quickfix.items[1].lnum, 7, "quickfix line")
	assert_equal(quickfix.items[1].col, 3, "quickfix column")
	assert_equal(quickfix.items[1].text, "expected failure", "quickfix message")

	consumer.open()
	assert(vim.fn.getqflist({ winid = 0 }).winid ~= 0, "quickfix window did not open")
	pcall(vim.cmd, "cclose")
	vim.fn.setqflist({}, "r", { title = "", items = {} })
	vim.fn.delete(root, "rf")
	print("neotest-regression-ok")
end

return M
