# Run from any directory. Example: .\sim\run_regression.ps1 -Tests fifo_wrap_test
# With no arguments, compile once, run seven directed tests, then random tests
# with reproducible seeds. Example: -Tests fifo_random_test -RandomSeeds 42
# Exit 0 means every requested test passed; compile/tool/UVM failures exit 1.
# Dot-source this file to load the log checker without running simulations.
[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z_][A-Za-z0-9_]*$')]
    [string[]]$Tests = @(
        'fifo_test', 'fifo_order_test', 'fifo_boundary_test',
        'fifo_simultaneous_test', 'fifo_wrap_test', 'fifo_reset_test', 'fifo_burst_test',
        'fifo_random_test'
    ),
    [ValidateRange(1, 2147483647)]
    [int[]]$RandomSeeds = @(1, 42, 2026),
    [string]$Simulator = 'vsim'
)

function Get-FifoLogVerdict {
    param([string]$LogPath, [string]$TestName, [int]$ToolExitCode, [int]$Seed = 0)

    $reasons = [System.Collections.Generic.List[string]]::new()
    $errorCount = $null
    $fatalCount = $null
    if ($ToolExitCode -ne 0) { $reasons.Add("Simulator exit code $ToolExitCode") }
    if (-not (Test-Path -LiteralPath $LogPath)) {
        $reasons.Add('Missing simulation log')
    } else {
        $logText = Get-Content -Raw -LiteralPath $LogPath
        $selectedPattern = 'Running test ' + [regex]::Escape($TestName) + '\.\.\.'
        if ($logText -notmatch $selectedPattern) { $reasons.Add('Requested test did not start') }
        if ($Seed -gt 0 -and $logText -notmatch ('(?m)^#\s*FIFO_RANDOM_SEED=' + $Seed + '\s*$')) {
            $reasons.Add('Requested seed was not configured')
        }
        if ($logText -notmatch '(?m)^#\s*FINAL PASS\s*$') { $reasons.Add('Missing FINAL PASS') }
        if ($logText -match '(?m)^#\s*FINAL FAIL\s*$') { $reasons.Add('FINAL FAIL reported') }
        if ($logText -match '(?m)^#\s*\*\*\s+(Error|Fatal):') { $reasons.Add('Simulator diagnostic error') }
        if ($logText -match '(?m)^#\s*UVM_(ERROR|FATAL)\s+[^\s:]') { $reasons.Add('UVM failure reported') }
        $errorMatches = [regex]::Matches($logText, '(?m)^#\s*UVM_ERROR\s*:\s*(\d+)\s*$')
        $fatalMatches = [regex]::Matches($logText, '(?m)^#\s*UVM_FATAL\s*:\s*(\d+)\s*$')
        if ($errorMatches.Count -eq 0 -or $fatalMatches.Count -eq 0) {
            $reasons.Add('Missing UVM report summary')
        } else {
            $errorCount = ($errorMatches | ForEach-Object { [int]$_.Groups[1].Value } | Measure-Object -Maximum).Maximum
            $fatalCount = ($fatalMatches | ForEach-Object { [int]$_.Groups[1].Value } | Measure-Object -Maximum).Maximum
            if ($errorCount -ne 0 -or $fatalCount -ne 0) { $reasons.Add('Nonzero UVM error/fatal count') }
        }
    }
    [pscustomobject]@{
        Test = $TestName
        Seed = $(if ($Seed -gt 0) { $Seed } else { $null })
        Status = $(if ($reasons.Count -eq 0) { 'PASS' } else { 'FAIL' })
        ExitCode = $ToolExitCode
        Errors = $errorCount
        Fatals = $fatalCount
        Reason = $reasons -join '; '
        Log = $LogPath
    }
}

