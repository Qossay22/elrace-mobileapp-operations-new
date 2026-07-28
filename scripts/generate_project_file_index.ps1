$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).ProviderPath
$outputName = "PROJECT_FILE_INDEX.md"
$outputPath = Join-Path $root $outputName

$excludedDirs = @(
  ".git",
  ".dart_tool",
  ".idea",
  ".vscode",
  "build",
  "dist",
  "coverage",
  "node_modules",
  "Pods",
  ".gradle",
  "DerivedData"
)

function Format-Size([long]$bytes) {
  if ($bytes -ge 1GB) { return "{0:N2} GB" -f ($bytes / 1GB) }
  if ($bytes -ge 1MB) { return "{0:N2} MB" -f ($bytes / 1MB) }
  if ($bytes -ge 1KB) { return "{0:N2} KB" -f ($bytes / 1KB) }
  return "$bytes B"
}

function Get-RelativeProjectPath([string]$fullPath) {
  $rootPath = $root
  if (-not $rootPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $rootPath += [System.IO.Path]::DirectorySeparatorChar
  }

  $rootUri = [System.Uri]::new($rootPath)
  $fileUri = [System.Uri]::new($fullPath)
  $relativeUri = $rootUri.MakeRelativeUri($fileUri)
  return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace("/", [System.IO.Path]::DirectorySeparatorChar)
}

