$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).ProviderPath
$lib = Join-Path $root "lib"

function Count-Matches([string]$pattern) {
  if (Get-Command rg -ErrorAction SilentlyContinue) {
    $result = rg -n $pattern $lib -g "*.dart" 2>$null
    if ($LASTEXITCODE -eq 1 -or $null -eq $result) { return 0 }
    return ($result | Measure-Object).Count
  }

  return (Get-ChildItem $lib -Recurse -File -Filter *.dart |
    Select-String -Pattern $pattern |
    Measure-Object).Count
}

$bloc = Count-Matches "BlocProvider|BlocBuilder|BlocConsumer|BlocListener|Cubit<|Bloc<"
$provider = Count-Matches "package:provider|(^|[^A-Za-z])ChangeNotifier([^A-Za-z]|$)|(^|[^A-Za-z])Consumer<|MultiProvider|ChangeNotifierProvider"
$riverpod = Count-Matches "flutter_riverpod|ConsumerWidget|WidgetRef|ProviderScope|NotifierProvider|FutureProvider|AsyncNotifierProvider"
$getx = Count-Matches "package:get/|Get\.|GetxController|Obx\("

Write-Host "State Management Audit"
Write-Host "Root: $root"
Write-Host ""
Write-Host "BLoC markers:     $bloc"
Write-Host "Provider markers: $provider"
Write-Host "Riverpod markers: $riverpod"
Write-Host "GetX markers:     $getx"
Write-Host ""

if ($provider -gt 0 -or $riverpod -gt 0 -or $getx -gt 0) {
  Write-Host "Migration status: mixed state management remains."
  Write-Host "Policy: new stateful feature code should use BLoC. Existing non-BLoC code should migrate feature by feature."
} else {
  Write-Host "Migration status: BLoC-only markers detected."
}
