local chessbot = {}

local realchess = xdecor.chess

-- Delay in seconds for a bot moving a piece (excluding choosing a promotion)
local BOT_DELAY_MOVE = 1.0
-- Delay in seconds for a bot promoting a piece
local BOT_DELAY_PROMOTE = 1.0

local function best_move(moves)
	local value, choices = 0, {}

	for from, _ in pairs(moves) do
	for to, val in pairs(_) do
		if val > value then
			value = val
			choices = {{
				from = from,
				to = to
			}}
		elseif val == value then
			choices[#choices + 1] = {
				from = from,
				to = to
			}
		end
	end
	end

	if #choices == 0 then
		return nil
	end
	local random = math.random(1, #choices)
	local choice_from, choice_to = choices[random].from, choices[random].to

	return tonumber(choice_from), choice_to
end

function chessbot.choose_move(board_t, meta_t)
	local lastMove = meta_t["lastMove"]
	local gameResult = meta_t["gameResult"]
	local botColor = meta_t["botColor"]
	local prevDoublePawnStepTo = meta_t["prevDoublePawnStepTo"]
	local castlingRights = {
		castlingWhiteR = meta_t["castlingWhiteR"],
		castlingWhiteL = meta_t["castlingWhiteL"],
		castlingBlackR = meta_t["castlingBlackR"],
		castlingBlackL = meta_t["castlingBlackL"],
	}

	if botColor == "" then
		return
	end
	local currentBotColor, opponentColor
	if botColor == "black" then
		currentBotColor = "black"
		opponentColor = "white"
	elseif botColor == "white" then
		currentBotColor = "white"
		opponentColor = "black"
	elseif botColor == "both" then
		opponentColor = lastMove
		if lastMove == "black" or lastMove == "" then
			currentBotColor = "white"
		else
			currentBotColor = "black"
		end
	end
	if (lastMove == opponentColor or ((botColor == "white" or botColor == "both") and lastMove == "")) and gameResult == "" then

		local moves = realchess.get_theoretical_moves_for(board_t, currentBotColor, prevDoublePawnStepTo, castlingRights)
		local safe_moves, safe_moves_count = realchess.get_king_safe_moves(moves, board_t, currentBotColor)
		if safe_moves_count == 0 then
			-- No safe move: stalemate or checkmate
		end
		local choice_from, choice_to = best_move(safe_moves)
		if choice_from == nil then
			-- No best move: stalemate or checkmate
			return
		end

		return choice_from, choice_to
	else
		minetest.log("error", "[xdecor] Chess: chessbot.choose_move was apparently called in an invalid game state!")
		return
	end
end

chessbot.perform_move = function(choice_from, choice_to, meta)
	local lastMove = meta:get_string("lastMove")
	local botColor = meta:get_string("botColor")
	local currentBotColor, opponentColor
	local botName
	if botColor == "black" then
		currentBotColor = "black"
		opponentColor = "white"
	elseif botColor == "white" then
		currentBotColor = "white"
		opponentColor = "black"
	elseif botColor == "both" then
		opponentColor = lastMove
		if lastMove == "black" or lastMove == "" then
			currentBotColor = "white"
		else
			currentBotColor = "black"
		end
	end

	-- Bot resigns if no move chosen
	if not choice_from or not choice_to then
		realchess.resign(meta, currentBotColor)
		return
	end

	if currentBotColor == "white" then
		botName = meta:get_string("playerWhite")
	else
		botName = meta:get_string("playerBlack")
	end

	local gameResult = meta:get_string("gameResult")
	if gameResult ~= "" then
		return
	end
	local botColor = meta:get_string("botColor")
	if botColor == "" then
		minetest.log("error", "[xdecor] Chess: chessbot.perform_move: botColor in meta string was empty!")
		return
	end
	local lastMove = meta:get_string("lastMove")
	local lastMoveTime = meta:get_int("lastMoveTime")
	if lastMoveTime > 0 or lastMove == "" then
		-- Set the bot name if not set already
		if currentBotColor == "black" and meta:get_string("playerBlack") == "" then
			meta:set_string("playerBlack", botName)
		elseif currentBotColor == "white" and meta:get_string("playerWhite") == "" then
			meta:set_string("playerWhite", botName)
		end

		-- Make a move
		local moveOK = realchess.move(meta, "board", choice_from, "board", choice_to, botName)
		if not moveOK then
			minetest.log("error", "[xdecor] Chess: Bot tried to make an invalid move from "..
				realchess.index_to_notation(choice_from).." to "..realchess.index_to_notation(choice_to))
		end
		-- Bot resigns if it tried to make an invalid move
		if not moveOK then
			realchess.resign(meta, currentBotColor)
		end
	else
		minetest.log("error", "[xdecor] Chess: chessbot.perform_move: No last move!")
	end
end

function chessbot.choose_promote(board_t, pawnIndex)
	-- Bot always promotes to queen
	return "queen"
end

function chessbot.perform_promote(meta, promoteTo)
	minetest.after(BOT_DELAY_PROMOTE, function()
		local lastMove = meta:get_string("lastMove")
		local color
		if lastMove == "black" or lastMove == "" then
			color = "white"
		else
			color = "black"
		end
		realchess.promote_pawn(meta, color, promoteTo)
	end)
end

function chessbot.move(inv, meta)
	local board_t = realchess.board_to_table(inv)
	local meta_t = {
		lastMove = meta:get_string("lastMove"),
		gameResult = meta:get_string("gameResult"),
		botColor = meta:get_string("botColor"),
		prevDoublePawnStepTo = meta:get_int("prevDoublePawnStepTo"),
		castlingWhiteL = meta:get_int("castlingWhiteL"),
		castlingWhiteR = meta:get_int("castlingWhiteR"),
		castlingBlackL = meta:get_int("castlingBlackL"),
		castlingBlackR = meta:get_int("castlingBlackR"),
	}
	local choice_from, choice_to = chessbot.choose_move(board_t, meta_t)
	minetest.after(BOT_DELAY_MOVE, function()
		chessbot.perform_move(choice_from, choice_to, meta)
	end)
end

function chessbot.promote(inv, meta, pawnIndex)
	local board_t = realchess.board_to_table(inv)
	local promoteTo = chessbot.choose_promote(board_t, pawnIndex)
	if not promoteTo then
		promoteTo = "queen"
	end
	chessbot.perform_promote(meta, promoteTo)
end

return chessbot
