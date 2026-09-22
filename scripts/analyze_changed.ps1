param(
  [switch]$Full,
  [string[]]$TargetPath
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).ProviderPath
$originalPriority = [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass

function Get-ChangedDartFiles {
  $paths = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
  )

  $gitQueries = @(
    @("diff", "--name-only", "--diff-filter=ACMR", "--", "*.dart"),
    @("diff", "--cached", "--name-only", "--diff-filter=ACMR", "--", "*.dart"),
    @("ls-files", "--others", "--exclude-standard", "--", "*.dart")
  )

  foreach ($query in $gitQueries) {
    $results = & git @query
    if ($LASTEXITCODE -ne 0) {
      throw "Git failed while collecting changed Dart files."
    }
    foreach ($result in $results) {
      if (-not [string]::IsNullOrWhiteSpace($result)) {
        [void]$paths.Add($result.Trim())
      }
    }
  }

  return @($paths | Where-Object {
      $_.EndsWith(".dart", [System.StringComparison]::OrdinalIgnoreCase) -and
      (Test-Path -LiteralPath (Join-Path $repoRoot $_) -PathType Leaf)
    } | Sort-Object)
}

Push-Location $repoRoot
try {
  if (-not (Test-Path -LiteralPath ".dart_tool/package_config.json")) {
    throw "Dependencies are not resolved. Run 'flutter pub get' once first."
  }

  if ($Full -and $TargetPath) {
    throw "Use either -Full or -TargetPath, not both."
  }

  if ($Full) {
    $analysisTargets = @()
    Write-Host "Running full project analysis. Close extra VS Code Flutter windows for best performance."
  } elseif ($TargetPath) {
    $analysisTargets = @($TargetPath)
  } else {
    $analysisTargets = @(Get-ChangedDartFiles)
    if ($analysisTargets.Count -eq 0) {
      Write-Host "No changed Dart files to analyze."
      exit 0
    }
  }

  $invalidTargets = @($analysisTargets | Where-Object {
      -not (Test-Path -LiteralPath $_)
    })
  if ($invalidTargets.Count -gt 0) {
    throw "Analysis target not found: $($invalidTargets -join ', ')"
  }

  $arguments = @(
    "analyze",
    "--no-pub",
    "--no-fatal-infos",
    "--no-fatal-warnings"
  ) + $analysisTargets

  [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = "BelowNormal"
  $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
  if ($analysisTargets.Count -gt 0) {
    Write-Host "Analyzing $($analysisTargets.Count) changed target(s) at below-normal CPU priority..."
  }

  & flutter @arguments
  $analysisExitCode = $LASTEXITCODE
  $stopwatch.Stop()
  Write-Host ("Analysis finished in {0:N1}s with exit code {1}." -f `
      $stopwatch.Elapsed.TotalSeconds, $analysisExitCode)
  exit $analysisExitCode
} finally {
  [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = $originalPriority
  Pop-Location
}
