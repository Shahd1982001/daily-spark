"""Publish the review gallery alongside a cache-safe Flutter bootstrap.

Existing Flutter service workers may keep serving old app files after a deploy.
New fingerprinted script filenames bypass both those old cache manifests and
GitHub Pages' 10-minute HTTP cache. The separate refresh.html entry point is
not in old worker manifests and lets an already-controlled browser reach the
new bootstrap without deleting the user's local data.
"""
import hashlib
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
index_path = root / 'index.html'
bootstrap_path = root / 'flutter_bootstrap.js'
main_path = root / 'main.dart.js'
version = hashlib.sha256(main_path.read_bytes()).hexdigest()[:16]

# Use a different path, not just a query string: old service workers often
# normalize query parameters before consulting their asset cache.
(root / f'main.{version}.dart.js').write_bytes(main_path.read_bytes())
bootstrap = bootstrap_path.read_text()
bootstrap, replacements = re.subn(r'"mainJsPath"\s*:\s*"main\.dart\.js"',
    f'"mainJsPath":"main.{version}.dart.js"', bootstrap, count=1)
if replacements != 1:
    raise RuntimeError('Flutter bootstrap did not contain expected mainJsPath')
# Flutter's default bootstrap re-registers a worker even after index removes
# it. Disable registration; this review build does not promise offline use.
bootstrap, replacements = re.subn(
    r'_flutter\.loader\.load\(\{\s*serviceWorkerSettings\s*:\s*\{.*?\}\s*\}\);',
    '_flutter.loader.load();', bootstrap, count=1, flags=re.S)
if replacements != 1:
    raise RuntimeError('Flutter bootstrap worker settings were not found')
bootstrap_name = f'flutter_bootstrap.{version}.js'
(root / bootstrap_name).write_text(bootstrap)

s = index_path.read_text()
if '<!-- no-sw -->' not in s:
    kill = '''  <!-- no-sw -->
  <script>
    // Remove previous Flutter workers; keep localStorage and user data intact.
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations()
        .then(function (rs) { rs.forEach(function (r) { r.unregister(); }); })
        .catch(function () {});
    }
  </script>
'''
    s = s.replace('</head>', kill + '</head>', 1)
s, replacements = re.subn(r'<script src="flutter_bootstrap\.js(?:\?[^\"]*)?"([^>]*)>',
    f'<script src="{bootstrap_name}"' + r'\1>', s, count=1)
if replacements != 1:
    raise RuntimeError('Flutter index bootstrap script was not found')
index_path.write_text(s)
(root / 'refresh.html').write_text(s)
print(f'patched: {version}')
