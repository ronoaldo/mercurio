# Chess

## Introduction

You can play Chess in X-Decor-libre!

While the game of Chess is well-known and widespread and its
rules are well-documented all over the Internet and elsewhere,
the devil still lies in the detail.

In X-Decor-libre, the game of Chess is closely modeled after
the FIDE Laws of Chess from January 2023. However, for a
computer version of Chess, there are still some details
that might need explanation.

## Objective

Chess is played between two players on a chessboard. One player plays
with white pieces while the other one plays with black pieces.
The goal of the game is to put the king of the opponent under attack
in such a way they have no legal move. This is known as ‘checkmate’.
It is not allowed to put one’s king in danger, to leave him in danger
or to capture the opponent’s king.

## How to play

You need a chessboard to play. Craft yourself a chessboard like this:

    BWB
    sss

B = Black Dye
W = White Dye
s = Wooden Slab (from apple tree)

Place the chessboard and examine it. You will see a close-up of the chessboard.

### The Chess interface

On the screen that pops up, you can choose to play against the
computer (Singleplayer) or another player on the server (Multiplayer).
You may also use the multiplayer option to play against yourself.
The computer player is quite weak.

Click on the corresponding button to start the game.

Once the game has started, you see the following things:

To the left, the large chessboard consisting of 8×8 dark and white squares.
The pieces are put on the chessboard. If there is no active game,
the chessboard is empty.

During a game, the interface has the following meaning:

Above and below the chessboard, plaques show the name of the players.
Above the chessboard is the player playing Black and below it
the player playing White.
An arrow left of the plaque shows whose turn it is. The name plaques
may also show the “game status”, such as victory, checkmate (=loss),
draw, being “in check”, etc.

On the right side, a list of moves that have been made is shown.
It is written in a figurine long algebraic notation (see appendix).

The two boxes below the list of moves is where all the captured pieces
go. This has no gameplay significance but it may serve as a visual
aid to see how badly hurt the player's “armies” are. This section
may change

The top right corner is used for starting a new game. Press
“New Game” to start a new game. This ends the current game.

The bottom right corner right corner is used for special
player actions, such as resigning or claiming a draw.

Note that during a game, the buttons only work for the two players
playing Chess. They don’t work for anyone else.

## The rules of Chess

### Starting a game

Select Singleplayer or Multiplayer. In Singleplayer, you choose
the color you play as by clicking the corresponding button.

White always plays first.

In multiplayer, anyone can make the first move.
The player making the first move as White will play as White,
the player making the first move as Black will play as Black.
After that, the players are “locked” to their colors and
nobody else can play as White or Black.

### The chessboard

The chessboard is a board of 8×8 squares alternating between light
and dark squares. Each square is either empty or holds exactly one
chess piece.

### The Chess pieces and how they move

Each player starts with the same pieces on opposing sides of the board,
only their color is different. 

There are 4 types of moves you can make:

* Normal move: You pick up the piece and place it to an empty square
* Capturing move: You pick up the piece and place it on top of an opposing piece
    Your piece will land on that square and the opponent’s piece is removed
* En passant: Special capturing move of the pawn (see below)
* Castling: Special king+rook move (see below)

It is not possible to place your piece on your own pieces.
It is not possible to capture a king or your own pieces.
Any square on which a piece could capture another piece in theory
(even if it is actually empty) is considered to be “attacked”.

For most pieces, the rules for making a normal move and
a capturing move are identical. Only for the pawn it is different
(read below).

If the square of the king is attacked, he and the player playing him
is considered to be in “check”.
If a player is in check, any move which would put or leave the own
king under attack is not allowed.

#### How to actually move

Each move can be made by either clicking on the piece and then clicking again
on the destination. The destination is either an empty square or a square
occupied by an opponent’s piece (which will be captured).
You can also do the same via drag-and-drop.

Once you made a valid move by placing the piece to its destination, it is
final and cannot be taken back. This ends your move and it’s your
opponent’s turn (exception: promotion, see below).

If you pick up a piece and put it back, nothing happens, it is still
your turn and you can still do your move normally. Also, if you try
to make an invalid move, nothing happens as well.

