local S = minetest.get_translator("accountmgr")
local function FS(...)
	return minetest.formspec_escape(S(...))
end


local bulk_dialog = {}


function bulk_dialog.build(context)
	local selected_user = context.selected_user or {}
	context.selected_user = selected_user

	-- Build cells
	local selected_user_idx = -1
	context.users = context.users or {}
	local cells = { "#aaa", FS("Name"), FS("Privs"), FS("Notes") }
	for i, user in ipairs(context.users) do
		cells[#cells + 1] = "#fff"
		cells[#cells + 1] = minetest.formspec_escape(user.name)
		cells[#cells + 1] = minetest.formspec_escape(minetest.privs_to_string(user.privs))
		cells[#cells + 1] = minetest.formspec_escape(user.notes or "")

		if user.name == selected_user.name then
			selected_user_idx = i + 1
		end
	end

	-- Build file list
	local files = minetest.get_dir_list(minetest.get_worldpath(), false)
	local selected_file_idx = 0
	local i = 1
	for _, file in ipairs(files) do
		if file and file:sub(-4):lower() == ".csv" and file:sub(1, 10) ~= "new-users-" then
			files[i] = minetest.formspec_escape(file)
			if file == context.selected_file then
				selected_file_idx = i
			end
			i = i + 1
		end
	end
	for j=i, #files do
		files[j] = nil
	end
	context.files = files

	local fs = {
		"formspec_version[4]",
		"size[16,12]",

		"tablecolumns[color;text;text;text]",
		"table[0.375,0.375;7.25,11.25;users;", table.concat(cells, ","), ";",
			tostring(selected_user_idx), "]",

		"container[8.1875,0.375]",
	}

	if #files > 0 then
		table.insert_all(fs, {
			"label[0,0.25;", FS("Import from CSV"), "]",
			"textlist[0,0.5;7.25,2;import_files;", table.concat(files, ","), ";]",
			"button[0,2.75;3,0.8;refresh;", FS("Refresh"), "]",
		})
		if selected_file_idx ~= 0 then
			table.insert_all(fs, {
				"button[4.25,2.75;3,0.8;import;", FS("Import"), "]",
			})
		else
			table.insert_all(fs, {
				"box[4.25,2.75;3,0.8;#222]",
				"style[import_dis;border=false,textcolor=grey]",
				"button[4.25,2.75;3,0.8;import_dis;", FS("Import"), "]",
			})
		end
	else
		local help_info = minetest.formspec_escape(
			S("Place a .csv file in the world directory (@1) to import users", minetest.get_worldpath()) ..
			"\n\n" ..
			S("This can be a list of usernames, one per line. It can also include privs.\nFull example:") ..
			"\n\n" ..
			"player1\nplayer2, fly fast\nplayer3, fly\nplayer3,")
		table.insert_all(fs, {
			"label[0,0.25;", FS("Import from CSV"), "]",
			"box[0,0.5;7.25,2;#1e1e1e]",
			"textarea[0.1,0.6;7.05,1.8;;;", help_info, "]",
			"button[0,2.75;3,0.8;refresh;", FS("Refresh"), "]",
			"box[4.25,2.75;3,0.8;#222]",
			"style[import_dis;border=false,textcolor=grey]",
			"button[4.25,2.75;3,0.8;import_dis;", FS("Import"), "]",
		})
	end

	table.insert_all(fs, {
		"container_end[]",

		"box[8.005,4.3625;7.625,0.03;#111f]",

		"container[8.1875,4.8]",
		-- "box[0,0;7.25,4;#111]",
		"label[0,0.25;", FS("Create / Update"), "]",
		"field[0,1;3.625,0.8;user_name;", FS("Name"), ";", selected_user.name or "", "]",
		"field[0,2.3;7.25,0.8;user_privs;", FS("Privileges"), ";",
			minetest.privs_to_string(selected_user.privs or {}, ", "), "]",
		"textarea[0,3.6;7.25,1.6;user_notes;", FS("Notes"), ";", selected_user.notes or "", "]",
		"button[5.25,0;2,0.8;user_save;", FS("Save"), "]",
		"button[3,0;2,0.8;user_delete;", FS("Delete"), "]",
		"container_end[]",

		"box[8.005,10.4125;7.625,0.03;#111f]",

		"container[8.1875,10.825]",
		"textarea[0,0;4.1875,0.8;;;", minetest.formspec_escape(context.message or ""), "]",
		"button[4.4375,0;3,0.8;create;", FS("Create Accounts"), "]",
		"container_end[]",
	})

	return table.concat(fs, "")
end


local function parse_csv(text)
	local users = {}

	local lines = text:split("\n")
	for _, line in ipairs(lines) do
		local parts = line:trim():split(",")
		if parts[1] ~= "" then
			local user = {
				name = parts[1]:trim():gsub("[^A-Za-z0-9_-]", "_"),
				privs = {},
				notes = parts[3] and parts[3]:trim() or "",
			}

			if parts[2] then
				user.privs = minetest.string_to_privs(parts[2], " ")
			end

			users[#users + 1] = user
		end
	end

	return users
end


local function update_user(users, user)
	for i, existing in ipairs(users) do
		if existing.name == user.name then
			users[i] = user
			return
		end
	end

	table.insert(users, user)
end


local password_charset = {}
-- a-zA-Z0-9
for i = 48,  57 do table.insert(password_charset, string.char(i)) end
for i = 65,  90 do table.insert(password_charset, string.char(i)) end
for i = 97, 122 do table.insert(password_charset, string.char(i)) end
table.insert_all(password_charset, { "_", "-", "!" })

function generate_password(length)
	local ret = ""
	for i=1, length do
		ret = ret ..  password_charset[math.random(1, #password_charset)]
	end
	return ret
end


local function write_reports(player, users, passwords)
	local filename = "new-users-" .. os.date("!%Y-%m-%d-%T")
	local filepath = minetest.get_worldpath() .. "/" .. filename

	minetest.log("action", ("Exported account creation reports to %s and %s"):format(
		filename .. ".csv", filename .. ".html"))

	-- CSV
	do
		local file = io.open(filepath .. ".csv", "w")
		file:write("Name, Password, Notes", "\n")
		for _, user in pairs(users) do
			file:write(("%s, %s, %s\n"):format(
				user.name, passwords[user.name], user.notes or ""))
		end
		file:close()
	end

	-- HTML
	do
		local file = io.open(filepath .. ".html", "w")

		local rows = ""
		for _, user in pairs(users) do
			rows = rows .. ("<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n"):format(
				user.name, passwords[user.name], user.notes or "")
		end

		local locale = minetest.get_player_information(player:get_player_name()).lang_code
		local title = minetest.get_translated_string(locale, S("Minetest Accounts"))

		file:write(([[
			<!doctype html>
			<html>
				<head>
					<title>%s</title>
					<style>
						body {
							font-family: "Arial", sans-serif;
							padding: 0.5rem;
						}
						h1 {
							margin-top: 0;
						}
						table {
							width: 100%%;
							border-collapse: collapse;
						}
						table td, table th {
							border: 1px solid #ddd;
							padding: 8px;
						}
						table tr:nth-child(even) {
							background-color: #f2f2f2;
						}
						table th {
							padding: 12px 8px;
							text-align: left;
							background-color: #04AA6D;
							color: white;
						}
					</style>
				</head>
				<body>
					<h1>%s</h1>
					<table>
						<thead>
							<tr><th>Name</th><th>Password</th><th>Notes</th></tr>
						</thead>
						<tbody>
							%s
						</tbody>
					</table>
				</body>
			</html>
		]]):format(title, title, rows), "\n")
		file:close()
	end

	return filename
end


function bulk_dialog.on_submit(player, context, fields)
	if not minetest.check_player_privs(player, { server = true }) then
		return
	end

	context.message = ""

	if fields.import_files then
		local e = minetest.explode_textlist_event(fields.import_files)
		context.selected_file = context.files and context.files[e.index] or context.selected_file
		if e.type == "DCL" then
			fields.import = "true"
		else
			return true
		end
	end

	if fields.users then
		local e = minetest.explode_table_event(fields.users)
		if e.row > 1 then
			local user = context.users[e.row - 1]
			context.selected_user = table.copy(user)
		end
		return true
	end

	if fields.user_name or fields.user_privs or fields.user_notes then
		context.selected_user.name = fields.user_name
		context.selected_user.privs = minetest.string_to_privs(fields.user_privs, ",")
		context.selected_user.notes = fields.user_notes
	end

	if fields.user_save then
		update_user(context.users, table.copy(context.selected_user))
		return true
	end

	if fields.user_delete then
		for i, user in ipairs(context.users) do
			if user.name == context.selected_user.name then
				table.remove(context.users, i)
				context.selected_user = {}
				break
			end
		end
		return true
	end

	if fields.import and context.selected_file then
		context.users = context.users or {}
		local path = minetest.get_worldpath() .. "/" .. context.selected_file

		local file = io.open(path, "r")
		if file then
			local users = parse_csv(file:read("*all"))
			for _, user in ipairs(users) do
				update_user(context.users, user)
			end

			file:close()
		end

		return true
	end

	if fields.create then
		local passwords = {}

		local handler = minetest.get_auth_handler()
		for _, user in ipairs(context.users) do
			passwords[user.name] = generate_password(16)

			local hash = minetest.get_password_hash(user.name, passwords[user.name])
			if handler.get_auth(user.name) then
				handler.set_password(user.name, hash)
			else
				handler.create_auth(user.name, hash)
			end

			if next(user.privs) then
				handler.set_privileges(user.name, user.privs)
			end
		end

		local filename = write_reports(player, context.users, passwords)
		context.message = S("Exported to world dir as @1", filename)

		return true
	end

	if fields.refresh then
		return true
	end

	return false
end


local contexts = {}
minetest.register_on_leaveplayer(function(player)
	contexts[player:get_player_name()] = nil
end)


function bulk_dialog.show(name)
	local context = contexts[name] or {}
	contexts[name] = context

	local fs = bulk_dialog.build(context)
	minetest.show_formspec(name, "accountmgr:create", fs)
end


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "accountmgr:create" then
		return false
	end

	local name = player:get_player_name()
	local context = contexts[name] or {}
	contexts[name] = context

	if bulk_dialog.on_submit(player, context, fields) then
		local fs = bulk_dialog.build(context)
		minetest.show_formspec(name, "accountmgr:create", fs)
		return true
	end

	return false
end)

return bulk_dialog
