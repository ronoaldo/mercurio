local m = mtimer
local S = m.translator
local esc = core.formspec_escape


-- Get a table line
--
-- The index determines the position from top within the current container and
-- is calculated to display the string in the correct position.
--
-- If `name` is a literal `'-'` then a line is printed at the position.
--
-- @param index    The numerical index for the line
-- @param name     Human-readable name for the variable
-- @param variable The variable like it’s used in the definition
-- @param value    The value to show for that variable
-- @return string  The created formspec string
mtimer.get_table_line = function (index, name, variable, value)
    local position = ((index-1) * 0.4)

    if name == '-' then
        return 'box[0,'..position..';+contentWidth,0.02;#ffffff]'
    end

    return table.concat({
        'label[0,'..position..';'..name..']',
        'label[4,'..position..';'..variable..']',
        'label[7,'..position..';'..value..']'
    }, ' ')
end


-- Get a button with icon
--
-- This function returns a fully formatted button with icon.
--
-- The provided ID is set as the button’s ID as well as the button’s image.
-- When set as image all colons are replaced with underscores and the id then
-- is formatted: `mtimer_ID.png` where `ID` is the given ID.
--
-- The definition table sets up the button’s parameters and is fully optional
-- even if it makes no sense.
--
-- definition = {
--   label = 'My Cool Button label'     or '',
--   width = 5,                         or 3,
--   image_size = 1,                    or 0.5,
--   colorize = color_table             or { use = false },
--   container = { left = 1, top = 1}   or pos_container
--   exit_button = true                 or false
-- }
--
-- The container table is used to position the button. If the `container` sub
-- table is unset, the following table is used, causing the button to be in the
-- top left corner of the formspec if not contained in another container.
--
-- pos_container = {
--   left = 0,
--   top = 0
-- }
--
-- Via the `colorize` sub-table it is possible to add colorization to the icon
-- shown oin the button. The table contains two entries to define the color and
-- the ratio for applying the color.
--
-- color_table = {
--   color = '#729fcf',
--   ratio = 200
-- }
--
-- If one of the values is omitted the value shown in the example is used.
--
-- @param id The ID for the button
-- @param definition The definition table as described
-- @return string The created button as formspec code
mtimer.get_icon_button = function (id, definition)
    local def = definition or {}

    -- Define colorization of button texture
    local t_table = type(def.colorize) == 'table'
    local t_values = t_table and def.colorize or { use = false }
    local t_color = t_values.color or '#729fcf'
    local t_ratio = t_values.ratio or 200
    local t_colorize = '^[colorize:'..t_color..':'..t_ratio

    -- Set button defaults
    local b_width = def.width or 3
    local i_size = def.image_size or 0.5
    local c_left = (def.container or {}).left or 0
    local c_top = (def.container or {}).top or 0

    -- Calculate button parameters
    local b_padding = i_size / 4
    local b_height = (b_padding * 2) + i_size
    local l_top_pos = i_size / 2
    local l_left_pos = i_size + (i_size / 4)

    -- Create/Return the button
    return (table.concat({
        'container[+containerLeft,+containerTop]',
        '  container[+buttonPadding,+buttonPadding]',
        '    image[0,0;+imageSize,+imageSize;+icon+colorize]',
        '    label[+labelLeftPos,+labelTopPos;+label]',
        '  container_end[]',
        '  +buttonType[0,0;+buttonWidth,+buttonHeight;+id;]',
        'container_end[]'
    }, ' '):gsub('%+%w+', {
        ['+containerLeft'] = c_left,
        ['+containerTop'] = c_top,
        ['+buttonType'] = def.exit_button==true and 'button_exit' or 'button',
        ['+buttonWidth'] = b_width,
        ['+buttonHeight'] = b_height,
        ['+buttonPadding'] = b_padding,
        ['+imageSize'] = i_size,
        ['+icon'] = 'mtimer_'..id:gsub(':', '_')..'.png',
        ['+colorize'] = t_values.use == false and '' or t_colorize,
        ['+labelLeftPos'] = l_left_pos,
        ['+labelTopPos'] = l_top_pos,
        ['+id'] = id,
        ['+label'] = esc(def.label or '')
    }))
end


