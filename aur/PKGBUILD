# Maintainer: Luis Martinez <luis dot martinez at disroot dot org>

pkgname=forgit
pkgver=23.03.0
pkgrel=1
pkgdesc="Utility tool powered by fzf for using git interactively"
arch=('any')
url="https://github.com/wfxr/forgit"
license=('MIT')
groups=('fish-plugins' 'zsh-plugins')
depends=('bash' 'fzf')
optdepends=(
	'zsh: supported shell'
	'fish: supported shell'
	'git-delta: human readable diffs'
	'diff-so-fancy: human readable diffs'
	'bat: syntax highlighting for .gitignore'
	'emoji-cli: emoji support for git log')
install="$pkgname.install"
source=("$pkgname-$pkgver.tar.gz::$url/archive/$pkgver.tar.gz")
sha256sums=('f64d0a5e0d4064ce9f60825383cca84a5735b3962e6d6c984f13cf8c0b199043')

package() {
	cd "$pkgname-$pkgver"

	# wrapper script
	install -Dv bin/git-forgit -t "$pkgdir/usr/bin/"

	# zsh install
	install -Dvm644 forgit.plugin.zsh -t "$pkgdir/usr/share/zsh/plugins/$pkgname/"

	# fish install
	install -Dvm644 conf.d/forgit.plugin.fish -t "$pkgdir/usr/share/fish/vendor_conf.d/"

	# docs
	install -Dvm644 README.md -t "$pkgdir/usr/share/doc/$pkgname/"

	# license
	install -Dvm644 LICENSE -t "$pkgdir/usr/share/licenses/$pkgname/"
}

