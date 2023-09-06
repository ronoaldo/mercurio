-- Init stuff
if minetest.get_modpath("realchess") ~= nil then
	-- If the 'realchess' mod was found, don't use any of this mod's Chess code
	minetest.log("action", "[xdecor] 'realchess' mod detected. Disabling X-Decor-libre's Chess module in favor of realchess")
	return
end

-- For making some functions available for the chessbot.
-- It is NOT recommended to use the public chess function outside of this mod!
xdecor.chess = {}

local realchess = xdecor.chess -- just an alias

-- Load chess bot code
local chessbot = dofile(minetest.get_modpath(minetest.get_current_modname()).."/src/chessbot.lua")

screwdriver = screwdriver or {}

-- Translation init
local S = minetest.get_translator("xdecor")
local NS = function(s) return s end
local FS = function(...) return minetest.formspec_escape(S(...)) end

-- Chess games are disabled because they are currently too broken.
-- Set this to true to enable this again and try your luck.
local ENABLE_CHESS_GAMES = true

-- If true, will show some hidden state for debugging purposes
-- and enables a "Bot vs Bot" gamemode for testing the bot
local CHESS_DEBUG = false

-- Number of consecutive halfmoves in which no pawn was moved
-- and no piece was captured after which a player can claim a draw.
local DRAWCLAIM_LONGGAME_PLAYER = 100 -- 50-move rule
-- Number of consecutive halfmoves in which no pawn was moved
-- and no piece was captured after which the game draw automatically.
local DRAWCLAIM_LONGGAME_FORCE = 150 -- 75-move rule

-- Bot names
local BOT_NAME = NS("Weak Computer")
-- Bot names in Bot vs Bot mode
local BOT_NAME_1 = NS("Weak Computer 1")
local BOT_NAME_2 = NS("Weak Computer 2")

-- Timeout in seconds to allow resetting the game or digging the chessboard.
-- If no move was made for this time, everyone can reset the game
-- and remove the chessboard.
local TIMEOUT = 300

local ALPHA_OPAQUE = minetest.features.use_texture_alpha_string_modes and "opaque" or false

-- Returns the player name for the given player color.
-- In case of a bot player, will return a translated
-- bot name.
local function get_display_player_name(meta, playerColor)
	local botColor = meta:get_string("botColor")
	local displayName
	if playerColor == botColor and (botColor == "white" or botColor == "black") then
		return "*"..S(BOT_NAME).."*"
	elseif botColor == "both" then
		if playerColor == "white" then
			return "*"..S(BOT_NAME_1).."*"
		else
			return "*"..S(BOT_NAME_2).."*"
		end
	elseif playerColor == "white" then
		return meta:get_string("playerWhite")
	elseif playerColor == "black" then
		return meta:get_string("playerBlack")
	else
		return ""
	end
end

local function index_to_xy(idx)
	if not idx then
		return nil
	end

	idx = idx - 1

	local x = idx % 8
	local y = math.floor((idx - x) / 8)

	return x, y
end

local function xy_to_index(x, y)
	return x + y * 8 + 1
end

local function get_square(a, b)
	return (a * 8) - (8 - b)
end

-- Given a board index (1..64), returns the color of the square at
-- this position: "light" or "dark".
-- Undefined behavior if given an invalid board index
local function get_square_index_color(idx)
	local x, y = index_to_xy(idx)
	if not x then
		return nil
	end
	if x % 2 == 0 then
		if y % 2 == 0 then
			return "light"
		else
			return "dark"
		end
	else
		if y % 2 == 0 then
			return "dark"
		else
			return "light"
		end
	end
end

local chat_prefix = minetest.colorize("#FFFF00", "["..S("Chess").."] ")
local chat_prefix_debug = minetest.colorize("#FFFF00", "["..S("Chess Debug").."] ")

-- Send a chat message to a player with a prefix.
-- If you pass playerColor and botColor, this function will also
-- check if the player is a bot, in which case the message
-- is not sent.
-- If you only pass playerName and message, the message will always
-- be sent (if the player exists).
--
-- Parameters:
-- * playerName: Name of player to send message to (can be a bot name)
-- * message: The message text
-- * playerColor: "white", "black" or nil (if color is irrelevant)
-- * botColor: optional color of the bot(s):
--     * "white", "black": white or black
--     * "both": Both players are bots
--     * "": No player is a bot (default)
-- * isDebug: if true, message will only be shown in Chess Debug Mode (default: false)
local function send_message(playerName, message, playerColor, botColor, isDebug)
	local prefix
	if isDebug then
		if not CHESS_DEBUG then
			return
		end
		prefix = chat_prefix_debug
	else
		prefix = chat_prefix
	end
	minetest.chat_send_player(playerName, prefix .. message)
end
-- Send a message to both players of the chess game (except bots, if botColor is provided)
-- * playerName1: White player name
-- * playerName2: Black player name
-- * message: Message text
-- * botColor: See `send_message`
-- * isDebug: See `send_message`
local function send_message_2(playerName1, playerName2, message, botColor, isDebug)
	send_message(playerName1, message, "white", botColor, isDebug)
	if playerName2 ~= playerName1 then
		send_message(playerName2, message, "black", botColor, isDebug)
	end
end

local notation_letters = {'a','b','c','d','e','f','g','h'}
function realchess.index_to_notation(idx)
	local x, y = index_to_xy(idx)
	if not x or not y then
		return "??"
	end
	local xstr = notation_letters[x+1] or "?"
	local ystr = tostring(9 - (y+1)) or "?"
	return xstr .. ystr
end

