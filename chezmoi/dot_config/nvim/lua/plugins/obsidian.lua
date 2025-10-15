-- set OBISIDIAN_VAULT_PATH=/path/to/your/vault if needed
local obsidian = function()
	local file_exists = function(filename)
		local command = string.format('test -d "' .. filename .. '" 2>/dev/null', filename)
		local status = os.execute(command)

		if status == 0 then
			vim.notify("Vault found", vim.log.levels.INFO, { title = "Obsidian" })
		else
			vim.notify(
				"Vault not found. Set OBSIDIAN_VAULT_PATH envr var if needed.",
				vim.log.levels.WARNING,
				{ title = "Obsidian" }
			)
		end
		return status == 0
	end

	local default_path = "/Users/seankay/Library/Mobile Documents/iCloud~md~obsidian/Documents/main"
	local obsidian_path = os.getenv("OBSIDIAN_VAULT_PATH") or default_path

	return {
		{
			"obsidian-nvim/obsidian.nvim",
			version = "*",
			ft = "markdown",
			lazy = false,
			cond = file_exists(obsidian_path),
			opts = {
				templates = {
					folder = "Templates",
				},
				frontmatter = {
					enabled = false,
				},
				daily_notes = {
					folder = "Timestamps",
					date_format = "%Y/%m-%B/%Y-%m-%d-%A",
					default_tags = { "daily_note" },
					template = "Daily.md",
				},
				note_id_func = function(title)
					return title
				end,
				workspaces = {
					{
						name = "main",
						path = obsidian_path,
					},
				},
			},
		},
	}
end

return obsidian()
