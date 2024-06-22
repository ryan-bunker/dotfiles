#!/usr/bin/env pwsh

$resolutions = @(
	@{ w=3840; h=2160 }
)

foreach ($res in $resolutions)
{
	$res.dir = "$($res.w)x$($res.h)"
	$res.r = [Math]::Round($res.w / $res.h, 2)
	if (-Not (Test-Path -Path $($res.dir)))
	{
		New-Item -Path $($res.dir) -ItemType Directory	
	}
}

Write-Host "Getting image sizes..."
$feh_output = @(feh -l .) | Select-Object -Skip 1
# $feh_output = Get-Content ./feh_cache.txt
$images = $feh_output | ForEach-Object {
	$fields = $_ -split '\s+'
	@{
		w = [int]$fields[2]
		h = [int]$fields[3]
		f = $fields[7]
	}
}

foreach ($image in $images)
{
	$ratio = [Math]::Round($image.w / $image.h, 2)
	$file = Split-Path -Leaf $image.f

	Write-Host "Processing $file - $($image.w)x$($image.h) $ratio ..."

	foreach ($res in $resolutions)
	{
		Write-Host "    Checking $($res.w)x$($res.h) $($res.r) ..."

		if ($ratio -eq $res.r -and $image.w -ge $res.w -and $image.h -ge $res.h)
		{
			# Write-Host ln -fs "../$file" "$($res.dir)/$file"
			New-Item -Path $res.dir -ItemType SymbolicLink -Name $file -Value "../$file" -Force
		}
	}
}
