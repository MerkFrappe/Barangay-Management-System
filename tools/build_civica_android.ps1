param(
    [switch]$EnableDemoAdminBypass
)

$secureKey = Read-Host 'Paste the restricted ANDROID Gemini API key' -AsSecureString
$oneSignalAppId = Read-Host 'Optional: paste a different OneSignal App ID (press Enter to use Civica production notifications)'
# The current release build uses Android's debug signing configuration.
# If you later create a separate release keystore, replace this SHA-1 with
# that keystore's fingerprint and update the Android API-key restriction.
$certificateSha1 = 'CA:44:A8:53:F7:8A:9B:10:8D:49:61:66:2E:D5:EC:DD:EC:B4:66:19'
$keyPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)

try {
    $env:GEMINI_API_KEY = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($keyPointer)
    $buildArgs = @('build', 'apk', '--release', "--dart-define=GEMINI_API_KEY=$env:GEMINI_API_KEY", "--dart-define=GEMINI_ANDROID_CERT_SHA1=$certificateSha1")
    if (-not [string]::IsNullOrWhiteSpace($oneSignalAppId)) {
        $buildArgs += "--dart-define=ONESIGNAL_APP_ID=$oneSignalAppId"
    }
    if ($EnableDemoAdminBypass) {
        $buildArgs += '--dart-define=ENABLE_DEMO_ADMIN_BYPASS=true'
    }
    flutter @buildArgs
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    $apkPath = Join-Path $PSScriptRoot '..\build\app\outputs\flutter-apk\app-release.apk'
    if (-not (Test-Path -LiteralPath $apkPath)) {
        Write-Error "Build completed but APK was not found at $apkPath"
        exit 1
    }
    Write-Host "APK ready: $([System.IO.Path]::GetFullPath($apkPath))" -ForegroundColor Green
}
finally {
    if ($keyPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($keyPointer)
    }
    Remove-Item Env:GEMINI_API_KEY -ErrorAction SilentlyContinue
}
