###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Find-StringInFile.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Find a string in multiple files
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Find a string in one or multiple files
                 
    .DESCRIPTION         
    Find a string in one or multiple files. The search is performed recursively from the start folder.
                                 
    .EXAMPLE
    Find-StringInFile -Path "C:\Scripts\FolderWithFiles" -Search "Test01"
       
	Filename    Path                      LineNumber IsBinary Matches
	--------    ----                      ---------- -------- -------
	File_01.txt E:\Temp\Files\File_01.txt          1    False {Test01}
	File_02.txt E:\Temp\Files\File_02.txt          1    False {TEST01}
	File_03.txt E:\Temp\Files\File_03.txt          1    False {TeST01}

	.EXAMPLE  
	Find-StringInFile -Path "C:\Scripts\FolderWithFiles" -Search "TEST01" -CaseSensitive

	Filename    Path                      LineNumber IsBinary Matches
	--------    ----                      ---------- -------- -------
	File_02.txt E:\Temp\Files\File_02.txt          1    False {TEST01}
	
    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Find-StringInFile.README.md
#>

function Find-StringInFile
{
	[CmdletBinding()]
	param(
	[Parameter(
			Position=0,
			Mandatory=$true, ValueFromPipeline=$true,
			HelpMessage="String to find")]
		[String]$Search,

		[Parameter(
			Position=1,
			HelpMessage="Folder where the files are stored (search is recursive)")]
		[ValidateScript({
			if(Test-Path -Path $_)
			{
				return $true
			}
			else 
			{
				throw "Enter a valid path!"	
			}
		})]
		[String]$Path = (Get-Location),
		
		[Parameter(
			Position=2,
			HelpMessage="String must be case sensitive (Default=false)")]
		[switch]$CaseSensitive
	)

	Begin{
		
	}

	Process{
		# Files with string to find
		$Strings = Get-ChildItem -Path $Path -Recurse | Select-String -Pattern ([regex]::Escape($Search)) -CaseSensitive:$CaseSensitive | Group-Object -Property Path 
		
		# Go through each file
		foreach($String in $Strings)
		{		
			$IsBinary = Test-IsFileBinary -FilePath $String.Name

			# Go through each group
			foreach($Group in $String.Group)
			{	
				[pscustomobject] @{
					Filename = $Group.Filename
					Path = $Group.Path
					LineNumber = $Group.LineNumber
					IsBinary = $IsBinary
					Matches = $Group.Matches.Value
				}
			}   
		}
	}

	End{
		
	}
}
