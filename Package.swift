// swift-tools-version: 6.2

import PackageDescription

// MARK: - Platform Configuration
//
// mbedTLS provides cryptography, X.509, and TLS. This package builds the full
// library using the default mbedtls_config.h with pthread threading on POSIX.
//
// Platform support:
// - Apple (macOS, iOS, tvOS, watchOS, visionOS): Full support
// - Linux: Full support
// - Android: Full support
// - Windows: Full support (no pthread; use MBEDTLS_THREADING_ALT if needed)

let apple: [Platform] = [.iOS, .macOS, .tvOS, .visionOS, .watchOS]

var sourcePaths: [String] = []
var excludedPaths: [String] = []
var cSettings: [CSetting] = []
var linkerSettings: [LinkerSetting] = []

// MARK: - Core

sourcePaths += [
  "library",
]

excludedPaths += [
  // Directories
  "programs",
  "tests",
  "docs",
  "scripts",
  "cmake",
  "configs",
  "doxygen",
  "visualc",
  "framework",
  "pkgconfig",
  "ChangeLog.d",
  ".github",
  // Files
  "CMakeLists.txt",
  "Makefile",
  "DartConfiguration.tcl",
  ".gitignore",
  ".gitattributes",
  ".gitmodules",
  ".globalrc",
  ".mypy.ini",
  ".pylintrc",
  ".readthedocs.yaml",
  ".travis.yml",
  ".uncrustify.cfg",
  "BRANCHES.md",
  "BUGS.md",
  "ChangeLog",
  "CONTRIBUTING.md",
  "dco.txt",
  "LICENSE",
  "README.md",
  "SECURITY.md",
  "SUPPORT.md",
  // include/
  "include/.gitignore",
  "include/CMakeLists.txt",
  // library/
  "library/CMakeLists.txt",
  "library/Makefile",
  "library/.gitignore",
  // 3rdparty/
  "3rdparty/.gitignore",
  "3rdparty/CMakeLists.txt",
  "3rdparty/Makefile.inc",
]

cSettings += [
  .headerSearchPath("include"),
  .headerSearchPath("library"),
]

// MARK: - Everest (Curve25519)

sourcePaths += [
  "3rdparty/everest/library",
]

excludedPaths += [
  "3rdparty/everest/.gitignore",
  "3rdparty/everest/CMakeLists.txt",
  "3rdparty/everest/Makefile.inc",
  "3rdparty/everest/README.md",
  // #included by Hacl_Curve25519_joined.c (avoid duplicate symbols)
  "3rdparty/everest/library/Hacl_Curve25519.c",
  "3rdparty/everest/library/kremlib",
  "3rdparty/everest/library/legacy",
]

cSettings += [
  .headerSearchPath("3rdparty/everest/include"),
  .headerSearchPath("3rdparty/everest/include/everest"),
  .headerSearchPath("3rdparty/everest/include/everest/kremlib"),
]

// MARK: - P256-M

sourcePaths += [
  "3rdparty/p256-m",
]

excludedPaths += [
  "3rdparty/p256-m/.gitignore",
  "3rdparty/p256-m/CMakeLists.txt",
  "3rdparty/p256-m/Makefile.inc",
  "3rdparty/p256-m/README.md",
  "3rdparty/p256-m/p256-m/README.md",
]

cSettings += [
  .headerSearchPath("3rdparty/p256-m"),
  .headerSearchPath("3rdparty/p256-m/p256-m"),
]

// MARK: - Threading

cSettings += [
  .define("MBEDTLS_THREADING_C", .when(platforms: apple + [.android, .linux])),
  .define("MBEDTLS_THREADING_PTHREAD", .when(platforms: apple + [.android, .linux])),
]

linkerSettings += [
  .linkedLibrary("pthread", .when(platforms: [.android, .linux])),
]

// MARK: - Entropy

// Windows uses BCryptGenRandom; Unix uses /dev/urandom or getrandom()
linkerSettings += [
  .linkedLibrary("bcrypt", .when(platforms: [.windows])),
]

// MARK: - Networking

linkerSettings += [
  .linkedLibrary("ws2_32", .when(platforms: [.windows])),
]

// MARK: - Platform-Specific Compiler Flags

// GNU extensions for Linux/Android
cSettings += [
  .define("_GNU_SOURCE", .when(platforms: [.android, .linux])),
]

// Windows-specific defines
cSettings += [
  .define("_WIN32_WINNT", to: "0x0600", .when(platforms: [.windows])),
  .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
]

// MARK: - Package Definition

let package = Package(
  name: "swift-mbedtls",
  products: [
    .library(name: "mbedtls", targets: ["mbedtls"])
  ],
  targets: [
    .target(
      name: "mbedtls",
      path: ".",
      exclude: excludedPaths,
      sources: sourcePaths,
      publicHeadersPath: "include",
      cSettings: cSettings,
      linkerSettings: linkerSettings
    ),
  ]
)
