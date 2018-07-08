module Ganalytics
  def self.to_html
    r = <<-EOF
<script>(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');ga('create', '%s', 'auto');ga('set', 'anonymizeIp', true);ga('send', 'pageview');</script>
EOF
    gakey = C[:ga]
    if not gakey
      Habitat.log :error, "google analytics key unset"
      return ""
    else
      r % gakey
    end
  end
end