-- Build the formspec frame
--
-- This function builds and displays a formspec based on the input.
--
-- The `id` is the usual formspec ID (for example `mymod:my_formspec`) and
-- has to be provided as a simple string all other parameters are provided via
-- the `def` table. The following table is an example.
--
-- {
--   title = 'Nice Title'     -- Automatically prefixed for orientation
--   prefix = '[Blarb] '      -- Optional title prefix
--   width = 8,               -- Optional width of the content container
--   height = 3,              -- Optional height of the content container
--   show_to = 'Playername',  -- Name of the player to show the formspec to
--   hide_buttons = true,     -- Optionally hide buttons
--   hide_title = true,       -- Optionally hide title
--   icon_size = 0.5,         -- Optionally set title icon size
--   content_offset = 0,      -- Optionally Offset content height position
--   formspec = {}            -- Table with formspec definition
-- }
--
-- When set the title is prefixed with the prefix value. If omitted “[mTimer] ”
-- is used. The example creates “[Blarb] Nice Title” as title. Translated
-- strings can be used here. The Title and prefix are “formspec-safe” so
-- strings that are formspec elements can be used to show them literal.
--
-- The default buttons can be hidden by adding `hide_buttons = true` to the
-- definition table. If omitted the buttons are shown. When not shown the
-- formspec size will be reduced by the amout of units the buttons would
-- have taken place. Same for the title with `hide_title = true`.
--
-- Some formspec elements do not properly start at 0,0 even if set so. The
-- `content_offset` attribute offsets the content vertically by the given
-- amount of units. Formspec height and button positions are adapted to the
-- given value.
--
-- The table entries for `formspec` are the usual formspec elements that
-- define what a formspec looks like. You can write all definition in one entry
-- or split the definition into multiple entries.
--
-- The definition defines the CONTENT of the formspec not the whole formspec so
-- you can easily start at 0,0 for your definition. The function automatically
-- places everything in relation to the formspec frame and default buttons.
--
-- The minimum formspec width and height are 10 units in width and 5 units in
-- height. So `width` and `height` can be omitted when all of your content fits
-- into the default size.
--
-- All formspec table entries can contain the following variables. Variables
-- start with a plus sign (+) and are read until any character that is not
-- a letter. Some variables are useless, some can be used quite well.
--
--   Variable Name      Value Type
--  --------------------------------------------------------------------------
--   +width                 Width of the formspec
--   +height                Height of the formspec
--   +iconSize              Size of the title icon
--   +labelPositionLeft     Position of the title label from left side
--   +labelPositionTop      Position of the title label from top
--   +linePosition          Position of the title separator line
--   +titleText             The text of the title label (the dialog title)
--   +titleIcon             The icon that is used in the dialog title
--   +contentPosition       Position of the actual content of the dialog
--   +buttonsPosition       The position where the buttons are
--
-- @param id The ID of the formspec
-- @param def  The definition table as described
-- @return string the constructed “frame”
mtimer.show_formspec = function (id, def)
    local title_text = def.title or ''
    local title_prefix = def.prefix or '[mTimer] '
    local content_offset = def.content_offset or 0
    local width = (def.width or 0) <= 10 and 10 or def.width
    local height = ((def.height or 0) <= 4 and 5 or def.height)+content_offset
    local icon_size = def.icon_size or 0.5
    local line_position = 0
    local buttons = ''
    local title = ''

    -- Set up title
    if def.hide_title ~= true then
        line_position = icon_size + 0.25
        content_offset = content_offset + line_position + (icon_size / 2) + 0.1
        height = height + content_offset + (icon_size / 2)
        title = table.concat({
            'container[0.25,0.25]',
            '  image[0,0;+iconSize,+iconSize;+titleIcon]',
            '  label[+labelPositionLeft,+labelPositionTop;+titleText]',
            '  box[0,+linePosition;+contentWidth,0.04;#ffffff]',
            'container_end[]'
        }, ' ')
    end

    -- Set up buttons
    if def.hide_buttons ~= true then
        height = height + 1
        buttons = table.concat({
            'container[0.25,+buttonsPosition]',
            'box[0,0;+contentWidth,0.04;#ffffff]',
            mtimer.get_icon_button('main_menu', {
                label = S('Main Menu'),
                width = 2.5, container = { top = 0.25 }
            }),
            'container[+contentWidth,0.25]',
            mtimer.get_icon_button('exit', {
                label = S('Exit'),
                exit_button = true,
                width = 2.5,
                container = { left = -2.5  }
            }),
            mtimer.get_icon_button('default', {
                label = S('Default'),
                width = 2.5,
                container = { left = -5.25  }
            }),
            'container_end[]', -- right side buttons
            'container_end[]' -- buttons
        }, ' ')
    end

    -- Build formspec
    local formspec = table.concat({
        'formspec_version[2]',
        'size[+width,+height]',
        title,
        'container[0.25,+contentPosition]',
        table.concat(def.formspec, ' '),
        'container_end[]',
        buttons
    }, ' '):gsub('%+%a+', {
        -- Formspec frame
        ['+width'] = width + 0.5,
        ['+height'] = height + 0.5,
        ['+contentWidth'] = width,
        ['+contentPosition'] = content_offset + 0.25,
        ['+iconSize'] = icon_size,
        -- Title-related settings
        ['+labelPositionLeft'] = icon_size + (icon_size / 4),
        ['+labelPositionTop'] = (icon_size / 2),
        ['+linePosition'] = line_position,
        ['+titleText'] = core.formspec_escape(title_prefix..title_text),
        ['+titleIcon'] = 'mtimer_'..id:gsub('mtimer:', '')..'.png',
        -- Buttons-related settings
        ['+buttonsPosition'] = height - 0.75,
    })

    -- Show formspec to the plauyer
    core.show_formspec(def.show_to, id, formspec)
end
