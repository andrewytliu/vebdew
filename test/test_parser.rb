require 'vebdew'
require 'bacon'

describe 'Parser' do
  Q_AND_A = [[["!SLIDE\n", "a\n", "!ENDSLIDE\n"],
              ["<section>","<p>a</p>","</section>"]],
             [["!STACK\n", "!SLIDE\n", "!ENDSTACK\n"],
              ["<section>", "<section>", "</section>", "</section>"]],
             [["~~~", "qqq", "~~~"],
              ["<script type='text/x-sample'>", "qqq", "</script>"]],
             [["---"],
              ["<hr>"]],
             [["abc", "---"],
              ["<h2>abc</h2>"]],
             [["abc", "==="],
              ["<h1>abc</h1>"]],
             [["### qqq"],
              ["<h3>qqq</h3>"]],
             [["* qqq", "* www"],
              ["<ul>", "<li>qqq</li>", "<li>www</li>", "</ul>"]],
             [["{:#def.abc[data=you]}", "papa"],
              ["<p class='abc' id='def' data='you'>papa</p>"]],
             [["{:.pre}`aloha`"],
              ["<p><code class='pre'>aloha</code></p>"]],
             [["![a.jpg](haha)"],
              ["<p><img src='a.jpg' alt='haha'></p>"]],
             [["![b.jpg]"],
              ["<p><img src='b.jpg'></p>"]],
             [["[google.com](you)"],
              ["<p><a href='google.com'>you</a></p>"]]
            ]

  for q, a in Q_AND_A
    it "should parse #{q}" do
      parser = Vebdew::Parser.new(q)
      parser.body.should == a
    end
  end
end
