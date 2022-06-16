# Contrast Security, Inc licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information.

param (
    [Parameter(Mandatory = $true)]
    [string] $Type,
    [string] $Image
)

$runId = [System.Guid]::NewGuid().ToString()
$workspace = Join-Path ([System.IO.Path]::GetTempPath()) $runId
New-Item -ItemType Directory $workspace | Out-Null

$agentPath = "./src/$Type"

if (-not (Test-Path $agentPath))
{
    throw "Agent path $agentPath does not exist."
}

if ($Image)
{
    docker tag $Image $runId
}
else
{
    docker build --file "$agentPath/Dockerfile" --tag $runId .
}

try
{
    Write-Host "Running image entrypoint."
    docker run `
        -i `
        --rm `
        --env "CONTRAST_MOUNT_PATH=/contrast-tmp" `
        --volume "${workspace}/:/contrast-tmp/" `
        $runId

    if (-not $?)
    {
        throw "Entrypoint failed."
    }

    $actualFiles = Get-ChildItem -Recurse -File $workspace
    $actualFiles | ForEach-Object {
        Write-Host "Found file `"$($_.FullName)`""
    }

    $expectedFiles = (Get-Content -Path "$agentPath/validation.json" | ConvertFrom-Json).Expects | ForEach-Object {
        Join-Path $workspace $_
    }

    Write-Host "Validating expected files."
    $missingFile = $expectedFiles | Where-Object {
        return -not (Test-Path $_)
    }

    $missingFile | ForEach-Object {
        Write-Host "Expected file `"$($_)`", but the file was not found."
    }

    if (@($missingFile).Length -gt 0)
    {
        throw "Expected files failed."
    }
    else
    {
        Write-Host "All expected files exist."
    }
}
finally
{
    Remove-Item -Recurse $workspace -ErrorAction Continue
    docker rmi $runId | Out-Null
}