(Nerd info: For the purposes of the FIDE Laws of Chess, pieces are never
considered “touched” here. Thus, article 4 of the FIDE Laws of Chess has
no effect.)

#### Rook

The rook looks like a tower and can move to any of square that lies
in a straight horizontal or vertical line from it.
It cannot move beyond pieces that are in the way.

The rook can move on a square occupied by an opponent, which
w

The rook may be involved in Castling, see “King” below.

#### Bishop

The bishop can move to any square on a diagonal line from it.
It cannot move beyond pieces that are in the way.

#### Queen

The queen combines the powers of the rook and bishop and can
move to any square in a straight horizontal, vertical
or diagonal line from it.
It cannot move beyond pieces that are in the way.

#### Knight

The knight looks like a horse and can move to any square closest to
it that is not in its same horizontal line (also known as “rank”),
vertical line (also known as “file”), or diagonal of the board.
To illustrate this:

    ..X.X..
    .X...X.
    ...n...
    .X...X.
    ..X.X..

In this diagram, “n” represents the knight and the Xes are all the
possible squares it can theoretically reach. The dots are empty
squares.

Unlike the other pieces, pieces are never “in the way” of the knight.
You might say the knight can “jump over” them, if you will.

#### King

The king can move exactly one square in any direction: horizontally,
vertically or diagonally. Also, the king can never move to any square that
is attacked by an opponent’s piece.

The king also has a special move called “Castling”.

##### Castling

Castling is a special move in which two pieces move at once.
Both the king and a rook move horizontally from their starting positions.
The king will move two squares horizontally and a rook will be
moved next to him.

Each player has two possible castling moves available, involving each
of the 2 starting rooks.

Castling has several conditions:

- The king must not have moved yet
- The rook you wish to castle with must not have moved yet
- All of the squares between king and rook must be empty
- The king must not be under attack
- The king’s destination as well the square it crosses must not be under attack
- You can castle only horizontally

If all the conditions are met, here’s how you castle:

Place the king two squares towards the rook you want to castle with.
This square is where the king will end up. The rook will then
automatically move towards the king and “jump” to the square
behind the king, from the rooks viewpoint.

**Remember**: You *must* move the king (not the rook) if you want
to castle. If you move the rook instead, this is considered
to be a regular move of the rook alone.

#### Pawn

The pawn has various ways to move.
The pawn has a “walking direction”, it walks and captures towards
the opponent’s side (i.e. the side on which the opponent’s
pieces have started).

The pawn’s basic moves are:

1. Single step: The pawn moves one step vertically towards the
                opponent’s side. It is not possible to walk backwards.
2. Double step: Like a single step, but it moves two squares instead.
                This is only possible from the pawn’s start position.

In both cases, the destination square must be empty as well as any crossed square.
The pawn cannot capture by a single or double step, however.

The capturing move of the pawn is different. To capture, the pawn has to
move one step diagonally towards the opponent’s side, either left or right.

To illustrate, in the following diagram, the X’es represent the
squares attacked by a white pawn (w) and a black pawn (b):

    .X.X..b..
    ..w..X.X.

##### En passant capture

An en passant capture is a pawn move that is available if a pawn
of the current player stands on a square left or right from an
opposing pawn that has made a double step in the previous move.

In this situation, the first pawn may move as if the second pawn
had made a single step instead. This will be considered as a
capturing move and the opposing pawn will be removed from the board.


Consider this example: Here, “w” represents a white pawn, “b” a black pawn and “.”
an empty square. White moves upwards and Black downwards. Consider this starting
position:

    b.
    ..
    .w

Now, White does a double step:

    bw
    ..
    ..

Black decides to do an en passant capture. For this, the black pawn moves one
diagonal step towards the square just crossed by the opponent. The white
pawn is captured and removed.

    ..
    .b
    ..

Remember! An 'en passant' capture is only possible in the move directly after
a pawn’s double step. So if the chance for a particular en passant capture
is not taken, it will be gone from that point on.

##### Promotion

