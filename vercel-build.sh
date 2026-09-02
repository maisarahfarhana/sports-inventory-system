cat << 'EOF' > vercel-build.sh
#!/bin/bash
set -e

echo "=== Memuat turun Flutter SDK ==="
git clone https://github.com/flutter/flutter.git -b stable --depth 1 _flutter
export PATH="$PATH:`pwd`/_flutter/bin"

echo "=== Mengesahkan versi Flutter ==="
flutter --version

echo "=== Membina aplikasi untuk Web ==="
flutter build web --release
EOF