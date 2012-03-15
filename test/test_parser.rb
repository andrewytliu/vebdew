require 'vebdew'
require 'bacon'

describe 'Parser' do
  Q_AND_A = [[["!SLIDE\n", "a\n", "!ENDSLIDE\n"],
              ["<section>","<p>a</p>","</section>"]],
             [["!STACK\n", "!SLIDE\n", "!ENDSTACK\n"],
              ["<section>", "<section>", "</section>", "</section>"]],
             [["~~~", "  <tag>AS-IS</tag>", "~~~"],
              ["<script type=\"text/x-sample\">", "  <tag>AS-IS</tag>", "</script>"]],
             [["```\n", "  if(a)\n", "# unindented comment\n", "    b\n", "    <tag>\n", "  end\n", "```\n"],
              ["<pre><code><!--", "-->if(a)\n# unindented comment\n  b\n  &lt;tag&gt;\nend\n<!--", "--></code></pre>"]],
             [["---"],
              ["<hr>"]],
             [["           \n",  "---"],
              ["<hr>"]],
             [["abc", "---"],
              ["<h2>abc</h2>"]],
             [["abc", "==="],
              ["<h1>abc</h1>"]],
             [["### qqq"],
              ["<h3>qqq</h3>"]],
             [["Yooo\n", "### qqq\n", "Tooo"],
              ["<p>Yooo</p>", "<h3>qqq</h3>", "<p>Tooo</p>"]],
             [["* qqq", "* www"],
              ["<ul>", "<li>qqq</li>", "<li>www</li>", "</ul>"]],
             [["![a.jpg](haha)"],
              ['<p><img src="a.jpg" alt="haha"></p>']],
             [["![b.jpg]"],
              ['<p><img src="b.jpg"></p>']],
             [["[google.com](you)"],
              ['<p><a href="google.com">you</a></p>']],
             [['[google.com](you\(\))'],
              ['<p><a href="google.com">you()</a></p>']],
             [["[http://google.com](you)"],
              ['<p><a href="http://google.com" target="_blank">you</a></p>']],

             # attributes
             [["{:.pre}`aloha`"],
              ['<p><code class="pre">aloha</code></p>']],
             [["{:#def.abc[data=you]}", "papa"],
              ['<p class="abc" id="def" data="you">papa</p>']],
             [["{:#id.test[data=you]}", "~~~", "lalala", "~~~"],
              ['<script type="text/x-sample" class="test" id="id" data="you">',
               'lalala','</script>']],
             [["{:#id.test[data=you]}", "abc", "==="],
              ['<h1 class="test" id="id" data="you">abc</h1>']],
             [["{:#id.test[data=you]}", "abc", "---"],
              ['<h2 class="test" id="id" data="you">abc</h2>']],
             [["{:.demo}", "lala"],
              ['<p class="demo">lala</p>']],
             [["{:.class#id}","!SLIDE", "a\n", "!ENDSLIDE\n"],
              ["<section class=\"class\" id=\"id\">","<p>a</p>","</section>"]],
             [["", "{:.def}", "abc"],
              [nil, '<p class="def">abc</p>']],
             [["", "{:.sld}", "!SLIDE"],
              [nil, '<section class="sld">', '</section>']],
             [["abc", "{:.la}", "oop"],
              ["<p>abc</p>", '<p class="la">oop</p>']],
             [["```", '# cmt', "```"],
              ["<pre><code><!--", '--># cmt<!--', "--></code></pre>"]],

             # checks whether buffer clears
             [[
                '!SLIDE',
                '{:.demo}',
                '~~~',
                '  should_have_demo_class',
                '~~~',
                '!SLIDE',
                '~~~',
                '  should_not_have_demo_class',
                '~~~'
              ],
              [
                '<section>',
                '<script type="text/x-sample" class="demo">',
                '  should_have_demo_class',
                '</script>',
                '</section>',
                '<section>',
                '<script type="text/x-sample">',
                '  should_not_have_demo_class',
                '</script>',
                '</section>'
              ]],
              # breaking
              [["{:.klass}![img](alt)\n\n", "* a\n"],
               ['<p><img src="img" alt="alt" class="klass"></p>', "<ul>","<li>a</li>", "</ul>"]],
            ]


  for q, a in Q_AND_A
    it "should parse #{q}" do
      parser = Vebdew::Parser.new(q)
      parser.body.should == a
    end
  end
end
