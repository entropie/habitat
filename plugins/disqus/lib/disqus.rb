module Disqus
  def self.to_html
    ret = <<-DOC
<div id="disqus_thread"></div>
(function() {
var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
dsq.src = '//' + '%s' + '.disqus.com/embed.js';
(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);})();
DOC
    ident = C[:disqus_ident]
    unless ident
      Habitat.log :error, "config[:disqus_ident] unset"
      return ""
    end
    ret % ident
  end
end
