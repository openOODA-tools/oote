Name:           oote
Version:        0.1.0
Release:        1%{?dist}
Summary:        Sovereign unified theming engine for openOODA
License:        Apache-2.0
URL:            https://github.com/openOODA-tools/oote
Source0:        oote-linux-x86_64
Source1:        oote-uninstall
BuildArch:      x86_64
Requires:       glibc

%description
oote is the sovereign unified theming and color styling engine for the
openOODA ecosystem. It establishes a 39-token semantic taxonomy spanning
UI chrome, status, syntax, diffs, search hits, shell prompts, and logs,
with 25 built-in themes (monthly and seasonal holidays), dual light/dark
variants, customizable border box-drawing sets, expressive ASCII mascots,
and global configuration persistence.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oote
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oote-uninstall

%files
/usr/bin/oote
/usr/bin/oote-uninstall

%changelog
* Tue Oct 06 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Sovereign release: 12 monthly themes, holiday themes, light/dark dual modes, ASCII mascots & emotions, border styles, and global sync.
