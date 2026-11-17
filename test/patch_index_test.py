"""Regression tests for deployment cache invalidation (stdlib unittest)."""
import hashlib
import pathlib
import subprocess
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parents[1] / 'tool' / 'patch_index.py'

class PatchIndexTest(unittest.TestCase):
    def test_fingerprints_js_and_does_not_register_worker(self):
        with tempfile.TemporaryDirectory() as d:
            root = pathlib.Path(d)
            source = b'console.log("new app");'
            version = hashlib.sha256(source).hexdigest()[:16]
            (root / 'main.dart.js').write_bytes(source)
            (root / 'index.html').write_text('<head></head><body><script src="flutter_bootstrap.js" async></script></body>')
            (root / 'flutter_bootstrap.js').write_text(
                '_flutter.buildConfig = {"builds":[{"mainJsPath":"main.dart.js"}]};\n'
                '_flutter.loader.load({ serviceWorkerSettings: { serviceWorkerVersion: "123" } });')
            subprocess.run(['python3', str(SCRIPT), d], check=True)
            page = (root / 'refresh.html').read_text()
            self.assertEqual(page, (root / 'index.html').read_text())
            self.assertIn(f'flutter_bootstrap.{version}.js', page)
            self.assertIn('unregister()', page)
            boot = (root / f'flutter_bootstrap.{version}.js').read_text()
            self.assertIn(f'main.{version}.dart.js', boot)
            self.assertIn('_flutter.loader.load();', boot)
            self.assertNotIn('serviceWorkerSettings', boot)
            self.assertEqual((root / f'main.{version}.dart.js').read_bytes(), source)

if __name__ == '__main__':
    unittest.main()
