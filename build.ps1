param (
    $f=$false,
    [Switch]$l,
    [Switch]$g
);

if($f){
    $folder = (Get-ChildItem "." -Attributes Directory -Filter $f* -Name)
} else {
    $folder = "."
}

Write-Output "Building files from " $folder;

$startFolder = Get-Location;

if (!$g){
    $files = Get-ChildItem $folder -Recurse -Filter *.md
} else {
    $files = @();
    git ls-files -o -m -- "*.md" | ForEach-Object{
        $files | Get-Item -Include (Get-Item $_);
    };
    Write-Output $files;
}

$files | ForEach-Object {
    Write-Output "Building " $_.FullName;
    # Write-Output $_.BaseName;
    # $_ | Format-List -Property *;
    if ($l){
        $outputfile = $_.DirectoryName +"\"+ $_.BaseName + ".tex";
    } else {
        $outputfile = $_.DirectoryName +"\"+ $_.BaseName + ".pdf";
    }
    if($_.BaseName.Contains(" - ")){
        $author = ($_.BaseName -Split " - ")[0];
        $title = ($_.BaseName -Split " - ")[1];
    } else {
        $title = $_.BaseName;
    }
    # Write-Output $outputfile;
    Set-Location $_.Directory;
    pandoc $_.FullName -o $outputfile --variable=title:$title --variable=author:$author
}

Set-Location $startFolder;