When a pawn reaches the other end of the chessboard (from its viewpoint)
it will be promoted. A promotion is considered to be part of the move.

When promotion happens, the boxes where normally the captured pieces go
will turn into a prompt. The current player must choose a new
piece to replace the pawn with:
A queen, rook, bishop or knight of the same color.
Just click the corresponding button. These buttons only work for the
current player. Promotion is mandatory and no other moves are possible
until it is completed.

Once a piece was selected, the pawn will be replaced replaced, which
immediately activates its powers. This ends the move.

### The end of the game

There are various ways for the game of Chess to end. A game always
ends in victory of one player, or in a draw.

#### Checkmate
Checkmating your opponent is the primary goal of Chess.
The player who has checkmated the opponent king wins the game and ends it.

You are checkmated when it’s your turn, your own king is in check
(i.e. under attack) and you have no valid move available.
This immediately ends the game and your opponent wins.

#### Stalemate
If it’s a player’s turn, but they have no possible move and their
king is not in check, the game immediately ends in a draw.
This is called a “stalemate”.

#### Resign
During the game, the possibility of resigning arises. Resigning 
basically means “giving up” and this leads to an instant loss
and the victory of your opponent.
Resigning is available after one’s name has been recorded on
the name plaque. Resigning is possible even when it’s not your turn.

To resign, click the skull icon in the bottom right.

#### Dead position
If during the game, on the board there are only the following pieces left,
the game ends in a draw:

* king versus king
* king versus king and bishop
* king versus king and knight
* king and bishop versus king and bishop, and both bishops stand on squares of the same color

This is called a “dead position”. For example, a board with only a white
and a black king is a draw. 

NOTE: In general, a dead position is any position from which neither player can
give checkmate, no matter how they move, but only those 4 cases above
lead to an instant draw in X-Decor-libre because it is tricky to
determine whether any position is “dead”.

However, dead positions are still guaranteed to end the game eventually
due to the 75-move rule.

#### 50-move rule
If in the last 50 consecutive moves of each player, no piece was
captured and no pawn was moved, the player whose turn it is can invoke
the 50-move rule to draw the game instantly.

When it’s your turn, and you believe your *next* move will satisfy
the condition of the 50-move rule, you may also invoke this rule
to draw the game, but in this case, you still have to make the move.
If this move satisfies the 50-move rule, the game is drawn.
But if not, this counts as a normal move, your turn ends and the
game continues as normal.

A button on the bottom right will appear when this rule is available.
The button is not shown when there are too few such moves for this
draw claim to be successful.

The icon represents a barricade, as if the game of Chess itself
has been blocked. This one will instantly draw the game.
If you still would have to make the game-drawing move, the
icon represents half a barricade.
Note the tooltip.

Note the latter icon is no guarantee you can actually draw the
game in the next move, only that such a draw claim is plausible.

#### 75-move rule
If in the last 75 consecutive moves of each player, no piece was captured
and no pawn was moved, the game automatically ends in a draw.

Exception: If the last move has lead to a checkmate. In this case, checkmate
takes precedence.

#### Threefold repetition rule
If the current position has appeared at least 3 times in the game
the current player can invoke the threefold repetition rule to draw
the game instantly.

Two positions are considered to be the same “same” if a position in which
the chessboard has the same pieces of the same color on the same squares,
it is the same player's turn, the castling rights are the same
and the vulnerability of pawns to en passant captures (if any) is the same.

Pawns are considered “vulnerable” to an en passant capture immediately
after a double step turn, no matter if is actually in danger of
being captured that way.

This rule can also be invoked when you think your *next* move will
lead to the 3rd (or more) repeated position in the game. This
works similar as for the 50-move rule.

Like for the 50-move rule, a button appears on the bottom right
once this rule can be invoked.

If the 3 same position has already occurred, the icon will
represent 3 chess squares stacked on top of each other.
If the game-drawing move still has to be made, the top
square is a “ghost square”.

#### Fivefold repetition rule
If the same position (as defined above) has appeared at for
least 5 times, the game is drawn.

#### No agreeing to draw

