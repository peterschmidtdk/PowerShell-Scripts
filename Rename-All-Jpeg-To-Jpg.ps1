#Renames all .jpeg files to .jpg in this folder and all subfolders.
Get-ChildItem *.jpeg -Recurse | Rename-Item -NewName { [System.IO.Path]::ChangeExtension($_.Name, ".jpg") }
