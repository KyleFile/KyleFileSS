# Install-AdobeAcrobat.ps1

# Installs Adobe Acrobat and applies the 24.002.20857 (Optional update, June 15, 2024). 
#Intended to be used with Intune app deployment.

# Copy contents of AcroPro.intunewin file to temp directory on client
New-Item -Force "C:\temp\Adobe" -ItemType "Directory"
Copy-Item -Path "$PSScriptRoot\*" -Destination "C:\temp\Adobe" -Recurse -Force


# Install app from temp directory
msiexec.exe /i "C:\temp\Adobe\AcroPro.msi" TRANSFORMS="C:\temp\Adobe\AcroPro.mst" PATCH=C:\temp\Adobe\AcrobatDCx64Upd2400320054.msp /qn /l*v c:\temp\Adobe_DC_Install.log

Start-Sleep -Seconds 60
# Clean up temp directory
Remove-Item -Path "C:\temp\Adobe" -Recurse -Force -Confirm:$false