function ConvertTo-FifoTclWord {
    param([string]$Value)
    '"' + $Value.Replace('\', '/').Replace('$', '\$').Replace('[', '\[').Replace(']', '\]').Replace('"', '\"').Replace("`r", '\r').Replace("`n", '\n') + '"'
}

function Invoke-FifoSimulator {
    param([string]$Executable, [string]$Macro, [string]$ProjectRoot,
          [string]$TestName, [string]$Mode, [string]$LogPath, [int]$Seed = 0)
    $doCommand = 'do ' + (ConvertTo-FifoTclWord $Macro) + ' ' +
        (ConvertTo-FifoTclWord $ProjectRoot) + ' ' +
        (ConvertTo-FifoTclWord $TestName) + ' ' + $Mode
    if ($Mode -ne 'compile') {
        $seedArgument = ''
        if ($Seed -gt 0) { $seedArgument = [string]$Seed }
        $doCommand += ' ' + (ConvertTo-FifoTclWord $seedArgument) + ' ' +
            (ConvertTo-FifoTclWord ($LogPath + '.coverage.txt'))
    }
    $simArguments = @('-c', '-l', $LogPath, '-do', $doCommand)
    try {
        & $Executable @simArguments *> ($LogPath + '.console.txt')
        return $LASTEXITCODE
    } catch {
        $_ | Out-String | Add-Content -LiteralPath ($LogPath + '.console.txt')
        return 127
    }
}

function Invoke-FifoRegression {
    param([string[]]$TestNames, [string]$SimulatorName, [int[]]$Seeds = @(1, 42, 2026))
    if ($TestNames.Count -eq 0) { throw 'Specify at least one test.' }
    if ($TestNames -contains 'fifo_random_test' -and $Seeds.Count -eq 0) { throw 'Specify at least one random seed.' }
    $cases = @(
        foreach ($test in $TestNames) {
            if ($test -eq 'fifo_random_test') {
                foreach ($seedValue in ($Seeds | Select-Object -Unique)) {
                    [pscustomobject]@{ Test = $test; Seed = $seedValue }
                }
            } else {
                [pscustomobject]@{ Test = $test; Seed = 0 }
            }
        }
    )
    $projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
    $macroPath = Join-Path $PSScriptRoot 'run_uvm_start.do'
    $simulatorPath = (Get-Command $SimulatorName -ErrorAction Stop).Source
    $runId = [Guid]::NewGuid().ToString('N').Substring(0, 12)
    $outputDirectory = Join-Path $projectRoot ('results\regression\run-' + $runId)
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    $compileLog = Join-Path $outputDirectory 'compile.log'
    $rows = [System.Collections.Generic.List[object]]::new()
    Push-Location -LiteralPath $projectRoot
    try {
        Write-Host 'Compiling UVM and FIFO testbench...'
        $compileExit = Invoke-FifoSimulator $simulatorPath $macroPath $projectRoot '' 'compile' $compileLog
        $compileText = ''
        if (Test-Path -LiteralPath $compileLog) { $compileText = Get-Content -Raw -LiteralPath $compileLog }
        $compileOk = $compileExit -eq 0 -and $compileText -match 'FIFO_COMPILE_OK' -and
            $compileText -notmatch '(?m)^#\s*\*\*\s+(Error|Fatal):' -and
            $compileText -notmatch 'Errors:\s*[1-9]'
        if (-not $compileOk) {
            foreach ($case in $cases) {
                $rows.Add([pscustomobject]@{ Test = $case.Test; Seed = $(if ($case.Seed -gt 0) { $case.Seed } else { $null }); Status = 'NOT_RUN'; ExitCode = $compileExit;
                    Errors = $null; Fatals = $null; Reason = 'Compilation failed'; Log = $compileLog })
            }
            Write-Host "Compilation failed. See $compileLog"
        } else {
            foreach ($case in $cases) {
                $test = $case.Test
                $label = $test
                if ($case.Seed -gt 0) { $label += '_seed_' + $case.Seed }
                Write-Host "Running $label..."
                $logPath = Join-Path $outputDirectory ($label + '.log')
                $toolExit = Invoke-FifoSimulator $simulatorPath $macroPath $projectRoot $test 'run' $logPath $case.Seed
                $verdict = Get-FifoLogVerdict $logPath $test $toolExit $case.Seed
                $rows.Add($verdict)
                Write-Host ("{0}: {1}" -f $label, $verdict.Status)
            }
        }
        $failedCount = @($rows | Where-Object { $_.Status -ne 'PASS' }).Count
        $summary = [pscustomobject]@{
            Status = $(if ($failedCount -eq 0) { 'PASS' } else { 'FAIL' })
            CompileLog = $compileLog
            Passed = $rows.Count - $failedCount
            FailedOrNotRun = $failedCount
            Tests = $rows.ToArray()
        }
        $summaryPath = Join-Path $outputDirectory 'summary.json'
        $summary | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $summaryPath -Encoding UTF8
        $rows | Format-Table Test, Seed, Status, Errors, Fatals, Reason -AutoSize | Out-Host
        Write-Host "Summary: $summaryPath"
        Write-Host ("REGRESSION {0}: {1}/{2} passed" -f $summary.Status, $summary.Passed, $rows.Count)
        if ($failedCount -ne 0) { return 1 }
        return 0
    } finally {
        Pop-Location
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    try {
        $requestedTests = @($Tests | Select-Object -Unique)
        exit (Invoke-FifoRegression $requestedTests $Simulator $RandomSeeds)
    } catch {
        Write-Error $_
        exit 1
    }
}