Unlike in other Chess programs, the players cannot agree to draw.

#### Game result

Once the game has ended, the game result is shown on the name plaques of the
players as well in chat (to the players only). From this point on, everyone
(even spectators) can start a new game with “New Game”.


## Resetting the chessboard

While a game of Chess is ongoing, the chessboard can’t be dug and the game
can’t be stopped by other players. But to prevent two players blocking a
chessboard forever, there is a 5-minute timer. If no player makes a move
for 5 minutes, then the chessboard can be reset and dug by anyone.

Exception: Players with the `protection_bypass` privilege can always
dig the chessboard.


## Appendix

### The Chess Notation

The list of moves is in a special notation called “algebraic notation”. There are many
variants of it, so this section explains what it means in X-Decor-libre.

This mod uses a longform figurine algebraic notation. “figurine” means that
icons are used for the chess pieces. “longform” means the start
and end coordinates are shown in full.

Square coordinates are important in any Chess notation. In algebraic notation,
each square is assigned coordinated with a letter from a to h,
followed by a number from 1 to 8.
Provided that the player playing White is on the “bottom” side of the chessboard,
the squares are numbered from the bottom left square in ascending order.
The horizontal lines (“ranks”) are numbered 1 to 8, starting from the bottom.
The vertical lines (“files”) are numbered a to h, starting from the left.
So from White's viewpoint, the bottom-left square is a1. The square above it
is a2, then a3, a4, ... a8. The square right of a1 is b1, then c1, d1, ... h1.
The top-right square is h8.

(Note that on a real chessboard, all of the coordinates are flipped from Black’s viewpoint
because the board is rotated 180° from their view. In X-Decor-libre, this does not
matter because the board is always aligned the same way.)

In the list of moves, each line shows 3 things: Move number, white’s move, black’s move (if made).
The move number is a simple counter that increases after each move of *both* players, starting by 1.

In the notation, a move by a single player is called a “halfmove”. The two moves
of each White and then Black are called a “fullmove”.

#### Normal moves

Normally, a halfmove is written like this, in this order:

1. Symbol of moved piece (called “figurine”)
2. Start coordinates, a dash or cross, destination coordinates
3. “e.p.”, if it was an en passant capture -OR- symbol of piece to which a pawn was promoted to

For number 1, the symbol is only shown if the piece is not a pawn.
For number 2, the syntax for normal moves is like: “a1–a2”. This means the piece was moved from a1 to a2.
The dash means it was a normal move.
For capturing moves, the dash is replaced with a cross “×”. If it was an en passant capture, then
“ e.p” is appended, like so: “a5×b4 e.p.”.
If a pawn was promoted, the symbol of the new piece is appended.
The figurines are always of the color of the player.

Both halfmoves on a line are separated by spacing.

#### Castling

When a player castles, it is notated the following way:

* “0–0” for castling with the rook on file h (“kingside castling”)
* “0–0–0” for castling with the rook on file a (“queenside castling”)

#### Game completion

If the game completed, the end of the game showing the result is listed in a final separate line as:

* “1–0” if White won
* “0–1” if Black won
* “½–½” in case of a draw

#### Example

    1.  d2—d4    e7—e6
    2. ♔e1–d2   ♛d8–h4
    3.  d4–d5    e6×d5
    ...
    8. d8×d8♖   ♞b8-c6
    9. e2–e4	 d4×e3 e.p.

Explanation of the moves:

* 1.: First fullmove: White moves pawn from d2 to d4, Black moves pawn from e7 to e6
* 2.: Second fullmove: White moves king from e1 to d2, Black moves queen from d8 to h4
* 3.: Third fullmove: White moves pawn from d4 to d5, Black moves pawn from d6 to d5 and captures
* 8.: Eight fullmove: White moves pawn from d7 to d8, captures a piece and promotes it to rook, Black moves knight from b8 to c6
* 9.: Ninth fullmove: White moves pawn from e2 to e4, black moves pawn from d4 to e3 and captures en passant

#### Other symbols

Other symbols are not used. So there are no special symbols for check and checkmate and no comments for moves considered good or bad.
