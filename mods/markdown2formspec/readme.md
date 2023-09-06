# Markdown2Formspec2

A super simple mod to covert markdown text into part of a formspec, specifically a `hypertext[]` element.

There are two functions provided:

```lua
md2f.md2f(x,y,w,h,markdown_string, settings)

md2f.md2ff(x,y,w,h,markdown_file, settings)
```

Both will result in correctly formatted hypertext elements that match markdown output.

### Settings

`settings` is an optional argument, and if present, can override any of the following default settings:

```lua
settings = {
    background_color = "#bababa25",
    font_color = "#FFF",
    heading_1_color = "#AFA",
    heading_2_color = "#FAA",
    heading_3_color = "#AAF",
    heading_4_color = "#FFA",
    heading_5_color = "#AFF",
    heading_6_color = "#FAF",
    heading_1_size = "26",
    heading_2_size = "24",
    heading_3_size = "22",
    heading_4_size = "20",
    heading_5_size = "18",
    heading_6_size = "16",
    code_block_mono_color = "#6F6",
    code_block_font_size = 14,
    mono_color = "#6F6",
    block_quote_color = "#FFA",
    tab_size = 1,
}
```

### Notes

1. All images will be centered
2. Images have extra syntax: `![w,h,(l or r)](image.png)` will result in an image scaled to those provided dimensions in pixels. 
    a. either l or r (optionally) floats the image left or right; no l or r means it will be centered
3. Headings are not auto-bolded or auto underlined