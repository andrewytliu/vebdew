# vebdew

A simple HTML5 slide generator.
Converts vew files (markdown like syntax) into HTML5 slides.

## Library used
- reveal.js: for the slides animation
- erubis: for the template
- htmlentities: for escaping the HTML

## Install
```
gem install vebdew
```

## Usage

Run `new` to create a new project, `generate` to convert all vew files in the project to HTML.  If you want to manually convert vew files, run `compile`.

```
Usage: vebdew COMMAND

Directory:
  - /vew           # Vew file, all the *.vew files will be compiled to html
                   # when running the `generate` command
    - template.erb # ERB template for the HTML
                   # @header meta tags and stylesheets
                   # @body   for the contents
                   # @footer for the javascripts
  - /css           # CSS styles
  - /js            # Javascript files
  - *.html         # Compiled html slides

Commands:
  new      # Create a new slide project
  generate # Generate slides for current directory  (shortcut: g)
  compile  # Compiles single file into HTML5 slides (shortcut: c)
           # [VEW FILE] [ERB TEMPLATE] [HTML SLIDE]
```

## Vew file syntax

### Head elements

```
:title <Page title>
:description <Description>
:author <Author Name>
:email <Author email>
:stylesheet_link_tag <File Path>
:javascript_include_tag <File Path>
```

- Head elements should be put on the top of the document.
- When any of the body elements are reached, head element is closed. That is, </head> is emitted and the Reveal.js body structure is established.

### !SLIDE, !ENDSLIDE

Marks the starting and ending of a slide (`<section>`) block.
Current slide is closed and a new slide is created when a `!SLIDE` token is encountered. Thus the ending is not mandatory.

### !STACK, !ENDSTACK
Marks the starting and ending of a stack (vertical slide stack). Rules are the same as `!SLIDE` and `!ENDSLIDE`.

### Code spans & code blocks
Code spans are wrapped by backticks. This emits a `<code>` block. Brackets (<, >) are escaped to &lt; and &gt; automatically. Escaptions are available in code spans.

Two types of code blocks are supported here. The code blocks wrapped in three or more backticks. This kind of code blocks emits `<code>...</code>`. The second kind is wrapped in three or more `~`s. This kind of code blocks emits `<script type="text/x-sample">...</script>`, which makes uses of sample.js.


### HTML elements
HTML tags are allowed in the syntax and is outputted as-is. Since we do not have any token that emits custom `<div>`, one can write `<div class="whatever" id="they-want"></div>` in vebdew directly.

### Headers
The following syntaxes are allowed:

```
# H1 Header
## H2 Header
...
###### H6 Header

H1 Header
=========

H2 Header
---------
```

### Horizontal Rules
Three or more `-` in a row with a leading and trailing blank line emits a `<hr>` tag.

### Paragraphs
Lines with leading and trailing blank lines, if not matched by any of the rules above, are treated as a paragraph. (p element).

### Attributes
CSS-Selector like decorators can be appended to any of the elements above. The syntax is like:

```
{:#ID.class[attr=value]}
```

Such examples are:

```
{:.inverted}
Introducing HTML
================
```

generating

```
<h1 class="inverted">Introducing HTML</h1>
```

Another example is:

```
`<input>` tag has an attribute called {:.attr[title=checkbox|radio|submit]}`type`
```

emits

```
<code>&lt;input&gt;</code> tag has an attribute called <code class="attr" title="checkbox|radio|submit">type</code>
```

## Copyright

Release under MIT license.

Copyright (c) 2012 Andrew Liu. See LICENSE.txt for
further details.

