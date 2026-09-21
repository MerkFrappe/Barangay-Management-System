param(
    [switch]$Deploy,
    [switch]$EnableDemoAdminBypass
)

$secureKey = Read-Host 'Paste the restricted WEB Gemini API key' -AsSecureString
$keyPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)

try {
    $env:GEMINI_API_KEY = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($keyPointer)
    $buildArgs = @('build', 'web', '--release', "--dart-define=GEMINI_API_KEY=$env:GEMINI_API_KEY")
    if ($EnableDemoAdminBypass) {
        $buildArgs += '--dart-define=ENABLE_DEMO_ADMIN_BYPASS=true'
    }
    flutter @buildArgs
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    if ($Deploy) {
        firebase deploy --only hosting --project bms-system-2499a
        exit $LASTEXITCODE
    }
    Write-Host "Web build ready: $([System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\build\web')))" -ForegroundColor Green
}
finally {
    if ($keyPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($keyPointer)
    }
    Remove-Item Env:GEMINI_API_KEY -ErrorAction SilentlyContinue
}