function Get-Category([string]$path) {
  $p = $path.Replace("\", "/")
  switch -Regex ($p) {
    '^lib/' { return "Flutter app code" }
    '^test/' { return "Automated tests" }
    '^assets/' { return "App assets" }
    '^android/' { return "Android native project" }
    '^ios/' { return "iOS native project" }
    '^functions/' { return "Firebase Cloud Functions" }
    '^functions-liveness/' { return "Face liveness backend functions" }
    '^packages/' { return "Local package/plugin" }
    '^doc/' { return "Project documentation" }
    '^docs/' { return "Architecture/documentation notes" }
    '^templates/' { return "Code generation templates" }
    '^scripts/' { return "Developer/automation scripts" }
    '^config/' { return "Configuration examples" }
    default { return "Project root/configuration" }
  }
}

function Get-Purpose([string]$path, [string]$extension) {
  $p = $path.Replace("\", "/")
  $name = [System.IO.Path]::GetFileNameWithoutExtension($path)

  switch -Regex ($p) {
    '^lib/main\.dart$' { return "Flutter app entry point and startup wiring." }
    '^pubspec\.yaml$' { return "Flutter project manifest for packages, assets, and fonts." }
    '^pubspec\.lock$' { return "Pinned Dart/Flutter dependency versions." }
    '^analysis_options\.yaml$' { return "Dart analyzer and lint configuration." }
    '^firebase\.json$' { return "Firebase project configuration." }
    '^firestore\.rules$' { return "Firestore security rules." }
    '^android/.+AndroidManifest\.xml$' { return "Android app manifest, permissions, and components." }
    '^ios/.+Info\.plist$' { return "iOS app settings, metadata, and permissions." }
    '^functions/.+\.js$' { return "Firebase Cloud Functions JavaScript backend code." }
    '^functions-liveness/.+\.js$' { return "Backend function code for face liveness flows." }
    '^test/.+_test\.dart$' { return "Automated Flutter/Dart test for app behavior." }
    '^assets/i18n/.+\.json$' { return "Translation and UI text resource file." }
    '^assets/antispoof/' { return "Face anti-spoofing or liveness model/support file." }
    '^assets/.+\.(png|jpg|jpeg|gif|svg)$' { return "Image or icon asset used by the app UI." }
    '^assets/.+\.(mp3|mp4)$' { return "Audio or video media asset used by the app." }
    '^assets/.+\.tflite$' { return "TensorFlow Lite machine-learning model for on-device use." }
    '^doc/.+\.md$' { return "Feature documentation, requirements, plan, or task notes." }
    '^docs/.+\.txt$' { return "Text notes or audit output." }
    '^templates/.+\.tmpl$' { return "Code generation template." }
    '^scripts/.+\.ps1$' { return "PowerShell automation script for project maintenance." }
    '^scripts/.+\.sh$' { return "Shell automation script for project maintenance." }
  }

  switch ($extension.ToLowerInvariant()) {
    ".dart" {
      switch -Regex ($name) {
        'bloc$' { return "BLoC logic for state and event handling." }
        'state$' { return "BLoC/Cubit state definitions." }
        'event$' { return "BLoC event definitions." }
        'screen$|page$' { return "Flutter screen or page UI." }
        'widget$' { return "Reusable Flutter UI widget." }
        'model$|models$' { return "Data model and JSON/DTO mapping." }
        'entity$|entities$' { return "Domain entity definitions." }
        'repository$|repository_impl$' { return "Repository layer for reading/writing data." }
        'datasource$|remote_datasource$' { return "Remote/local data source or API access." }
        'service$' { return "Service helper for business logic or integration." }
        'usecase$' { return "Domain use case." }
        'theme$' { return "Feature-specific UI theme and styling constants." }
        default { return "Dart file in the Flutter app; purpose follows its folder and name." }
      }
    }
    ".yaml" { return "YAML configuration file." }
    ".json" { return "JSON data or configuration file." }
    ".gradle" { return "Gradle build configuration for Android." }
    ".kt" { return "Native Android Kotlin code." }
    ".swift" { return "Native iOS Swift code." }
    ".m" { return "Objective-C iOS integration code." }
    ".h" { return "Objective-C/C header for iOS integration." }
    ".plist" { return "Apple plist configuration file." }
    ".md" { return "Markdown documentation file." }
    ".txt" { return "Plain text notes or configuration file." }
    ".png" { return "PNG image asset." }
    ".jpg" { return "JPG image asset." }
    ".jpeg" { return "JPEG image asset." }
    ".svg" { return "SVG icon or vector asset." }
    ".gif" { return "Animated GIF or visual asset." }
    ".mp3" { return "MP3 audio asset." }
    ".mp4" { return "MP4 video asset." }
    ".tflite" { return "TensorFlow Lite model for on-device execution." }
    ".py" { return "Python automation script or API example." }
    ".js" { return "JavaScript code or Node.js configuration." }
    ".lock" { return "Dependency lock file." }
    ".php" { return "PHP helper/page related to QR or web integration." }
    default { return "Project file; use its path and extension to locate its role." }
  }
}

function Escape-Pipe([string]$value) {
  return $value.Replace("|", "\|").Replace("`r", " ").Replace("`n", " ")
}

$files = Get-ChildItem -Path $root -Recurse -File -Force |
  Where-Object {
    $relative = Get-RelativeProjectPath $_.FullName
    $parts = $relative -split '[\\/]'
    foreach ($part in $parts) {
      if ($excludedDirs -contains $part) { return $false }
    }
    return $true
  } |
  Sort-Object FullName

$totalBytes = ($files | Measure-Object Length -Sum).Sum
$generatedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Project File Index")
$lines.Add("")
$lines.Add("Quick reference for the project files: path, size, category, and a short responsibility note.")
$lines.Add("")
$lines.Add("- Generated at: $generatedAt")
$lines.Add("- Root: $root")
$lines.Add("- Indexed files: $($files.Count)")
$lines.Add("- Indexed total size: $(Format-Size ([long]$totalBytes))")
$lines.Add("- Skipped generated/heavy folders: $($excludedDirs -join ', ')")
$lines.Add("")
$lines.Add("> Note: descriptions are inferred from file path, name, and extension. Regenerate after major updates with: powershell -ExecutionPolicy Bypass -File .\scripts\generate_project_file_index.ps1")
$lines.Add("")
$lines.Add("## Quick Map")
$lines.Add("")
$files |
  Group-Object { Get-Category (Get-RelativeProjectPath $_.FullName) } |
  Sort-Object Name |
  ForEach-Object {
    $groupBytes = ($_.Group | Measure-Object Length -Sum).Sum
    $lines.Add("- **$($_.Name)**: $($_.Count) files, $(Format-Size ([long]$groupBytes))")
  }
$lines.Add("")
$lines.Add("## Files")
$lines.Add("")
$lines.Add("| Path | Size | Category | Responsibility |")
$lines.Add("|---|---:|---|---|")

foreach ($fileInfo in $files) {
  $relative = Get-RelativeProjectPath $fileInfo.FullName
  $relative = $relative.Replace("\", "/")
  $extension = [System.IO.Path]::GetExtension($relative)
  $category = Get-Category $relative
  $purpose = Get-Purpose $relative $extension
  $safePath = Escape-Pipe $relative
  $safeCategory = Escape-Pipe $category
  $safePurpose = Escape-Pipe $purpose
  $lines.Add("| $safePath | $(Format-Size $fileInfo.Length) | $safeCategory | $safePurpose |")
}

[System.IO.File]::WriteAllLines($outputPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Host "Generated $outputName with $($files.Count) files."
