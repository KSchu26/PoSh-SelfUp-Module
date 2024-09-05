# PoSh-SelfUp-Module
A Skeleton of a Self-Updating Powershell Module using the Powershell Gallery.</br>

## How To Use
This system is based on assuming the machine in question can connect to and download modules from the Powershell Gallery. </br>
</br>
The module should be contained within a named folder, and the main module file and manifest files should be the same name </br>
Replace the example.ps1 file with any .ps1 files you want to include in your module.</br>
At this time, all functions within any .ps1 files are imported as part of the module.</br>
</br>
You will need to also adjust your manifest file to include the new name of your main module file, and any metadata you want to include</br>
Please follow best practices when adjusting the module manifest file </br>
</br>
Once this module is installed on a machine, each time it is explicitly or implicitly imported, the first step of the module will attempt to update</br>
the module from the powershell gallery, and reload it before continuing the import</br>

## Known Issues
At this time, all functions within any .ps1 files are imported as part of the module.</br>
This is somewhat contrary to the best practice of importing only public functions, or choosing functions manually.</br>
</br>

## Notes
This is a Work-In-Progress, but I am using it successfully in my environment.</br>
As always, please feel free to bring up issues and I will try to address them!