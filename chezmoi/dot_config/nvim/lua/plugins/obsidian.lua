-- set OBSIDIAN_VAULT_PATH=/path/to/your/vault if needed
local obsidian = function()
	local file_exists = function(filename)
		if vim.fn.isdirectory(filename) ~= 1 then
			vim.notify(
				"Vault not found. Set OBSIDIAN_VAULT_PATH env var if needed.",
				vim.log.levels.ERROR,
				{ title = "Obsidian" }
			)
			return false
		end
		return true
	end

	local home = os.getenv("HOME")
	local default_path = home .. "/main-vault"
	local obsidian_path = os.getenv("OBSIDIAN_VAULT_PATH") or default_path

	return {
		{
			"obsidian-nvim/obsidian.nvim",
			version = "*",
			ft = "markdown",
			lazy = false,
			cond = file_exists(obsidian_path),
			opts = {
				legacy_commands = false,
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
