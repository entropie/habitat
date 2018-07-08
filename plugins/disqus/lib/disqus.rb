module Disqus
  def self.to_html
    ret = <<-DOC
<div id="disqus-wrapper">
<div class="container grid-xl">
<div class="columns">
<div class="col-8 col-mx-auto">
<div id="disqus_thread"></div>
</div></div></div></div>
<script>(function() {
var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
dsq.src = '//' + '%s' + '.disqus.com/embed.js';
(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);})();</script>
DOC
    ident = C[:disqus_ident]
    unless ident
      Habitat.log :error, "config[:disqus_ident] unset"
      return ""
    end
    ret % ident
  end
end
