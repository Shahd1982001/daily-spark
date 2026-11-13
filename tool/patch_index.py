import re, time, sys
p = sys.argv[1] + '/index.html'
s = open(p).read()
marker = '<!-- no-sw -->'
if marker not in s:
    kill = """  <!-- no-sw -->
  <script>
    // Always serve the freshest build: drop any legacy service worker cache.
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations()
        .then(function (rs) { rs.forEach(function (r) { r.unregister(); }); })
        .catch(function () {});
    }
  </script>
"""
    s = s.replace('</head>', kill + '</head>', 1)
    v = str(int(time.time()))
    s = re.sub(r'<script src="flutter_bootstrap\.js"([^>]*)>',
               '<script src="flutter_bootstrap.js?v=' + v + r'"\1>', s)
    open(p, 'w').write(s)
print('patched')