function realchess.board_to_table(inv)
	local t = {}
	for i = 1, 64 do
		t[#t + 1] = inv:get_stack("board", i):get_name()
	end

	return t
end

local piece_values = {
	pawn   = 10,
	knight = 30,
	bishop = 30,
	rook   = 50,
	queen  = 90,
	king   = 900
}

local rowDirs = {-1, -1, -1, 0, 0, 1, 1, 1}
local colDirs = {-1, 0, 1, -1, 1, -1, 0, 1}

local rowDirsKnight = { 2,  1, 2, 1, -2, -1, -2, -1}
local colDirsKnight = {-1, -2, 1, 2,  1,  2, -1, -2}

local bishopThreats = {true,  false, true,  false, false, true,  false, true}
local rookThreats   = {false, true,  false, true,  true,  false, true,  false}
local queenThreats  = {true,  true,  true,  true,  true,  true,  true,  true}
local kingThreats   = {true,  true,  true,  true,  true,  true,  true,  true}

function realchess.attacked(color, idx, board)
	local threatDetected = false
	local kill           = color == "white"
	local pawnThreats    = {kill, false, kill, false, false, not kill, false, not kill}

	for dir = 1, 8 do
		if not threatDetected then
			local col, row = index_to_xy(idx)
			col, row = col + 1, row + 1

			for step = 1, 8 do
				row = row + rowDirs[dir]
				col = col + colDirs[dir]

				if row >= 1 and row <= 8 and col >= 1 and col <= 8 then
					local square            = get_square(row, col)
					local square_name       = board[square]
					local piece, pieceColor = square_name:match(":(%w+)_(%w+)")

					if piece then
						if pieceColor ~= color then
							if piece == "bishop" and bishopThreats[dir] then
								threatDetected = true
							elseif piece == "rook" and rookThreats[dir] then
								threatDetected = true
							elseif piece == "queen" and queenThreats[dir] then
								threatDetected = true
							else
								if step == 1 then
									if piece == "pawn" and pawnThreats[dir] then
										threatDetected = true
									end
									if piece == "king" and kingThreats[dir] then
										threatDetected = true
									end
								end
							end
						end
						break
					end
				end
			end

			local colK, rowK = index_to_xy(idx)
			colK, rowK = colK + 1, rowK + 1
			rowK = rowK + rowDirsKnight[dir]
			colK = colK + colDirsKnight[dir]

			if rowK >= 1 and rowK <= 8 and colK >= 1 and colK <= 8 then
				local square            = get_square(rowK, colK)
				local square_name       = board[square]
				local piece, pieceColor = square_name:match(":(%w+)_(%w+)")

				if piece and pieceColor ~= color and piece == "knight" then
					threatDetected = true
				end
			end
		end
	end

	return threatDetected
end

local function get_current_halfmove(meta)
	local moves_raw = meta:get_string("moves_raw")
	local mrsplit = string.split(moves_raw, ";")
	return #mrsplit
end
local function get_current_fullmove(meta)
	local moves_raw = meta:get_string("moves_raw")
	local mrsplit = string.split(moves_raw, ";")
	return math.floor(#mrsplit / 2)
end

-- Returns a FEN-style string to represent castling rights
-- Will return a sequence of K, Q, k and q, with each letter
-- representing castling rights:
-- * K: white kingside
-- * Q: white queenside
-- * k: black kingside
-- * q: black queenside
-- If all castling rights are gone, will return "-" instead.
-- The 4 arguments are booleans for each possible castling,
-- true means the castling is possible.
local function castling_to_string(white_kingside, white_queenside, black_kingside, black_queenside)
	local s_castling = ""
	if white_kingside then
		s_castling = s_castling .. "K"
	end
	if white_queenside then
		s_castling = s_castling .. "Q"
	end
	if black_kingside then
		s_castling = s_castling .. "k"
	end
	if black_queenside then
		s_castling = s_castling .. "q"
	end
	if s_castling == "" then
		s_castling = "-"
	end
	return s_castling
end

-- Returns a FEN-style string to represent the state of a theoretically
-- possible en passant capture on the board (even if no pawn can actually
-- capture). If an en passant capture is possible, returns the square
-- coordinates in algebraic notation of the square the vulnerable pawn
-- has just crossed. If no en passant capture is possible, returns "-".
-- double_step is the board index of the square the vulnerable
-- pawn has just double-stepped to or 0 if there is no such pawn.
local function en_passant_to_string(double_step)
	local s_en_passant = "-"
	if double_step ~= 0 and double_step ~= nil then
		-- write the square crossed by the pawn who made
		-- the double step
		local dsx, dsy = index_to_xy(double_step)
		if dsy == 3 then
			dsy = dsy - 1
		else
			dsy = dsy + 1
		end
		s_en_passant = realchess.index_to_notation(xy_to_index(dsx, dsy))
	end
	return s_en_passant
end

local function can_castle(meta, board, from_list, from_idx, to_idx)
	local from_x, from_y = index_to_xy(from_idx)
	local to_x, to_y = index_to_xy(to_idx)
	local inv = meta:get_inventory()
	local kingPiece = inv:get_stack(from_list, from_idx):get_name()
	local kingColor
	if kingPiece:find("black") then
		kingColor = "black"
	else
		kingColor = "white"
	end
	local possible_castles = {
		-- white queenside
		{ y = 7, to_x = 2, rook_idx = 57, rook_goal = 60, acheck_dir = -1, color = "white", meta = "castlingWhiteL", rook_id = 1 },
		-- white kingside
		{ y = 7, to_x = 6, rook_idx = 64, rook_goal = 62, acheck_dir = 1, color = "white", meta = "castlingWhiteR", rook_id = 2 },
		-- black queenside
		{ y = 0, to_x = 2, rook_idx = 1, rook_goal = 4, acheck_dir = -1, color = "black", meta = "castlingBlackL", rook_id = 1 },
		-- black kingside
		{ y = 0, to_x = 6, rook_idx = 8, rook_goal = 6, acheck_dir = 1, color = "black", meta = "castlingBlackR", rook_id = 2 },
	}

	for p=1, #possible_castles do
		local pc = possible_castles[p]
		if pc.color == kingColor and pc.to_x == to_x and to_y == pc.y and from_y == pc.y then
			local castlingMeta = meta:get_int(pc.meta)
			local rookPiece = inv:get_stack(from_list, pc.rook_idx):get_name()
			if castlingMeta == 1 and rookPiece == "realchess:rook_"..kingColor.."_"..pc.rook_id then
				-- Check if all squares between king and rook are empty
				local empty_start, empty_end
				if pc.acheck_dir == -1 then
					-- queenside
					empty_start = pc.rook_idx + 1
					empty_end = from_idx - 1
				else
					-- kingside
					empty_start = from_idx + 1
					empty_end = pc.rook_idx - 1
				end
				for i = empty_start, empty_end do
					if inv:get_stack(from_list, i):get_name() ~= "" then
						return false
					end
				end
				-- Check if square of king as well the squares that king must cross and reach
				-- are NOT attacked
				for i = from_idx, from_idx + 2 * pc.acheck_dir, pc.acheck_dir do
					if realchess.attacked(kingColor, i, board) then
						return false
					end
				end
				return true, pc.rook_idx, pc.rook_goal, "realchess:rook_"..kingColor.."_"..pc.rook_id
			end
		end
	end
	return false

end

-- Checks if a square to check if there is a piece that can be captured en passant. Returns true if this
-- is the case, false otherwise.
-- Parameters:
-- * meta: chessboard node metadata
-- * victim_color: color of the opponent to capture a piece from. "white" or "black". (so in White's turn, pass "black" here)
-- * victim_index: board index of the square where you expect the victim to be
local function can_capture_en_passant(meta, victim_color, victim_index)
	local inv = meta:get_inventory()
	local victimPiece = inv:get_stack("board", victim_index)
	local double_step_index = meta:get_int("prevDoublePawnStepTo")
	local victim_name = victimPiece:get_name()
	if double_step_index ~= 0 and double_step_index == victim_index and victim_name:find(victim_color) and victim_name:sub(11,14) == "pawn" then
		return true
	end
	return false
end

-- Returns all theoretically possible moves from a given
-- square, according to the piece it occupies. Ignores restrictions like check, etc.
-- If the square is empty, no moves are returned.
-- Parameters:
-- * board: chessboard table
-- * from_idx:
-- returns: table with the keys used as destination indices
--    Any key with a numeric value is a possible destination.
--    The numeric value is a move rating for the bot and is 0 by default.
-- Example: { [4] = 0, [9] = 0 } -- can move to squares 4 and 9
local function get_theoretical_moves_from(meta, board, from_idx)
	local piece, color = board[from_idx]:match(":(%w+)_(%w+)")
	if not piece then
		return {}
	end
	local moves = {}
	local from_x, from_y = index_to_xy(from_idx)

	for i = 1, 64 do
		local stack_name = board[i]
		if stack_name:find((color == "black" and "white" or "black")) or
				stack_name == "" then
			moves[i] = 0
		end
	end

	for to_idx in pairs(moves) do
		local pieceTo    = board[to_idx]
		local to_x, to_y = index_to_xy(to_idx)

		-- PAWN
		if piece == "pawn" then
			if color == "white" then
				local pawnWhiteMove = board[xy_to_index(from_x, from_y - 1)]
				local en_passant = false
				-- white pawns can go up only
				if from_y - 1 == to_y then
					if from_x == to_x then
						if pieceTo ~= "" then
							moves[to_idx] = nil
						end
					elseif from_x - 1 == to_x or from_x + 1 == to_x then
						local can_capture = false
						if pieceTo:find("black") then
							can_capture = true
						else
							-- en passant
							if can_capture_en_passant(meta, "black", xy_to_index(to_x, from_y)) then
								can_capture = true
								en_passant = true
							end
						end
						if not can_capture then
							moves[to_idx] = nil
						end
					else
						moves[to_idx] = nil
					end
				elseif from_y - 2 == to_y then
					if pieceTo ~= "" or from_y < 6 or pawnWhiteMove ~= "" then
						moves[to_idx] = nil
					end
				else
					moves[to_idx] = nil
				end

				--[[
				     if x not changed
				          ensure that destination cell is empty
				     elseif x changed one unit left or right
				          ensure the pawn is killing opponent piece
				     else
				          move is not legal - abort
				]]

				if from_x == to_x then
					if pieceTo ~= "" then
						moves[to_idx] = nil
					end
				elseif from_x - 1 == to_x or from_x + 1 == to_x then
					if not pieceTo:find("black") and not en_passant then
						moves[to_idx] = nil
					end
				else
					moves[to_idx] = nil
				end

			elseif color == "black" then
				local pawnBlackMove = board[xy_to_index(from_x, from_y + 1)]
				local en_passant = false
				-- black pawns can go down only
				if from_y + 1 == to_y then
					if from_x == to_x then
						if pieceTo ~= "" then
							moves[to_idx] = nil
						end
					elseif from_x - 1 == to_x or from_x + 1 == to_x then
						local can_capture = false
						if pieceTo:find("white") then
							can_capture = true
						else
							-- en passant
							if can_capture_en_passant(meta, "white", xy_to_index(to_x, from_y)) then
								can_capture = true
								en_passant = true
							end
						end
						if not can_capture then
							moves[to_idx] = nil
						end
					else
						moves[to_idx] = nil
					end
				elseif from_y + 2 == to_y then
					if pieceTo ~= "" or from_y > 1 or pawnBlackMove ~= "" then
						moves[to_idx] = nil
					end
				else
					moves[to_idx] = nil
				end

				--[[
				     if x not changed
				          ensure that destination cell is empty
				     elseif x changed one unit left or right
				          ensure the pawn is killing opponent piece
				     else
				          move is not legal - abort
				]]

				if from_x == to_x then
					if pieceTo ~= "" then
						moves[to_idx] = nil
					end
				elseif from_x - 1 == to_x or from_x + 1 == to_x then
					if not pieceTo:find("white") and not en_passant then
						moves[to_idx] = nil
					end
				else
					moves[to_idx] = nil
				end
			else
				moves[to_idx] = nil
			end

		-- ROOK
		elseif piece == "rook" then
			if from_x == to_x then
				-- Moving vertically
				if from_y < to_y then
					-- Moving down
					-- Ensure that no piece disturbs the way
					for i = from_y + 1, to_y - 1 do
						if board[xy_to_index(from_x, i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Moving up
					-- Ensure that no piece disturbs the way
					for i = to_y + 1, from_y - 1 do
						if board[xy_to_index(from_x, i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			elseif from_y == to_y then
				-- Moving horizontally
				if from_x < to_x then
					-- moving right
					-- ensure that no piece disturbs the way
					for i = from_x + 1, to_x - 1 do
						if board[xy_to_index(i, from_y)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Moving left
					-- Ensure that no piece disturbs the way
					for i = to_x + 1, from_x - 1 do
						if board[xy_to_index(i, from_y)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			else
				-- Attempt to move arbitrarily -> abort
				moves[to_idx] = nil
			end

		-- KNIGHT
		elseif piece == "knight" then
			-- Get relative pos
			local dx = from_x - to_x
			local dy = from_y - to_y

			-- Get absolute values
			if dx < 0 then
				dx = -dx
			end

			if dy < 0 then
				dy = -dy
			end

			-- Sort x and y
			if dx > dy then
				dx, dy = dy, dx
			end

			-- Ensure that dx == 1 and dy == 2
			if dx ~= 1 or dy ~= 2 then
				moves[to_idx] = nil
			end
			-- Just ensure that destination cell does not contain friend piece
			-- ^ It was done already thus everything ok

		-- BISHOP
		elseif piece == "bishop" then
			-- Get relative pos
			local dx = from_x - to_x
			local dy = from_y - to_y

			-- Get absolute values
			if dx < 0 then
				dx = -dx
			end

			if dy < 0 then
				dy = -dy
			end

			-- Ensure dx and dy are equal
			if dx ~= dy then
				moves[to_idx] = nil
			end

			if from_x < to_x then
				if from_y < to_y then
					-- Moving right-down
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x + i, from_y + i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Moving right-up
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x + i, from_y - i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			else
				if from_y < to_y then
					-- Moving left-down
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x - i, from_y + i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Moving left-up
					-- ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x - i, from_y - i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			end

		-- QUEEN
		elseif piece == "queen" then
			local dx = from_x - to_x
			local dy = from_y - to_y

			-- Get absolute values
			if dx < 0 then
				dx = -dx
			end

			if dy < 0 then
				dy = -dy
			end

			-- Ensure valid relative move
			if dx ~= 0 and dy ~= 0 and dx ~= dy then
				moves[to_idx] = nil
			end

			if from_x == to_x then
				-- Moving vertically
				if from_y < to_y then
					-- Moving down
					-- Ensure that no piece disturbs the way
					for i = from_y + 1, to_y - 1 do
						if board[xy_to_index(from_x, i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Moving up
					-- Ensure that no piece disturbs the way
					for i = to_y + 1, from_y - 1 do
						if board[xy_to_index(from_x, i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			elseif from_x < to_x then
				if from_y == to_y then
					-- Goes right
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x + i, from_y)] ~= "" then
							moves[to_idx] = nil
						end
					end
				elseif from_y < to_y then
					-- Goes right-down
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x + i, from_y + i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Goes right-up
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x + i, from_y - i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			else
				if from_y == to_y then
					-- Moving horizontally
					if from_x < to_x then
						-- moving right
						-- ensure that no piece disturbs the way
						for i = from_x + 1, to_x - 1 do
							if board[xy_to_index(i, from_y)] ~= "" then
								moves[to_idx] = nil
							end
						end
					else
						-- Moving left
						-- Ensure that no piece disturbs the way
						for i = to_x + 1, from_x - 1 do
							if board[xy_to_index(i, from_y)] ~= "" then
								moves[to_idx] = nil
							end
						end
					end
				elseif from_y < to_y then
					-- Goes left-down
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x - i, from_y + i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				else
					-- Goes left-up
					-- Ensure that no piece disturbs the way
					for i = 1, dx - 1 do
						if board[xy_to_index(from_x - i, from_y - i)] ~= "" then
							moves[to_idx] = nil
						end
					end
				end
			end

		-- KING
		elseif piece == "king" then
			local inv = meta:get_inventory()
			-- King can't move to any attacked square
			-- king_board simulates the board with the king moved already.
			-- Required for the attacked() check to work
			local king_board = realchess.board_to_table(inv)
			king_board[to_idx] = king_board[from_idx]
			king_board[from_idx] = ""
			if realchess.attacked(color, to_idx, king_board) then
				moves[to_idx] = nil
			else
				local dx = from_x - to_x
				local dy = from_y - to_y

				if dx < 0 then
					dx = -dx
				end

				if dy < 0 then
					dy = -dy
				end

				if dx > 1 or dy > 1 then
					local cc = can_castle(meta, board, "board", from_idx, to_idx)
					if not cc then
						moves[to_idx] = nil
					end
				end
			end
		end
	end

	if not next(moves) then
		return {}
	end

	-- Rate the possible moves depending on its piece value
	-- TODO: Move this to chessbot.lua
	for i in pairs(moves) do
		local stack_name = board[tonumber(i)]
		if stack_name ~= "" then
			for p, value in pairs(piece_values) do
				if stack_name:find(p) then
					moves[i] = value
				end
			end
		end
	end

	return moves
end

-- returns all theoretically possible moves on the board for a player
-- Parameters:
-- * board: chessboard table
-- * player: "black" or "white"
-- returns: table of this format:
-- {
--	[origin_index_1] = { [destination_index_1] = r1, [destination_index_2] = r2 },
--	[origin_index_2] = { [destination_index_3] = r3 },
--      ...
-- }
--   origin_index is the board index for the square to start the piece from (as string)
--   and this is the key for a list of destination indixes.
--   r1, r2, r3 ... are numeric values (normally 0) to "rate" this square for the bot.
function realchess.get_theoretical_moves_for(meta, board, player)
	local moves = {}
	for i = 1, 64 do
		local possibleMoves = get_theoretical_moves_from(meta, board, i)
		if next(possibleMoves) then
			local stack_name = board[i]
			if stack_name:find(player) then
				moves[tostring(i)] = possibleMoves
			end
		end
	end
	return moves
end

function realchess.locate_kings(board)
	local Bidx, Widx
	for i = 1, 64 do
		local piece, color = board[i]:match(":(%w+)_(%w+)")
		if piece == "king" then
			if color == "black" then
				Bidx = i
			else
				Widx = i
			end
		end
	end

	return Bidx, Widx
end

-- Given a table of theoretical moves, returns a table
-- of moves that are safe for the king, i.e. moves
-- that neither put or leave the king at risk.
-- 2nd return value is the number of said safe moves.
-- * theoretical_moves: moves table returned by realchess.get_theoretical_moves_for()
-- * board: board table
-- * player: player color ("white" or "black")
function realchess.get_king_safe_moves(theoretical_moves, board, player)
	local safe_moves = {}
	local safe_moves_count = 0
	-- create a virtual board
	local v_board = table.copy(board)

	for from_idx, _ in pairs(theoretical_moves) do
	for to_idx, value in pairs(_) do
		from_idx = tonumber(from_idx)

		-- save the old board values before manipulating them
		local bak_to = v_board[to_idx]
		local bak_from = v_board[from_idx]

		-- move the piece on the virtual board
		v_board[to_idx]   = v_board[from_idx]
		v_board[from_idx] = ""
		local black_king_idx, white_king_idx = realchess.locate_kings(v_board)
		if not black_king_idx or not white_king_idx then
			minetest.log("error", "[xdecor] Chess: Insufficient kings on chessboard!")
			return {}, 0
		end
		local king_idx
		if player == "black" then
			king_idx = black_king_idx
		else
			king_idx = white_king_idx
		end
		local playerAttacked = realchess.attacked(player, king_idx, v_board)
		if not playerAttacked then
			safe_moves[from_idx] = safe_moves[from_idx] or {}
			safe_moves[from_idx][to_idx] = value
			safe_moves_count = safe_moves_count + 1
		end

		-- restore the old state of the virtual board
		v_board[to_idx] = bak_to
		v_board[from_idx] = bak_from
	end
	end

	return safe_moves, safe_moves_count
end

-- Given a chessboard, checks whether it is in a "dead position",
-- i.e. a position in which neither player would be able to checkmate.
-- This function does not cover all dead positions, but only
-- the most common ones.
-- NOT checked are dead posisions in which both sides can still move,
-- but cannot capture pieces or checkmate the king
-- Parameters
-- * board: Chessboard table
-- Returns true if the board is in a dead position, false otherwise.
local function is_dead_position(board)
	-- Dead position by lack of material
	local mat = {} -- material table to count pieces
	-- white material
	mat.w = {
		-- piece counters
		pawn = 0,
		bishop = 0,
		knight = 0,
		rook = 0,
		queen = 0,
		-- for bishops, also record their square color
		bishop_square_light = 0,
		bishop_square_dark = 0,
	}
	-- black material
	mat.b = table.copy(mat.w)
	-- Count material for both players
	for b=1, #board do
		local piece = board[b]
		if piece ~= "" then
			local color
			if piece:find("white") then
				color = "w"
			else
				color = "b"
			end
			-- Count all pieces except kings because we can assume
			-- the board always has 1 white and 1 black king
			if piece:find("pawn") then
				mat[color].pawn = mat[color].pawn + 1
			elseif piece:find("bishop") then
				mat[color].bishop = mat[color].bishop + 1
				local sqcolor = get_square_index_color(b)
				mat[color]["bishop_square_"..sqcolor] = mat[color]["bishop_square_"..sqcolor] + 1
			elseif piece:find("knight") then
				mat[color].knight = mat[color].knight + 1
			elseif piece:find("rook") then
				mat[color].rook = mat[color].rook + 1
			elseif piece:find("queen") then
				mat[color].queen = mat[color].queen + 1
			end
		end
	end
	-- Check well-known dead positions based on insufficient material.
	-- If there is any rook, queen or pawn on the board, the material is sufficient.
	if mat.w.rook == 0 and mat.w.queen == 0 and mat.w.pawn == 0 and
			mat.b.rook == 0 and mat.b.queen == 0 and mat.b.pawn == 0 then
		-- King against king
		if mat.w.knight == 0 and mat.w.bishop == 0 and mat.b.knight == 0 and mat.b.bishop == 0 then
			return true
		-- King against king and bishop
		elseif mat.w.knight == 0 and mat.b.knight == 0 and
				((mat.w.bishop == 1 and mat.b.bishop == 0) or
				(mat.w.bishop == 0 and mat.b.bishop == 1)) then
			return true
		-- King against king and knight
		elseif mat.w.bishop == 0 and mat.b.bishop == 0 and
				((mat.w.knight == 1 and mat.b.knight == 0) or
				(mat.w.knight == 0 and mat.b.knight == 1)) then
			return true
		-- King and bishop against king and bishop,
		-- and both bishops are on squares of the same color
		elseif mat.w.knight == 0 and mat.b.knight == 0 and
				(mat.w.bishop == 1 and mat.b.bishop == 1) and
				(mat.w.bishop_square_color_light == mat.b.bishop_square_color_light) and
				(mat.w.bishop_square_color_dark == mat.b.bishop_square_color_dark) then
			return true
		end
	end

	return false
end

-- Base names of all Chess pieces (with color)
local pieces_basenames = {
	"pawn_white",
	"rook_white",
	"knight_white",
	"bishop_white",
	"queen_white",
	"king_white",
	"pawn_black",
	"rook_black",
	"knight_black",
	"bishop_black",
	"queen_black",
	"king_black",
}

-- Initial positions of the pieces on the chessboard.
-- The pieces are specified as item names.
-- It starts a8, continues with b8, c8, etc. then continues with a7, b7, etc. etc.
local starting_grid = {
	-- rank '8'
	"realchess:rook_black_1", -- a8
	"realchess:knight_black_1", -- b8
	"realchess:bishop_black_1", -- c8
	"realchess:queen_black", -- ...
	"realchess:king_black",
	"realchess:bishop_black_2",
	"realchess:knight_black_2",
	"realchess:rook_black_2",
	-- rank '8'
	-- rank '7'
	"realchess:pawn_black_1",
	"realchess:pawn_black_2",
	"realchess:pawn_black_3",
	"realchess:pawn_black_4",
	"realchess:pawn_black_5",
	"realchess:pawn_black_6",
	"realchess:pawn_black_7",
	"realchess:pawn_black_8",
	-- ranks '6' thru '3'
	'','','','','','','','',
	'','','','','','','','',
	'','','','','','','','',
	'','','','','','','','',
        -- rank '2'
	"realchess:pawn_white_1",
	"realchess:pawn_white_2",
	"realchess:pawn_white_3",
	"realchess:pawn_white_4",
	"realchess:pawn_white_5",
	"realchess:pawn_white_6",
	"realchess:pawn_white_7",
	"realchess:pawn_white_8",
        -- rank '1'
	"realchess:rook_white_1",
	"realchess:knight_white_1",
	"realchess:bishop_white_1",
	"realchess:queen_white",
	"realchess:king_white",
	"realchess:bishop_white_2",
	"realchess:knight_white_2",
	"realchess:rook_white_2"
}

-- Figurine image IDs and file names for the chess notation table.
-- Note: "figurine" refers to the chess notation icon, NOT the chess piece for playing.
local figurines_str = "", 0
local figurines_str_cnt = 0
local MOVES_LIST_SYMBOL_EMPTY = figurines_str_cnt
figurines_str = figurines_str .. MOVES_LIST_SYMBOL_EMPTY .. "=mailbox_blank16.png"
for i = 1, #pieces_basenames do
	figurines_str_cnt = figurines_str_cnt + 1
	local p = pieces_basenames[i]
	figurines_str = figurines_str .. "," .. figurines_str_cnt .. "=chess_figurine_" .. p .. ".png"
end

local function get_figurine_id(piece_itemname)
	local piece_s = piece_itemname:match(":(%w+_%w+)")
	return figurines_str:match("(%d+)=chess_figurine_" .. piece_s)
end


local fs_gamemode_x
if CHESS_DEBUG then
	fs_gamemode_x = 10.2
else
	fs_gamemode_x = 11.5
end

local fs_init = [[
	formspec_version[2]
	size[16,10.7563;]
	no_prepend[]
	]]
	.."bgcolor[#00000000;false]"
	.."background[0,0;16,10.7563;chess_bg.png;true]"
	.."style_type[button,image_button,item_image_button;bgcolor=#8f3000]"
	.."label[2.2,0.652;"..minetest.colorize("#404040", FS("Select a game mode")).."]"
	.."label[2.2,10.21;"..minetest.colorize("#404040", FS("Select a game mode")).."]"
	.."label[11.2,1.8;"..FS("Select a mode:").."]"
	.."button[11,2.1;3,0.8;single;"..FS("Singleplayer").."]"
	.."button[11,3.1;3,0.8;multi;"..FS("Multiplayer").."]"
	if CHESS_DEBUG then
		fs_init = fs_init .."button[11,4.1;3,0.8;bot_vs_bot;"..FS("Bot vs Bot").."]"
	end

local fs = [[
	formspec_version[2]
	size[16,10.7563;]
	no_prepend[]
	bgcolor[#00000000;false]
	background[0,0;16,10.7563;chess_bg.png;true]
	style_type[button,image_button,item_image_button;bgcolor=#8f3000]
	style_type[list;spacing=0.1;size=0.975]
	listcolors[#00000000;#00000000;#00000000;#30434C;#FFF]
	list[context;board;0.47,1.155;8,8;]
	tableoptions[background=#00000000;highlight=#00000000;border=false]
	]]
	-- table columns for Chess notation.
	-- Columns: move no.; white piece; white halfmove; white promotion; black piece; black halfmove; black promotion
	.."tablecolumns[" ..
		"text,align=right;"..
		"image," .. figurines_str .. ";text;image," .. figurines_str .. ";" ..
		--"image,0=mailbox_blank16.png;" ..
		"image," .. figurines_str .. ";text;image," .. figurines_str .. "]"

local function add_move_to_moves_list(meta, pieceFrom, pieceTo, from_idx, to_idx, special)
	local moves_raw = meta:get_string("moves_raw")
	if moves_raw ~= "" then
		moves_raw = moves_raw .. ";"
	end
	if not special then
		special = ""
	end
	moves_raw = moves_raw .. pieceFrom .. "," .. pieceTo .. "," .. from_idx .. "," .. to_idx .. "," .. special
	meta:set_string("moves_raw", moves_raw)
end

local function add_special_to_moves_list(meta, special)
	add_move_to_moves_list(meta, "", "", "", "", special)
end


-- abbreviation for each piece for the string
-- representation of the board (like in FEN)
local piece_letters = {
	white = {
		pawn   = "P",
		knight = "N",
		bishop = "B",
		rook   = "R",
		queen  = "Q",
		king   = "K",
	},
	black = {
		pawn   = "p",
		knight = "n",
		bishop = "b",
		rook   = "r",
		queen  = "q",
		king   = "k",
	},
}

local function piece_to_letter(piece)
	if piece == "" then
		return "."
	elseif piece:find("white") then
		for k,v in pairs(piece_letters.white) do
			if piece:find(k) then
				return v
			end
		end
	elseif piece:find("black") then
		for k,v in pairs(piece_letters.black) do
			if piece:find(k) then
				return v
			end
		end
	end
end
local function letter_to_piece(letter)
	if letter == "." then
		return ""
	else
		for k,v in pairs(piece_letters.white) do
			if v == letter then
				return v
			end
		end
		for k,v in pairs(piece_letters.black) do
			if v == letter then
				return v
			end
		end
	end
	return nil
end

-- Returns a list of all positions so far, for the purposes
-- of determining position equality under the
-- "3-/5-fold repetition" draw rules.
-- Each possible position is uniquely identified by a string
-- so equal positions have the same string and unequal positons
-- have a different string.
-- A position string containts the following data:
-- * position of pieces on the board
-- * current player
-- * castling rights
-- * target coords of the square crossed by the pawn who
--   made a double step in the prvious turn (if any)
--
-- Patemeter: meta is the node metadata of the chessboard
--
-- NOTE: The FIDE Laws of Chess (Jan 2023, article 9.2.3.1)
-- are somewhat unclear about en passant here ... Is it important
-- the pawn was only theoretically vulnerable to being
-- captured en passant without being actually threatened
-- that way, or does it only count if the pawn was actually
-- threatened by another pawn to be captured that way?
-- This mod currently interprets the rule in the former way,
-- i.e. a double step by a pawn
local function get_positions_history(meta)
	-- Turns a board table to a string.
	-- The syntax is inspired by FEN but not identical.
	-- It iterates through the table from start
	-- to finish and turns every square to a character,
	-- representing a piece or an empty square.
	local function board_to_string(board)
		local str = ""
		for b=1, #board do
			local piece = board[b]
			local append
			str = str .. piece_to_letter(piece)
		end
		return str
	end

	-- Record the position no. of the position from which
	-- all positions before that can be ignored
	-- when counting same positions.
	-- This number is updated each time an irreversible
	-- move is made:
	-- * pawn move
	-- * capturing move
	-- * loss of castling rights
	-- * loss of (theoretical) en passant availability
	-- This works cuz when an irreversible move is made,
	-- it is impossible for this and all positions before
	-- that to occur again so the "repetition counter"
	-- for each of these position never increases again.
	local no_repetitions_before = 1

	local moves_raw = meta:get_string("moves_raw")
	local moves_split = string.split(moves_raw, ";")
	local positions_list = ""
	local board = table.copy(starting_grid)
	local castling_state = { true, true, true, true }
	local castling_str = castling_to_string(unpack(castling_state))
	local pawn_double_step_index
	positions_list = {}

	local current_player = "w"
	local position_string = board_to_string(board) .. " " ..
		current_player .. " " ..
		castling_str .. " " ..
		en_passant_to_string(nil)
	table.insert(positions_list, position_string)
	for m=1, #moves_split do
		local move_split = string.split(moves_split[m], ",", true)
		local pieceFrom = move_split[1]
		local pieceTo = move_split[2]
		local from_idx = tonumber(move_split[3])
		local to_idx = tonumber(move_split[4])
		local special = move_split[5]
		if special == "" or special:sub(1,7) == "promo__" then

		if current_player == "w" then
			current_player = "b"
		else
			current_player = "w"
		end
		-- Reset repetition counter on piece capture
		if pieceTo ~= "" then
			no_repetitions_before = m
		end

		-- Piece movement
		board[to_idx] = board[from_idx]
		board[from_idx] = ""

		-- Pawn promotion
		if special:sub(1, 7) == "promo__" then
			local promoSym = special:sub(8)
			board[to_idx] = promoSym
		end

		local from_x, from_y  = index_to_xy(from_idx)
		local to_x, to_y      = index_to_xy(to_idx)
		if pieceFrom:sub(11,14) == "king" then
			-- Castling (move rook)
			if (from_y == 7 and to_y == 7) then
				if (from_x == 4 and to_x == 2) then
					board[60] = board[57]
					board[57] = ""
					no_repetitions_before = m
				elseif (from_x == 4 and to_x == 6) then
					board[62] = board[64]
					board[64] = ""
					no_repetitions_before = m
				end
			elseif (from_y == 0 and to_y == 0) then
				if (from_x == 4 and to_x == 2) then
					board[4] = board[1]
					board[1] = ""
					no_repetitions_before = m
				elseif (from_x == 4 and to_x == 6) then
					board[6] = board[8]
					board[8] = ""
					no_repetitions_before = m
				end
			end
			-- Lose castling rights on any king move
			if pieceFrom:find("white") then
				if castling_state[1] or castling_state[2] then
					no_repetitions_before = m
				end
				castling_state[1] = false
				castling_state[2] = false
			else
				if castling_state[3] or castling_state[4] then
					no_repetitions_before = m
				end
				castling_state[3] = false
				castling_state[4] = false
			end

		-- Lose castling rights on lone rook move
		elseif pieceFrom:sub(11,14) == "rook" then
			if from_idx == 57 then
				-- white queenside
				if castling_state[2] then
					castling_state[2] = false
					no_repetitions_before = m
				end
			elseif from_idx == 64 then
				-- white kingside
				if castling_state[1] then
					castling_state[1] = false
					no_repetitions_before = m
				end
			elseif from_idx == 1 then
				-- black queenside
				if castling_state[4] then
					castling_state[4] = false
					no_repetitions_before = m
				end
			elseif from_idx == 8 then
				-- black kingside
				if castling_state[3] then
					castling_state[3] = false
					no_repetitions_before = m
				end
			end
		end

		-- Pawn movement resets repetition counter
		if pieceFrom:sub(11,14) == "pawn" then
			no_repetitions_before = m
		end

		-- Loss of (theoretical) en passant capture availability
		-- resets repetition counter
		if pawn_double_step_index then
			no_repetitions_before = m
			pawn_double_step_index = nil
		end

		if pieceTo == "" and pieceFrom:sub(11,14) == "pawn" then
			-- En passant (remove captured pawn)
			if from_x ~= to_x then
				local epp_y
				if pieceFrom:find("white") then
					epp_y = to_y + 1
				else
					epp_y = to_y - 1
				end
				board[xy_to_index(to_x, epp_y)] = ""
			-- Double pawn step (record pos)
			elseif math.abs(from_y-to_y) == 2 then
				pawn_double_step_index = to_idx
			end
		end

		castling_str = castling_to_string(unpack(castling_state))
		local position_string = board_to_string(board) .. " " ..
			current_player .. " " ..
			castling_str .. " " ..
			en_passant_to_string(pawn_double_step_index)
		table.insert(positions_list, position_string)
	end
	end
	local p=#positions_list
	return positions_list, no_repetitions_before
end

-- Returns the highest number of positions that are repeated
-- in the given positions history list as well as the number
-- of occurrances of the last position.
--
-- Arguments:
-- * positions: positions history list returned by get_position_history()
-- * first_position_no: index of first position to check (default: 1)
--
-- Returns <max. no. of repetitions in history starting from first_position_no>, <no. of repetitions of last position>
local function count_repeated_positions(positions, first_position_no)
	-- Count how often each position occurred
	local positions_counter = {}
	local maxRepeatedPositions = 0
	first_position_no = first_position_no or 1
	for p = first_position_no, #positions do
		local position = positions[p]
		if positions_counter[position] == nil then
			positions_counter[position] = 1
		else
			positions_counter[position] = positions_counter[position] + 1
		end
		if positions_counter[position] > maxRepeatedPositions then
			maxRepeatedPositions = positions_counter[position]
		end
	end
	local lastPosition = positions[#positions]
	local lastPositionOccurredTimes = positions_counter[lastPosition] or 0
	return maxRepeatedPositions, lastPositionOccurredTimes
end

-- Create the full formspec string for the sequence of moves.
-- Uses Figurine Algebraic Notation.
local function get_moves_formstring(meta)
	local moves_raw = meta:get_string("moves_raw")
	if moves_raw == "" then
		return "", 0
	end

	local moves_split = string.split(moves_raw, ";")
	local moves_out = ""
	local move_no = 0
	for m=1, #moves_split do
		local move_split = string.split(moves_split[m], ",", true)
		local pieceFrom = move_split[1]
		local pieceTo = move_split[2]
		local from_idx = tonumber(move_split[3])
		local to_idx = tonumber(move_split[4])
		local special = move_split[5]

		-- true if White plays, false if Black plays
		local curPlayerIsWhite = m % 2 == 1

		if special == "whiteWon" or special == "blackWon" or special == "draw" then
			if not curPlayerIsWhite then
				moves_out = moves_out .. ""..MOVES_LIST_SYMBOL_EMPTY..",," .. MOVES_LIST_SYMBOL_EMPTY .. ","
			end
		end
		if special == "whiteWon" then
			moves_out = moves_out .. ","..MOVES_LIST_SYMBOL_EMPTY..",1–0,"..MOVES_LIST_SYMBOL_EMPTY
			move_no = move_no + 1
		elseif special == "blackWon" then
			moves_out = moves_out .. ","..MOVES_LIST_SYMBOL_EMPTY..",0–1,"..MOVES_LIST_SYMBOL_EMPTY
			move_no = move_no + 1
		elseif special == "draw" then
			moves_out = moves_out .. ","..MOVES_LIST_SYMBOL_EMPTY..",½–½,"..MOVES_LIST_SYMBOL_EMPTY
			move_no = move_no + 1
		else
		local from_x, from_y  = index_to_xy(from_idx)
		local to_x, to_y      = index_to_xy(to_idx)
		local pieceFrom_si_id
		-- Show no piece icon for pawn
		if pieceFrom:sub(11,14) == "pawn" then
			pieceFrom_si_id = MOVES_LIST_SYMBOL_EMPTY
		else
			pieceFrom_si_id = get_figurine_id(pieceFrom)
		end
		local pieceTo_si_id   = pieceTo ~= "" and get_figurine_id(pieceTo)

		local coordFrom = realchess.index_to_notation(from_idx)
		local coordTo   = realchess.index_to_notation(to_idx)

		if curPlayerIsWhite then
			move_no = move_no + 1
			-- Add move number (e.g. "3.")
			moves_out = moves_out .. string.format("%d.", move_no) .. ","
		end
		local betweenCoordsSymbol = "–" -- to be inserted between source and destination coords
						-- dash for normal moves, × for capturing moves
		local enPassantSymbol = "" -- symbol for en passant captures
		if pieceTo ~= "" then
			-- normal capture
			betweenCoordsSymbol = "×"
		elseif pieceTo == "" and pieceFrom:sub(11,14) == "pawn" and from_x ~= to_x then
			-- 'en passant' capture
			betweenCoordsSymbol = "×"
			enPassantSymbol = " e.p."
		end

		---- Add halfmove of current player
		-- Castling
		local castling = false
		if pieceFrom:sub(11,14) == "king" and ((curPlayerIsWhite and from_y == 7 and to_y == 7) or (not curPlayerIsWhite and from_y == 0 and to_y == 0)) then
			-- queenside castling
			if from_x == 4 and to_x == 2 then
				-- write "0–0–0"
				moves_out = moves_out .. MOVES_LIST_SYMBOL_EMPTY .. ",0–0–0," .. MOVES_LIST_SYMBOL_EMPTY
				castling = true
			-- kingside castling
			elseif from_x == 4 and to_x == 6 then
				-- write "0–0"
				moves_out = moves_out .. MOVES_LIST_SYMBOL_EMPTY .. ",0–0," .. MOVES_LIST_SYMBOL_EMPTY
				castling = true
			end
		end
		-- Normal halfmove
		if not castling then
			moves_out = moves_out ..
				pieceFrom_si_id .. "," .. -- piece image ID
				coordFrom .. betweenCoordsSymbol .. coordTo .. -- coords in long algebraic notation, e.g. "e2e3"
				enPassantSymbol .. "," -- written in case of an 'en passant' capture

			-- Promotion?
			if special:sub(1, 7) == "promo__" then
				local promoSym = special:sub(8)
				moves_out = moves_out .. get_figurine_id(promoSym)
			else
				moves_out = moves_out .. MOVES_LIST_SYMBOL_EMPTY
			end
		end

		-- If White moved, fill up the rest of the row with empty space.
		-- Required for validity of the table
		if curPlayerIsWhite and m == #moves_split then
			moves_out = moves_out .. "," .. MOVES_LIST_SYMBOL_EMPTY .. ",," .. MOVES_LIST_SYMBOL_EMPTY
		end
		end

		if m ~= #moves_split then
			moves_out = moves_out .. ","
		end
	end
	return moves_out, move_no
end

-- Verify eaten list
local verify_eaten_list
if CHESS_DEBUG then
	verify_eaten_list = function(meta)
		local inv = meta:get_inventory()
		local board = realchess.board_to_table(inv)
		local whitePiecesLeft = 0
		local whitePiecesEaten = 0
		local blackPiecesLeft = 0
		local blackPiecesEaten = 0
		for b=1, 64 do
			local piece = board[b]
			if piece:find("white") then
				whitePiecesLeft = whitePiecesLeft + 1
			elseif piece:find("black") then
				blackPiecesLeft = blackPiecesLeft + 1
			end
		end
		local eaten = meta:get_string("eaten")
		local eaten_split = string.split(eaten, ",")
		for e=1, #eaten_split do
			local piece = eaten_split[e]
			if piece:find("white") then
				whitePiecesEaten = whitePiecesEaten + 1
			elseif piece:find("black") then
				blackPiecesEaten = blackPiecesEaten + 1
			end
		end
		local eatenError = false
		if whitePiecesLeft + whitePiecesEaten ~= 16 then
			minetest.log("error", "[xdecor] Chess: Incorrect number of white pieces in eaten list! pieces="..whitePiecesLeft.."; eaten="..whitePiecesEaten)
			eatenError = true
		elseif blackPiecesLeft + blackPiecesEaten ~= 16 then
			minetest.log("error", "[xdecor] Chess: Incorrect number of black pieces in eaten list! pieces="..blackPiecesLeft.."; eaten="..blackPiecesEaten)
			eatenError = true
		end
		if eatenError then
			-- halt bots
			local mode = meta:get_string("mode")
			if mode == "bot_vs_bot" then
				meta:set_string("botColor", "")
			end
		end
	end
end

-- Reports that a piece was "eaten" (=captured).
-- Must be called right after the board inventory was updated
-- on which the piece is already removed
-- * meta: Chessboard node metadata
-- * piece: The itemname of the piece that was captured
local function add_to_eaten_list(meta, piece)
	if piece ~= "" then
		local eaten = meta:get_string("eaten")
		if eaten ~= "" then
			eaten = eaten .. ","
		end
		local piece_s = piece:match(":(%w+_%w+)") or ""
		eaten = eaten .. piece_s
		meta:set_string("eaten", eaten)
		if CHESS_DEBUG then
			verify_eaten_list(meta)
		end
	end
end

local function get_eaten_formstring(meta)
	local eaten = meta:get_string("eaten")
	local eaten_t   = string.split(eaten, ",")
	local eaten_img = ""
	local a, b = 0, 0
	for i = 1, #eaten_t do
		local is_white = eaten_t[i]:sub(-5,-1) == "white"
		local X = (is_white and a or b) % 4
		local Y = ((is_white and a or b) % 16 - X) / 4

		if is_white then
			a = a + 1
		else
			b = b + 1
		end

		eaten_img = eaten_img ..
			"image[" .. ((X + (is_white and 12.82 or 9.72)) - (X * 0.44)) .. "," ..
				    ((Y + 6) - (Y * 0.12)) .. ";1,1;" .. eaten_t[i] .. ".png]"
	end
	return eaten_img
end

local function update_formspec(meta)
	local black_king_attacked = meta:get_string("blackAttacked") == "true"
	local white_king_attacked = meta:get_string("whiteAttacked") == "true"
	local botColor = meta:get_string("botColor")

	local playerWhite = meta:get_string("playerWhite")
	local playerBlack = meta:get_string("playerBlack")

	-- Translate the bot names for the display
	-- (internally, the bot names are still English-only)
	local playerWhiteDisplay = get_display_player_name(meta, "white")
	local playerBlackDisplay = get_display_player_name(meta, "black")

	local moves_raw = meta:get_string("moves_raw")
	local moves, mlistlen = get_moves_formstring(meta)
	local eaten_img = get_eaten_formstring(meta)
	local lastMove  = meta:get_string("lastMove")
	local gameResult = meta:get_string("gameResult")
	local grReason  = meta:get_string("gameResultReason")
	local mode = meta:get_string("mode")

	-- arrow to show whose turn it is
	local blackArr  = (gameResult == "" and lastMove == "white" and "image[1.2,0.252;0.7,0.7;chess_turn_black.png]") or ""
	local whiteArr  = (gameResult == "" and (lastMove == "" or lastMove == "black") and "image[1.2,9.81;0.7,0.7;chess_turn_white.png]") or ""
	local turnBlack = minetest.colorize("#000001", playerBlackDisplay)
	local turnWhite = minetest.colorize("#000001", playerWhiteDisplay)

	-- several status words for the player
	-- player is in check
	local check_s   = minetest.colorize("#FF8000", "["..S("check").."]")
	-- player has been checkmated
	local mate_s    = minetest.colorize("#FF0000", "["..S("checkmate").."]")
	-- player has resigned
	local resign_s    = minetest.colorize("#FF0000", "["..S("resigned").."]")
	-- player has won
	local win_s     = minetest.colorize("#26AB2B", "["..S("winner").."]")
	-- player has lost
	local lose_s     = minetest.colorize("#FF0000", "["..S("loser").."]")
	-- player has a draw
	local draw_s    = minetest.colorize("#FF00FF", "["..S("draw").."]")

	local status_black = ""
	local status_white = ""
	if gameResult == "blackWon" then
		if grReason == "resign" then
			status_white = " " .. resign_s
		elseif grReason == "checkmate" then
			status_white = " " .. mate_s
		else
			status_white = " " .. lose_s
		end
		status_black = " " .. win_s
	elseif gameResult == "draw" then
		status_black = " " .. draw_s
		status_white = " " .. draw_s
	elseif gameResult == "whiteWon" then
		if grReason == "resign" then
			status_black = " " .. resign_s
		elseif grReason == "checkmate" then
			status_black = " " .. mate_s
		else
			status_black = " " .. lose_s
		end
		status_white = " " .. win_s
	else
		if black_king_attacked then
			status_black = " " .. check_s
		end
		if white_king_attacked then
			status_white = " " .. check_s
		end
	end

	local promotion = ""
	if gameResult == "" then
		promotion = meta:get_string("promotionActive")
	end
	local promotion_formstring = ""

	-- Show promotion prompt to ask player to choose to which piece to promote a pawn to
	if promotion == "black" then
		eaten_img = ""
		promotion_formstring =
			"label[10.1,6.35;"..FS("PROMOTION\nFOR BLACK!").."]" ..
			"animated_image[10.05,7.2;2,2;p_img_white;pawn_black_promo_anim.png;5;100]"
		if botColor ~= "black" and botColor ~= "both" then
			-- Hide buttons if computer player promotes
			promotion_formstring = promotion_formstring ..
			"label[13.15,6.35;"..FS("Promote pawn to:").."]" ..
			"item_image_button[13.15,7.2;1,1;realchess:queen_black;p_queen_black;]" ..
			"item_image_button[14.15,7.2;1,1;realchess:rook_black_1;p_rook_black;]" ..
			"item_image_button[13.15,8.2;1,1;realchess:bishop_black_1;p_bishop_black;]" ..
			"item_image_button[14.15,8.2;1,1;realchess:knight_black_1;p_knight_black;]"
		end

	elseif promotion == "white" then
		eaten_img = ""
		promotion_formstring =
			"label[10.1,6.35;"..FS("PROMOTION\nFOR WHITE!").."]" ..
			"animated_image[10.05,7.2;2,2;p_img_white;pawn_white_promo_anim.png;5;100]"
		if botColor ~= "white" and botColor ~= "both" then
			-- Hide buttons if computer player promotes
			promotion_formstring = promotion_formstring ..
			"label[13.15,6.35;"..FS("Promote pawn to:").."]" ..
			"item_image_button[13.15,7.2;1,1;realchess:queen_white;p_queen_white;]" ..
			"item_image_button[14.15,7.2;1,1;realchess:rook_white_1;p_rook_white;]" ..
			"item_image_button[13.15,8.2;1,1;realchess:bishop_white_1;p_bishop_white;]" ..
			"item_image_button[14.15,8.2;1,1;realchess:knight_white_1;p_knight_white;]"
		end
	end

	local drawClaim = meta:get_string("drawClaim")
	local draw_claim_formstring = ""
	if drawClaim ~= "" and gameResult == "" then
		if lastMove == "black" or lastMove == "" then
			draw_claim_formstring = "label[10.1,6.35;"..FS("DRAW CLAIM\nBY WHITE!").."]"
		else
			draw_claim_formstring = "label[10.1,6.35;"..FS("DRAW CLAIM\nBY BLACK!").."]"
		end
		if drawClaim == "50_move_rule" then
			eaten_img = ""
			draw_claim_formstring = draw_claim_formstring ..
				"image[10.05,7.2;2,2;chess_draw_50move_next.png]"..
				"textarea[13,6.35;2.2,3.2;;;"..FS("The player has invoked the 50-move rule for the next move. The next move might draw the game.").."]"
		elseif drawClaim == "same_position_3" then
			eaten_img = ""
			draw_claim_formstring = draw_claim_formstring ..
				"image[10.05,7.2;2,2;chess_draw_repeat3_next.png]"..
				"textarea[13,6.35;2.2,3.2;;;"..FS("The player has invoked the threefold-repetition rule for the next move. The next move might draw the game.").."]"
		end
	end

	-- Resign / Start new game
	local game_buttons = ""
	game_buttons = game_buttons .. "button[13.36,0.26;2,0.8;new;"..FS("New game").."]"

	local playerActionsAvailable = mode ~= "bot_vs_bot" and gameResult == ""

	if playerActionsAvailable and (playerWhite ~= "" and playerBlack ~= "") then
		game_buttons = game_buttons .. "image_button[14.56,9.7;0.8,0.8;chess_resign.png;resign;]" ..
			"tooltip[resign;"..FS("Resign").."]"
	end

	-- Let player choose with which to play singleplayer
	if lastMove == "" and gameResult == "" and mode == "single" and playerWhite == "" then
		game_buttons = game_buttons .. "label[11.2,1.8;"..FS("Select a color:").."]"
			.."style[single_black;bgcolor=#000000FF;textcolor=#FFFFFFFF]"
			.."style[single_white;bgcolor=#FFFFFFFF;textcolor=#000000FF]"
			.."button[11,2.1;3,0.8;single_white;"..FS("White").."]"
			.."button[11,3.1;3,0.8;single_black;"..FS("Black").."]"
	end

	if playerActionsAvailable and drawClaim == "" then
		-- 50-move rule
		local halfmoveClock = meta:get_int("halfmoveClock")
		if halfmoveClock == DRAWCLAIM_LONGGAME_PLAYER - 1 then
			-- When the 50 moves without capture / pawn move is about to occur.
			-- Will trigger "draw claim" mode in which player must do the final move that triggers the draw
			game_buttons = game_buttons .. "image_button[13.36,9.7;0.8,0.8;chess_draw_50move_next.png;draw_50_moves;]"..
				"tooltip[draw_50_moves;"..
				FS("Invoke the 50-move rule for your next move").."]"
		elseif halfmoveClock >= DRAWCLAIM_LONGGAME_PLAYER then
			-- When the 50 moves without capture / pawn move have occured occur.
			-- Will insta-draw.
			game_buttons = game_buttons .. "image_button[13.36,9.7;0.8,0.8;chess_draw_50move.png;draw_50_moves;]"..
				"tooltip[draw_50_moves;"..
				FS("Invoke the 50-move rule and draw the game").."]"
		end

		-- Threefold repetition rule
		-- Count how often each position occurred
		local positions, first_p = get_positions_history(meta)
		local maxRepeatedPositions, lastOccurred = count_repeated_positions(positions, first_p)
		if lastOccurred >= 3 then
			-- If the same position has already occured 3 times
			-- Will insta-draw.
			game_buttons = game_buttons .. "image_button[12.36,9.7;0.8,0.8;chess_draw_repeat3.png;draw_repeat_3;]"..
				"tooltip[draw_repeat_3;"..
				FS("Invoke the threefold repetition rule and draw the game").."]"
		elseif maxRepeatedPositions >= 2 then
			-- If the same position may be about to occur 3 times.
			-- Will trigger "draw claim" mode in which player must do the final move that triggers the draw.
			game_buttons = game_buttons .. "image_button[12.36,9.7;0.8,0.8;chess_draw_repeat3_next.png;draw_repeat_3;]"..
				"tooltip[draw_repeat_3;"..
				FS("Invoke the threefold repetition rule for your next move").."]"
		end
	end

	local debug_formstring = ""
	if CHESS_DEBUG then
		-- Write a debug string in the formspec based on FEN
		-- to show some hidden state.
		-- It uses FEN syntax but without the piece positions

		-- current player: b or w
		local d_turn = "-"
		if lastMove == "white" then
			d_turn  = "b"
		elseif lastMove == "black" or lastMove == "" then
			d_turn  = "w"
		end
		-- castling rights
		local d_castling = castling_to_string(
			meta:get_int("castlingWhiteR") == 1,
			meta:get_int("castlingWhiteL") == 1,
			meta:get_int("castlingBlackR") == 1,
			meta:get_int("castlingBlackL") == 1)
		-- en passant possible?
		local double_step = meta:get_int("prevDoublePawnStepTo")
		local d_en_passant = en_passant_to_string(double_step)

		-- The halfmove clock counts for how many consecutive halfmoves
		-- have been made with no pawn advancing and no piece being captured
		local d_halfmove_clock = meta:get_int("halfmoveClock")

		-- fullmove starts at 1 and should count up every time black moves
		local d_fullmove = tostring(get_current_fullmove(meta) + 1)

		local debug_str = d_turn .. " " .. d_castling .. " " .. d_en_passant .. " " .. d_halfmove_clock .. " " .. d_fullmove
		debug_formstring = "label[7.9,10.2;DEBUG: "..debug_str.."]"
	end

	local moves_list = ""
	if mlistlen > 0 then
		-- Moves list (show only if not empty)
		moves_list = "table[9.9,1.25;5.45,4;moves;" .. moves .. ";"..mlistlen.."]"
	end

	local formspec = fs ..
		"label[2.2,0.652;"  .. turnBlack .. minetest.formspec_escape(status_black) .. "]" ..
		blackArr ..
		"label[2.2,10.21;" .. turnWhite .. minetest.formspec_escape(status_white) .. "]" ..
		whiteArr ..
		moves_list ..
		promotion_formstring ..
		draw_claim_formstring ..
		eaten_img ..
		game_buttons ..
		debug_formstring

	meta:set_string("formspec", formspec)
end

local function update_game_result(meta)
	local inv = meta:get_inventory()
	local board_t = realchess.board_to_table(inv)

	local playerWhite = meta:get_string("playerWhite")
	local playerBlack = meta:get_string("playerBlack")

	update_formspec(meta)
	local blackCanMove = false
	local whiteCanMove = false

	local blackMoves = realchess.get_theoretical_moves_for(meta, board_t, "black")
	local whiteMoves = realchess.get_theoretical_moves_for(meta, board_t, "white")
	if next(blackMoves) then
		blackCanMove = true
	end
	if next(whiteMoves) then
		whiteCanMove = true
	end

	-- assume lastMove was updated *after* the player moved
	local lastMove = meta:get_string("lastMove")

	local black_king_idx, white_king_idx = realchess.locate_kings(board_t)
	if not black_king_idx or not white_king_idx then
		minetest.log("error", "[xdecor] Chess: Insufficient kings on chessboard!")
		return
	end

	local checkPlayer, king_idx, checkMoves
	if lastMove == "black" or lastMove == "" then
		checkPlayer = "white"
		checkMoves = whiteMoves
		king_idx = white_king_idx
	else
		checkPlayer = "black"
		checkMoves = blackMoves
		king_idx = black_king_idx
	end

	-- King attacked?
	local isKingAttacked = realchess.attacked(checkPlayer, king_idx, board_t)
	if isKingAttacked then
		meta:set_string(checkPlayer.."Attacked", "true")
	end

	-- If not safe moves left, player can't move
	local safe_moves, safe_moves_count = realchess.get_king_safe_moves(checkMoves, board_t, checkPlayer)
	if safe_moves_count == 0 then
		if checkPlayer == "black" then
			blackCanMove = false
		else
			whiteCanMove = false
		end
	end

	local playerWhiteDisplay = get_display_player_name(meta, "white")
	local playerBlackDisplay = get_display_player_name(meta, "black")
	local botColor = meta:get_string("botColor")

	if lastMove == "white" and not blackCanMove then
		if meta:get_string("blackAttacked") == "true" then
			-- black was checkmated
			meta:set_string("gameResult", "whiteWon")
			meta:set_string("gameResultReason", "checkmate")
			add_special_to_moves_list(meta, "whiteWon")
			send_message(playerWhite, S("You have checkmated @1. You win!", playerBlackDisplay), "white", botColor)
			send_message(playerBlack, S("You were checkmated by @1. You lose!", playerWhiteDisplay), "black", botColor)
			minetest.log("action", "[xdecor] Chess: "..playerWhite.." won against "..playerBlack.." by checkmate")
			return
		else
			-- stalemate
			meta:set_string("gameResult", "draw")
			meta:set_string("gameResultReason", "stalemate")
			add_special_to_moves_list(meta, "draw")
			send_message_2(playerWhite, playerBlack, S("The game ended up in a stalemate! It's a draw!"), botColor)
			minetest.log("action", "[xdecor] Chess: A game between "..playerWhite.." and "..playerBlack.." ended in a draw by stalemate")
			return
		end
	end
	if lastMove == "black" and not whiteCanMove then
		if meta:get_string("whiteAttacked") == "true" then
			-- white was checkmated
			meta:set_string("gameResult", "blackWon")
			meta:set_string("gameResultReason", "checkmate")
			add_special_to_moves_list(meta, "blackWon")
			send_message(playerBlack, S("You have checkmated @1. You win!", playerWhiteDisplay), "white", botColor)
			send_message(playerWhite, S("You were checkmated by @1. You lose!", playerBlackDisplay), "white", botColor)
			minetest.log("action", "[xdecor] Chess: "..playerBlack .." won against "..playerWhite.." by checkmate")
			return
		else
			-- stalemate
			meta:set_string("gameResult", "draw")
			meta:set_string("gameResultReason", "stalemate")
			add_special_to_moves_list(meta, "draw")
			send_message_2(playerWhite, playerBlack, S("The game ended up in a stalemate! It's a draw!"), botColor)
			minetest.log("action", "[xdecor] Chess: A game between "..playerWhite.." and "..playerBlack.." ended in a draw by stalemate")
			return
		end
	end

	-- Is this a dead position?
	if is_dead_position(board_t) then
		meta:set_string("gameResult", "draw")
		meta:set_string("gameResultReason", "dead_position")
		add_special_to_moves_list(meta, "draw")
		send_message_2(playerWhite, playerBlack, S("The game ended up in a dead position! It's a draw!"), botColor)
		minetest.log("action", "[xdecor] Chess: A game between "..playerWhite.." and "..playerBlack.." ended in a draw by dead position")
	end

	local drawClaim = meta:get_string("drawClaim")
	-- 75-move rule. Automatically draw game if the last 75 moves of EACH player (thus 150 halfmoves)
	-- neither moved a pawn or captured a piece.
	-- Important: This rule MUST be checked AFTER checkmate because checkmate takes precedence.
	if meta:get_int("halfmoveClock") >= DRAWCLAIM_LONGGAME_FORCE then
		meta:set_string("gameResult", "draw")
		meta:set_string("gameResultReason", "75_move_rule")
		add_special_to_moves_list(meta, "draw")
		local msg = S("No piece was captured and no pawn was moved for 75 consecutive moves of each player. It's a draw!")
		send_message_2(playerWhite, playerBlack, msg, botColor)
		minetest.log("action", "[xdecor] Chess: A game between "..playerWhite.." and "..playerBlack.." ended in a draw via the 75-move rule")
	-- 50-move rule, after a player issued a draw claim for their next move.
	-- If no pawn moved nor a piece was captured for >= 100 halfmoves, the game is drawn.
	elseif meta:get_int("halfmoveClock") >= DRAWCLAIM_LONGGAME_PLAYER and drawClaim == "50_move_rule" then
		meta:set_string("drawClaim", "")
		meta:set_string("gameResult", "draw")
		meta:set_string("gameResultReason", "50_move_rule")
		add_special_to_moves_list(meta, "draw")
		update_formspec(meta)
		local claimer, other
		if lastMove == "black" or lastMove == "" then
			claimer = playerWhite
			other = playerBlack
		else
			claimer = playerBlack
			other = playerWhite
		end
		send_message(claimer, S("You have drawn the game by invoking the 50-move rule."), botColor)
		if claimer ~= other then
			send_message(other, S("@1 has drawn the game by invoking the 50-move rule.", claimer), botColor)
		end
		minetest.log("action", "[xdecor] Chess: A game between "..playerWhite.." and "..playerBlack.." ended in a draw because "..claimer.." has invoked the 50-move rule")
	elseif drawClaim == "50_move_rule" then
		local claimer, other
		if lastMove == "black" or lastMove == "" then
			claimer = playerWhite
			other = playerBlack
		else
			claimer = playerBlack
			other = playerWhite
		end
		send_message(claimer, S("You have failed to make a game-drawing move. The game continues."), botColor)
		if claimer ~= other then
			send_message(other, S("@1 made a draw claim using the 50-move rule but it was false. The game continues.", claimer), botColor)
		end
	end

	-- Draw if same position appeared >= 5 times
	-- or if it appeared >= 3 times and the player claimed the draw previously
	-- First, generate the position history
	local forceRepetitionDraw = false
	local chosenRepetitionDraw = false
	local positions, first_p = get_positions_history(meta)
	-- Then count the repeated positions
	local _, lastOccurred = count_repeated_positions(positions, first_p)
	if lastOccurred >= 3 then
		chosenRepetitionDraw = true
	end
	if lastOccurred >= 5 then
		forceRepetitionDraw = true
	end
	if CHESS_DEBUG then
		-- Show last position
		local last_position = positions[#positions]
		local msg = "Current position: \"" .. last_position .. "\""
		send_message_2(playerWhite, playerBlack, msg, botColor)

		-- Compare the last position with the actual chessboard
		-- to automatically test if the position history is still valid
		local pos_split = last_position:split(" ")
		local p_board = pos_split[1]
		local p_player = pos_split[2]
		local p_castling = pos_split[3]
		local p_en_passant = pos_split[4]
		local errors = 0
		for b=1, #board_t do
			local piece = board_t[b]
			local letter_real = piece_to_letter(piece)
			local letter_pos = string.sub(p_board, b, b)
			if letter_real ~= letter_pos then
				minetest.log("error", "[xdecor] Chess: Position history inconsistency on board index "..b..": '"..letter_pos.."' seen but '"..letter_real.."' expected")
			end
		end
		-- Compare current player
		if (lastMove == "black" or lastMove == "") and p_player ~= "w" then
			minetest.log("error", "[xdecor] Chess: Position history inconsistency: Wrong player! '"..p_player.."' seen but 'w' expected")
		elseif (lastMove == "white") and p_player ~= "b" then
			minetest.log("error", "[xdecor] Chess: Position history inconsistency: Wrong player! '"..p_player.."' seen but 'b' expected")
		end
		-- Compare castling rights
		local d_castling = castling_to_string(
			meta:get_int("castlingWhiteR") == 1,
			meta:get_int("castlingWhiteL") == 1,
			meta:get_int("castlingBlackR") == 1,
			meta:get_int("castlingBlackL") == 1)
		if d_castling ~= p_castling then
			minetest.log("error", "[xdecor] Chess: Position history inconsistency: Castling rights mismatch! '"..p_castling.."' seen but '"..d_castling.."' expected")
		end
		-- Compare en passant status
		local double_step = meta:get_int("prevDoublePawnStepTo")
		local d_en_passant = en_passant_to_string(double_step)
		if d_en_passant ~= p_en_passant then
			minetest.log("error", "[xdecor] Chess: Position history inconsistency: En passant status mismatch! '"..p_en_passant.."' seen but '"..d_en_passant.."' expected")
		end
	end

	-- fivefold repetition
	if forceRepetitionDraw then
		meta:set_string("gameResult", "draw")
		meta:set_string("gameResultReason", "same_position_5")
		add_special_to_moves_list(meta, "draw")
		local msg = S("The exact same position has occured 5 times. It's a draw!")
		send_message_2(playerWhite, playerBlack, msg, botColor)
		minetest.log("action", "[xdecor] Chess: A game between "..playerWhite.." and "..playerBlack.." ended in a draw because the same position has appeared 5 times")

	-- threefold repetition
	elseif chosenRepetitionDraw and drawClaim == "same_position_3" then
		meta:set_string("drawClaim", "")
		meta:set_string("gameResult", "draw")
		meta:set_string("gameResultReason", "same_position_3")
		add_special_to_moves_list(meta, "draw")
		update_formspec(meta)
		local claimer, other
		if lastMove == "black" or lastMove == "" then
			claimer = playerWhite
			other = playerBlack
		else
			claimer = playerBlack
			other = playerWhite
		end
		send_message(claimer, S("You have drawn the game by invoking the threefold repetition rule."), botColor)
		if claimer ~= other then
			send_message(other, S("@1 has drawn the game by invoking the threefold repetition rule.", claimer), botColor)
		end
		minetest.log("action", "[xdecor] Chess: A game between "..playerWhite.." and "..playerBlack.." ended in a draw because "..claimer.." has invoked the threefold repetition rule")
	elseif drawClaim == "same_position_3" then
		local claimer, other
		if lastMove == "black" or lastMove == "" then
			claimer = playerWhite
			other = playerBlack
		else
			claimer = playerBlack
			other = playerWhite
		end
		send_message(claimer, S("You have failed to make a game-drawing move. The game continues."), botColor)
		if claimer ~= other then
			send_message(other, S("@1 made a draw claim using the threefold repetition rule but it was false. The game continues.", claimer), botColor)
		end
	end

	meta:set_string("drawClaim", "")
end


function realchess.init(pos)
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	meta:set_string("formspec", fs_init)
	meta:set_string("infotext", S("Chess Board"))
	meta:set_string("playerBlack", "")
	meta:set_string("playerWhite", "")
	meta:set_string("botColor",    "")
	meta:set_string("lastMove",    "")
	meta:set_string("gameResult",  "")
	meta:set_string("gameResultReason", "")
	meta:set_string("drawClaim",   "")
	meta:set_string("blackAttacked", "")
	meta:set_string("whiteAttacked", "")
	meta:set_string("promotionActive", "")

	meta:set_int("lastMoveTime",   0)
	meta:set_int("castlingBlackL", 1)
	meta:set_int("castlingBlackR", 1)
	meta:set_int("castlingWhiteL", 1)
	meta:set_int("castlingWhiteR", 1)
	meta:set_int("promotionPawnFromIdx", 0)
	meta:set_int("promotionPawnToIdx", 0)
	meta:set_int("prevDoublePawnStepTo", 0)
	meta:set_int("halfmoveClock", 0)

	meta:set_string("moves_raw", "")
	meta:set_string("eaten", "")
	meta:set_string("mode", "")

	inv:set_list("board", starting_grid)
	inv:set_size("board", 64)

	-- Clear legacy metadata
	meta:set_string("moves", "")
	meta:set_string("eaten_img", "")
end

-- The move logic of Chess.
-- This is meant to be called when a player *ATTEMPTS* to move a piece
-- from one slot of the inventory to another one and reacts accordingly.
-- If the move is valid, the inventory is changed to reflect the new
-- situation, and the game state and UI is upated as well and true
-- is returned.
-- If the move is invalid, nothing happens and false is returned.
-- Note: The move can also be done by a computer player.
--
-- * meta: Chessboard node metadata
-- * from_list: Inventory list of source square
-- * from_index: Inventory index of source square
-- * to_list: Inventory list of destination square
-- * to_index: Inventory list of destination square
-- * playerName: Name of player to move
function realchess.move(meta, from_list, from_index, to_list, to_index, playerName)
	if from_list ~= "board" and to_list ~= "board" then
		return false
	end

	local promo       = meta:get_string("promotionActive")
	if promo ~= "" then
		-- Can't move when waiting for selecting a pawn promotion
		return false
	end
	local gameResult  = meta:get_string("gameResult")
	if gameResult ~= "" then
		-- No moves if game is over
		return false
	end

	local inv         = meta:get_inventory()
	local pieceFrom   = inv:get_stack(from_list, from_index):get_name()
	local pieceTo     = inv:get_stack(to_list, to_index):get_name()
	local lastMove    = meta:get_string("lastMove")
	local playerWhite = meta:get_string("playerWhite")
	local playerBlack = meta:get_string("playerBlack")
	local kingMoved   = false
	local thisMove    -- Will replace lastMove when move is legal

	if pieceFrom:find("white") then
		if playerWhite ~= "" and playerWhite ~= playerName then
			send_message(playerName, S("Someone else plays white pieces!"))
			return false
		end

		if pieceTo:find("white") then
			-- Don't replace pieces of same color
			return false
		end

		if lastMove == "white" then
			send_message(playerName, S("It's not your turn!"))
			return
		end

		playerWhite = playerName
		thisMove = "white"

	elseif pieceFrom:find("black") then
		if playerBlack ~= "" and playerBlack ~= playerName then
			send_message(playerName, S("Someone else plays black pieces!"))
			return false
		end

		if pieceTo:find("black") then
			-- Don't replace pieces of same color
			return false
		end

		if lastMove == "black" then
			send_message(playerName, S("It's not your turn!"))
			return false
		end

		if lastMove == "" then
			-- Nobody has moved yet, and Black cannot move first
			send_message(playerName, S("Black cannot move first!"))
			return false
		end

		playerBlack = playerName
		thisMove = "black"
	end

	-- MOVE LOGIC

	local from_x, from_y = index_to_xy(from_index)
	local to_x, to_y     = index_to_xy(to_index)

	local promotion = false
	local doublePawnStep = nil
	local en_passant_target = nil
	local lostCastlingRightRook = nil
	local resetHalfmoveClock = false

	-- PAWN
	if pieceFrom:sub(11,14) == "pawn" then
		if thisMove == "white" then
			local pawnWhiteMove = inv:get_stack(from_list, xy_to_index(from_x, from_y - 1)):get_name()
			-- white pawns can go up only
			if from_y - 1 == to_y then
				-- single step
				if from_x == to_x then
					if pieceTo ~= "" then
						return false
					elseif to_index >= 1 and to_index <= 8 then
						-- activate promotion
						promotion = true
					end
					resetHalfmoveClock = true
				elseif from_x - 1 == to_x or from_x + 1 == to_x then
					if to_index >= 1 and to_index <= 8 and pieceTo:find("black") then
						-- activate promotion
						promotion = true
					end
					resetHalfmoveClock = true
				else
					return false
				end
			elseif from_y - 2 == to_y then
				-- double step
				if pieceTo ~= "" or from_y < 6 or pawnWhiteMove ~= "" then
					return false
				end
				-- store the destination of this double step in meta (needed for en passant check)
				doublePawnStep = to_index
				resetHalfmoveClock = true
			else
				return false
			end

			--[[
			     if x not changed
			          ensure that destination cell is empty
			     elseif x changed one unit left or right
			          ensure the pawn is killing opponent piece
			     else
			          move is not legal - abort
			]]

			if from_x == to_x then
				if pieceTo ~= "" then
					return false
				end
			elseif from_x - 1 == to_x or from_x + 1 == to_x then
				-- capture
				local can_capture = false
				if pieceTo:find("black") then
					-- normal capture
					can_capture = true
				else
					-- en passant
					if can_capture_en_passant(meta, "black", xy_to_index(to_x, from_y)) then
						can_capture = true
						en_passant_target = xy_to_index(to_x, from_y)
					end
				end
				if not can_capture then
					return false
				end
				resetHalfmoveClock = true
			else
				return false
			end

		elseif thisMove == "black" then
			local pawnBlackMove = inv:get_stack(from_list, xy_to_index(from_x, from_y + 1)):get_name()
			-- black pawns can go down only
			if from_y + 1 == to_y then
				-- single step
				if from_x == to_x then
					if pieceTo ~= "" then
						return false
					elseif to_index >= 57 and to_index <= 64 then
						-- activate promotion
						promotion = true
					end
					resetHalfmoveClock = true
				elseif from_x - 1 == to_x or from_x + 1 == to_x then
					if to_index >= 57 and to_index <= 64 and pieceTo:find("white") then
						-- activate promotion
						promotion = true
					end
					resetHalfmoveClock = true
				else
					return false
				end
			elseif from_y + 2 == to_y then
				-- double step
				if pieceTo ~= "" or from_y > 1 or pawnBlackMove ~= "" then
					return false
				end
				-- store the destination of this double step in meta (needed for en passant check)
				doublePawnStep = to_index
				resetHalfmoveClock = true
			else
				return false
			end

			--[[
			     if x not changed
			          ensure that destination cell is empty
			     elseif x changed one unit left or right
			          ensure the pawn is killing opponent piece
			     else
			          move is not legal - abort
			]]

			if from_x == to_x then
				if pieceTo ~= "" then
					return false
				end
			elseif from_x - 1 == to_x or from_x + 1 == to_x then
				-- capture
				local can_capture = false
				if pieceTo:find("white") then
					-- normal capture
					can_capture = true
				else
					-- en passant
					if can_capture_en_passant(meta, "white", xy_to_index(to_x, from_y)) then
						can_capture = true
						en_passant_target = xy_to_index(to_x, from_y)
					end
				end
				if not can_capture then
					return false
				end
				resetHalfmoveClock = true
			else
				return false
			end
		else
			return false
		end

	-- ROOK
	elseif pieceFrom:sub(11,14) == "rook" then
		if from_x == to_x then
			-- Moving vertically
			if from_y < to_y then
				-- Moving down
				-- Ensure that no piece disturbs the way
				for i = from_y + 1, to_y - 1 do
					if inv:get_stack(from_list, xy_to_index(from_x, i)):get_name() ~= "" then
						return false
					end
				end
			else
				-- Moving up
				-- Ensure that no piece disturbs the way
				for i = to_y + 1, from_y - 1 do
					if inv:get_stack(from_list, xy_to_index(from_x, i)):get_name() ~= "" then
						return false
					end
				end
			end
		elseif from_y == to_y then
			-- Moving horizontally
			if from_x < to_x then
				-- moving right
				-- ensure that no piece disturbs the way
				for i = from_x + 1, to_x - 1 do
					if inv:get_stack(from_list, xy_to_index(i, from_y)):get_name() ~= "" then
						return false
					end
				end
			else
				-- Moving left
				-- Ensure that no piece disturbs the way
				for i = to_x + 1, from_x - 1 do
					if inv:get_stack(from_list, xy_to_index(i, from_y)):get_name() ~= "" then
						return false
					end
				end
			end
		else
			-- Attempt to move arbitrarily -> abort
			return false
		end

		-- Lose castling right when moving rook
		if thisMove == "white" then
			if from_index == 57 then
				-- queenside white rook
				lostCastlingRightRook = "castlingWhiteL"
			elseif from_index == 64 then
				-- kingside white rook
				lostCastlingRightRook = "castlingWhiteR"
			end
		elseif thisMove == "black" then
			if from_index == 1 then
				-- queenside black rook
				lostCastlingRightRook = "castlingBlackL"
			elseif from_index == 8 then
				-- kingside black rook
				lostCastlingRightRook = "castlingBlackR"
			end
		end

	-- KNIGHT
	elseif pieceFrom:sub(11,16) == "knight" then
		-- Get relative pos
		local dx = from_x - to_x
		local dy = from_y - to_y

		-- Get absolute values
		if dx < 0 then dx = -dx end
		if dy < 0 then dy = -dy end

		-- Sort x and y
		if dx > dy then dx, dy = dy, dx end

		-- Ensure that dx == 1 and dy == 2
		if dx ~= 1 or dy ~= 2 then
			return false
		end
		-- Just ensure that destination cell does not contain friend piece
		-- ^ It was done already thus everything ok

	-- BISHOP
	elseif pieceFrom:sub(11,16) == "bishop" then
		-- Get relative pos
		local dx = from_x - to_x
		local dy = from_y - to_y

		-- Get absolute values
		if dx < 0 then dx = -dx end
		if dy < 0 then dy = -dy end

		-- Ensure dx and dy are equal
		if dx ~= dy then return false end

		if from_x < to_x then
			if from_y < to_y then
				-- Moving right-down
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x + i, from_y + i)):get_name() ~= "" then
						return false
					end
				end
			else
				-- Moving right-up
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x + i, from_y - i)):get_name() ~= "" then
						return false
					end
				end
			end
		else
			if from_y < to_y then
				-- Moving left-down
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x - i, from_y + i)):get_name() ~= "" then
						return false
					end
				end
			else
				-- Moving left-up
				-- ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x - i, from_y - i)):get_name() ~= "" then
						return false
					end
				end
			end
		end

	-- QUEEN
	elseif pieceFrom:sub(11,15) == "queen" then
		local dx = from_x - to_x
		local dy = from_y - to_y

		-- Get absolute values
		if dx < 0 then dx = -dx end
		if dy < 0 then dy = -dy end

		-- Ensure valid relative move
		if dx ~= 0 and dy ~= 0 and dx ~= dy then
			return false
		end

		if from_x == to_x then
			if from_y < to_y then
				-- Goes down
				-- Ensure that no piece disturbs the way
				for i = from_y + 1, to_y - 1 do
					if inv:get_stack(from_list, xy_to_index(from_x, i)):get_name() ~= "" then
						return false
					end
				end
			else
				-- Goes up
				-- Ensure that no piece disturbs the way
				for i = to_y + 1, from_y - 1 do
					if inv:get_stack(from_list, xy_to_index(from_x, i)):get_name() ~= "" then
						return false
					end
				end
			end
		elseif from_x < to_x then
			if from_y == to_y then
				-- Goes right
				-- Ensure that no piece disturbs the way
				for i = from_x + 1, to_x - 1 do
					if inv:get_stack(from_list, xy_to_index(i, from_y)):get_name() ~= "" then
						return false
					end
				end
			elseif from_y < to_y then
				-- Goes right-down
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x + i, from_y + i)):get_name() ~= "" then
						return false
					end
				end
			else
				-- Goes right-up
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x + i, from_y - i)):get_name() ~= "" then
						return false
					end
				end
			end
		else
			if from_y == to_y then
				-- Goes left
				-- Ensure that no piece disturbs the way and destination cell does
				for i = to_x + 1, from_x - 1 do
					if inv:get_stack(from_list, xy_to_index(i, from_y)):get_name() ~= "" then
						return false
					end
				end
			elseif from_y < to_y then
				-- Goes left-down
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x - i, from_y + i)):get_name() ~= "" then
						return false
					end
				end
			else
				-- Goes left-up
				-- Ensure that no piece disturbs the way
				for i = 1, dx - 1 do
					if inv:get_stack(
						from_list, xy_to_index(from_x - i, from_y - i)):get_name() ~= "" then
						return false
					end
				end
			end
		end

	-- KING
	elseif pieceFrom:sub(11,14) == "king" then
		local dx = from_x - to_x
		local dy = from_y - to_y
		local check = true
		local inv = meta:get_inventory()
		local board = realchess.board_to_table(inv)

		-- Castling
		local cc, rook_start, rook_goal, rook_name = can_castle(meta, board, from_list, from_index, to_index)
		if cc then
			inv:set_stack(from_list, rook_goal, rook_name)
			inv:set_stack(from_list, rook_start, "")
			check = false
			kingMoved = true
		end

		if check then
			if dx < 0 then
				dx = -dx
			end

			if dy < 0 then
				dy = -dy
			end

			if dx > 1 or dy > 1 then
				return false
			end
		end
		kingMoved = true

	end

	local board       = realchess.board_to_table(inv)
	board[to_index]   = board[from_index]
	board[from_index] = ""

	local black_king_idx, white_king_idx = realchess.locate_kings(board)
	if not black_king_idx or not white_king_idx then
		minetest.log("error", "[xdecor] Chess: Insufficient kings on chessboard!")
		return false
	end
	local blackAttacked = realchess.attacked("black", black_king_idx, board)
	local whiteAttacked = realchess.attacked("white", white_king_idx, board)

	-- Refuse to move if it would put or leave the own king
	-- under attack
	if blackAttacked and thisMove == "black" then
		return false
	end
	if whiteAttacked and thisMove == "white" then
		return false
	end

	if pieceTo ~= "" then
		resetHalfmoveClock = true
	end

	-- The halfmove clock counts the number of consecutive halfmoves
	-- in which neither a pawn was moved nor a piece was captured.
	if resetHalfmoveClock then
		meta:set_int("halfmoveClock", 0)
	else
		meta:set_int("halfmoveClock", meta:get_int("halfmoveClock") + 1)
	end

	if en_passant_target then
		-- Capture pawn en passant
		local capturedPiece = inv:get_stack(to_list, en_passant_target):get_name()
		inv:set_stack(to_list, en_passant_target, "")
		add_to_eaten_list(meta, capturedPiece)
	end

	if kingMoved and thisMove == "white" then
		meta:set_int("castlingWhiteL", 0)
		meta:set_int("castlingWhiteR", 0)
	elseif kingMoved and thisMove == "black" then
		meta:set_int("castlingBlackL", 0)
		meta:set_int("castlingBlackR", 0)
	elseif lostCastlingRightRook then
		meta:set_int(lostCastlingRightRook, 0)
	end

	if promotion then
		meta:set_string("promotionActive", thisMove)
		meta:set_int("promotionPawnFromIdx", from_index)
		meta:set_int("promotionPawnToIdx", to_index)
	else
		realchess.update_state(meta, from_index, to_index, thisMove)
	end

	if doublePawnStep then
		meta:set_int("prevDoublePawnStepTo", doublePawnStep)
	else
		meta:set_int("prevDoublePawnStepTo", 0)
	end

	if meta:get_string("playerWhite") == "" then
		meta:set_string("playerWhite", playerWhite)
		-- If in singleplayer, the player moved a white piece first without
		-- explicitly selecting a color, interpret this as the player wanting
		-- to play as white
		if meta:get_string("mode") == "single" and lastMove == "" and meta:get_string("gameResult") == "" then
			meta:set_string("playerBlack", "*"..BOT_NAME.."*")
			meta:set_string("botColor", "black")
		end
	elseif meta:get_string("playerBlack") == "" then
		meta:set_string("playerBlack", playerBlack)
	end

	realchess.move_piece(meta, pieceFrom, from_list, from_index, to_list, to_index)

	return true
end

-- Causes the player ("white" or "blue") to resign
function realchess.resign(meta, playerColor)
	if playerColor == "black" then
		meta:set_string("gameResult", "whiteWon")
		meta:set_string("gameResultReason", "resign")
		add_special_to_moves_list(meta, "whiteWon")
		update_formspec(meta)
	elseif playerColor == "white" then
		meta:set_string("gameResult", "blackWon")
		meta:set_string("gameResultReason", "resign")
		add_special_to_moves_list(meta, "blackWon")
		update_formspec(meta)
	end
end

local function timeout_format(timeout_limit)
	local time_remaining = timeout_limit - minetest.get_gametime()
	local minutes        = math.floor(time_remaining / 60)
	local seconds        = time_remaining % 60

	if minutes == 0 then
		-- number of seconds
		return S("@1 s", seconds)
	end

	-- number of minutes and seconds
	return S("@1 min @2 s", minutes, seconds)
end

function realchess.fields(pos, _, fields, sender)
	local playerName    = sender:get_player_name()
	local meta          = minetest.get_meta(pos)
	local timeout_limit = meta:get_int("lastMoveTime") + TIMEOUT
	local playerWhite   = meta:get_string("playerWhite")
	local playerBlack   = meta:get_string("playerBlack")
	local lastMoveTime  = meta:get_int("lastMoveTime")
	local gameResult    = meta:get_int("gameResult")
	if fields.quit then return end

	if fields.single or fields.multi or fields.bot_vs_bot then
		if fields.bot_vs_bot then
			if not CHESS_DEBUG then
				-- Bot vs Bot only allowed in Chess Debug Mode
				return
			end
			meta:set_string("mode", "bot_vs_bot")
			meta:set_string("botColor", "both")
			-- Add asterisk to bot names so it can't collide with a player name
			-- (asterisk is forbidden in player names)
			meta:set_string("playerWhite", "*"..BOT_NAME_1.."*")
			meta:set_string("playerBlack", "*"..BOT_NAME_2.."*")
			local inv = meta:get_inventory()
			chessbot.move(inv, meta)
		elseif fields.single then
			meta:set_string("mode", "single")
		elseif fields.multi then
			meta:set_string("mode", "multi")
		end
		update_formspec(meta)
		return
	end

	local mode = meta:get_string("mode")
	-- "Play as White/Black" button in Singleplayer when nobody has moved yet
	if (fields.single_black or fields.single_white) and mode == "single" and meta:get_string("gameResult") == "" and meta:get_string("lastMove") == "" then
		if fields.single_white then
			meta:set_string("botColor", "black")
			meta:set_string("playerWhite", playerName)
			meta:set_string("playerBlack", "*"..BOT_NAME.."*")
			update_formspec(meta)
		else
			meta:set_string("botColor", "white")
			meta:set_string("playerWhite", "*"..BOT_NAME.."*")
			meta:set_string("playerBlack", playerName)
			update_formspec(meta)
			local inv = meta:get_inventory()
			chessbot.move(inv, meta)
		end
		return
	end

	-- If the game is ongoing and no move was made for TIMEOUT seconds,
	-- the game can be aborted by everyone.
	-- Also allow instant reset before White and Black moved,
	-- as well as in Bot vs Bot mode, as well
	-- when the game ended.
	if fields.new then
		if mode == "bot_vs_bot" or (playerWhite == playerName or playerBlack == playerName or playerWhite == "" or playerBlack == "") or meta:get_string("gameResult") ~= "" then
			realchess.init(pos)

		elseif lastMoveTime > 0 then
			if minetest.get_gametime() >= timeout_limit and
					(playerWhite ~= playerName or playerBlack ~= playerName) then
				realchess.init(pos)
			else
				send_message(playerName,
					S("You can't reset the chessboard, a game has been started. Try again in @1.",
					timeout_format(timeout_limit)))
			end
		end
		return
	end

	if fields.resign and mode ~= "bot_vs_bot" then
		local lastMove = meta:get_string("lastMove")
		if (playerName == playerWhite and playerWhite == "") or (playerName == playerBlack and playerBlack == "") then
			-- Can't resign before the player name has been recorded
			send_message(playerName, S("Resigning is not possible yet."))
			return
		end
		local winner, loser, whiteWon
		if playerWhite == playerBlack and playerWhite == playerName and playerWhite ~= "" then
			if lastMove == "black" then
				winner = playerBlack
				loser = playerWhite
				whiteWon = false
			else
				winner = playerWhite
				loser = playerBlack
				whiteWon = true
			end
		elseif playerName == playerWhite and playerWhite ~= "" then
			winner = playerBlack
			loser = playerWhite
			whiteWon = false
		elseif playerName == playerBlack and playerBlack ~= "" then
			winner = playerWhite
			loser = playerBlack
			whiteWon = true
		end
		if winner and loser then
			if whiteWon then
				realchess.resign(meta, "black")
			else
				realchess.resign(meta, "white")
			end

			send_message(loser, S("You have resigned."))
			if playerWhite ~= playerBlack then
				send_message(winner, S("@1 has resigned. You win!", loser))
			end
			minetest.log("action", "[xdecor] Chess: "..loser.." has resigned from the game against "..winner)
			update_formspec(meta)
		else
			send_message(playerName, S("You can't resign, you're not playing in this game."))
		end
		return
	end

	-- Claim or declare draw via the 50-move rule
	if fields.draw_50_moves then
		local botColor = meta:get_string("botColor")
		local lastMove = meta:get_string("lastMove")
		if playerWhite == "" and playerBlack == "" or lastMove == "" then
			return
		end
		local currentPlayer
		if lastMove == "black" or lastMove == "" then
			currentPlayer = "white"
		else
			currentPlayer = "black"
		end

		local claimer, other
		if (currentPlayer == "white" and playerWhite == playerName) then
			claimer = playerWhite
			other = playerBlack
		elseif (currentPlayer == "black" and playerBlack == playerName) then
			claimer = playerBlack
			other = playerWhite
		else
			send_message(playerName, S("You can't claim a draw, it's not your turn!"))
			return
		end

		local halfmoveClock = meta:get_int("halfmoveClock")
		if halfmoveClock >= DRAWCLAIM_LONGGAME_PLAYER then
			meta:set_string("gameResult", "draw")
			meta:set_string("gameResultReason", "50_move_rule")
			add_special_to_moves_list(meta, "draw")
			update_formspec(meta)
			send_message(claimer, S("You have drawn the game by invoking the 50-move rule."), botColor)
			if claimer ~= other then
				send_message(other, S("@1 has drawn the game by invoking the 50-move rule.", claimer), botColor)
			end
			minetest.log("action", "[xdecor] Chess: A game between "..playerWhite.." and "..playerBlack.." ended in a draw because "..claimer.." has invoked the 50-move rule")
		else
			meta:set_string("drawClaim", "50_move_rule")
			update_formspec(meta)
		end

		return
	end

	-- Claim or declare draw via the threefold repetition rule (same position occured >= 3 times)
	if fields.draw_repeat_3 then
		local botColor = meta:get_string("botColor")
		local lastMove = meta:get_string("lastMove")
		if playerWhite == "" and playerBlack == "" or lastMove == "" then
			return
		end
		local currentPlayer
		if lastMove == "black" or lastMove == "" then
			currentPlayer = "white"
		else
			currentPlayer = "black"
		end

		local claimer, other
		if (currentPlayer == "white" and playerWhite == playerName) then
			claimer = playerWhite
			other = playerBlack
		elseif (currentPlayer == "black" and playerBlack == playerName) then
			claimer = playerBlack
			other = playerWhite
		else
			send_message(playerName, S("You can't claim a draw, it's not your turn!"))
			return
		end

		local positions, first_p = get_positions_history(meta)
		local _, lastOccurred = count_repeated_positions(positions, first_p)
		if lastOccurred >= 3 then
			meta:set_string("gameResult", "draw")
			meta:set_string("gameResultReason", "same_position_3")
			add_special_to_moves_list(meta, "draw")
			update_formspec(meta)
			send_message(claimer, S("You have drawn the game by invoking the threefold repetition rule."), botColor)
			if claimer ~= other then
				send_message(other, S("@1 has drawn the game by invoking the threefold repetition rule.", claimer), botColor)
			end
			minetest.log("action", "[xdecor] Chess: A game between "..playerWhite.." and "..playerBlack.." ended in a draw because "..claimer.." has invoked the threefold repetition rule")
		else
			meta:set_string("drawClaim", "same_position_3")
			update_formspec(meta)
		end
		return
	end

	local promotions = {
		"queen_white", "rook_white", "bishop_white", "knight_white",
		"queen_black", "rook_black", "bishop_black", "knight_black",
	}
	for p=1, #promotions do
		local gameResult = meta:get_string("gameResult")
		if gameResult ~= "" then
			return
		end
		local promo = promotions[p]
		if fields["p_"..promo] then
			if not (playerName == playerWhite or playerName == playerBlack) then
				send_message(playerName, S("You're only a spectator in this game of Chess."))
				return
			end
			local pcolor = promo:sub(-5)
			local activePromo = meta:get_string("promotionActive")
			if activePromo == "" then
				send_message(playerName, S("This isn't the time for promotion."))
				return
			elseif activePromo ~= pcolor then
				send_message(playerName, S("It's not your turn! This promotion is meant for the other player."))
				return
			end
			if pcolor == "white" and playerName == playerWhite or pcolor == "black" and playerName == playerBlack then
				realchess.promote_pawn(meta, pcolor, promo:sub(1, -7))
				return
			else
				send_message(playerName, S("It's not your turn! This promotion is meant for the other player."))
				return
			end
		end
	end
end

function realchess.can_dig(pos, player)
	if not player or not player:is_player() then
		return false
	end
	-- Protection_bypass priv guarantees digging rights
	if minetest.check_player_privs(player, "protection_bypass") then
		return true
	end

	local meta          = minetest.get_meta(pos)
	local playerName    = player:get_player_name()
	local timeout_limit = meta:get_int("lastMoveTime") + TIMEOUT
	local lastMoveTime  = meta:get_int("lastMoveTime")
	local playerWhite   = meta:get_string("playerWhite")
	local playerBlack   = meta:get_string("playerBlack")
	local botColor      = meta:get_string("botColor")

	-- Bot matches always allow dig
	if (meta:get_string("mode") == "bot_vs_bot") then
		return true
	elseif (meta:get_string("gameResult") ~= "") then
	-- If the game was completed, the board is free to be dug
		return true
	-- If the game is ongoing and no move was made for TIMEOUT seconds,
	-- the board is free to be dug
	elseif (lastMoveTime == 0 and minetest.get_gametime() > timeout_limit) then
		return true
	else
		if playerName == playerWhite or playerName == playerBlack or botColor == "both" then
			send_message(playerName,
					S("You can't dig the chessboard, a game has been started. " ..
					"Reset it first or dig it again in @1.",
					timeout_format(timeout_limit)))
		else
			send_message(playerName,
					S("You can't dig the chessboard, a game has been started. " ..
					"Try it again in @1.",
					timeout_format(timeout_limit)))
		end
		return false
	end
end

-- Helper function for realchess.move.
-- To be called when a valid normal move should be taken.
-- Will also update the state for the Chessboard.
function realchess.move_piece(meta, pieceFrom, from_list, from_index, to_list, to_index)
	local inv = meta:get_inventory()
	local pieceTo = inv:get_stack(to_list, to_index):get_name()

	-- Update inventory slots
	inv:set_stack(from_list, from_index, "")
	inv:set_stack(to_list, to_index, pieceFrom)

	-- Report the eaten piece
	if pieceTo ~= "" then
		add_to_eaten_list(meta, pieceTo)
	end

	local promo = meta:get_string("promotionActive") ~= ""
	if not promo then
		update_game_result(meta)
	end
	update_formspec(meta)

	local botColor = meta:get_string("botColor")
	if botColor == "" then botColor = "black" end
	local lastMove = meta:get_string("lastMove")
	if lastMove == "" then lastMove = "black" end
	local mode = meta:get_string("mode")
	local gameResult = meta:get_string("gameResult")
	-- Let the bot play when it its turn
	if (mode == "bot_vs_bot" or (mode == "single" and lastMove ~= botColor)) and gameResult == "" then
		if not promo then
			chessbot.move(inv, meta)
		else
			chessbot.promote(inv, meta, to_index)
		end
	end
end

function realchess.update_state(meta, from_index, to_index, thisMove, promoteFrom, promoteTo)
	local inv         = meta:get_inventory()
	local board       = realchess.board_to_table(inv)
	local pieceTo     = board[to_index]
	local pieceFrom   = promoteFrom or board[from_index]

	if not promoteFrom then
		board[to_index]   = board[from_index]
		board[from_index] = ""
	end

	local black_king_idx, white_king_idx = realchess.locate_kings(board)
	if not black_king_idx or not white_king_idx then
		minetest.log("error", "[xdecor] Chess: Insufficient kings on chessboard!")
		return
	end
	local blackAttacked = realchess.attacked("black", black_king_idx, board)
	local whiteAttacked = realchess.attacked("white", white_king_idx, board)

	if blackAttacked then
		meta:set_string("blackAttacked", "true")
	else
		meta:set_string("blackAttacked", "")
	end

	if whiteAttacked then
		meta:set_string("whiteAttacked", "true")
	else
		meta:set_string("whiteAttacked", "")
	end

	local lastMove = thisMove
	meta:set_string("lastMove", lastMove)
	meta:set_int("lastMoveTime", minetest.get_gametime())

	local special
	if promoteTo then
		special = "promo__"..promoteTo
	end
	add_move_to_moves_list(meta, pieceFrom, pieceTo, from_index, to_index, special)
end

function realchess.promote_pawn(meta, color, promoteTo)
	local inv = meta:get_inventory()
	local pstr = promoteTo .. "_" .. color
	local promoted = false
	local to_idx = meta:get_int("promotionPawnToIdx")
	local from_idx = meta:get_int("promotionPawnFromIdx")
	if to_idx < 1 or from_idx < 1 then
		return
	end
	if promoteTo ~= "queen" then
		pstr = pstr .. "_1"
	end
	pstr = "realchess:" .. pstr

	local promoteFrom
	if color == "white" then
		promoteFrom = inv:get_stack("board", to_idx)
		if promoteFrom:get_name():sub(11,14) == "pawn" then
			inv:set_stack("board", to_idx, pstr)
			promoted = true
		end
	elseif color == "black" then
		promoteFrom = inv:get_stack("board", to_idx)
		if promoteFrom:get_name():sub(11,14) == "pawn" then
			inv:set_stack("board", to_idx, pstr)
			promoted = true
		end
	end
	if promoted then
		meta:set_string("promotionActive", "")
		meta:set_int("promotionPawnFromIdx", 0)
		meta:set_int("promotionPawnToIdx", 0)
		realchess.update_state(meta, from_idx, to_idx, color, promoteFrom:get_name(), pstr)
		update_formspec(meta)

		local botColor = meta:get_string("botColor")
		if botColor == "" then botColor = "black" end
		local lastMove = meta:get_string("lastMove")
		if lastMove == "" then lastMove = "black" end

		local mode = meta:get_string("mode")
		local gameResult = meta:get_string("gameResult")
		if (mode == "bot_vs_bot" or (mode == "single" and lastMove ~= botColor)) and gameResult == "" then
			chessbot.move(inv, meta)
		end
	else
		minetest.log("error", "[xdecor] Chess: Could not find pawn to promote!")
	end
end

function realchess.blast(pos)
	minetest.remove_node(pos)
end

local chessboarddef = {
	description = S("Chess Board"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	inventory_image = "chessboard_top.png",
	wield_image = "chessboard_top.png",
	tiles = {"chessboard_top.png", "chessboard_top.png", "chessboard_sides.png"},
	use_texture_alpha = ALPHA_OPAQUE,
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=3},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	node_box = {type = "fixed", fixed = {-.375, -.5, -.375, .375, -.4375, .375}},
	sunlight_propagates = true,
	on_rotate = screwdriver.rotate_simple,
}
if ENABLE_CHESS_GAMES then
	-- Extend chess board node definition if chess games are enabled
	chessboarddef._tt_help = S("Play a game of Chess against another player or the computer")
	chessboarddef.on_blast = realchess.blast
	chessboarddef.can_dig = realchess.can_dig
	chessboarddef.on_construct = realchess.init
	chessboarddef.on_receive_fields = realchess.fields
	-- The move logic of Chess is here (at least for players)
	chessboarddef.allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, _, player)
		-- Normally, the allow function is meant to just check if an inventory move
		-- is allowed but instead we abuse it to detect where the player is *attempting*
		-- to move pieces to.
		-- This function may manipulate the inventory. This is a bit dirty
		-- because this is not really what the allow function is meant to do.
		local meta = minetest.get_meta(pos)
		local playerName
		if player and player:is_player() then
			playerName = player:get_player_name()
		else
			playerName = "<UNKNOWN PLAYER>"
			minetest.log("error", "[xdecor] Chess: An unknown player tried to move a piece in the chessboard inventory")
		end
		realchess.move(meta, from_list, from_index, to_list, to_index, playerName)
		-- We always return 0 to disable all *builtin* inventory moves, since
		-- we do it ourselves. This should be fine because there shouldn't be a
		-- conflict between this mod and Minetest then.
		return 0
	end
	chessboarddef.allow_metadata_inventory_take = function() return 0 end
	chessboarddef.allow_metadata_inventory_put = function() return 0 end
	-- Note: There is no on_move function because we put the entire move handling
	-- into the allow function above. The reason for this is of Minetest's
	-- awkward behavior when swapping items.

	minetest.register_lbm({
		label = "Re-initialize chessboard (enable Chess games)",
		name = "xdecor:chessboard_reinit",
		nodenames = {"realchess:chessboard"},
		run_at_every_load = true,
		action = function(pos, node)
			-- Init chessboard only if neccessary
			local meta = minetest.get_meta(pos)
			if meta:get_string("formspec", "") then
				realchess.init(pos)
			end
		end,
	})
else
	minetest.register_lbm({
		label = "Clear chessboard formspec+infotext+inventory (disable Chess games)",
		name = "xdecor:chessboard_clear",
		nodenames = {"realchess:chessboard"},
		run_at_every_load = true,
		action = function(pos, node)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", "")
			meta:set_string("infotext", "")
			local inv = meta:get_inventory()
			inv:set_size("board", 0)
		end,
	})
end
minetest.register_node(":realchess:chessboard", chessboarddef)

local function register_piece(name, white_desc, black_desc, count)
	for _, color in pairs({"black", "white"}) do
	if not count then
		minetest.register_craftitem(":realchess:" .. name .. "_" .. color, {
			description = (color == "black") and black_desc or white_desc,
			inventory_image = name .. "_" .. color .. ".png",
			stack_max = 1,
			groups = {not_in_creative_inventory=1}
		})
	else
		for i = 1, count do
			minetest.register_craftitem(":realchess:" .. name .. "_" .. color .. "_" .. i, {
				description = (color == "black") and black_desc or white_desc,
				inventory_image = name .. "_" .. color .. ".png",
				stack_max = 1,
				groups = {not_in_creative_inventory=1}
			})
		end
	end
	end
end

register_piece("pawn", S("White Pawn"), S("Black Pawn"), 8)
register_piece("rook", S("White Rook"), S("Black Rook"), 2)
register_piece("knight", S("White Knight"), S("Black Knight"), 2)
register_piece("bishop", S("White Bishop"), S("Black Bishop"), 2)
register_piece("queen", S("White Queen"), S("Black Queen"))
register_piece("king", S("White King"), S("Black King"))

-- Recipes

minetest.register_craft({
	output = "realchess:chessboard",
	recipe = {
		{"dye:black", "dye:white", "dye:black"},
		{"stairs:slab_wood", "stairs:slab_wood", "stairs:slab_wood"}
	}
})
